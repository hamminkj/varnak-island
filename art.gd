extends RefCounted
# Procedural art for Varnak Island. Everything is built from primitives, so no asset files are needed.

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
varying vec3 wp;
float hf(vec2 p) {
	float t = TIME * speed;
	return 0.5 + 0.25 * sin(p.x * 1.3 + t) + 0.2 * sin(p.y * 1.9 - t * 1.2) + 0.15 * sin((p.x + p.y) * 3.1 + t * 1.7);
}
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
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
varying vec3 wp;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}
void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	vec2 p = wp.xz;
	float n = vnoise(p * 0.3) * 0.55 + vnoise(p * 1.4) * 0.3 + vnoise(p * 6.0) * 0.15;
	vec3 grass = mix(vec3(0.22, 0.42, 0.18), vec3(0.40, 0.60, 0.24), n);
	grass = mix(grass, vec3(0.52, 0.60, 0.22), smoothstep(0.62, 0.9, vnoise(p * 0.7)) * 0.45);
	vec3 sand = mix(vec3(0.82, 0.72, 0.50), vec3(0.74, 0.63, 0.42), vnoise(p * 2.2));
	float dx = 29.0 - abs(p.x);
	float dz = min(25.5 - p.y, p.y + 39.5);
	float gmask = smoothstep(-0.6, 2.2, min(dx, dz) + (vnoise(p * 0.9) - 0.5) * 2.4);
	vec3 col = mix(sand, grass, gmask);
	float pathd = abs(p.x + (vnoise(vec2(p.y * 0.15, 3.0)) - 0.5) * 0.9) + (vnoise(p * 1.7) - 0.5) * 0.5;
	float path = 1.0 - smoothstep(1.6, 2.5, pathd);
	vec3 pathc = mix(vec3(0.72, 0.58, 0.36), vec3(0.62, 0.48, 0.30), vnoise(p * 3.5));
	pathc = mix(pathc, vec3(0.50, 0.46, 0.40), step(0.965, hash(floor(p * 16.0))) * 0.55);
	col = mix(col, pathc, path * 0.95);
	float edge = min(38.0 - abs(p.x), 47.0 - abs(p.y));
	col = mix(col, col * vec3(0.78, 0.74, 0.68), 1.0 - smoothstep(0.0, 2.0, edge));
	float river = 1.0 - smoothstep(2.0, 3.2, abs(p.y + 23.0));
	col = mix(col, vec3(0.50, 0.46, 0.36), river * 0.85);
	float inlet = (1.0 - smoothstep(14.0, 16.0, abs(p.x))) * smoothstep(33.0, 35.0, p.y);
	col = mix(col, vec3(0.58, 0.52, 0.38), inlet * 0.9);
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

static func ground_material() -> ShaderMaterial:
	var sh = Shader.new()
	sh.code = GROUND_SHADER
	var m = ShaderMaterial.new()
	m.shader = sh
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

static func person(shirt: Color, skin: Color, hair: Color, style: int = 0, accent: Color = Color("f2e6c8")) -> Node3D:
	var n = Node3D.new()
	var pants = shirt.darkened(0.45)
	box(n, Vector3(-0.11, 0.3, 0), Vector3(0.17, 0.6, 0.2), pants)
	box(n, Vector3(0.11, 0.3, 0), Vector3(0.17, 0.6, 0.2), pants)
	box(n, Vector3(-0.11, 0.04, 0.05), Vector3(0.19, 0.09, 0.32), Color("3b2d25"))
	box(n, Vector3(0.11, 0.04, 0.05), Vector3(0.19, 0.09, 0.32), Color("3b2d25"))
	var body = Node3D.new()
	n.add_child(body)
	cyl(body, Vector3(0, 0.95, 0), 0.22, 0.28, 0.78, shirt, Vector3.ZERO, 14)
	cyl(body, Vector3(0, 0.62, 0), 0.285, 0.285, 0.07, accent.darkened(0.2), Vector3.ZERO, 14)
	torus(body, Vector3(0, 1.36, 0), 0.07, 0.18, accent, Vector3.ZERO)
	var arms = []
	for side in [-1.0, 1.0]:
		var pivot = Node3D.new()
		pivot.position = Vector3(side * 0.3, 1.28, 0)
		body.add_child(pivot)
		cyl(pivot, Vector3(0, -0.28, 0), 0.065, 0.075, 0.58, shirt.lightened(0.05), Vector3.ZERO, 8)
		sph(pivot, Vector3(0, -0.6, 0), 0.075, skin, Vector3.ONE, 8)
		arms.append(pivot)
	var head = Node3D.new()
	head.position = Vector3(0, 1.62, 0)
	body.add_child(head)
	sph(head, Vector3.ZERO, 0.21, skin, Vector3.ONE, 14)
	sph(head, Vector3(0, -0.02, 0.2), 0.04, skin.darkened(0.08), Vector3.ONE, 6)
	sph(head, Vector3(-0.08, 0.03, 0.185), 0.04, Color("1a120e"), Vector3(1, 1.25, 0.7), 6)
	sph(head, Vector3(0.08, 0.03, 0.185), 0.04, Color("1a120e"), Vector3(1, 1.25, 0.7), 6)
	box(head, Vector3(0, -0.1, 0.19), Vector3(0.09, 0.015, 0.02), skin.darkened(0.35))
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
	var small: Array = [head]
	small.append_array(arms)
	for part in small:
		for c in part.get_children():
			if c is GeometryInstance3D: c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	n.set_meta("body", body)
	n.set_meta("head", head)
	n.set_meta("arms", arms)
	return n

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

static func signpost(parent: Node3D, pos: Vector3, text: String, face_yaw: float = 0.0) -> void:
	var s = Node3D.new()
	s.position = pos
	s.rotation_degrees.y = face_yaw
	parent.add_child(s)
	cyl(s, Vector3(0, 0.8, 0), 0.07, 0.09, 1.6, Color("6d4a33"), Vector3.ZERO, 6)
	box(s, Vector3(0, 1.55, 0.07), Vector3(1.15, 0.6, 0.08), Color("b8935f"))
	box(s, Vector3(0, 1.55, 0.05), Vector3(1.25, 0.7, 0.05), Color("6d4a33"))
	label3(s, text, Vector3(0, 1.57, 0.2), 38)
