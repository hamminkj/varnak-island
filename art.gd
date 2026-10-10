extends RefCounted
# Procedural art for Tujuju Island. Everything is built from primitives, so no asset files are needed.

static var _mats: Dictionary = {}

static func mat(color: Color, rough: float = 0.9, emit: float = 0.0) -> StandardMaterial3D:
	var key = str(color) + "|" + str(rough) + "|" + str(emit)
	if _mats.has(key): return _mats[key]
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emit
	_mats[key] = m
	return m

static func add(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, rough: float = 0.9, emit: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat(color, rough, emit)
	mi.position = pos
	mi.rotation_degrees = rot
	parent.add_child(mi)
	return mi

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO, rough: float = 0.9, emit: float = 0.0) -> MeshInstance3D:
	var m = BoxMesh.new()
	m.size = size
	return add(parent, m, pos, color, rot, rough, emit)

static func cyl(parent: Node3D, pos: Vector3, top: float, bottom: float, h: float, color: Color, rot: Vector3 = Vector3.ZERO, seg: int = 12, emit: float = 0.0) -> MeshInstance3D:
	var m = CylinderMesh.new()
	m.top_radius = top
	m.bottom_radius = bottom
	m.height = h
	m.radial_segments = seg
	m.rings = 1
	return add(parent, m, pos, color, rot, 0.9, emit)

static func sph(parent: Node3D, pos: Vector3, r: float, color: Color, sc: Vector3 = Vector3.ONE, seg: int = 14, emit: float = 0.0) -> MeshInstance3D:
	var m = SphereMesh.new()
	m.radius = r
	m.height = r * 2.0
	m.radial_segments = seg
	m.rings = maxi(seg / 2, 3)
	var mi = add(parent, m, pos, color, Vector3.ZERO, 0.9, emit)
	mi.scale = sc
	return mi

static func prism(parent: Node3D, pos: Vector3, size: Vector3, color: Color, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var m = PrismMesh.new()
	m.size = size
	return add(parent, m, pos, color, rot)

static func torus(parent: Node3D, pos: Vector3, inner: float, outer: float, color: Color, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var m = TorusMesh.new()
	m.inner_radius = inner
	m.outer_radius = outer
	m.rings = 14
	m.ring_segments = 8
	return add(parent, m, pos, color, rot)

static func label3(parent: Node3D, text: String, pos: Vector3, size: int = 40) -> Label3D:
	var label = Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = size
	label.pixel_size = 0.008
	label.outline_size = 10
	label.outline_modulate = Color(0.1, 0.08, 0.06, 0.9)
	label.modulate = Color(1.0, 0.97, 0.88)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
	return label

# ---------- shaders ----------

const WATER_SHADER = """
shader_type spatial;
render_mode specular_schlick_ggx;
uniform vec4 deep_color : source_color = vec4(0.07, 0.38, 0.52, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.30, 0.76, 0.80, 1.0);
uniform float alpha = 0.86;
uniform float speed = 0.7;
uniform vec3 hole = vec3(0.0, 0.0, 0.0);
varying vec3 wp;
float hf(vec2 p) {
	float t = TIME * speed;
	return 0.5 + 0.25 * sin(p.x * 1.3 + t) + 0.2 * sin(p.y * 1.9 - t * 1.2) + 0.15 * sin((p.x + p.y) * 3.1 + t * 1.7);
}
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	if (hole.z > 0.0 && distance(wp.xz, hole.xy) < hole.z) discard;
	float e = 0.06;
	float h0 = hf(wp.xz);
	float hx = hf(wp.xz + vec2(e, 0.0));
	float hz = hf(wp.xz + vec2(0.0, e));
	vec3 n = normalize(vec3((h0 - hx) * 1.2, e, (h0 - hz) * 1.2));
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 col = mix(deep_color.rgb, shallow_color.rgb, clamp(0.25 + h0 * 0.6 + fres * 0.4, 0.0, 1.0));
	col += vec3(smoothstep(0.93, 1.1, h0)) * 0.35;
	ALBEDO = col;
	ROUGHNESS = 0.06;
	SPECULAR = 0.85;
	ALPHA = clamp(alpha + fres * 0.12, 0.0, 1.0);
}
"""

const GROUND_SHADER = """
shader_type spatial;
render_mode specular_disabled;
uniform vec4 segs[24];
uniform int seg_count = 0;
varying vec3 wp;
varying vec3 mask;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
float seg_d(vec2 p, vec4 s) {
	vec2 pa = p - s.xy;
	vec2 ba = s.zw - s.xy;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	mask = COLOR.rgb;
}
void fragment() {
	vec2 p = wp.xz;
	float n = vnoise(p * 0.3) * 0.55 + vnoise(p * 1.4) * 0.3 + vnoise(p * 6.0) * 0.15;
	vec3 grass = mix(vec3(0.22, 0.42, 0.18), vec3(0.40, 0.60, 0.24), n);
	grass = mix(grass, vec3(0.52, 0.60, 0.22), smoothstep(0.62, 0.9, vnoise(p * 0.7)) * 0.45);
	grass = mix(grass, vec3(0.30, 0.45, 0.20), smoothstep(1.0, 6.0, wp.y) * 0.5);
	vec3 sand = mix(vec3(0.82, 0.72, 0.50), vec3(0.74, 0.63, 0.42), vnoise(p * 2.2));
	float smask = smoothstep(0.25, 0.75, mask.r + (vnoise(p * 0.9) - 0.5) * 0.5);
	vec3 col = mix(grass, sand, smask);
	vec3 rock = mix(vec3(0.46, 0.46, 0.42), vec3(0.60, 0.58, 0.52), vnoise(p * 1.8));
	col = mix(col, rock, smoothstep(0.3, 0.7, mask.g + (vnoise(p * 1.2) - 0.5) * 0.4));
	float pathd = abs(p.x + (vnoise(vec2(p.y * 0.15, 3.0)) - 0.5) * 0.9);
	if (p.y < -49.0 || p.y > 44.0) pathd = 99.0;
	for (int i = 0; i < 24; i++) {
		if (i >= seg_count) break;
		pathd = min(pathd, seg_d(p, segs[i]) + (vnoise(p * 0.4 + float(i)) - 0.5) * 0.7);
	}
	pathd += (vnoise(p * 1.7) - 0.5) * 0.5;
	float path = 1.0 - smoothstep(1.6, 2.5, pathd);
	vec3 pathc = mix(vec3(0.72, 0.58, 0.36), vec3(0.62, 0.48, 0.30), vnoise(p * 3.5));
	pathc = mix(pathc, vec3(0.50, 0.46, 0.40), step(0.965, hash(floor(p * 16.0))) * 0.55);
	col = mix(col, pathc, path * 0.95 * (1.0 - smask * 0.6));
	float wet = smoothstep(0.02, -0.25, wp.y);
	col = mix(col, vec3(0.52, 0.47, 0.34) * (1.0 - smoothstep(-0.2, -2.0, wp.y) * 0.45), wet);
	ALBEDO = col;
	ROUGHNESS = 1.0;
}
"""

static func water_material(deep: Color = Color(0.07, 0.38, 0.52), shallow: Color = Color(0.30, 0.76, 0.80), alpha: float = 0.86) -> ShaderMaterial:
	var sh = Shader.new()
	sh.code = WATER_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("deep_color", deep)
	m.set_shader_parameter("shallow_color", shallow)
	m.set_shader_parameter("alpha", alpha)
	return m

static func ground_material(paths: Array = []) -> ShaderMaterial:
	var sh = Shader.new()
	sh.code = GROUND_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	var arr = PackedVector4Array()
	for i in range(24):
		arr.append(paths[i] if i < paths.size() else Vector4.ZERO)
	m.set_shader_parameter("segs", arr)
	m.set_shader_parameter("seg_count", mini(paths.size(), 24))
	return m

static func plane(parent: Node3D, pos: Vector3, size: Vector2, material: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var pm = PlaneMesh.new()
	pm.size = size
	mi.mesh = pm
	mi.material_override = material
	mi.position = pos
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi

# ---------- multimesh scatter ----------

static func scatter(parent: Node3D, mesh: Mesh, transforms: Array, colors: Array, shadows: bool = true) -> MultiMeshInstance3D:
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i in range(transforms.size()):
		mm.set_instance_transform(i, transforms[i])
		mm.set_instance_color(i, colors[i])
	var mmi = MultiMeshInstance3D.new()
	mmi.multimesh = mm
	var m = StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.95
	mmi.material_override = m
	if not shadows: mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mmi)
	return mmi

static func cone_mesh(radius: float, height: float, seg: int = 7) -> CylinderMesh:
	var m = CylinderMesh.new()
	m.top_radius = 0.0
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = seg
	m.rings = 1
	return m

static func sphere_mesh(radius: float, seg: int = 10) -> SphereMesh:
	var m = SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = seg
	m.rings = maxi(seg / 2, 3)
	return m

static func cyl_mesh(radius: float, height: float, seg: int = 7) -> CylinderMesh:
	var m = CylinderMesh.new()
	m.top_radius = radius * 0.8
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = seg
	m.rings = 1
	return m

# ---------- people ----------

static func person(shirt: Color, skin: Color, hair: Color, style: int = 0, accent: Color = Color("f2e6c8"), ex: Dictionary = {}) -> Node3D:
	shirt = ex.get("shirt", shirt)
	style = ex.get("style", style)
	var n = Node3D.new()
	var rig = Node3D.new()
	var h: float = ex.get("h", 1.0)
	var w: float = ex.get("w", 1.0)
	rig.scale = Vector3.ONE * h
	n.add_child(rig)
	n.set_meta("h", h)
	var pants: Color = ex.get("pants", shirt.darkened(0.45))
	var shoes: Color = ex.get("shoes", Color("3b2d25"))
	for side in [-1.0, 1.0]:
		box(rig, Vector3(side * 0.11 * w, 0.3, 0), Vector3(0.17 * w, 0.6, 0.2), pants)
		box(rig, Vector3(side * 0.11 * w, 0.04, 0.05), Vector3(0.19 * w, 0.09, 0.32), shoes)
	var body = Node3D.new()
	rig.add_child(body)
	cyl(body, Vector3(0, 0.95, 0), 0.22, 0.28, 0.78, shirt, Vector3.ZERO, 14).scale = Vector3(w, 1, w)
	cyl(body, Vector3(0, 0.62, 0), 0.285, 0.285, 0.07, accent.darkened(0.2), Vector3.ZERO, 14).scale = Vector3(w, 1, w)
	torus(body, Vector3(0, 1.36, 0), 0.07, 0.18, accent, Vector3.ZERO)
	if ex.get("build", "") == "round":
		sph(body, Vector3(0, 0.88, 0.07), 0.3 * w, shirt, Vector3(1, 0.95, 0.95), 14)
	if ex.has("dress"):
		cyl(body, Vector3(0, 0.38, 0), 0.27 * w, 0.4 * w, 0.62, ex["dress"], Vector3.ZERO, 16)
	if ex.has("robe"):
		cyl(body, Vector3(0, 0.55, 0), 0.29 * w, 0.36 * w, 1.0, ex["robe"], Vector3.ZERO, 16)
		cyl(body, Vector3(0, 0.82, 0), 0.3 * w, 0.3 * w, 0.06, ex.get("belt", ex["robe"].darkened(0.4)), Vector3.ZERO, 16)
	if ex.has("overalls"):
		var ov: Color = ex["overalls"]
		box(body, Vector3(0, 1.0, 0.22 * w), Vector3(0.3 * w, 0.32, 0.05), ov)
		for sd in [-1.0, 1.0]: box(body, Vector3(sd * 0.11 * w, 1.2, 0.0), Vector3(0.05, 0.05, 0.5 * w), ov)
		cyl(body, Vector3(0, 0.7, 0), 0.29 * w, 0.29 * w, 0.24, ov, Vector3.ZERO, 14)
	if ex.has("vest"):
		for sd in [-1.0, 1.0]: box(body, Vector3(sd * 0.13 * w, 0.98, 0.18 * w), Vector3(0.13 * w, 0.58, 0.14), ex["vest"], Vector3(0, sd * -18.0, 0))
		box(body, Vector3(0, 0.98, -0.2 * w), Vector3(0.42 * w, 0.58, 0.06), ex["vest"])
	if ex.has("apron"):
		box(body, Vector3(0, 0.84, 0.25 * w + 0.01), Vector3(0.34 * w, 0.52, 0.02), ex["apron"])
		box(body, Vector3(0, 1.16, 0.2 * w + 0.01), Vector3(0.2, 0.16, 0.02), ex["apron"])
	if ex.has("stripe"):
		for k in range(3): cyl(body, Vector3(0, 0.75 + k * 0.17, 0), 0.226 + 0.03 * (2 - k), 0.235 + 0.03 * (2 - k), 0.045, ex["stripe"], Vector3.ZERO, 14).scale = Vector3(w * 1.02, 1, w * 1.02)
	if ex.has("bag"):
		box(body, Vector3(0.3 * w, 0.72, 0.05), Vector3(0.1, 0.28, 0.3), ex["bag"])
		box(body, Vector3(0, 1.0, 0.05), Vector3(0.6 * w, 0.04, 0.05), ex["bag"].darkened(0.2), Vector3(0, 0, -38))
	if ex.has("backpack"):
		box(body, Vector3(0, 0.98, -0.3 * w), Vector3(0.36, 0.44, 0.18), ex["backpack"])
	if ex.has("scarf"):
		torus(body, Vector3(0, 1.33, 0), 0.12, 0.23, ex["scarf"], Vector3.ZERO)
		box(body, Vector3(0.1, 1.12, 0.22 * w), Vector3(0.09, 0.32, 0.03), ex["scarf"])
	var arms = []
	for side in [-1.0, 1.0]:
		var pivot = Node3D.new()
		pivot.position = Vector3(side * 0.3 * w, 1.28, 0)
		body.add_child(pivot)
		cyl(pivot, Vector3(0, -0.28, 0), 0.065, 0.075, 0.58, shirt.lightened(0.05), Vector3.ZERO, 8)
		sph(pivot, Vector3(0, -0.6, 0), 0.075, skin, Vector3.ONE, 8)
		arms.append(pivot)
	var head = Node3D.new()
	head.position = Vector3(0, 1.62, 0)
	body.add_child(head)
	sph(head, Vector3.ZERO, 0.21, skin, Vector3(ex.get("head_w", 1.0), ex.get("head_h", 1.0), 1.0), 14)
	sph(head, Vector3(0, -0.02, 0.2), ex.get("nose", 0.04), skin.darkened(0.08), Vector3.ONE, 6)
	var eye: Color = ex.get("eyes", Color("1a120e"))
	var eyes: String = ex.get("eye_kind", "")
	for sd in [-1.0, 1.0]:
		if eyes == "sleepy":
			sph(head, Vector3(sd * 0.08, 0.02, 0.185), 0.04, eye, Vector3(1.1, 0.45, 0.7), 6)
			box(head, Vector3(sd * 0.08, 0.045, 0.19), Vector3(0.1, 0.03, 0.03), skin.darkened(0.12))
		elif eyes == "big":
			sph(head, Vector3(sd * 0.085, 0.03, 0.18), 0.055, Color("fbf7ef"), Vector3(1, 1.2, 0.6), 8)
			sph(head, Vector3(sd * 0.085, 0.025, 0.205), 0.035, eye, Vector3(1, 1.2, 0.6), 6)
			sph(head, Vector3(sd * 0.075, 0.045, 0.222), 0.011, Color.WHITE, Vector3.ONE, 4)
		else:
			sph(head, Vector3(sd * 0.08, 0.03, 0.185), 0.04, eye, Vector3(1, 1.25, 0.7), 6)
	var lip = skin.darkened(0.4)
	match str(ex.get("mouth", "")):
		"smile":
			box(head, Vector3(-0.035, -0.095, 0.192), Vector3(0.06, 0.016, 0.02), lip, Vector3(0, 0, -22))
			box(head, Vector3(0.035, -0.095, 0.192), Vector3(0.06, 0.016, 0.02), lip, Vector3(0, 0, 22))
		"grin":
			box(head, Vector3(0, -0.095, 0.19), Vector3(0.12, 0.05, 0.03), Color("5a2a22"))
			box(head, Vector3(0, -0.08, 0.2), Vector3(0.1, 0.018, 0.02), Color("fbf7ef"))
		"frown":
			box(head, Vector3(-0.035, -0.105, 0.192), Vector3(0.06, 0.016, 0.02), lip, Vector3(0, 0, 20))
			box(head, Vector3(0.035, -0.105, 0.192), Vector3(0.06, 0.016, 0.02), lip, Vector3(0, 0, -20))
		"o":
			sph(head, Vector3(0, -0.1, 0.19), 0.032, Color("5a2a22"), Vector3(1, 1.2, 0.5), 8)
		_:
			box(head, Vector3(0, -0.1, 0.19), Vector3(0.09, 0.015, 0.02), lip)
	if ex.has("brows"):
		var bc: Color = ex.get("brow_color", hair if style != 7 else ex.get("beard", hair))
		var bt = 0.03 if ex.get("thick", false) else 0.018
		var tilt = {"angry": 18.0, "worried": -16.0, "raised": 0.0, "flat": 0.0}.get(ex["brows"], 0.0)
		var by = 0.115 if ex["brows"] == "raised" else 0.095
		for sd in [-1.0, 1.0]: box(head, Vector3(sd * 0.085, by, 0.19), Vector3(0.085, bt, 0.025), bc, Vector3(0, 0, sd * tilt))
	if ex.get("freckles", false):
		for k in range(6): sph(head, Vector3((-1 if k < 3 else 1) * (0.07 + (k % 3) * 0.025), -0.03 + (k % 2) * 0.02, 0.19), 0.009, skin.darkened(0.3), Vector3.ONE, 4)
	if ex.get("cheeks", false):
		for side in [-1.0, 1.0]: sph(head, Vector3(side * 0.12, -0.05, 0.16), 0.045, Color("f08a8a"), Vector3(1, 0.7, 0.4), 6)
	match style:
		0:
			sph(head, Vector3(0, 0.07, -0.02), 0.225, hair, Vector3(1, 0.7, 1.02), 12)
		1:
			sph(head, Vector3(0, 0.07, -0.02), 0.225, hair, Vector3(1, 0.7, 1.02), 12)
			box(head, Vector3(0, -0.22, -0.16), Vector3(0.38, 0.56, 0.12), hair)
		2:
			sph(head, Vector3(0, 0.07, -0.02), 0.225, hair, Vector3(1, 0.7, 1.02), 12)
			sph(head, Vector3(0, 0.27, -0.05), 0.11, hair, Vector3.ONE, 8)
		3:
			cyl(head, Vector3(0, 0.17, 0), 0.34, 0.34, 0.03, accent.darkened(0.15), Vector3.ZERO, 14)
			cyl(head, Vector3(0, 0.27, 0), 0.16, 0.2, 0.2, accent.darkened(0.15), Vector3.ZERO, 14)
			sph(head, Vector3(0, 0.05, -0.02), 0.215, hair, Vector3(1, 0.6, 1.0), 10)
		4:
			sph(head, Vector3(0, 0.0, -0.06), 0.215, hair, Vector3(1, 1, 0.85), 10)
		5:
			# spiky
			sph(head, Vector3(0, 0.07, -0.02), 0.22, hair, Vector3(1, 0.65, 1.0), 10)
			for k in range(5): cyl(head, Vector3(-0.14 + k * 0.07, 0.24, -0.02 + (k % 2) * 0.04), 0.0, 0.05, 0.16, hair, Vector3(0, 0, (k - 2) * 12.0), 6)
		6:
			# pigtails
			sph(head, Vector3(0, 0.07, -0.02), 0.225, hair, Vector3(1, 0.7, 1.02), 12)
			for side in [-1.0, 1.0]: sph(head, Vector3(side * 0.25, -0.02, -0.06), 0.09, hair, Vector3(0.8, 1.3, 0.8), 8)
		7:
			# bald with a fringe
			box(head, Vector3(0, -0.02, -0.17), Vector3(0.36, 0.14, 0.08), hair)
		8:
			# big curly afro
			for k in range(9):
				var a = k * TAU / 9.0
				sph(head, Vector3(cos(a) * 0.17, 0.12 + sin(k * 1.7) * 0.06, sin(a) * 0.15 - 0.04), 0.14, hair, Vector3.ONE, 8)
			sph(head, Vector3(0, 0.22, -0.03), 0.2, hair, Vector3(1.1, 0.8, 1.0), 10)
		9:
			# long braid down the back
			sph(head, Vector3(0, 0.07, -0.02), 0.225, hair, Vector3(1, 0.7, 1.02), 12)
			for k in range(5): sph(head, Vector3(0, -0.12 - k * 0.1, -0.2 - k * 0.012), 0.055 - k * 0.004, hair, Vector3.ONE, 6)
			sph(head, Vector3(0, -0.62, -0.25), 0.04, accent, Vector3.ONE, 6)
		10:
			# mohawk
			box(head, Vector3(0, 0.25, -0.02), Vector3(0.06, 0.16, 0.36), hair)
			sph(head, Vector3(0, 0.0, -0.06), 0.212, hair.darkened(0.3), Vector3(1, 0.9, 0.85), 10)
	var hat: String = ex.get("hat", "")
	var hc: Color = ex.get("hat_color", accent.darkened(0.2))
	match hat:
		"cap":
			sph(head, Vector3(0, 0.09, -0.01), 0.225, hc, Vector3(1, 0.62, 1.02), 12)
			box(head, Vector3(0, 0.08, 0.2), Vector3(0.26, 0.025, 0.18), hc.darkened(0.2))
		"captain":
			cyl(head, Vector3(0, 0.2, 0), 0.25, 0.22, 0.14, Color("f4f1e8"), Vector3.ZERO, 14)
			cyl(head, Vector3(0, 0.13, 0), 0.23, 0.23, 0.05, Color("1d2a44"), Vector3.ZERO, 14)
			box(head, Vector3(0, 0.11, 0.21), Vector3(0.26, 0.025, 0.14), Color("1d2a44"))
			sph(head, Vector3(0, 0.2, 0.24), 0.03, Color("e9c46a"), Vector3.ONE, 6, 0.4)
		"beanie":
			sph(head, Vector3(0, 0.1, -0.01), 0.235, hc, Vector3(1, 0.72, 1.02), 12)
			sph(head, Vector3(0, 0.29, -0.01), 0.06, hc.lightened(0.3), Vector3.ONE, 6)
		"nightcap":
			cyl(head, Vector3(0, 0.25, -0.06), 0.02, 0.23, 0.42, hc, Vector3(-35, 0, 0), 10)
			sph(head, Vector3(0, 0.36, -0.3), 0.06, Color("f4f1e8"), Vector3.ONE, 6)
		"straw":
			cyl(head, Vector3(0, 0.15, 0), 0.42, 0.42, 0.025, Color("e2c46b"), Vector3.ZERO, 16)
			cyl(head, Vector3(0, 0.23, 0), 0.17, 0.21, 0.16, Color("e2c46b"), Vector3.ZERO, 14)
			cyl(head, Vector3(0, 0.18, 0), 0.215, 0.215, 0.04, hc, Vector3.ZERO, 14)
		"band":
			torus(head, Vector3(0, 0.1, 0), 0.2, 0.235, hc, Vector3.ZERO)
		"toque":
			cyl(head, Vector3(0, 0.22, 0), 0.2, 0.2, 0.14, Color("fbf7ef"), Vector3.ZERO, 14)
			sph(head, Vector3(0, 0.4, 0), 0.24, Color("fbf7ef"), Vector3(1, 0.75, 1), 12)
		"cowboy":
			cyl(head, Vector3(0, 0.16, 0), 0.4, 0.4, 0.025, hc, Vector3(8, 0, 0), 16)
			cyl(head, Vector3(0, 0.27, 0), 0.15, 0.2, 0.2, hc, Vector3.ZERO, 14)
			box(head, Vector3(0, 0.37, 0), Vector3(0.06, 0.04, 0.26), hc.darkened(0.2))
			cyl(head, Vector3(0, 0.2, 0), 0.205, 0.205, 0.04, Color("2b1d14"), Vector3.ZERO, 14)
		"flower":
			for k in range(5): sph(head, Vector3(0.17 + cos(k * 1.26) * 0.05, 0.14 + sin(k * 1.26) * 0.05, 0.08), 0.035, hc, Vector3.ONE, 6)
			sph(head, Vector3(0.17, 0.14, 0.09), 0.025, Color("ffd34d"), Vector3.ONE, 6)
	match str(ex.get("face", "")):
		"glasses", "sunglasses":
			var dark = ex["face"] == "sunglasses"
			for side in [-1.0, 1.0]:
				if dark: sph(head, Vector3(side * 0.08, 0.03, 0.2), 0.06, Color("15151a"), Vector3(1, 0.8, 0.3), 8)
				else: torus(head, Vector3(side * 0.08, 0.03, 0.2), 0.042, 0.058, ex.get("frame", Color("2b1d14")), Vector3(90, 0, 0))
			box(head, Vector3(0, 0.04, 0.21), Vector3(0.06, 0.015, 0.015), Color("15151a") if dark else ex.get("frame", Color("2b1d14")))
	if ex.has("beard"):
		sph(head, Vector3(0, -0.13, 0.08), 0.17, ex["beard"], Vector3(1, 0.9, 0.75), 10)
	if ex.has("mustache"):
		box(head, Vector3(-0.05, -0.065, 0.205), Vector3(0.1, 0.035, 0.04), ex["mustache"], Vector3(0, 0, 12))
		box(head, Vector3(0.05, -0.065, 0.205), Vector3(0.1, 0.035, 0.04), ex["mustache"], Vector3(0, 0, -12))
	if ex.get("earrings", false):
		for side in [-1.0, 1.0]: sph(head, Vector3(side * 0.21, -0.08, 0.0), 0.03, Color("ffd34d"), Vector3.ONE, 6, 0.3)
	if ex.has("prop"): add_prop(arms[1] if ex["prop"] != "cane" else arms[0], body, str(ex["prop"]), ex)
	var small: Array = [head]
	small.append_array(arms)
	for part in small:
		for c in part.get_children():
			if c is GeometryInstance3D: c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.set_meta("body", body)
	n.set_meta("head", head)
	n.set_meta("arms", arms)
	return n

static func add_prop(arm: Node3D, body: Node3D, kind: String, ex: Dictionary):
	var p = Node3D.new()
	p.position = Vector3(0, -0.62, 0.06)
	arm.add_child(p)
	var wood = Color("7a5232")
	match kind:
		"hammer":
			cyl(p, Vector3(0, 0.0, 0.12), 0.025, 0.025, 0.42, wood, Vector3(90, 0, 0), 6)
			box(p, Vector3(0, 0.0, 0.33), Vector3(0.09, 0.22, 0.09), Color("5d6670"))
		"ladle":
			cyl(p, Vector3(0, 0.1, 0.08), 0.015, 0.015, 0.4, Color("c9ccd1"), Vector3(30, 0, 0), 6)
			sph(p, Vector3(0, -0.07, 0.0), 0.08, Color("c9ccd1"), Vector3(1, 0.6, 1), 8)
		"fish":
			sph(p, Vector3(0, -0.12, 0.05), 0.09, Color("8fc9d6"), Vector3(0.55, 1.7, 0.8), 8)
			prism(p, Vector3(0, -0.32, 0.05), Vector3(0.03, 0.12, 0.14), Color("e9946a"))
		"book":
			box(p, Vector3(0, -0.02, 0.1), Vector3(0.05, 0.26, 0.2), Color("7a1f3d"))
			box(p, Vector3(0.012, -0.02, 0.1), Vector3(0.04, 0.24, 0.18), Color("f4f1e8"))
		"lantern":
			cyl(p, Vector3(0, -0.12, 0.05), 0.07, 0.07, 0.16, Color("ffd27a"), Vector3.ZERO, 8, 2.5)
			cyl(p, Vector3(0, -0.02, 0.05), 0.08, 0.06, 0.04, Color("2b2b2b"), Vector3.ZERO, 8)
			cyl(p, Vector3(0, -0.22, 0.05), 0.08, 0.08, 0.03, Color("2b2b2b"), Vector3.ZERO, 8)
		"drum":
			p.queue_free()
			var d = cyl(body, Vector3(0, 0.82, 0.32), 0.2, 0.2, 0.22, Color("e76f51"), Vector3(90, 0, 0), 14)
			d.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			cyl(body, Vector3(0, 0.82, 0.44), 0.19, 0.19, 0.01, Color("f4f1e8"), Vector3(90, 0, 0), 14)
			box(body, Vector3(0, 1.08, 0.12), Vector3(0.04, 0.04, 0.5), Color("2b1d14"), Vector3(-35, 0, 0))
		"cane":
			cyl(p, Vector3(0, -0.4, 0.06), 0.02, 0.02, 0.8, wood, Vector3.ZERO, 6)
			torus(p, Vector3(0, 0.02, 0.0), 0.015, 0.06, wood, Vector3(0, 90, 0))
		"telescope":
			cyl(p, Vector3(0, 0.0, 0.18), 0.035, 0.05, 0.42, Color("c9a46d"), Vector3(90, 0, 0), 8)
			cyl(p, Vector3(0, 0.0, 0.4), 0.055, 0.055, 0.04, Color("6d4a33"), Vector3(90, 0, 0), 8)
		"oar":
			cyl(p, Vector3(0, 0.1, 0.0), 0.022, 0.022, 1.2, wood, Vector3.ZERO, 6)
			box(p, Vector3(0, -0.55, 0.0), Vector3(0.03, 0.3, 0.15), wood.lightened(0.15))
		"clipboard":
			box(p, Vector3(0, -0.05, 0.1), Vector3(0.03, 0.28, 0.21), Color("b0814f"))
			box(p, Vector3(0.018, -0.07, 0.1), Vector3(0.01, 0.22, 0.17), Color("fbf7ef"))
			box(p, Vector3(0.02, 0.08, 0.1), Vector3(0.02, 0.03, 0.08), Color("c9ccd1"))
		"pillow":
			box(p, Vector3(0, -0.05, 0.12), Vector3(0.14, 0.24, 0.32), Color("f4f1e8"))
		"cup":
			cyl(p, Vector3(0, -0.04, 0.06), 0.05, 0.04, 0.1, ex.get("cup_color", Color("fbf7ef")), Vector3.ZERO, 8)
			torus(p, Vector3(0.06, -0.04, 0.06), 0.008, 0.03, ex.get("cup_color", Color("fbf7ef")), Vector3(90, 0, 0))
		"carrot":
			cyl(p, Vector3(0, -0.1, 0.08), 0.035, 0.0, 0.22, Color("f28c28"), Vector3(160, 0, 0), 6)
			sph(p, Vector3(0, 0.03, 0.06), 0.035, Color("4f8b3c"), Vector3(1, 1.4, 1), 5)
		"letter":
			box(p, Vector3(0, -0.04, 0.08), Vector3(0.02, 0.15, 0.22), Color("fbf7ef"))
			box(p, Vector3(0.012, -0.0, 0.08), Vector3(0.01, 0.05, 0.05), Color("c0392b"))
		"basket":
			cyl(p, Vector3(0, -0.15, 0.05), 0.15, 0.11, 0.16, Color("c9a46d"), Vector3.ZERO, 10)
			torus(p, Vector3(0, -0.02, 0.05), 0.012, 0.14, Color("a8834f"), Vector3(0, 0, 90))
			for k in range(4): sph(p, Vector3(-0.07 + k * 0.05, -0.06, 0.05 + (k % 2) * 0.04), 0.045, Color("9bd06a"), Vector3(1.3, 0.6, 1), 6)
		"map":
			cyl(p, Vector3(0, -0.04, 0.08), 0.035, 0.035, 0.3, Color("e9dcb4"), Vector3(0, 0, 90), 8)
		"pencil":
			cyl(p, Vector3(0, -0.04, 0.08), 0.015, 0.015, 0.22, Color("f2c14e"), Vector3(70, 0, 0), 6)
		"fruit":
			sph(p, Vector3(0, -0.08, 0.06), 0.07, Color("e63946"), Vector3.ONE, 8)
		"mug":
			cyl(p, Vector3(0, -0.04, 0.06), 0.055, 0.055, 0.12, Color("a78bda"), Vector3.ZERO, 8)
	for c in p.get_children():
		if c is GeometryInstance3D: c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

# ---------- items ----------

static func item_model(id: String, color: Color) -> Node3D:
	var n = Node3D.new()
	match id:
		"own_bag", "forest_bag":
			box(n, Vector3(0, 0.22, 0), Vector3(0.5, 0.38, 0.22), color)
			box(n, Vector3(0, 0.4, 0.02), Vector3(0.52, 0.12, 0.26), color.darkened(0.2))
			box(n, Vector3(0, 0.22, 0.12), Vector3(0.1, 0.36, 0.02), Color("3b2d25"))
			torus(n, Vector3(0, 0.46, 0), 0.015, 0.14, Color("3b2d25"), Vector3(90, 0, 0))
		"water":
			cyl(n, Vector3(0, 0.22, 0), 0.15, 0.2, 0.44, color.darkened(0.15), Vector3.ZERO, 12)
			cyl(n, Vector3(0, 0.45, 0), 0.14, 0.14, 0.02, color.lightened(0.4), Vector3.ZERO, 12)
			torus(n, Vector3(0.21, 0.24, 0), 0.02, 0.09, color.darkened(0.3), Vector3(0, 0, 90))
		"fruit":
			sph(n, Vector3(-0.1, 0.12, 0), 0.12, color, Vector3.ONE, 10)
			sph(n, Vector3(0.1, 0.12, 0.04), 0.11, color.lightened(0.15), Vector3.ONE, 10)
			sph(n, Vector3(0, 0.12, -0.12), 0.11, color.darkened(0.1), Vector3.ONE, 10)
			sph(n, Vector3(0, 0.3, 0), 0.1, color.lightened(0.1), Vector3.ONE, 10)
			box(n, Vector3(0, 0.42, 0), Vector3(0.12, 0.02, 0.05), Color("4f8b3c"), Vector3(0, 30, 20))
		"container":
			cyl(n, Vector3(0, 0.14, 0), 0.26, 0.15, 0.28, color, Vector3.ZERO, 14)
			cyl(n, Vector3(0, 0.275, 0), 0.22, 0.22, 0.02, color.darkened(0.45), Vector3.ZERO, 14)
		"wood":
			cyl(n, Vector3(0, 0.12, 0), 0.11, 0.11, 0.75, color, Vector3(0, 0, 90), 10)
			cyl(n, Vector3(0, 0.12, 0.2), 0.1, 0.1, 0.7, color.darkened(0.12), Vector3(0, 12, 90), 10)
			cyl(n, Vector3(0.02, 0.3, 0.1), 0.1, 0.1, 0.65, color.lightened(0.08), Vector3(0, -8, 90), 10)
		"stone":
			sph(n, Vector3(0, 0.15, 0), 0.22, color, Vector3(1.2, 0.8, 1), 9)
			sph(n, Vector3(0.25, 0.1, 0.1), 0.14, color.lightened(0.1), Vector3(1, 0.8, 1), 8)
			sph(n, Vector3(-0.2, 0.08, 0.15), 0.1, color.darkened(0.1), Vector3(1, 0.8, 1), 8)
		"rope":
			torus(n, Vector3(0, 0.07, 0), 0.05, 0.26, color, Vector3.ZERO)
			torus(n, Vector3(0, 0.15, 0), 0.05, 0.22, color.darkened(0.08), Vector3.ZERO)
			torus(n, Vector3(0, 0.23, 0), 0.05, 0.18, color.lightened(0.05), Vector3.ZERO)
		"herb":
			for i in range(5):
				var a = i * TAU / 5.0
				cyl(n, Vector3(cos(a) * 0.08, 0.2, sin(a) * 0.08), 0.012, 0.018, 0.4, Color("4f8b3c"), Vector3(cos(a) * 18.0, 0, sin(a) * 18.0), 5)
				sph(n, Vector3(cos(a) * 0.16, 0.38, sin(a) * 0.16), 0.09, color.lerp(Color("9bd06a"), float(i) / 5.0), Vector3(1.4, 0.5, 1.0), 7)
			box(n, Vector3(0, 0.14, 0), Vector3(0.16, 0.04, 0.16), Color("c9a46d"))
		"torch":
			cyl(n, Vector3(0, 0.3, 0), 0.04, 0.05, 0.6, Color("6d4a33"), Vector3.ZERO, 7)
			cyl(n, Vector3(0, 0.62, 0), 0.08, 0.06, 0.1, Color("3b2d25"), Vector3.ZERO, 8)
			cyl(n, Vector3(0, 0.78, 0), 0.0, 0.09, 0.26, Color("ff8a2a"), Vector3.ZERO, 7, 2.2)
			sph(n, Vector3(0, 0.72, 0), 0.07, Color("ffd27a"), Vector3.ONE, 6, 2.5)
		_:
			sph(n, Vector3(0, 0.3, 0), 0.24, color, Vector3.ONE, 10)
	return n

# ---------- animals ----------

static func animal(kind: String) -> Node3D:
	var n = Node3D.new()
	match kind:
		"par":
			var body = Node3D.new()
			n.add_child(body)
			sph(body, Vector3(0, 0.3, 0), 0.17, Color("e9c46a"), Vector3(1, 0.9, 1.3), 10)
			sph(body, Vector3(0, 0.45, 0.17), 0.1, Color("e9c46a"), Vector3.ONE, 8)
			box(body, Vector3(0, 0.44, 0.29), Vector3(0.04, 0.04, 0.1), Color("e76f51"))
			sph(body, Vector3(-0.04, 0.48, 0.24), 0.018, Color("201814"), Vector3.ONE, 4)
			sph(body, Vector3(0.04, 0.48, 0.24), 0.018, Color("201814"), Vector3.ONE, 4)
			box(body, Vector3(0, 0.3, -0.28), Vector3(0.12, 0.03, 0.22), Color("2a9d8f"), Vector3(-15, 0, 0))
			var wl = Node3D.new()
			wl.position = Vector3(-0.14, 0.34, 0)
			body.add_child(wl)
			box(wl, Vector3(-0.15, 0, 0), Vector3(0.3, 0.03, 0.2), Color("2a9d8f"))
			var wr = Node3D.new()
			wr.position = Vector3(0.14, 0.34, 0)
			body.add_child(wr)
			box(wr, Vector3(0.15, 0, 0), Vector3(0.3, 0.03, 0.2), Color("2a9d8f"))
			n.set_meta("wings", [wl, wr])
		"tujuju":
			# jabiru stork (tujuju): all-white body and wings, bare black head and swollen
			# neck with a red collar at the base, huge black bill tilted slightly up, black legs
			var white = Color("f4f2ec")
			var black = Color("17171a")
			var legs = Node3D.new()
			legs.position = Vector3(0, 0.8, 0)
			n.add_child(legs)
			for lx in [-0.08, 0.08]:
				box(legs, Vector3(lx, -0.4, 0), Vector3(0.05, 0.8, 0.05), black)
				box(legs, Vector3(lx, -0.79, 0.06), Vector3(0.08, 0.02, 0.15), black)
			sph(n, Vector3(0, 1.0, -0.03), 0.25, white, Vector3(1.0, 0.95, 1.7), 10)
			box(n, Vector3(0, 0.98, -0.42), Vector3(0.22, 0.07, 0.18), white, Vector3(-12, 0, 0))
			for side in [-1.0, 1.0]:
				sph(n, Vector3(0.13 * side, 1.03, -0.1), 0.2, Color("e9e5da"), Vector3(0.45, 0.6, 1.75), 8)
			var neck = Node3D.new()
			neck.position = Vector3(0, 1.1, 0.3)
			n.add_child(neck)
			sph(neck, Vector3(0, 0.04, 0.0), 0.12, Color("c8282c"), Vector3(1.05, 0.55, 1.05), 10)
			sph(neck, Vector3(0, 0.22, 0.01), 0.11, black, Vector3(0.95, 1.9, 1.0), 10)
			sph(neck, Vector3(0, 0.47, 0.03), 0.085, black, Vector3(1, 1, 1.15), 8)
			box(neck, Vector3(0, 0.44, 0.2), Vector3(0.075, 0.085, 0.24), black, Vector3(6, 0, 0))
			box(neck, Vector3(0, 0.455, 0.39), Vector3(0.045, 0.05, 0.2), Color("25252a"), Vector3(-4, 0, 0))
			sph(neck, Vector3(-0.07, 0.5, 0.08), 0.014, Color("cfc9b8"), Vector3.ONE, 4)
			sph(neck, Vector3(0.07, 0.5, 0.08), 0.014, Color("cfc9b8"), Vector3.ONE, 4)
			var ws: Array = []
			for side in [-1.0, 1.0]:
				var w = Node3D.new()
				w.position = Vector3(0.21 * side, 1.06, 0.02)
				n.add_child(w)
				box(w, Vector3(0.5 * side, 0, 0.0), Vector3(1.0, 0.035, 0.46), white)
				box(w, Vector3(0.96 * side, 0, -0.02), Vector3(0.12, 0.03, 0.4), Color("e6e2d8"))
				ws.append(w)
			n.set_meta("wings", ws)
			n.set_meta("neck", neck)
			n.set_meta("legs", legs)
		"tari":
			var body = Node3D.new()
			n.add_child(body)
			sph(body, Vector3(0, 0.25, 0), 0.2, Color("8fc9d6"), Vector3(0.55, 0.8, 1.6), 10)
			prism(body, Vector3(0, 0.25, -0.42), Vector3(0.05, 0.3, 0.25), Color("e9946a"), Vector3(0, 0, 0))
			sph(body, Vector3(-0.07, 0.3, 0.2), 0.025, Color("201814"), Vector3.ONE, 4)
			sph(body, Vector3(0.07, 0.3, 0.2), 0.025, Color("201814"), Vector3.ONE, 4)
			box(body, Vector3(0, 0.42, 0), Vector3(0.02, 0.1, 0.3), Color("e9946a"))
		"gor":
			var fur = Color("c08a54")
			box(n, Vector3(0, 0.42, 0), Vector3(0.34, 0.3, 0.7), fur)
			box(n, Vector3(0, 0.62, 0.42), Vector3(0.26, 0.26, 0.28), fur.lightened(0.05))
			box(n, Vector3(0, 0.56, 0.62), Vector3(0.13, 0.1, 0.14), fur.lightened(0.25))
			sph(n, Vector3(0, 0.6, 0.7), 0.035, Color("201814"), Vector3.ONE, 6)
			box(n, Vector3(-0.15, 0.73, 0.4), Vector3(0.07, 0.17, 0.1), fur.darkened(0.3))
			box(n, Vector3(0.15, 0.73, 0.4), Vector3(0.07, 0.17, 0.1), fur.darkened(0.3))
			for lx in [-0.12, 0.12]:
				for lz in [-0.24, 0.24]:
					box(n, Vector3(lx, 0.15, lz), Vector3(0.09, 0.3, 0.09), fur.darkened(0.15))
			var tail = Node3D.new()
			tail.position = Vector3(0, 0.55, -0.35)
			n.add_child(tail)
			box(tail, Vector3(0, 0.12, -0.05), Vector3(0.06, 0.3, 0.06), fur.lightened(0.1), Vector3(25, 0, 0))
			n.set_meta("tail", tail)
		"mar":
			var coat = Color("8b5a3c")
			box(n, Vector3(0, 1.0, 0), Vector3(0.6, 0.7, 1.5), coat)
			box(n, Vector3(0, 1.45, 0.85), Vector3(0.28, 0.75, 0.35), coat, Vector3(-25, 0, 0))
			box(n, Vector3(0, 1.75, 1.15), Vector3(0.3, 0.32, 0.55), coat.lightened(0.05))
			box(n, Vector3(0, 1.5, 0.7), Vector3(0.1, 0.5, 0.1), Color("2d1f16"), Vector3(-25, 0, 0))
			box(n, Vector3(-0.1, 2.0, 1.0), Vector3(0.07, 0.17, 0.07), coat.darkened(0.3))
			box(n, Vector3(0.1, 2.0, 1.0), Vector3(0.07, 0.17, 0.07), coat.darkened(0.3))
			for lx in [-0.2, 0.2]:
				for lz in [-0.55, 0.55]:
					box(n, Vector3(lx, 0.33, lz), Vector3(0.14, 0.66, 0.14), coat.darkened(0.2))
			var tail = Node3D.new()
			tail.position = Vector3(0, 1.2, -0.75)
			n.add_child(tail)
			box(tail, Vector3(0, -0.3, -0.05), Vector3(0.1, 0.7, 0.1), Color("2d1f16"), Vector3(10, 0, 0))
			n.set_meta("tail", tail)
	return n

# ---------- buildings ----------

static func house(parent: Node3D, pos: Vector3, wall: Color, roof: Color, trim: Color) -> Node3D:
	var h = Node3D.new()
	h.position = Vector3(pos.x, 0, pos.z)
	parent.add_child(h)
	box(h, Vector3(0, 0.15, 0), Vector3(5.4, 0.3, 5.4), Color("9a9185"))
	box(h, Vector3(0, 1.65, 0), Vector3(5.0, 3.0, 5.0), wall)
	box(h, Vector3(2.52, 1.65, 0), Vector3(0.08, 3.0, 5.1), trim)
	box(h, Vector3(-2.52, 1.65, 0), Vector3(0.08, 3.0, 5.1), trim)
	prism(h, Vector3(0, 3.8, 0), Vector3(5.9, 1.9, 6.3), roof, Vector3(0, 90, 0))
	prism(h, Vector3(0, 3.65, 0), Vector3(5.0, 1.65, 6.35), wall.lightened(0.05), Vector3(0, 90, 0))
	box(h, Vector3(0, 2.72, 2.6), Vector3(5.5, 0.12, 0.3), trim)
	box(h, Vector3(1.6, 4.5, -1.2), Vector3(0.7, 1.8, 0.7), Color("8a8279"))
	box(h, Vector3(1.6, 5.45, -1.2), Vector3(0.85, 0.12, 0.85), Color("6f6860"))
	box(h, Vector3(0, 1.35, 2.52), Vector3(1.6, 2.1, 0.08), trim.darkened(0.25))
	box(h, Vector3(0, 0.12, 3.0), Vector3(1.9, 0.24, 1.0), Color("a89f93"))
	var pivot = Node3D.new()
	pivot.position = Vector3(-0.6, 0.3, 2.6)
	h.add_child(pivot)
	box(pivot, Vector3(0.6, 1.0, 0), Vector3(1.2, 2.0, 0.1), Color("6d4a33"))
	sph(pivot, Vector3(1.0, 1.0, 0.08), 0.06, Color("e0c068"), Vector3.ONE, 6)
	for wx in [-1.7, 1.7]:
		box(h, Vector3(wx, 1.9, 2.52), Vector3(1.0, 1.0, 0.08), trim)
		box(h, Vector3(wx, 1.9, 2.55), Vector3(0.8, 0.8, 0.06), Color("f6dc8c"), Vector3.ZERO, 0.4, 0.8)
		box(h, Vector3(wx, 1.9, 2.58), Vector3(0.05, 0.8, 0.04), trim)
		box(h, Vector3(wx, 1.9, 2.58), Vector3(0.8, 0.05, 0.04), trim)
		box(h, Vector3(wx, 1.3, 2.7), Vector3(1.1, 0.22, 0.3), Color("6d4a33"))
		sph(h, Vector3(wx - 0.3, 1.5, 2.7), 0.1, Color("e76f51"), Vector3.ONE, 6)
		sph(h, Vector3(wx, 1.52, 2.7), 0.1, Color("f4a261"), Vector3.ONE, 6)
		sph(h, Vector3(wx + 0.3, 1.5, 2.7), 0.1, Color("e9c46a"), Vector3.ONE, 6)
	for sz in [-1.2, 1.2]:
		box(h, Vector3(2.55, 1.9, sz), Vector3(0.06, 0.9, 0.8), Color("f6dc8c"), Vector3.ZERO, 0.4, 0.8)
	cyl(h, Vector3(1.25, 2.3, 2.75), 0.03, 0.03, 0.4, Color("3b2d25"), Vector3.ZERO, 6)
	sph(h, Vector3(1.25, 2.05, 2.75), 0.1, Color("ffd27a"), Vector3.ONE, 8, 1.6)
	for c in h.get_children():
		if c is MeshInstance3D:
			var sz = (c as MeshInstance3D).mesh.get_aabb().size * (c as MeshInstance3D).scale
			if sz.x * sz.y * sz.z < 1.6: (c as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	h.set_meta("door", pivot)
	return h

static func set_door(house_node: Node3D, open: bool) -> void:
	var pivot = house_node.get_meta("door") as Node3D
	pivot.rotation_degrees.y = -105.0 if open else 0.0

static func boat(parent: Node3D, pos: Vector3) -> Node3D:
	var b = Node3D.new()
	b.position = pos
	parent.add_child(b)
	var wood = Color("8a5a3a")
	box(b, Vector3(0, 0.2, 0), Vector3(2.0, 0.6, 4.2), wood)
	box(b, Vector3(0, 0.2, 2.5), Vector3(1.6, 0.55, 1.2), wood.darkened(0.08), Vector3(0, 0, 0))
	prism(b, Vector3(0, 0.2, 3.4), Vector3(1.6, 0.55, 1.0), wood.darkened(0.05), Vector3(0, 90, 0))
	box(b, Vector3(0, 0.2, -2.4), Vector3(1.8, 0.55, 0.7), wood.darkened(0.1))
	box(b, Vector3(0, 0.52, 0), Vector3(1.7, 0.06, 4.0), Color("c9a46d"))
	box(b, Vector3(-0.95, 0.62, 0), Vector3(0.1, 0.25, 4.3), wood.lightened(0.1))
	box(b, Vector3(0.95, 0.62, 0), Vector3(0.1, 0.25, 4.3), wood.lightened(0.1))
	box(b, Vector3(0, 0.62, 2.1), Vector3(1.8, 0.25, 0.1), wood.lightened(0.1))
	cyl(b, Vector3(0, 2.0, 0.6), 0.07, 0.09, 3.0, Color("5b3d28"), Vector3.ZERO, 8)
	box(b, Vector3(0, 2.2, 0.62), Vector3(0.04, 1.8, 1.9), Color("f2e8d0"), Vector3(0, 0, 0))
	box(b, Vector3(0, 3.2, 0.6), Vector3(0.2, 0.18, 0.02), Color("c0392b"))
	box(b, Vector3(-0.5, 0.85, -0.8), Vector3(0.06, 0.06, 1.8), Color("6d4a33"), Vector3(0, 20, 12))
	return b

static func bridge(parent: Node3D, pos: Vector3) -> Dictionary:
	var br = Node3D.new()
	br.position = pos
	parent.add_child(br)
	var planks = []
	for i in range(14):
		var z = -3.25 + i * 0.5
		var p = box(br, Vector3(0, 0.04, z), Vector3(3.0, 0.1, 0.42), Color("a77b4f").lerp(Color("8f6a43"), float(i % 3) / 3.0))
		planks.append(p)
	var rails = []
	for sx in [-1.5, 1.5]:
		box(br, Vector3(sx, -0.1, 0), Vector3(0.18, 0.3, 7.0), Color("6d4a33"))
		for i in range(5):
			cyl(br, Vector3(sx, 0.5, -3.0 + i * 1.5), 0.06, 0.07, 1.0, Color("6d4a33"), Vector3.ZERO, 6)
		rails.append(box(br, Vector3(sx, 0.95, 0), Vector3(0.1, 0.1, 6.2), Color("7d5a3c")))
	br.set_meta("planks", planks)
	br.set_meta("rails", rails)
	return {"node": br, "planks": planks, "rails": rails}

static func set_bridge(info: Dictionary, repaired: bool) -> void:
	var planks: Array = info["planks"]
	for i in range(planks.size()):
		var p = planks[i] as MeshInstance3D
		p.visible = true
		p.rotation_degrees = Vector3.ZERO
		p.position.y = 0.04
		if not repaired:
			if i in [4, 5, 9]: p.visible = false
			elif i in [3, 8]:
				p.rotation_degrees = Vector3(14, 0, 6)
				p.position.y = -0.08
	var rails: Array = info["rails"]
	for r in rails:
		(r as MeshInstance3D).rotation_degrees = Vector3.ZERO if repaired else Vector3(0, 0, 0)
		(r as MeshInstance3D).scale = Vector3(1, 1, 1.0 if repaired else 0.55)
		(r as MeshInstance3D).position.z = 0.0 if repaired else 1.4

static func table(parent: Node3D, pos: Vector3) -> Node3D:
	var t = Node3D.new()
	t.position = pos
	parent.add_child(t)
	var wood = Color("b0814f")
	box(t, Vector3(0, 0.8, 0), Vector3(1.8, 0.1, 1.0), wood)
	for lx in [-0.8, 0.8]:
		for lz in [-0.4, 0.4]:
			box(t, Vector3(lx, 0.4, lz), Vector3(0.1, 0.8, 0.1), wood.darkened(0.2))
	for cz in [-1.0, 1.0]:
		box(t, Vector3(0, 0.45, cz), Vector3(0.7, 0.08, 0.6), wood.darkened(0.1))
		box(t, Vector3(0, 0.75, cz + (0.28 if cz > 0 else -0.28)), Vector3(0.7, 0.55, 0.06), wood.darkened(0.1))
		for lx in [-0.28, 0.28]:
			box(t, Vector3(lx, 0.22, cz), Vector3(0.07, 0.44, 0.07), wood.darkened(0.25))
	box(t, Vector3(-0.5, 0.9, 0.1), Vector3(0.45, 0.08, 0.34), Color("2a6f97"))
	box(t, Vector3(-0.5, 0.96, 0.1), Vector3(0.42, 0.05, 0.31), Color("f2e8d0"))
	var feast = Node3D.new()
	t.add_child(feast)
	cyl(feast, Vector3(0.1, 0.92, 0), 0.22, 0.14, 0.14, Color("d5c5a4"), Vector3.ZERO, 12)
	sph(feast, Vector3(0.1, 1.0, 0), 0.12, Color("dc8060"), Vector3.ONE, 8)
	cyl(feast, Vector3(0.6, 1.0, 0.1), 0.1, 0.13, 0.3, Color("52bddd"), Vector3.ZERO, 10)
	feast.visible = false
	t.set_meta("feast", feast)
	return t

static func tent(parent: Node3D, pos: Vector3) -> Node3D:
	var t = Node3D.new()
	t.position = pos
	parent.add_child(t)
	prism(t, Vector3(0, 1.1, 0), Vector3(3.2, 2.2, 3.6), Color("d9a05b"), Vector3(0, 90, 0))
	box(t, Vector3(0, 0.9, 1.81), Vector3(0.9, 1.5, 0.05), Color("5a3c26"))
	for i in range(3):
		cyl(t, Vector3(5.0 + i * 0.12, 0.12 + i * 0.1, 0.0), 0.06, 0.08, 0.5, Color("6d4a33"), Vector3(0, 0, 80 - i * 20), 6)
	var fire = Node3D.new()
	fire.position = Vector3(3.0, 0, 1.8)
	t.add_child(fire)
	for a in range(6):
		var ang = a * TAU / 6.0
		sph(fire, Vector3(cos(ang) * 0.45, 0.1, sin(ang) * 0.45), 0.12, Color("7d7a76"), Vector3(1, 0.7, 1), 6)
	cyl(fire, Vector3(0, 0.15, 0), 0.04, 0.08, 0.4, Color("5a3c26"), Vector3(0, 0, 30), 6)
	cyl(fire, Vector3(0, 0.15, 0), 0.04, 0.08, 0.4, Color("5a3c26"), Vector3(0, 90, -30), 6)
	var flame = cyl(fire, Vector3(0, 0.45, 0), 0.0, 0.22, 0.6, Color("ff8a2a"), Vector3.ZERO, 7, 2.0)
	t.set_meta("flame", flame)
	return t

static func lamp(parent: Node3D, pos: Vector3) -> void:
	cyl(parent, pos + Vector3(0, 1.1, 0), 0.05, 0.07, 2.2, Color("3b2d25"), Vector3.ZERO, 6)
	box(parent, pos + Vector3(0, 2.3, 0), Vector3(0.3, 0.34, 0.3), Color("ffd27a"), Vector3.ZERO, 0.4, 1.6)
	prism(parent, pos + Vector3(0, 2.6, 0), Vector3(0.42, 0.22, 0.42), Color("3b2d25"))

static func fence(parent: Node3D, a: Vector3, b: Vector3) -> void:
	var d = b - a
	var length = d.length()
	var count = int(length / 2.4) + 1
	var dir = d.normalized()
	var angle = atan2(dir.x, dir.z)
	for i in range(count + 1):
		var p = a + dir * (length * float(i) / float(count))
		box(parent, p + Vector3(0, 0.5, 0), Vector3(0.12, 1.0, 0.12), Color("8a6a46")).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var mid = (a + b) * 0.5
	for ry in [0.4, 0.8]:
		var r = box(parent, mid + Vector3(0, ry, 0), Vector3(0.07, 0.09, length), Color("a07c54"))
		r.rotation.y = angle
		r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func crate(parent: Node3D, pos: Vector3, s: float, color: Color, rot: float = 0.0) -> void:
	var c = box(parent, pos + Vector3(0, s * 0.5, 0), Vector3(s, s, s), color)
	c.rotation_degrees.y = rot
	var d = box(parent, pos + Vector3(0, s * 0.5, 0), Vector3(s * 1.04, s * 0.12, s * 1.04), color.darkened(0.25))
	d.rotation_degrees.y = rot

static func barrel(parent: Node3D, pos: Vector3, color: Color) -> void:
	cyl(parent, pos + Vector3(0, 0.45, 0), 0.38, 0.38, 0.9, color, Vector3.ZERO, 12)
	cyl(parent, pos + Vector3(0, 0.25, 0), 0.4, 0.4, 0.07, Color("3b2d25"), Vector3.ZERO, 12)
	cyl(parent, pos + Vector3(0, 0.65, 0), 0.4, 0.4, 0.07, Color("3b2d25"), Vector3.ZERO, 12)

static var signs: Array = []

static func signpost(parent: Node3D, pos: Vector3, text: String, face_yaw: float = 0.0) -> void:
	var s = Node3D.new()
	s.set_meta("text", text)
	signs.append(s)
	s.position = pos
	s.rotation_degrees.y = face_yaw
	parent.add_child(s)
	cyl(s, Vector3(0, 0.8, 0), 0.07, 0.09, 1.6, Color("6d4a33"), Vector3.ZERO, 6)
	box(s, Vector3(0, 1.55, 0.07), Vector3(1.15, 0.6, 0.08), Color("b8935f"))
	box(s, Vector3(0, 1.55, 0.05), Vector3(1.25, 0.7, 0.05), Color("6d4a33"))
	# The name is painted flat on the board, sized so the longest line fits.
	var lines = text.split("\n")
	var longest = 1
	for l in lines: longest = maxi(longest, l.length())
	var fs = mini(30, int(1.0 / (longest * 0.55 * 0.006)))
	fs = mini(fs, int(0.5 / (lines.size() * 1.15 * 0.006)))
	for back in [false, true]:
		var lb = Label3D.new()
		lb.text = text
		lb.font_size = fs
		lb.pixel_size = 0.006
		lb.outline_size = 8
		lb.outline_modulate = Color(0.16, 0.1, 0.05, 0.9)
		lb.modulate = Color("fff3d6")
		lb.double_sided = false
		lb.position = Vector3(0, 1.55, 0.116 if not back else 0.02)
		if back: lb.rotation_degrees.y = 180
		lb.visibility_range_end = 30.0
		s.add_child(lb)

# ---------- expansion: markers ----------

const BEAM_SHADER = """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, shadows_disabled, depth_draw_never;
uniform vec4 color : source_color = vec4(1.0, 0.82, 0.38, 1.0);
uniform float strength = 0.5;
varying float yy;
void vertex() { yy = VERTEX.y; }
void fragment() {
	float a = 1.0 - smoothstep(-1.9, 1.9, yy);
	ALBEDO = color.rgb;
	ALPHA = a * strength * (0.8 + 0.2 * sin(TIME * 3.0));
}
"""

# A soft column of light so loose items can be spotted from a distance.
static func beacon(parent: Node3D) -> Node3D:
	var b = Node3D.new()
	parent.add_child(b)
	var sh = Shader.new()
	sh.code = BEAM_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	var mi = MeshInstance3D.new()
	var cm = CylinderMesh.new()
	cm.top_radius = 0.03
	cm.bottom_radius = 0.1
	cm.height = 2.2
	cm.radial_segments = 10
	cm.rings = 1
	cm.cap_top = false
	cm.cap_bottom = false
	mi.mesh = cm
	mi.material_override = m
	mi.position.y = 1.1
	m.set_shader_parameter("strength", 0.2)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.add_child(mi)
	var ring = MeshInstance3D.new()
	var rm = CylinderMesh.new()
	rm.top_radius = 0.55
	rm.bottom_radius = 0.55
	rm.height = 0.01
	rm.radial_segments = 20
	rm.rings = 1
	ring.mesh = rm
	var rmat = StandardMaterial3D.new()
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.albedo_color = Color(1.0, 0.86, 0.45, 0.18)
	ring.material_override = rmat
	ring.position.y = 0.03
	ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	b.add_child(ring)
	return b

static func quest_mark(parent: Node3D, y: float) -> Label3D:
	var l = Label3D.new()
	l.text = "!"
	l.font_size = 120
	l.pixel_size = 0.009
	l.outline_size = 22
	l.outline_modulate = Color(0.25, 0.12, 0.02, 0.95)
	l.modulate = Color(1.0, 0.84, 0.25)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.position = Vector3(0, y, 0)
	l.visibility_range_end = 80.0
	parent.add_child(l)
	return l

# ---------- expansion: places ----------

static func stall(parent: Node3D, pos: Vector3, yaw: float, awning: Color, goods: String) -> Node3D:
	var s = Node3D.new()
	s.position = pos
	s.rotation_degrees.y = yaw
	parent.add_child(s)
	var wood = Color("8a6a46")
	box(s, Vector3(0, 0.5, 0), Vector3(2.6, 1.0, 1.0), Color("a77b4f"))
	box(s, Vector3(0, 1.03, 0), Vector3(2.8, 0.06, 1.15), Color("c9a46d"))
	for sx in [-1.3, 1.3]:
		cyl(s, Vector3(sx, 1.3, 0.55), 0.05, 0.06, 2.6, wood, Vector3.ZERO, 6)
		cyl(s, Vector3(sx, 1.45, -0.55), 0.05, 0.06, 2.9, wood, Vector3.ZERO, 6)
	for i in range(6):
		var c = awning if i % 2 == 0 else Color("f4ead0")
		var st = box(s, Vector3(-1.2 + i * 0.48, 2.72, 0.05), Vector3(0.48, 0.05, 1.8), c, Vector3(-12, 0, 0))
		st.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	match goods:
		"fruit":
			for i in range(9):
				sph(s, Vector3(-1.0 + (i % 5) * 0.22 + (0.1 if i >= 5 else 0.0), 1.15 + (0.15 if i >= 5 else 0.0), -0.1 + (i % 2) * 0.15), 0.1, [Color("dc8060"), Color("e9c46a"), Color("c0392b")][i % 3], Vector3.ONE, 7)
			cyl(s, Vector3(0.7, 1.18, 0), 0.3, 0.22, 0.2, Color("b58a52"), Vector3.ZERO, 10)
		"fish":
			for i in range(4):
				sph(s, Vector3(-0.9 + i * 0.5, 1.12, 0.1), 0.09, Color("9fb8c4"), Vector3(1, 0.7, 2.6), 7)
		"bread":
			for i in range(5):
				sph(s, Vector3(-1.0 + i * 0.45, 1.13, 0.05), 0.12, Color("c98a45"), Vector3(1.5, 0.75, 1), 8)
		"pots":
			for i in range(4):
				cyl(s, Vector3(-0.9 + i * 0.6, 1.25, 0), 0.12, 0.18, 0.4, [Color("b5654a"), Color("d3b08a"), Color("6b7f9c"), Color("8f5a48")][i], Vector3.ZERO, 10)
		"cloth":
			for i in range(4):
				box(s, Vector3(-0.9 + i * 0.6, 1.12, 0), Vector3(0.5, 0.12, 0.7), [Color("e76f51"), Color("2a9d8f"), Color("e9c46a"), Color("a78bda")][i])
	return s

static func well(parent: Node3D, pos: Vector3) -> Node3D:
	var w = Node3D.new()
	w.position = pos
	parent.add_child(w)
	cyl(w, Vector3(0, 0.4, 0), 0.85, 0.9, 0.8, Color("9a9185"), Vector3.ZERO, 14)
	cyl(w, Vector3(0, 0.79, 0), 0.7, 0.7, 0.04, Color("2f7f96"), Vector3.ZERO, 14)
	for sx in [-0.8, 0.8]:
		box(w, Vector3(sx, 1.3, 0), Vector3(0.12, 1.8, 0.12), Color("6d4a33"))
	prism(w, Vector3(0, 2.35, 0), Vector3(1.4, 0.6, 2.1), Color("8f5a48"), Vector3(0, 90, 0))
	cyl(w, Vector3(0, 1.9, 0), 0.06, 0.06, 1.5, Color("5b3d28"), Vector3(0, 0, 90), 6)
	cyl(w, Vector3(0.2, 1.3, 0), 0.14, 0.12, 0.25, Color("a77b4f"), Vector3.ZERO, 8)
	return w

static func school(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var s = Node3D.new()
	s.position = pos
	s.rotation_degrees.y = yaw
	parent.add_child(s)
	var wall = Color("e8d9b5")
	box(s, Vector3(0, 0.15, 0), Vector3(9.4, 0.3, 5.6), Color("9a9185"))
	box(s, Vector3(0, 1.75, 0), Vector3(9.0, 3.2, 5.0), wall)
	prism(s, Vector3(0, 4.15, 0), Vector3(6.0, 1.9, 9.8), Color("4f7ca8"), Vector3(0, 90, 0))
	prism(s, Vector3(0, 3.95, 0), Vector3(5.0, 1.6, 9.0), wall.lightened(0.05), Vector3(0, 90, 0))
	box(s, Vector3(0, 1.4, 2.52), Vector3(1.4, 2.2, 0.08), Color("6d4a33"))
	for wx in [-3.0, -1.6, 1.6, 3.0]:
		box(s, Vector3(wx, 2.0, 2.52), Vector3(0.9, 1.0, 0.08), Color("f4ead0"))
		box(s, Vector3(wx, 2.0, 2.55), Vector3(0.72, 0.82, 0.06), Color("f6dc8c"), Vector3.ZERO, 0.4, 0.6)
	# chalkboard outside the door
	var board = Node3D.new()
	board.position = Vector3(3.2, 0, 4.2)
	board.rotation_degrees.y = -20
	s.add_child(board)
	for sx in [-0.8, 0.8]:
		cyl(board, Vector3(sx, 0.8, 0), 0.04, 0.05, 1.6, Color("6d4a33"), Vector3.ZERO, 6)
	box(board, Vector3(0, 1.2, 0.03), Vector3(1.7, 1.0, 0.06), Color("2f4a3a"))
	box(board, Vector3(0, 1.2, 0.0), Vector3(1.85, 1.15, 0.04), Color("8a6a46"))
	label3(board, "han?  hal?\nhama?  hamur?", Vector3(0, 1.22, 0.08), 26).billboard = BaseMaterial3D.BILLBOARD_DISABLED
	# bell
	cyl(s, Vector3(-4.0, 1.4, 3.6), 0.05, 0.06, 2.8, Color("6d4a33"), Vector3.ZERO, 6)
	box(s, Vector3(-4.0, 2.8, 3.6), Vector3(0.7, 0.08, 0.1), Color("6d4a33"))
	cyl(s, Vector3(-4.0, 2.55, 3.6), 0.06, 0.16, 0.3, Color("d4a537"), Vector3.ZERO, 10)
	for i in range(2):
		box(s, Vector3(-1.5 + i * 3.0, 0.45, 4.6), Vector3(1.6, 0.1, 0.45), Color("a77b4f"))
		for lx in [-0.65, 0.65]:
			box(s, Vector3(-1.5 + i * 3.0 + lx, 0.22, 4.6), Vector3(0.08, 0.44, 0.35), Color("8a6a46"))
	return s

static func hut(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var h = Node3D.new()
	h.position = pos
	h.rotation_degrees.y = yaw
	parent.add_child(h)
	cyl(h, Vector3(0, 1.3, 0), 2.4, 2.5, 2.6, Color("d9c29a"), Vector3.ZERO, 18)
	cyl(h, Vector3(0, 3.6, 0), 0.0, 3.2, 2.2, Color("b8964e"), Vector3.ZERO, 18)
	cyl(h, Vector3(0, 2.62, 0), 3.15, 3.2, 0.12, Color("9c7a3c"), Vector3.ZERO, 18)
	box(h, Vector3(0, 1.0, 2.42), Vector3(1.0, 2.0, 0.12), Color("5a3c26"))
	for i in range(3):
		var a = deg_to_rad(-40.0 + i * 40.0)
		var p = Vector3(sin(a) * 2.5, 2.2, cos(a) * 2.5)
		cyl(h, p + Vector3(0.6 if i == 0 else (-0.6 if i == 2 else 0.9), 0, 0), 0.08, 0.04, 0.4, Color("6a9a4a"), Vector3.ZERO, 6)
	sph(h, Vector3(-1.3, 2.0, 2.15), 0.13, Color("ffd27a"), Vector3.ONE, 8, 1.4)
	return h

static func bed(parent: Node3D, pos: Vector3, yaw: float) -> Node3D:
	var b = Node3D.new()
	b.position = pos
	b.rotation_degrees.y = yaw
	parent.add_child(b)
	box(b, Vector3(0, 0.25, 0), Vector3(1.0, 0.3, 2.0), Color("8a6a46"))
	box(b, Vector3(0, 0.45, 0), Vector3(0.92, 0.12, 1.9), Color("f2e8d0"))
	box(b, Vector3(0, 0.53, 0.25), Vector3(0.94, 0.08, 1.2), Color("2a9d8f"))
	box(b, Vector3(0, 0.56, -0.7), Vector3(0.6, 0.12, 0.35), Color("f4ead0"))
	box(b, Vector3(0, 0.55, -1.0), Vector3(1.0, 0.7, 0.08), Color("6d4a33"))
	return b

static func lighthouse(parent: Node3D, pos: Vector3) -> Node3D:
	var l = Node3D.new()
	l.position = pos
	parent.add_child(l)
	cyl(l, Vector3(0, 0.5, 0), 2.6, 2.8, 1.0, Color("9a9185"), Vector3.ZERO, 18)
	cyl(l, Vector3(0, 6.5, 0), 1.35, 2.0, 11.0, Color("f4f1e8"), Vector3.ZERO, 18)
	for y in [3.0, 7.0, 10.6]:
		var r = lerpf(1.95, 1.4, (y - 1.0) / 11.0)
		cyl(l, Vector3(0, y, 0), r + 0.02, r + 0.05, 1.0, Color("c0392b"), Vector3.ZERO, 18)
	box(l, Vector3(0, 1.9, 1.85), Vector3(0.9, 1.8, 0.3), Color("5a3c26"))
	cyl(l, Vector3(0, 12.1, 0), 1.9, 1.9, 0.2, Color("3b2d25"), Vector3.ZERO, 18)
	for i in range(12):
		var a = i * TAU / 12.0
		cyl(l, Vector3(cos(a) * 1.8, 12.5, sin(a) * 1.8), 0.03, 0.03, 0.7, Color("3b2d25"), Vector3.ZERO, 5)
	torus(l, Vector3(0, 12.85, 0), 0.03, 1.8, Color("3b2d25"))
	var lamp_mat = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color("6f7f86")
	lamp_mat.roughness = 0.2
	var lamp = MeshInstance3D.new()
	var lm = CylinderMesh.new()
	lm.top_radius = 1.0
	lm.bottom_radius = 1.0
	lm.height = 1.5
	lm.radial_segments = 14
	lamp.mesh = lm
	lamp.material_override = lamp_mat
	lamp.position = Vector3(0, 12.95, 0)
	l.add_child(lamp)
	cyl(l, Vector3(0, 14.2, 0), 0.0, 1.35, 1.1, Color("c0392b"), Vector3.ZERO, 14)
	sph(l, Vector3(0, 14.8, 0), 0.15, Color("3b2d25"), Vector3.ONE, 6)
	var beam = Node3D.new()
	beam.position = Vector3(0, 12.95, 0)
	l.add_child(beam)
	var sh = Shader.new()
	sh.code = BEAM_SHADER.replace("smoothstep(-1.9, 1.9, yy)", "smoothstep(-14.0, 14.0, -yy)").replace("0.5 *", "0.45 *")
	var bm = ShaderMaterial.new()
	bm.shader = sh
	bm.set_shader_parameter("color", Color(1.0, 0.9, 0.55))
	for side in [-1.0, 1.0]:
		var cone = MeshInstance3D.new()
		var c = CylinderMesh.new()
		c.top_radius = 0.4
		c.bottom_radius = 3.5
		c.height = 28.0
		c.radial_segments = 10
		c.rings = 1
		c.cap_top = false
		c.cap_bottom = false
		cone.mesh = c
		cone.material_override = bm
		cone.rotation_degrees = Vector3(0, 0, 90.0 * side)
		cone.position = Vector3(side * 14.0, 0, 0)
		cone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		beam.add_child(cone)
	beam.visible = false
	l.set_meta("lamp", lamp_mat)
	l.set_meta("beam", beam)
	return l

static func set_lighthouse(l: Node3D, lit: bool) -> void:
	var m = l.get_meta("lamp") as StandardMaterial3D
	m.albedo_color = Color("ffe9a8") if lit else Color("6f7f86")
	m.emission_enabled = lit
	m.emission = Color("ffd27a")
	m.emission_energy_multiplier = 2.4
	(l.get_meta("beam") as Node3D).visible = lit

static func lookout(parent: Node3D, pos: Vector3) -> Node3D:
	var p = Node3D.new()
	p.position = pos
	parent.add_child(p)
	box(p, Vector3(0, 0.06, 0), Vector3(4.2, 0.12, 4.2), Color("a77b4f"))
	for sx in [-2.0, 2.0]:
		for sz in [-2.0, 2.0]:
			cyl(p, Vector3(sx, 0.55, sz), 0.06, 0.07, 1.0, Color("6d4a33"), Vector3.ZERO, 6)
	box(p, Vector3(0, 1.0, -2.0), Vector3(4.0, 0.08, 0.08), Color("7d5a3c"))
	box(p, Vector3(-2.0, 1.0, 0), Vector3(0.08, 0.08, 4.0), Color("7d5a3c"))
	box(p, Vector3(2.0, 1.0, 0), Vector3(0.08, 0.08, 4.0), Color("7d5a3c"))
	cyl(p, Vector3(-1.6, 2.4, -1.6), 0.05, 0.06, 4.8, Color("6d4a33"), Vector3.ZERO, 6)
	var flag = box(p, Vector3(-1.05, 4.4, -1.6), Vector3(1.0, 0.6, 0.03), Color("e76f51"))
	p.set_meta("flag", flag)
	# telescope on a tripod
	for i in range(3):
		var a = i * TAU / 3.0
		cyl(p, Vector3(1.0 + cos(a) * 0.2, 0.6, -0.8 + sin(a) * 0.2), 0.02, 0.02, 1.1, Color("3b2d25"), Vector3(sin(a) * 12.0, 0, -cos(a) * 12.0), 4)
	cyl(p, Vector3(1.0, 1.2, -0.8), 0.06, 0.09, 0.8, Color("d4a537"), Vector3(70, 30, 0), 8)
	return p

static func stepping_stones(parent: Node3D, a: Vector3, b: Vector3, n: int) -> Array:
	var out: Array = []
	for i in range(n):
		var p = a.lerp(b, float(i) / float(n - 1))
		cyl(parent, Vector3(p.x, -0.1, p.z), 0.92, 1.0, 0.42, Color("8d9394").lerp(Color("b4aea0"), float(i % 3) / 3.0), Vector3.ZERO, 10)
		out.append(p)
	return out

static func log_bridge(parent: Node3D, a: Vector3, b: Vector3) -> void:
	var d = b - a
	var length = Vector2(d.x, d.z).length()
	var yaw = atan2(d.x, d.z)
	var mid = (a + b) * 0.5
	for off in [-0.84, -0.42, 0.0, 0.42, 0.84]:
		var side = Vector3(cos(yaw), 0, -sin(yaw)) * off
		var lg = cyl(parent, mid + side + Vector3(0, -0.12, 0), 0.22, 0.24, length, Color("7d5a3c").lerp(Color("9c7a52"), absf(off)), Vector3(90, rad_to_deg(yaw), 0), 9)
		lg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if absf(off) < 0.5 else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for off in [-1.2, 1.2]:
		var side = Vector3(cos(yaw), 0, -sin(yaw)) * off
		for t in [0.0, 0.5, 1.0]:
			cyl(parent, a.lerp(b, t) + side + Vector3(0, 0.45, 0), 0.05, 0.06, 1.0, Color("6d4a33"), Vector3.ZERO, 6)
		var rope = cyl(parent, mid + side + Vector3(0, 0.85, 0), 0.025, 0.025, length, Color("dfc990"), Vector3(90, rad_to_deg(yaw), 0), 5)
		rope.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func drum(parent: Node3D, pos: Vector3) -> void:
	cyl(parent, pos + Vector3(0, 0.35, 0), 0.32, 0.26, 0.7, Color("8f5a48"), Vector3.ZERO, 12)
	cyl(parent, pos + Vector3(0, 0.71, 0), 0.33, 0.33, 0.03, Color("f2e6c8"), Vector3.ZERO, 12)
	for i in range(6):
		var a = i * TAU / 6.0
		cyl(parent, pos + Vector3(cos(a) * 0.3, 0.38, sin(a) * 0.3), 0.012, 0.012, 0.66, Color("e9c46a"), Vector3(sin(a) * 6.0, 0, cos(a) * 6.0), 4)

static func umbrella(parent: Node3D, pos: Vector3, color: Color) -> void:
	cyl(parent, pos + Vector3(0, 1.2, 0), 0.04, 0.04, 2.4, Color("f4ead0"), Vector3.ZERO, 6)
	cyl(parent, pos + Vector3(0, 2.4, 0), 0.0, 1.5, 0.5, color, Vector3.ZERO, 10)
	box(parent, pos + Vector3(0.8, 0.12, 0.6), Vector3(0.9, 0.04, 1.8), Color("f2e6c8"), Vector3(0, 25, 0))

# ---------- third expansion: surprises and new places ----------

static func unshaded(color: Color, alpha: bool = false) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = color
	m.disable_fog = true
	if alpha: m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

static func ruins(parent: Node3D, pos: Vector3) -> Array:
	var r = Node3D.new()
	r.position = pos
	parent.add_child(r)
	var stone = Color("b8ad98")
	box(r, Vector3(0, 0.03, 0), Vector3(11, 0.06, 11), Color("a59a86"))
	var cols: Array = []
	var heights = [3.4, 1.2, 3.4, 2.1, 3.4, 0.7, 3.4, 2.6]
	for i in range(8):
		var a = i * TAU / 8.0
		var p = Vector3(cos(a) * 4.3, 0, sin(a) * 4.3)
		var h: float = heights[i]
		cyl(r, p + Vector3(0, 0.15, 0), 0.55, 0.6, 0.3, stone.darkened(0.1), Vector3.ZERO, 10)
		cyl(r, p + Vector3(0, 0.3 + h * 0.5, 0), 0.36, 0.4, h, stone.lerp(Color("cfc4ae"), float(i % 3) / 3.0), Vector3.ZERO, 10)
		if h > 3.0: box(r, p + Vector3(0, 0.3 + h + 0.12, 0), Vector3(0.95, 0.24, 0.95), stone)
		cols.append(pos + p)
	box(r, Vector3(cos(0.0) * 4.3, 3.95, sin(TAU / 8.0) * 2.15), Vector3(0.7, 0.35, 3.6), stone, Vector3(0, -22.5, 0))
	cyl(r, Vector3(-2.0, 0.42, 6.6), 0.38, 0.38, 3.2, stone.darkened(0.05), Vector3(0, 30, 90), 10)
	# a great stone face, half buried
	sph(r, Vector3(1.2, 0.7, -1.4), 1.0, Color("a39a88"), Vector3(1, 1.2, 0.9), 12)
	box(r, Vector3(1.2, 0.95, -0.55), Vector3(0.9, 0.12, 0.1), Color("6f675a"))
	sph(r, Vector3(0.85, 1.15, -0.55), 0.1, Color("4a443c"), Vector3.ONE, 6)
	sph(r, Vector3(1.55, 1.15, -0.55), 0.1, Color("4a443c"), Vector3.ONE, 6)
	box(r, Vector3(1.2, 0.55, -0.52), Vector3(0.5, 0.08, 0.08), Color("6f675a"))
	return cols

const FALLS_SHADER = """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
void fragment() {
	float x = UV.x;
	float s = fract(UV.y * 2.5 - TIME * 1.4 + sin(x * 37.0) * 0.21 + sin(x * 11.0) * 0.4);
	float streak = smoothstep(0.55, 1.0, s) * (0.6 + 0.4 * sin(x * 63.0 + TIME));
	vec3 col = mix(vec3(0.42, 0.74, 0.86), vec3(0.95, 0.98, 1.0), streak);
	col = mix(col, vec3(1.0), smoothstep(0.85, 1.0, UV.y) * 0.6);
	ALBEDO = col;
	ALPHA = 0.82 - 0.25 * smoothstep(0.0, 0.5, abs(x - 0.5) * 2.0 - 0.5);
}
"""

static func waterfall(parent: Node3D, pos: Vector3, width: float, height: float) -> Node3D:
	var w = Node3D.new()
	w.position = pos
	parent.add_child(w)
	var sh = Shader.new()
	sh.code = FALLS_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	var mi = MeshInstance3D.new()
	var qm = QuadMesh.new()
	qm.size = Vector2(width, height)
	mi.mesh = qm
	mi.material_override = m
	mi.position = Vector3(0, height * 0.5, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	w.add_child(mi)
	var foam = sph(w, Vector3(0, 0.0, 0.4), 1.0, Color(1, 1, 1), Vector3(1.4, 0.25, 0.9), 10)
	foam.material_override = unshaded(Color(1, 1, 1, 0.75), true)
	w.set_meta("foam", foam)
	return w

static func cave_mouth(parent: Node3D, pos: Vector3) -> void:
	var c = sph(parent, pos, 1.0, Color("120f0c"), Vector3(1.3, 1.25, 0.5), 12)
	c.material_override = unshaded(Color("100c0a"))
	for i in range(5):
		var a = -0.9 + i * 0.45
		var g = sph(parent, pos + Vector3(sin(a) * 0.8, 0.3 + cos(a * 2.0) * 0.4, 0.1), 0.12, Color("7fe0ff"), Vector3(0.6, 1.4, 0.6), 6)
		g.material_override = unshaded(Color("8fe9ff"))

static func palm(parent: Node3D, pos: Vector3, lean: float) -> void:
	var t = Node3D.new()
	t.position = pos
	t.rotation_degrees = Vector3(0, lean * 57.0, 0)
	parent.add_child(t)
	for i in range(6):
		var y = 0.4 + i * 0.7
		cyl(t, Vector3(i * i * 0.025, y, 0), 0.16, 0.2, 0.75, Color("8a6a46").lerp(Color("a07c54"), float(i % 2)), Vector3(0, 0, -4.0 - i * 1.5), 8)
	var top = Vector3(0.9, 4.4, 0)
	for k in range(7):
		var a = k * TAU / 7.0
		var leaf = box(t, top + Vector3(cos(a) * 0.9, -0.25, sin(a) * 0.9), Vector3(1.9, 0.05, 0.5), Color("3d8a48").lerp(Color("6aa84f"), float(k % 3) / 3.0))
		leaf.rotation = Vector3(0, -a, -0.45)
	for k in range(3):
		sph(t, top + Vector3(cos(k * 2.1) * 0.25, -0.35, sin(k * 2.1) * 0.25), 0.16, Color("6b4f36"), Vector3.ONE, 7)

static func sea_star(color: Color) -> Node3D:
	var n = Node3D.new()
	for i in range(5):
		var a = i * TAU / 5.0
		var arm = box(n, Vector3(cos(a) * 0.12, 0.05, sin(a) * 0.12), Vector3(0.24, 0.05, 0.09), color)
		arm.rotation.y = -a
	sph(n, Vector3(0, 0.06, 0), 0.08, color.lightened(0.15), Vector3(1, 0.5, 1), 7)
	return n

static func chest(parent: Node3D, pos: Vector3) -> Node3D:
	var c = Node3D.new()
	c.position = pos
	parent.add_child(c)
	box(c, Vector3(0, 0.25, 0), Vector3(0.9, 0.5, 0.6), Color("7d5a3c"))
	box(c, Vector3(0, 0.25, 0), Vector3(0.94, 0.08, 0.64), Color("d4a537"))
	var lid = Node3D.new()
	lid.position = Vector3(0, 0.5, -0.3)
	c.add_child(lid)
	box(lid, Vector3(0, 0.1, 0.3), Vector3(0.92, 0.2, 0.62), Color("8f6a43"))
	for i in range(7):
		sph(c, Vector3(-0.3 + i * 0.1, 0.48, (i % 2) * 0.1 - 0.05), 0.07, Color("ffd34d"), Vector3(1, 0.3, 1), 8, 0.6)
	c.set_meta("lid", lid)
	return c

static func mound(parent: Node3D, pos: Vector3) -> Node3D:
	var m = Node3D.new()
	m.position = pos
	parent.add_child(m)
	sph(m, Vector3(0, 0.0, 0), 0.7, Color("d9c08a"), Vector3(1, 0.35, 1), 10)
	box(m, Vector3(0.45, 0.35, 0.2), Vector3(0.06, 0.7, 0.06), Color("6d4a33"), Vector3(0, 0, 20))
	return m

static func whale() -> Node3D:
	var w = Node3D.new()
	var body = Node3D.new()
	w.add_child(body)
	var skin = Color("2f4a66")
	sph(body, Vector3(0, 0, 1.2), 1.0, skin, Vector3(1.6, 1.45, 3.2), 14)
	sph(body, Vector3(0, -0.05, -2.0), 1.0, skin, Vector3(1.05, 0.95, 2.8), 12)
	sph(body, Vector3(0, -0.55, 1.6), 1.0, Color("dfe8ee"), Vector3(1.2, 0.85, 2.6), 12)
	sph(body, Vector3(-0.95, 0.25, 3.3), 0.13, Color("0d1116"), Vector3.ONE, 6)
	sph(body, Vector3(0.95, 0.25, 3.3), 0.13, Color("0d1116"), Vector3.ONE, 6)
	box(body, Vector3(-2.2, -0.6, 1.6), Vector3(3.0, 0.12, 0.75), Color("e6edf2"), Vector3(0, 25, 28))
	box(body, Vector3(2.2, -0.6, 1.6), Vector3(3.0, 0.12, 0.75), Color("e6edf2"), Vector3(0, -25, -28))
	prism(body, Vector3(0, 0.95, -1.6), Vector3(0.12, 0.5, 0.9), skin.darkened(0.1), Vector3(0, 90, 0))
	cyl(body, Vector3(0, 0.0, -4.4), 0.25, 0.6, 1.6, skin, Vector3(90, 0, 0), 10)
	var fl = box(body, Vector3(-1.1, 0.0, -5.4), Vector3(2.2, 0.1, 1.0), skin.darkened(0.15), Vector3(0, 28, 0))
	var fr = box(body, Vector3(1.1, 0.0, -5.4), Vector3(2.2, 0.1, 1.0), skin.darkened(0.15), Vector3(0, -28, 0))
	w.set_meta("body", body)
	return w

const RAINBOW_SHADER = """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, shadows_disabled, depth_draw_never;
uniform float strength = 0.0;
vec3 hue(float h) { return clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0); }
void fragment() {
	vec2 p = UV - vec2(0.5, 1.0);
	p.x *= 2.0;
	float r = length(p);
	float band = (r - 0.78) / 0.12;
	if (band < 0.0 || band > 1.0) discard;
	float edge = sin(band * 3.14159);
	ALBEDO = hue(band * 0.8);
	ALPHA = edge * 0.45 * strength;
}
"""

static func rainbow(parent: Node3D) -> MeshInstance3D:
	var sh = Shader.new()
	sh.code = RAINBOW_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	var mi = MeshInstance3D.new()
	var qm = QuadMesh.new()
	qm.size = Vector2(240, 120)
	mi.mesh = qm
	mi.material_override = m
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mi.visible = false
	parent.add_child(mi)
	return mi

static func burst(parent: Node3D, amount: int, size: float) -> CPUParticles3D:
	var p = CPUParticles3D.new()
	p.amount = amount
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 1.8
	p.emitting = false
	p.direction = Vector3.UP
	p.spread = 180.0
	p.initial_velocity_min = 6.0
	p.initial_velocity_max = 9.0
	p.gravity = Vector3(0, -3.0, 0)
	p.damping_min = 1.5
	p.damping_max = 2.5
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.0
	var mesh = SphereMesh.new()
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 6
	mesh.rings = 3
	p.mesh = mesh
	var mat = unshaded(Color.WHITE, true)
	mat.vertex_color_use_as_albedo = true
	p.material_override = mat
	var g = Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = g
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(p)
	return p

static func rain(parent: Node3D) -> CPUParticles3D:
	var p = CPUParticles3D.new()
	p.amount = 900
	p.lifetime = 1.1
	p.emitting = false
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(22, 0.5, 22)
	p.direction = Vector3(0.1, -1, 0)
	p.spread = 3.0
	p.initial_velocity_min = 17.0
	p.initial_velocity_max = 21.0
	p.gravity = Vector3(0, -9.8, 0)
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.025, 0.55, 0.025)
	p.mesh = mesh
	p.material_override = unshaded(Color(0.82, 0.9, 1.0, 0.55), true)
	p.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	p.position = Vector3(0, 14, 0)
	parent.add_child(p)
	return p

# ---------- emotions: cartoon effects that float around a character's head ----------

static func heart(parent: Node3D, pos: Vector3, s: float, color: Color) -> Node3D:
	var h = Node3D.new()
	h.position = pos
	h.scale = Vector3.ONE * s
	parent.add_child(h)
	var m = unshaded(color)
	for x in [-0.07, 0.07]:
		var b = sph(h, Vector3(x, 0.05, 0), 0.085, color, Vector3.ONE, 8)
		b.material_override = m
	var tip = box(h, Vector3(0, -0.04, 0), Vector3(0.14, 0.14, 0.06), color, Vector3(0, 0, 45))
	tip.material_override = m
	return h

static func emote_fx(parent: Node3D) -> Node3D:
	var fx = Node3D.new()
	fx.position = Vector3(0, 1.62, 0)
	parent.add_child(fx)
	var hearts = Node3D.new()
	fx.add_child(hearts)
	for i in range(4):
		heart(hearts, Vector3(-0.3 + i * 0.2, 0.4, 0.1), 1.0, Color("ff4f81") if i % 2 == 0 else Color("ff8fb1"))
	var steam = Node3D.new()
	fx.add_child(steam)
	for x in [-0.3, 0.3]:
		var p = sph(steam, Vector3(x, 0.15, 0), 0.12, Color.WHITE, Vector3.ONE, 8)
		p.material_override = unshaded(Color(1, 1, 1, 0.85), true)
	var cloud = Node3D.new()
	fx.add_child(cloud)
	for i in range(4):
		var c = sph(cloud, Vector3(-0.22 + i * 0.15, 0.75 + (0.06 if i % 2 else 0.0), 0), 0.16, Color("6f7682"), Vector3(1, 0.8, 0.8), 8)
		c.material_override = unshaded(Color("6f7682"))
	var drops: Array = []
	for i in range(4):
		var d = sph(cloud, Vector3(-0.2 + i * 0.13, 0.5, 0), 0.03, Color("6db9ff"), Vector3(0.7, 1.6, 0.7), 5)
		d.material_override = unshaded(Color("6db9ff"))
		drops.append(d)
	var stars = Node3D.new()
	fx.add_child(stars)
	for i in range(4):
		var a = i * TAU / 4.0
		var st = box(stars, Vector3(cos(a) * 0.32, 0.3, sin(a) * 0.32), Vector3(0.09, 0.09, 0.09), Color("ffd34d"), Vector3(45, 45, 0))
		st.material_override = unshaded(Color("ffd34d"))
	var sweat = sph(fx, Vector3(0.2, 0.15, 0.12), 0.05, Color("8fd3ff"), Vector3(0.8, 1.3, 0.8), 6)
	sweat.material_override = unshaded(Color("8fd3ff"))
	var labels = {}
	for k in ["!", "?", "zzz", "Ha!"]:
		var l = Label3D.new()
		l.text = k
		l.font_size = 90 if k != "zzz" else 60
		l.pixel_size = 0.008
		l.outline_size = 16
		l.modulate = Color("ff3b3b") if k == "!" else (Color("ffd34d") if k != "zzz" else Color("bfe4ff"))
		l.outline_modulate = Color(0.1, 0.05, 0.05)
		l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		l.position = Vector3(0.35, 0.55, 0)
		fx.add_child(l)
		labels[k] = l
	fx.set_meta("hearts", hearts)
	fx.set_meta("steam", steam)
	fx.set_meta("cloud", cloud)
	fx.set_meta("drops", drops)
	fx.set_meta("stars", stars)
	fx.set_meta("sweat", sweat)
	fx.set_meta("labels", labels)
	for c in fx.get_children(): c.visible = false
	return fx

# ---------- poem plants ----------

static func berry_bush() -> Node3D:
	var n = Node3D.new()
	for i in range(5):
		var a = i * TAU / 5.0
		sph(n, Vector3(cos(a) * 0.32, 0.35 + (i % 2) * 0.12, sin(a) * 0.32), 0.36, Color("3d7a3a").lerp(Color("5a9a3e"), float(i % 3) / 3.0), Vector3(1, 0.85, 1), 9)
	var fruit = Node3D.new()
	n.add_child(fruit)
	for i in range(9):
		var a = i * TAU / 9.0 + 0.3
		var b = sph(fruit, Vector3(cos(a) * 0.55, 0.42 + sin(i * 1.7) * 0.18, sin(a) * 0.55), 0.075, Color("b84dff"), Vector3.ONE, 7, 1.6)
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.set_meta("fruit", fruit)
	return n

static func mushroom_patch() -> Node3D:
	var n = Node3D.new()
	var fruit = Node3D.new()
	n.add_child(fruit)
	for i in range(4):
		var p = Vector3([-0.25, 0.2, 0.0, 0.35][i], 0, [0.1, -0.2, 0.3, 0.15][i])
		var h = [0.42, 0.3, 0.24, 0.34][i]
		cyl(fruit, p + Vector3(0, h * 0.5, 0), 0.05, 0.07, h, Color("f2ead8"), Vector3.ZERO, 7)
		var cap = sph(fruit, p + Vector3(0, h, 0), 0.17, Color("3fc6e0"), Vector3(1, 0.55, 1), 10, 1.4)
		cap.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for k in range(3):
			var a = k * TAU / 3.0 + i
			sph(fruit, p + Vector3(cos(a) * 0.09, h + 0.07, sin(a) * 0.09), 0.025, Color("ffffff"), Vector3.ONE, 4)
	n.set_meta("fruit", fruit)
	return n


const FLOOR_SHADER = """
shader_type spatial;
uniform vec4 color : source_color = vec4(0.05, 0.27, 0.38, 1.0);
uniform vec3 hole = vec3(0.0, 0.0, 0.0);
varying vec3 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
	if (hole.z > 0.0 && distance(wp.xz, hole.xy) < hole.z) discard;
	ALBEDO = color.rgb;
	ROUGHNESS = 0.9;
}
"""

static func floor_material(color: Color, hole: Vector3) -> ShaderMaterial:
	var sh = Shader.new()
	sh.code = FLOOR_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
	m.set_shader_parameter("color", color)
	m.set_shader_parameter("hole", hole)
	return m
