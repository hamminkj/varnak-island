extends Node3D

const Art = preload("res://art.gd")
const Data = preload("res://data.gd")
const SAVE = "user://varnak_island.json"

var player: CharacterBody3D
var camera: Camera3D
var ui: Control
var status: Label
var prompt: Label
var toast_label: Label
var panel: PanelContainer
var content: VBoxContainer
var interact_button: Button
var marker: MeshInstance3D
var joy: Vector2 = Vector2.ZERO
var move_finger: int = -1
var look_finger: int = -1
var joy_origin: Vector2
var mouse_look: bool = false
var left_down: bool = false
var left_drag: float = 0.0
var hint_time: float = 0.0
var toast_time: float = 0.0
var zone: String = ""
var entities: Array = []
var inventory: Array = []
var discovered: Array = []
var completed: Array = []
var mastered: Array = []
var phrases: Array = []
var solved: Array = []
var fish_caught: int = 0
var last_skip: Button
var target: Dictionary = {}
var clock: float = 0.0
var save_clock: float = 0.0
var lesson: String = ""
var guesses: Dictionary = {}
var houses: Dictionary = {}
var bridge_info: Dictionary = {}
var table_node: Node3D
var boat_node: Node3D
var tent_node: Node3D
var animals: Array = []
var butterflies: Array = []
var clouds: Array = []
var gulls: Array = []
var words = {
	"wak":"water", "guro":"fruit", "kor":"container", "kel":"bag", "murak":"tree / wood",
	"sek":"stone", "lin":"rope", "tari":"fish", "par":"bird", "dom":"house", "teka":"village",
	"mora":"river", "ruk":"path", "sena":"boat", "bei":"north", "sava":"safe",
	"anni":"my / of me (an + ni)", "nalum":"I go (na + lum)", "talumo":"Go! (ta + lum + o)",
	"tekama":"in the village (teka + ma)", "tekaru":"to the village (teka + ru)",
	"tnaveno":"Give it to me! (t + na + ven + o)", "sen":"small", "var":"big",
	"italpada":"They arrived, witnessed (i + tal + pa + da)",
	"italpashi":"They apparently arrived (i + tal + pa + shi)",
	"italpanu":"They reportedly arrived (i + tal + pa + nu)"
}
var quests = [
	["belongings","Find your bag at the harbor. Talk to Ena."],
	["meal","Bring wak, guro and kor to Mira in the village."],
	["bag","Find the forest bag and take it to Sanu."],
	["bridge","Bring murak, sek and lin to Tor by the river."],
	["evidence","Compare the accounts of Tor, Lira and Oren."],
	["cove","Visit the northern cove and talk to Neri."]
]
# skin, hair, hair style, accent
var looks = {
	"ena": [Color("d6ac83"), Color("2b1d14"), 0, Color("e9c46a")],
	"mira": [Color("c68e66"), Color("3b2418"), 2, Color("f2e6c8")],
	"sanu": [Color("e3b98f"), Color("7a4a22"), 3, Color("5b8c5a")],
	"tor": [Color("a87650"), Color("1d1d1d"), 4, Color("c9a46d")],
	"lira": [Color("f0c9a0"), Color("b5651d"), 1, Color("e76f51")],
	"oren": [Color("8d5a3b"), Color("4a4a4a"), 0, Color("a8dadc")],
	"neri": [Color("d9a679"), Color("2e2a5a"), 2, Color("f4a261")]
}
var house_centers = [Vector3(-9,0,12), Vector3(10,0,7), Vector3(-11,0,1), Vector3(12,0,-4)]

func _ready():
	words.merge(Data.WORDS)
	build_world()
	build_ui()
	load_game()
	refresh_world()
	show_intro()

# ------------------------------------------------------------ world

func solid(pos: Vector3, size: Vector3):
	var body = StaticBody3D.new()
	body.position = pos
	var cs = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)

func entity(id: String, kind: String, word: String, pos: Vector3, color: Color, label_y: float = 1.0) -> Dictionary:
	var node: Node3D
	match kind:
		"npc":
			var look = looks[id]
			node = Art.person(color, look[0], look[1], look[2], look[3])
			label_y = 2.15
		"item":
			node = Art.item_model(id, color)
			label_y = 0.85
		"observe":
			node = Art.animal(word)
			label_y = 0.85 if word != "mar" else 2.5
			if word == "tari": label_y = 0.7
		_:
			node = Node3D.new()
	node.position = pos
	add_child(node)
	var label = Art.label3(node, id.capitalize() if kind == "npc" else word, Vector3(0, label_y, 0), 38 if kind == "npc" else 34)
	label.visibility_range_end = 30.0 if kind == "npc" else 12.0
	var e = {"id":id,"kind":kind,"word":word,"node":node,"home":pos}
	entities.append(e)
	return e

func build_world():
	build_environment()
	build_terrain()
	build_forest()
	build_village()
	build_harbor()
	build_river()
	build_cove()
	build_scatter()
	build_sky_life()
	build_entities()
	build_player()

func build_environment():
	var we = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var psm = ProceduralSkyMaterial.new()
	psm.sky_top_color = Color("3f86d0")
	psm.sky_horizon_color = Color("bfe4f2")
	psm.ground_horizon_color = Color("bfe4f2")
	psm.ground_bottom_color = Color("86b9c9")
	psm.sky_curve = 0.18
	psm.sun_angle_max = 28.0
	psm.sun_curve = 0.12
	sky.sky_material = psm
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	env.tonemap_exposure = 0.82
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.05
	env.adjustment_contrast = 1.04
	env.fog_enabled = true
	env.fog_light_color = Color("c9e7f0")
	env.fog_density = 0.0035
	env.fog_sky_affect = 0.25
	we.environment = env
	add_child(we)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -32, 0)
	sun.light_energy = 0.9
	sun.light_color = Color("fff0d8")
	sun.shadow_enabled = true
	sun.shadow_bias = 0.04
	sun.shadow_blur = 1.4
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 48.0
	add_child(sun)

func build_terrain():
	solid(Vector3(0,-0.3,0), Vector3(76,0.6,94))
	Art.box(self, Vector3(0,-0.3,0), Vector3(76,0.6,94), Color("d9c795"))
	Art.plane(self, Vector3(0,0.012,0), Vector2(76,94), Art.ground_material())
	Art.plane(self, Vector3(0,-0.10,0), Vector2(900,900), Art.water_material(Color("0e5a78"), Color("2f9fb2"), 0.97))
	Art.plane(self, Vector3(0,-0.06,0), Vector2(82,100), Art.water_material(Color("3fb7bd"), Color("8fe0d8"), 0.7))
	Art.plane(self, Vector3(0,0.035,40.3), Vector2(30,14.8), Art.water_material())
	Art.plane(self, Vector3(0,0.035,-23), Vector2(76,5), Art.water_material(Color("1c7a8c"), Color("5cc3c4"), 0.82))

func build_forest():
	var rng = RandomNumberGenerator.new()
	rng.seed = 70426
	var vary = RandomNumberGenerator.new()
	vary.seed = 9913
	var trunks: Array = []
	var trunk_colors: Array = []
	var pines: Array = []
	var pine_colors: Array = []
	var oaks: Array = []
	var oak_colors: Array = []
	for i in range(48):
		var x = rng.randf_range(-30,30)
		if abs(x) < 5: x += 7
		var z = rng.randf_range(-32,-5)
		solid(Vector3(x,1.2,z), Vector3(0.5,2.4,0.5))
		add_tree(Vector3(x,0,z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
	for i in range(80):
		var side = -1.0 if i % 2 == 0 else 1.0
		var x = side * vary.randf_range(29.5, 36.5)
		var z = vary.randf_range(-42, 30)
		add_tree(Vector3(x,0,z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
	for i in range(14):
		var x = vary.randf_range(-24, 24)
		var z = vary.randf_range(-45, -41)
		add_tree(Vector3(x,0,z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
	Art.scatter(self, Art.cyl_mesh(0.28, 1.0, 7), trunks, trunk_colors)
	Art.scatter(self, Art.cone_mesh(1.0, 1.0, 8), pines, pine_colors)
	Art.scatter(self, Art.sphere_mesh(1.0, 9), oaks, oak_colors)

func add_tree(p: Vector3, vary: RandomNumberGenerator, trunks: Array, trunk_colors: Array, pines: Array, pine_colors: Array, oaks: Array, oak_colors: Array):
	var s = vary.randf_range(0.85, 1.45)
	var yaw = vary.randf() * TAU
	var trunk_h = 2.0 * s
	trunks.append(Transform3D(Basis.from_scale(Vector3(s, trunk_h, s)), p + Vector3(0, trunk_h * 0.5, 0)))
	trunk_colors.append(Color("6b4f36").lerp(Color("85623f"), vary.randf()))
	if vary.randf() < 0.5:
		for layer in range(3):
			var r = (1.9 - layer * 0.5) * s
			var h = 1.9 * s
			var y = trunk_h * 0.7 + layer * 1.15 * s + h * 0.5
			pines.append(Transform3D(Basis.from_scale(Vector3(r, h, r)).rotated(Vector3.UP, yaw), p + Vector3(0, y, 0)))
			pine_colors.append(Color("1f5a3a").lerp(Color("3d8a48"), vary.randf() * 0.8 + layer * 0.1))
	else:
		var base = Color("4c8f3a").lerp(Color("86b84a"), vary.randf())
		if vary.randf() < 0.08: base = Color("d98f3a")
		var cy = trunk_h + 0.7 * s
		oaks.append(Transform3D(Basis.from_scale(Vector3(2.0 * s, 1.55 * s, 2.0 * s)), p + Vector3(0, cy, 0)))
		oak_colors.append(base)
		oaks.append(Transform3D(Basis.from_scale(Vector3(1.3 * s, 1.1 * s, 1.3 * s)), p + Vector3(0.9 * s * cos(yaw), cy + 0.7 * s, 0.9 * s * sin(yaw))))
		oak_colors.append(base.lightened(0.1))
		oaks.append(Transform3D(Basis.from_scale(Vector3(1.2 * s, 1.0 * s, 1.2 * s)), p + Vector3(-0.8 * s * cos(yaw), cy + 0.3 * s, -0.8 * s * sin(yaw))))
		oak_colors.append(base.darkened(0.08))

func build_village():
	var walls = [Color("e0c39a"), Color("ead2ac"), Color("d3b08a"), Color("dcc0a4")]
	var roofs = [Color("b5654a"), Color("8f5a48"), Color("a8584a"), Color("6b7f9c")]
	var trims = [Color("f4ead0"), Color("5c4b3e"), Color("f4ead0"), Color("f4ead0")]
	for i in range(4):
		var c = house_centers[i]
		var h = Art.house(self, c, walls[i], roofs[i], trims[i])
		houses["house" + str(i + 1)] = h
		solid(Vector3(c.x, 1.6, c.z), Vector3(5, 3.2, 5))
	for z in [28,15,-8,-19,-32]:
		Art.signpost(self, Vector3(3,0,z), "bei\n↑")
	Art.signpost(self, Vector3(-3.2,0,21.5), "teka-ma")
	Art.signpost(self, Vector3(-6,0,-18), "mora-ven")
	for p in [Vector3(-2.8,0,22), Vector3(2.8,0,8), Vector3(-2.8,0,-2), Vector3(2.8,0,-14)]:
		Art.lamp(self, p)
	table_node = Art.table(self, Vector3(-6.2,0,7.5))
	# field and paddock
	for i in range(8):
		var row = Art.box(self, Vector3(23, 0.22, 0.9 + i * 1.1), Vector3(11, 0.4, 0.55), Color("5a4631"))
		row.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	Art.fence(self, Vector3(17,0,-0.8), Vector3(29,0,-0.8))
	Art.fence(self, Vector3(29,0,-0.8), Vector3(29,0,10))
	Art.fence(self, Vector3(17,0,10), Vector3(29,0,10))
	Art.fence(self, Vector3(17,0,-0.8), Vector3(17,0,3))
	Art.fence(self, Vector3(17,0,12), Vector3(29,0,12))
	Art.fence(self, Vector3(29,0,12), Vector3(29,0,22))
	Art.fence(self, Vector3(17,0,22), Vector3(29,0,22))
	Art.fence(self, Vector3(17,0,12), Vector3(17,0,15))
	Art.fence(self, Vector3(17,0,19), Vector3(17,0,22))
	var scarecrow = Art.person(Color("8c5a3c"), Color("d6b97a"), Color("d6b97a"), 3, Color("c9a46d"))
	scarecrow.position = Vector3(23, 0.3, 4.5)
	add_child(scarecrow)
	for arm in scarecrow.get_meta("arms"): arm.rotation_degrees.z = 85.0 * (1.0 if arm.position.x < 0 else -1.0)
	solid(Vector3(23, 1, 4.5), Vector3(0.4, 2, 0.4))

func build_harbor():
	solid(Vector3(0,0.04,36), Vector3(8,0.08,12))
	var plank_t: Array = []
	var plank_c: Array = []
	for i in range(24):
		plank_t.append(Transform3D(Basis.IDENTITY, Vector3(0, 0.07, 30.25 + i * 0.5)))
		plank_c.append(Color("a77b4f").lerp(Color("8f6a43"), float(i % 4) / 4.0))
	var plank_mesh = BoxMesh.new()
	plank_mesh.size = Vector3(8, 0.08, 0.485)
	Art.scatter(self, plank_mesh, plank_t, plank_c, false)
	for sx in [-3.9, 3.9]:
		for i in range(5):
			Art.cyl(self, Vector3(sx, 0.35, 30.5 + i * 2.6), 0.1, 0.12, 1.2, Color("5b3d28"), Vector3.ZERO, 7)
	boat_node = Art.boat(self, Vector3(-8, 0.03, 39.6))
	solid(Vector3(-8,0.5,39), Vector3(3,1,6))
	Art.crate(self, Vector3(-5.6,0,31.4), 0.8, Color("b58a52"), 15)
	Art.crate(self, Vector3(-5.0,0,32.5), 0.6, Color("a37a47"), -10)
	Art.crate(self, Vector3(-5.5,0.8,31.5), 0.5, Color("c19a62"), 30)
	Art.barrel(self, Vector3(5.6,0,31.2), Color("8f6a43"))
	Art.barrel(self, Vector3(6.5,0,32.3), Color("7d5a3c"))

func build_river():
	var info = Art.bridge(self, Vector3(0, 0, -23))
	bridge_info = info
	solid(Vector3(0,0.04,-23), Vector3(3,0.08,7))

func build_cove():
	tent_node = Art.tent(self, Vector3(-4, 0, -42.5))
	for p in [Vector3(6,0,-43), Vector3(-9,0,-41), Vector3(10,0,-39.8)]:
		Art.cyl(self, p + Vector3(0,0.15,0), 0.12, 0.16, 2.2, Color("8a7a66"), Vector3(0, 0, 84), 7)

func build_scatter():
	var rs = RandomNumberGenerator.new()
	rs.seed = 5150
	var tufts: Array = []
	var tuft_colors: Array = []
	var stems: Array = []
	var stem_colors: Array = []
	var heads: Array = []
	var head_colors: Array = []
	var rocks: Array = []
	var rock_colors: Array = []
	var reeds: Array = []
	var reed_colors: Array = []
	var tries = 0
	while tufts.size() < 2600 and tries < 12000:
		tries += 1
		var x = rs.randf_range(-28.5, 28.5)
		var z = rs.randf_range(-38.5, 25)
		if grass_ok(x, z):
			var s = rs.randf_range(0.6, 1.3)
			var tilt = Basis.from_euler(Vector3(rs.randf_range(-0.25, 0.25), rs.randf() * TAU, rs.randf_range(-0.25, 0.25)))
			tufts.append(Transform3D(tilt.scaled(Vector3(s, s, s)), Vector3(x, 0.13 * s, z)))
			tuft_colors.append(Color("2f6a2a").lerp(Color("86b84a"), rs.randf()))
	var palette = [Color("f2d36b"), Color("f5f0e1"), Color("e8789a"), Color("a78bda"), Color("f2915a")]
	for c in range(34):
		var cx = rs.randf_range(-27, 27)
		var cz = rs.randf_range(-37, 24)
		var col: Color = palette[rs.randi() % palette.size()]
		for k in range(rs.randi_range(4, 8)):
			var x = cx + rs.randf_range(-1.3, 1.3)
			var z = cz + rs.randf_range(-1.3, 1.3)
			if grass_ok(x, z):
				var h = rs.randf_range(0.28, 0.42)
				stems.append(Transform3D(Basis.from_scale(Vector3(1, h, 1)), Vector3(x, h * 0.5, z)))
				stem_colors.append(Color("4f8b3c"))
				heads.append(Transform3D(Basis.IDENTITY, Vector3(x, h + 0.02, z)))
				head_colors.append(col.lightened(rs.randf() * 0.15))
	for i in range(55):
		var x = rs.randf_range(-33, 33)
		var z = rs.randf_range(-44, 44)
		if abs(x) < 2.6 or in_house(x, z): continue
		var s = rs.randf_range(0.18, 0.55)
		rocks.append(Transform3D(Basis.from_scale(Vector3(s * 1.3, s * 0.8, s)).rotated(Vector3.UP, rs.randf() * TAU), Vector3(x, s * 0.3, z)))
		rock_colors.append(Color("8d9394").lerp(Color("b4aea0"), rs.randf()))
	for side in [-1.0, 1.0]:
		for i in range(70):
			var x = rs.randf_range(-35, 35)
			var z = -23 + side * rs.randf_range(2.35, 3.1)
			if abs(x) < 2.4: continue
			var h = rs.randf_range(0.7, 1.4)
			reeds.append(Transform3D(Basis.from_scale(Vector3(1, h, 1)).rotated(Vector3.RIGHT, rs.randf_range(-0.12, 0.12)), Vector3(x, h * 0.5, z)))
			reed_colors.append(Color("6e9a46").lerp(Color("a8b86a"), rs.randf()))
	var wheat: Array = []
	var wheat_colors: Array = []
	for i in range(8):
		var wz = 0.9 + i * 1.1
		var wx = 17.8
		while wx < 28.3:
			var h = rs.randf_range(0.7, 1.1)
			var wb = Basis.from_euler(Vector3(rs.randf_range(-0.1, 0.1), rs.randf() * TAU, rs.randf_range(-0.1, 0.1)))
			wheat.append(Transform3D(wb.scaled(Vector3(1, h, 1)), Vector3(wx + rs.randf_range(-0.05, 0.05), 0.4 + 0.3 * h, wz + rs.randf_range(-0.2, 0.2))))
			wheat_colors.append(Color("d2b04a").lerp(Color("8fa63a"), rs.randf()))
			wx += 0.3
	Art.scatter(self, Art.cone_mesh(0.07, 0.6, 5), wheat, wheat_colors, false)
	Art.scatter(self, Art.cone_mesh(0.045, 0.3, 4), tufts, tuft_colors, false)
	Art.scatter(self, Art.cyl_mesh(0.015, 1.0, 4), stems, stem_colors, false)
	Art.scatter(self, Art.sphere_mesh(0.085, 7), heads, head_colors, false)
	Art.scatter(self, Art.sphere_mesh(1.0, 8), rocks, rock_colors)
	Art.scatter(self, Art.cyl_mesh(0.03, 1.0, 4), reeds, reed_colors, false)

func in_house(x: float, z: float) -> bool:
	for c in house_centers:
		if abs(x - c.x) < 4.0 and abs(z - c.z) < 4.0: return true
	return false

func grass_ok(x: float, z: float) -> bool:
	if abs(x) < 2.6: return false
	if abs(z + 23) < 3.3: return false
	if in_house(x, z): return false
	if x > 16.5 and z > -1.5 and z < 22.5: return false
	if abs(x - (-6.2)) < 2.0 and abs(z - 7.5) < 2.0: return false
	return true

func build_sky_life():
	var cloud_mat = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1, 1, 1, 0.93)
	cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloud_mat.disable_fog = true
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var rc = RandomNumberGenerator.new()
	rc.seed = 321
	for i in range(9):
		var c = Node3D.new()
		c.position = Vector3(rc.randf_range(-90, 90), rc.randf_range(42, 62), rc.randf_range(-100, 40))
		add_child(c)
		for k in range(rc.randi_range(3, 5)):
			var m = MeshInstance3D.new()
			var sm = SphereMesh.new()
			sm.radius = 1.0
			sm.height = 2.0
			sm.radial_segments = 10
			sm.rings = 5
			m.mesh = sm
			m.material_override = cloud_mat
			m.position = Vector3(k * 5.5 - 10, rc.randf_range(-1, 1.5), rc.randf_range(-3, 3))
			var sc = rc.randf_range(4.5, 8)
			m.scale = Vector3(sc, sc * 0.45, sc * 0.8)
			m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			c.add_child(m)
		clouds.append(c)
	for i in range(14):
		var b = Node3D.new()
		var col = [Color("f2915a"), Color("e8789a"), Color("f2d36b"), Color("8fb8f0"), Color("f5f0e1")][i % 5]
		var wl = Node3D.new()
		var wr = Node3D.new()
		b.add_child(wl)
		b.add_child(wr)
		Art.box(wl, Vector3(-0.07, 0, 0), Vector3(0.14, 0.01, 0.12), col)
		Art.box(wr, Vector3(0.07, 0, 0), Vector3(0.14, 0.01, 0.12), col)
		add_child(b)
		var center = Vector3(rc.randf_range(-24, 24), 0, rc.randf_range(-36, 22))
		butterflies.append({"node": b, "l": wl, "r": wr, "c": center, "a": rc.randf_range(0.4, 0.9), "p": rc.randf() * 20.0, "r2": rc.randf_range(2, 5)})
	for i in range(3):
		var g = Node3D.new()
		var wl = Node3D.new()
		var wr = Node3D.new()
		g.add_child(wl)
		g.add_child(wr)
		Art.box(wl, Vector3(-0.5, 0, 0), Vector3(1.0, 0.05, 0.28), Color("f5f5f0"))
		Art.box(wr, Vector3(0.5, 0, 0), Vector3(1.0, 0.05, 0.28), Color("f5f5f0"))
		Art.box(g, Vector3(0, 0, 0), Vector3(0.22, 0.18, 0.5), Color("f5f5f0"))
		add_child(g)
		gulls.append({"node": g, "l": wl, "r": wr, "p": i * 2.1, "rad": 18 + i * 5, "h": 15 + i * 3})

func build_entities():
	entity("ena","npc","Ena",Vector3(-2,0,32),Color("426c9c"))
	entity("mira","npc","Mira",Vector3(-4,0,11),Color("bb714b"))
	entity("sanu","npc","Sanu",Vector3(4,0,-8),Color("d5b54c"))
	entity("tor","npc","Tor",Vector3(-3,0,-19),Color("637ba3"))
	entity("lira","npc","Lira",Vector3(7,0,3),Color("9678a5"))
	entity("oren","npc","Oren",Vector3(6,0,-29),Color("7e9975"))
	entity("neri","npc","Neri",Vector3(0,0,-40),Color("bd795f"))
	entity("own_bag","item","kel",Vector3(2,0,32),Color("c58b55"))
	entity("water","item","wak",Vector3(4,0,20),Color("52bddd"))
	entity("fruit","item","guro",Vector3(-4,0,17),Color("dc8060"))
	entity("container","item","kor",Vector3(4,0,13),Color("d5c5a4"))
	entity("forest_bag","item","kel",Vector3(-5,0,-12),Color("849ab9"))
	entity("wood","item","murak",Vector3(4,0,-14),Color("906b44"))
	entity("stone","item","sek",Vector3(-4,0,-16),Color("889496"))
	entity("rope","item","lin",Vector3(4,0,-18),Color("dfc990"))
	var bird = entity("bird","observe","par",Vector3(-6,0,-5),Color("ead8a4"))
	var fish = entity("fish","observe","tari",Vector3(6,0,-22),Color("7bb9c7"))
	var dog = entity("dog","observe","gor",Vector3(-1,0,5),Color("c08a54"))
	var horse = entity("horse","observe","mar",Vector3(22,0,17),Color("8b5a3c"))
	animals.append({"e": bird, "kind": "bird", "radius": 2.6, "speed": 1.1, "tp": Vector3(-6,0,-5), "wait": 0.0})
	animals.append({"e": fish, "kind": "fish", "radius": 0.0, "speed": 0.0, "tp": Vector3.ZERO, "wait": 2.0})
	animals.append({"e": dog, "kind": "dog", "radius": 6.0, "speed": 1.9, "tp": Vector3(-1,0,5), "wait": 0.0})
	animals.append({"e": horse, "kind": "horse", "radius": 3.8, "speed": 1.2, "tp": Vector3(22,0,17), "wait": 0.0})
	entity("boat","object","sena",Vector3(-6.3,0,39),Color.WHITE,1.6)
	for i in range(4):
		var c = house_centers[i]
		entity("house" + str(i + 1),"object","dom",Vector3(c.x, 0, c.z + 3.6),Color.WHITE,2.5)
	entity("table","object","tab",Vector3(-6.2,0,7.5),Color.WHITE,1.5)
	entity("gira","object","gira",Vector3(0,0,-19.2),Color.WHITE,1.8)
	entity("field","object","mara",Vector3(16.2,0,5),Color.WHITE,1.2)
	entity("sign1","object","bei",Vector3(3,0,28),Color.WHITE,2.3)
	entity("sign2","object","bei",Vector3(3,0,-8),Color.WHITE,2.3)
	entity("sign3","object","bei",Vector3(3,0,-32),Color.WHITE,2.3)
	entity("sign_village","object","teka",Vector3(-3.2,0,21.5),Color.WHITE,2.3)
	entity("sign_river","object","mora",Vector3(-6,0,-18),Color.WHITE,2.3)
	entity("cairn","object","sek",Vector3(-3.2,0,-3.5),Color.WHITE,0.9)
	entity("flowers","object","fal",Vector3(3.6,0,24),Color.WHITE,0.9)
	entity("basket","object","guro",Vector3(-1.8,0,9.2),Color.WHITE,0.9)
	# count props
	build_count_prop(Vector3(-3.2,0,-3.5), "stone", 3)
	build_count_prop(Vector3(3.6,0,24), "flower", 4)
	build_count_prop(Vector3(-1.8,0,9.2), "fruit", 5)

func build_count_prop(pos: Vector3, kind: String, n: int):
	var g = Node3D.new()
	g.position = pos
	add_child(g)
	match kind:
		"stone":
			for i in range(n):
				var a = i * TAU / float(n)
				Art.sph(g, Vector3(cos(a) * 0.45, 0.2, sin(a) * 0.45), 0.24, Color("8d9394").lerp(Color("b4aea0"), float(i) / float(n)), Vector3(1.2, 0.8, 1), 8)
		"flower":
			for i in range(n):
				var a = i * TAU / float(n) + 0.5
				var p = Vector3(cos(a) * 0.5, 0, sin(a) * 0.5)
				Art.cyl(g, p + Vector3(0, 0.3, 0), 0.02, 0.025, 0.6, Color("4f8b3c"), Vector3.ZERO, 5)
				for k in range(6):
					var b = k * TAU / 6.0
					Art.sph(g, p + Vector3(cos(b) * 0.1, 0.64, sin(b) * 0.1), 0.06, Color("f5f0e1"), Vector3.ONE, 6)
				Art.sph(g, p + Vector3(0, 0.64, 0), 0.06, Color("f2c14e"), Vector3.ONE, 6)
		"fruit":
			Art.cyl(g, Vector3(0, 0.15, 0), 0.5, 0.36, 0.3, Color("a77b4f"), Vector3.ZERO, 12)
			for i in range(n):
				var a = i * TAU / float(n)
				Art.sph(g, Vector3(cos(a) * 0.22, 0.38, sin(a) * 0.22), 0.13, Color("dc8060").lerp(Color("e9c46a"), float(i) / float(n)), Vector3.ONE, 8)

func build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0,0.1,36)
	add_child(player)
	var collision = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.7
	collision.shape = capsule
	collision.position.y = 0.85
	player.add_child(collision)
	camera = Camera3D.new()
	camera.position.y = 1.65
	camera.fov = 75
	camera.far = 600.0
	camera.current = true
	player.add_child(camera)

func refresh_world():
	for i in range(1, 5):
		var id = "house" + str(i)
		var open = false
		if i == 4: open = not solved.has(id)
		elif i != 3: open = solved.has(id)
		Art.set_door(houses[id], open)
	Art.set_bridge(bridge_info, completed.has("bridge"))
	(table_node.get_meta("feast") as Node3D).visible = completed.has("meal")

# ------------------------------------------------------------ ui

func panel_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.95, 0.86, 0.97)
	sb.border_color = Color(0.55, 0.38, 0.2)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(16)
	sb.shadow_color = Color(0, 0, 0, 0.35)
	sb.shadow_size = 10
	return sb

func chip_style(alpha: float = 0.62) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.11, 0.14, alpha)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	return sb

func button_style(color: Color) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	sb.border_color = color.darkened(0.35)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 9
	sb.content_margin_bottom = 9
	return sb

func make_theme() -> Theme:
	var theme = Theme.new()
	theme.default_font_size = 19
	theme.set_stylebox("normal", "Button", button_style(Color("e0b676")))
	theme.set_stylebox("hover", "Button", button_style(Color("ebc78e")))
	theme.set_stylebox("pressed", "Button", button_style(Color("c99a58")))
	theme.set_stylebox("focus", "Button", button_style(Color("ebc78e")))
	theme.set_stylebox("disabled", "Button", button_style(Color("c9bfae")))
	theme.set_color("font_color", "Button", Color("2e1c0c"))
	theme.set_color("font_hover_color", "Button", Color("2e1c0c"))
	theme.set_color("font_pressed_color", "Button", Color("2e1c0c"))
	theme.set_color("font_disabled_color", "Button", Color("7d735f"))
	theme.set_color("font_color", "Label", Color("2e1c0c"))
	theme.set_stylebox("panel", "PanelContainer", panel_style())
	return theme

func button(text: String, callback: Callable, parent: Node) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size.y = 52
	b.pressed.connect(callback)
	parent.add_child(b)
	return b

func build_ui():
	var layer = CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(ui)
	ui.theme = make_theme()
	status = Label.new()
	status.position = Vector2(14,30)
	status.size = Vector2(452,68)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_stylebox_override("normal", chip_style())
	status.add_theme_color_override("font_color", Color("fff6df"))
	status.add_theme_font_size_override("font_size", 18)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(status)
	var top = HBoxContainer.new()
	top.position = Vector2(14,112)
	ui.add_child(top)
	button("Notebook",show_notebook,top)
	button("Bag",show_inventory,top)
	button("Map",show_map,top)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	prompt.position = Vector2(-150,40)
	prompt.size = Vector2(300,70)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_stylebox_override("normal", chip_style(0.7))
	prompt.add_theme_color_override("font_color", Color("fff6df"))
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.hide()
	ui.add_child(prompt)
	var cross = Label.new()
	cross.text = "+"
	cross.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
	cross.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-7,-34)
	cross.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(cross)
	toast_label = Label.new()
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast_label.position = Vector2(-170,168)
	toast_label.size = Vector2(340,40)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal", chip_style(0.78))
	toast_label.add_theme_color_override("font_color", Color("ffe9a8"))
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.modulate.a = 0.0
	ui.add_child(toast_label)
	var move = Label.new()
	move.text = "MOVE\nDrag here"
	move.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	move.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	move.add_theme_constant_override("outline_size", 6)
	move.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	move.position = Vector2(30,-156)
	move.size = Vector2(150,100)
	move.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(move)
	interact_button = button("Interact",interact,ui)
	interact_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.position = Vector2(-160,-138)
	interact_button.size = Vector2(140,64)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_right = -18
	panel.offset_top = 185
	panel.offset_bottom = -35
	ui.add_child(panel)
	var margin = MarginContainer.new()
	for edge in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+edge,16)
	panel.add_child(margin)
	var scroll = ScrollContainer.new()
	margin.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation",12)
	scroll.add_child(content)
	panel.hide()
	marker = MeshInstance3D.new()
	var ring = CylinderMesh.new()
	ring.top_radius = 0.6
	ring.bottom_radius = 0.6
	ring.height = 0.02
	ring.radial_segments = 24
	ring.rings = 1
	marker.mesh = ring
	var mm = StandardMaterial3D.new()
	mm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mm.albedo_color = Color(1.0, 0.88, 0.4, 0.55)
	mm.no_depth_test = false
	marker.material_override = mm
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	marker.hide()
	add_child(marker)

func toast(text: String):
	if toast_label == null: return
	toast_label.text = text
	toast_label.modulate.a = 1.0
	toast_time = 2.6

func clear_panel(title: String):
	joy = Vector2.ZERO
	move_finger = -1
	look_finger = -1
	mouse_look = false
	left_down = false
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()
	panel.show()
	text_line(title,26)

func text_line(text: String, font_size: int = 20) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(label)
	return label

func close_panel():
	panel.hide()
	lesson = ""

func show_intro():
	clear_panel("TuJuJu Studios\nVarnak Island")
	text_line("Your friend Neri is somewhere on this island. Learn Varnak through objects, requests and clues to find them.")
	button("Explore",close_panel,content)
	text_line("Portrait controls: drag the lower left to walk; swipe the right side to look. Approach an object or person and tap Interact.\n\nDesktop: W/S walk, A/D sidestep, left/right arrows turn, drag with the mouse to look around. Walk up to an object or person, then click it or press E.\n\nNorth is along the main path. Notebook meanings are optional hints. Progress saves automatically.")
	text_line("Things to try: talk to everyone and ask follow-up questions, knock on the doors, count the piles, try fishing, and build new words in the notebook workshop.")

func learn(word: String):
	if words.has(word) and not discovered.has(word):
		discovered.append(word)
		toast("New word: " + word)

func complete(id: String):
	if not completed.has(id): completed.append(id)
	if id == "bridge" or id == "meal": refresh_world()
	save_game()

func objective() -> String:
	for q in quests:
		if not completed.has(q[0]): return q[1]
	return "Neri found. Keep exploring and practicing Varnak."

func zone_name(p: Vector3) -> String:
	if p.z > 26: return "The harbor"
	if p.z > -6: return "teka: the village"
	if p.z > -20: return "The forest path"
	if p.z > -26.5: return "mora: the river"
	if p.z > -36: return "The far bank"
	return "The northern cove"

# ------------------------------------------------------------ frame loop

func _process(delta):
	clock += delta
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time < 0.6: toast_label.modulate.a = maxf(toast_time / 0.6, 0.0)
	for c in clouds:
		c.position.x += delta * 0.9
		if c.position.x > 110: c.position.x = -110
	for b in butterflies:
		var t = clock * b["a"] + b["p"]
		var cpos: Vector3 = b["c"]
		var np = Vector3(cpos.x + sin(t) * b["r2"], 0.9 + sin(t * 1.7) * 0.35, cpos.z + cos(t * 0.8) * b["r2"])
		var node = b["node"] as Node3D
		var dir = np - node.position
		node.position = np
		if dir.length() > 0.001: node.rotation.y = atan2(dir.x, dir.z)
		var flap = sin(clock * 22.0 + b["p"]) * 0.9
		(b["l"] as Node3D).rotation.z = flap
		(b["r"] as Node3D).rotation.z = -flap
	for g in gulls:
		var t = clock * 0.25 + g["p"]
		var node = g["node"] as Node3D
		var np = Vector3(sin(t) * g["rad"], g["h"] + sin(t * 2.0), cos(t) * g["rad"] - 5.0)
		var dir = np - node.position
		node.position = np
		if dir.length() > 0.001: node.rotation.y = atan2(dir.x, dir.z)
		var flap = sin(clock * 4.0 + g["p"]) * 0.5
		(g["l"] as Node3D).rotation.z = flap
		(g["r"] as Node3D).rotation.z = -flap
	if boat_node:
		boat_node.position.y = 0.04 + sin(clock * 1.3) * 0.04
		boat_node.rotation.z = sin(clock * 1.1) * 0.025
		boat_node.rotation.x = sin(clock * 0.9 + 1.0) * 0.015
	if tent_node:
		var fl = tent_node.get_meta("flame") as Node3D
		fl.scale = Vector3(1.0 + sin(clock * 11.0) * 0.12, 1.0 + sin(clock * 13.0 + 1.0) * 0.18, 1.0 + sin(clock * 9.0) * 0.12)
	animate_people(delta)
	animate_animals(delta)
	animate_items()
	update_marker()

func animate_people(delta: float):
	var idx = 0
	for e in entities:
		if e["kind"] != "npc": continue
		idx += 1
		var node = e["node"] as Node3D
		var d = player.position - node.position
		var yaw = sin(clock * 0.35 + float(idx)) * 0.12
		var near = Vector2(d.x, d.z).length() < 9.0
		if near: yaw = atan2(d.x, d.z)
		node.rotation.y = lerp_angle(node.rotation.y, yaw, minf(delta * 3.0, 1.0))
		var arms: Array = node.get_meta("arms")
		var talk = 0.0
		if not target.is_empty() and target.get("id", "") == e["id"]: talk = 0.5
		var swing = 0.06 + talk * 0.5
		(arms[0] as Node3D).rotation.x = sin(clock * (1.2 + talk * 3.0) + idx) * swing
		(arms[1] as Node3D).rotation.x = -sin(clock * (1.2 + talk * 3.0) + idx) * swing
		(node.get_meta("body") as Node3D).scale.y = 1.0 + sin(clock * 1.6 + idx) * 0.008
		(node.get_meta("head") as Node3D).rotation.z = sin(clock * 0.7 + idx) * 0.04

func animate_items():
	var i = 0
	for e in entities:
		if e["kind"] != "item": continue
		i += 1
		var node = e["node"] as Node3D
		node.position.y = 0.06 + sin(clock * 2.0 + i) * 0.05
		node.rotation.y = clock * 0.7 + i

func animate_animals(delta: float):
	for a in animals:
		var e = a["e"]
		var node = e["node"] as Node3D
		var home: Vector3 = e["home"]
		match a["kind"]:
			"fish":
				a["wait"] -= delta
				var t = -a["wait"]
				if a["wait"] > 0.0:
					node.position.y = -0.4
				elif t < 0.9:
					var u = t / 0.9
					node.position.y = -0.05 + sin(u * PI) * 1.0
					node.rotation.x = lerpf(0.9, -0.9, u)
				else:
					a["wait"] = randf_range(2.5, 5.5)
					node.position.y = -0.4
			_:
				var moving = false
				a["wait"] -= delta
				var to: Vector3 = a["tp"] - node.position
				to.y = 0.0
				if a["wait"] <= 0.0:
					if to.length() > 0.15:
						moving = true
						var step = to.normalized() * a["speed"] * delta
						node.position += step
						node.rotation.y = lerp_angle(node.rotation.y, atan2(to.x, to.z), minf(delta * 6.0, 1.0))
					else:
						a["wait"] = randf_range(1.0, 3.5)
						var ang = randf() * TAU
						var r = randf() * a["radius"]
						a["tp"] = home + Vector3(cos(ang) * r, 0, sin(ang) * r)
				match a["kind"]:
					"bird":
						var wings: Array = node.get_meta("wings")
						var flap = sin(clock * (22.0 if moving else 3.0)) * (0.7 if moving else 0.15)
						(wings[0] as Node3D).rotation.z = flap
						(wings[1] as Node3D).rotation.z = -flap
						node.position.y = 0.05 + (absf(sin(clock * 9.0)) * 0.12 if moving else 0.0)
					"dog":
						var tail = node.get_meta("tail") as Node3D
						tail.rotation.y = sin(clock * 14.0) * 0.6
						node.position.y = absf(sin(clock * 10.0)) * 0.05 if moving else 0.0
					"horse":
						var tail = node.get_meta("tail") as Node3D
						tail.rotation.z = sin(clock * 3.0) * 0.15
						node.position.y = absf(sin(clock * 5.0)) * 0.04 if moving else 0.0

func update_marker():
	if target.is_empty() or panel.visible:
		marker.hide()
		return
	var node = target["node"] as Node3D
	marker.show()
	marker.position = Vector3(node.position.x, 0.04, node.position.z)
	var pulse = 1.0 + sin(clock * 4.0) * 0.1
	var base = 1.0
	if target["kind"] == "item": base = 0.55
	elif target["kind"] == "object": base = 0.8
	elif target["id"] == "horse": base = 1.3
	marker.scale = Vector3(base * pulse, 1, base * pulse)

func _physics_process(delta):
	save_clock += delta
	if save_clock > 8:
		save_game()
		save_clock = 0
	status.text = objective()
	if panel.visible: return
	var axis = joy
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): axis.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): axis.y += 1
	if Input.is_physical_key_pressed(KEY_A): axis.x -= 1
	if Input.is_physical_key_pressed(KEY_D): axis.x += 1
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_Q): player.rotation.y += 1.9 * delta
	if Input.is_physical_key_pressed(KEY_RIGHT): player.rotation.y -= 1.9 * delta
	axis = axis.limit_length()
	var direction = player.basis * Vector3(axis.x,0,axis.y)
	player.velocity.x = direction.x * 4
	player.velocity.z = direction.z * 4
	player.velocity.y -= 18 * delta
	if player.is_on_floor(): player.velocity.y = 0
	player.move_and_slide()
	player.position.x = clampf(player.position.x,-36,36)
	player.position.z = clampf(player.position.z,-45,45)
	var z = zone_name(player.position)
	if z != zone:
		if zone != "": toast(z)
		zone = z
	target = {}
	var best = 3.4
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var distance = player.position.distance_to(node.position)
		if distance < best:
			best = distance
			target = e
	hint_time -= delta
	if hint_time > 0.0: pass
	elif target.is_empty(): prompt.text = ""
	else: prompt.text = display_name(target) + "\n(click it, press E, or tap Interact)"
	prompt.visible = prompt.text != ""
	interact_button.disabled = target.is_empty()

func display_name(e: Dictionary) -> String:
	if e["kind"] == "npc": return str(e["id"]).capitalize()
	return str(e.get("word", ""))

# ------------------------------------------------------------ input

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE: close_panel()
		if event.keycode == KEY_E and not panel.visible: interact()
	if panel.visible: return
	var size = get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < size.x * 0.46 and event.position.y > size.y * 0.6 and move_finger == -1:
				move_finger = event.index
				joy_origin = event.position
			elif event.position.x > size.x * 0.46 and look_finger == -1:
				look_finger = event.index
		else:
			if event.index == move_finger:
				move_finger = -1
				joy = Vector2.ZERO
			if event.index == look_finger: look_finger = -1
	if event is InputEventScreenDrag:
		if event.index == move_finger: joy = ((event.position-joy_origin)/65).limit_length()
		if event.index == look_finger: look(event.relative)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_look = event.pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_down = true
			left_drag = 0.0
		else:
			if left_down and left_drag < 8.0: click_pick(event.position)
			left_down = false
	if event is InputEventMouseMotion:
		if mouse_look: look(event.relative)
		elif left_down:
			left_drag += event.relative.length()
			if left_drag >= 8.0: look(event.relative)

func click_pick(pos: Vector2):
	var best_e = {}
	var best_d = 70.0
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var p = node.global_position + Vector3(0,0.9,0)
		if camera.is_position_behind(p): continue
		var d = camera.unproject_position(p).distance_to(pos)
		if d < best_d:
			best_d = d
			best_e = e
	if best_e.is_empty(): return
	var node2 = best_e["node"] as Node3D
	if player.position.distance_to(node2.position) <= 3.4:
		target = best_e
		interact()
	else:
		prompt.text = "Too far away. Walk closer, then click again."
		prompt.show()
		hint_time = 2.5

func look(amount: Vector2):
	player.rotation.y -= amount.x * 0.004
	camera.rotation.x = clampf(camera.rotation.x - amount.y * 0.004,-1.05,1.05)

# ------------------------------------------------------------ interaction

func interact():
	if target.is_empty(): return
	var e = target.duplicate()
	match e["kind"]:
		"npc": talk(e["id"])
		"item":
			learn(e["word"])
			clear_panel(e["word"])
			text_line("You examine the object. Its name is now in your notebook.")
			button("Pick up",func():
				inventory.append(e["id"])
				e["node"].hide()
				save_game()
				close_panel(),content)
			button("Return",close_panel,content)
		"observe": observe(e)
		_: examine(e)

func examine(e: Dictionary):
	var id: String = e["id"]
	if id.begins_with("house"):
		door_puzzle(id)
		return
	if id.begins_with("sign") and id != "sign_village" and id != "sign_river":
		sentence_card("sign_north")
		return
	match id:
		"boat": sentence_card("boat_small")
		"table":
			learn("tab")
			learn("puka")
			sentence_card("book_table")
		"gira":
			if completed.has("bridge"): sentence_card("gira_safe")
			else: sentence_card("gira_broken")
		"field": sentence_card("field_big")
		"sign_village": sentence_card("sign_village")
		"sign_river": sentence_card("sign_river")
		"cairn", "flowers", "basket": count_puzzle(id)
		_: message(e["word"], "You look closely, but there is nothing more to learn here yet.")

func observe(e: Dictionary):
	var id: String = e["id"]
	learn(e["word"])
	match id:
		"bird": sentence_card("bird_sky")
		"dog": sentence_card("dog_runs")
		"horse": sentence_card("horse_fast")
		"fish":
			sentence_card("fish_river", close_panel)
			button("Try fishing", fishing, content)

func ask(situation: String, options: Array, correct: int, on_right: Callable, right_text: String, wrong_text: String, back: Callable = Callable(), extra: Callable = Callable()):
	text_line(situation)
	var answer: String = options[correct]
	var order: Array = options.duplicate()
	order.shuffle()
	var buttons: Array = []
	var feedback = Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	feedback.add_theme_font_size_override("font_size", 19)
	for opt in order:
		buttons.append(button(opt, _answer.bind(opt, answer, buttons, feedback, on_right, right_text, wrong_text, back, extra), content))
	content.add_child(feedback)
	last_skip = button("Skip", back if back.is_valid() else close_panel, content)

func _answer(opt: String, answer: String, buttons: Array, feedback: Label, on_right: Callable, right_text: String, wrong_text: String, back: Callable, extra: Callable):
	if opt == answer:
		for b in buttons: b.disabled = true
		feedback.text = "Correct. " + right_text
		feedback.add_theme_color_override("font_color", Color("2f6b2f"))
		if on_right.is_valid(): on_right.call()
		if extra.is_valid(): extra.call()
		last_skip.text = "Return"
		content.move_child(last_skip, content.get_child_count() - 1)
	else:
		feedback.text = "Not quite. " + wrong_text
		feedback.add_theme_color_override("font_color", Color("8a2f1f"))

func choice_puzzle(title: String, situation: String, options: Array, correct: int, on_right: Callable, right_text: String, wrong_text: String, back: Callable = Callable(), extra: Callable = Callable()):
	clear_panel(title)
	ask(situation, options, correct, on_right, right_text, wrong_text, back, extra)

func master(key: String):
	if not mastered.has(key):
		mastered.append(key)
		save_game()

func sentence_card(sid: String, back: Callable = Callable()):
	var s: Dictionary = Data.SENTENCES[sid]
	for w in s["words"]: learn(w)
	clear_panel(s["v"])
	text_line(s["gesture"])
	if not phrases.has(sid):
		phrases.append(sid)
		toast("Added to your phrasebook")
		save_game()
	var options: Array = [s["en"]]
	options.append_array(s["wrong"])
	ask("What do you think this means?", options, 0, func(): master("s:" + sid), "\n" + s["parts"] + "\n= " + s["en"], "Look at the gesture again and compare the word endings.", back)

func door_puzzle(id: String):
	var d: Dictionary = Data.DOORS[id]
	for w in d["words"]: learn(w)
	learn("dom")
	var scene = "A closed door. What request would you say?"
	if id == "house4": scene = "An open doorway. What request would you say?"
	choice_puzzle("dom: a house", d["situation"] + "\n\n" + scene, d["options"], d["correct"], func():
		if not solved.has(id): solved.append(id)
		master("d:" + id)
		refresh_world()
		save_game(), d["right"], d["wrong"])

func count_puzzle(id: String):
	var c: Dictionary = Data.COUNTS[id]
	var options: Array = [c["numword"]]
	options.append_array(c["wrongs"])
	var phrase = c["numword"].capitalize() + " " + c["noun"] + "."
	choice_puzzle(c["noun"], "You count " + str(c["n"]) + " " + c["en"] + " here. Which number word is right?", options, 0, func():
		learn(c["noun"])
		learn(c["numword"])
		master("w:" + c["numword"])
		save_game(), phrase + " (" + str(c["n"]) + " " + c["en"] + ")", "Count again, then try another number word. They are in your notebook once you learn them.")

func fishing():
	choice_puzzle("tari-nuk: fishing", "You crouch at the bank and cast a line. You want to say that you are fishing in general. A fish is not the focus, so the noun joins the verb. Which form fits?",
		["Na-tari-nuk-im.", "Tari k-i-nuk-ak-pa-da.", "Ma-na-tari-nuk-ki-da."], 0,
		func():
			learn("tari-nuk")
			learn("nuk"),
		"Na-tari-nuk-im means I am fishing. The noun tari sits right before the root nuk, so the verb is intransitive and takes only na-.",
		"Look for the form where tari sits inside the verb before nuk and only na- (I) marks the person.", Callable(),
		func(): button("Now catch one", catch_fish, content))

func catch_fish():
	choice_puzzle("A bite!", "A fish is on the line and you pull it out. Now you want to say that you caught one particular fish. Which sentence says it?",
		["Anke tari k-i-nuk-ak-pa-da.", "Na-tari-nuk-ak-pa-da.", "Tari na-nuk-ak-pa-da."], 0,
		func():
			fish_caught += 1
			master("w:nuk")
			save_game(),
		"Anke tari k-i-nuk-ak-pa-da: anke is you acting on something (ergative -ke), k- is I the agent and i- is the fish as patient. A specific fish is not incorporated.",
		"A particular fish stays a separate noun, and the one acting takes -ke.")

func neri_story():
	choice_puzzle("Neri's story", "Neri mimes a traveler hauling one particular fish out of the river. Which sentence says that the traveler caught the fish?",
		["Kelarke tari i-nuk-ak-pa-da.", "Kelar i-tari-nuk-ak-pa-da.", "Kelar tari i-nuk-ak-pa-da."], 0,
		func():
			learn("kelar")
			learn("nuk")
			master("w:kelar"),
		"Kelarke tari i-nuk-ak-pa-da: the traveler (kelar-ke) acts on a specific fish (tari). Kelar i-tari-nuk-ak-pa-da means the traveler went fishing in general.",
		"The traveler acts on a particular fish, so the traveler takes -ke and tari stays outside the verb.", talk.bind("neri"))

func where_puzzle(id: String):
	var w: Dictionary = Data.WHERE[id]
	learn("hama")
	choice_puzzle("Ti hama ta-esh-ha?", w["gesture"] + "\n\nThe question means Where are you? Answer using " + w["place"] + ".", w["options"], w["correct"], func():
		learn("-ma")
		learn("esh")
		master("w:hama"),
		str(w["options"][w["correct"]]) + " The ending -ma means in or at, and na- marks I.",
		"Match the place word and its ending: -ma means in or at.", talk.bind(id))

func add_topics(id: String):
	match id:
		"ena": topic("Ask about the boat", "boat_small", id)
		"mira":
			topic("Ask about the village", "village_big", id)
			topic("Ask about the food", "food_warm", id)
			topic("Ask what Mira is doing", "mira_cooks", id)
			if completed.has("meal"): topic("Ask about the water", "water_container", id)
		"sanu": topic("Ask about the path", "path_safe", id)
		"tor":
			topic("Ask about the river", "river_small", id)
			button("Answer: where are you?", where_puzzle.bind("tor"), content)
			if completed.has("bridge"):
				topic("Ask about the bridge", "gira_safe", id)
				topic("Ask who built it", "tor_built", id)
		"lira":
			button("Answer: where are you?", where_puzzle.bind("lira"), content)
			topic("Ask about the dog", "dog_runs", id)
		"oren":
			topic("Ask about the horse", "horse_fast", id)
			topic("Ask about the tree", "tree_tall", id)
		"neri":
			if completed.has("evidence"):
				button("Ask Neri for a story", neri_story, content)
				button("Practice with Neri", show_practice, content)

func topic(label: String, sid: String, npc: String):
	button(label, func(): sentence_card(sid, talk.bind(npc)), content)

func talk(id: String):
	match id:
		"ena":
			learn("kel")
			learn("anni")
			learn("tekaru")
			clear_panel("Ena")
			text_line("Ena points to your bag, then gestures toward you.\n\n“Kel.”\n\nTry telling Ena: “My bag.”")
			button("Anni kel",func():
				if inventory.has("own_bag"):
					complete("belongings")
					message("Ena nods", "“Tekaru.” Ena points along the path toward the village. Mira is preparing a meal there.")
				else: message("Ena points again", "Pick up the brown bag beside Ena, then try again."),content)
			button("Kel anni",func(): message("Ena demonstrates","Ena places a hand on their own bag: “Anni kel.” The possessor comes before the object."),content)
		"mira":
			learn("tnaveno")
			for word in ["wak","guro","kor"]: learn(word)
			clear_panel("Mira")
			text_line("Mira points to a pitcher, some fruit and a bowl.\n\n“Wak. Guro. Kor. Tnaveno.”")
			button("Offer supplies",func():
				if has_items(["water","fruit","container"]):
					consume(["water","fruit","container"])
					complete("meal")
					message("A shared meal","Mira smiles and sets the table. Sanu has lost a bag in the forest beyond the village.")
				elif completed.has("meal"): message("Mira smiles","The meal is ready. Sanu is near the forest path.")
				else: offer_help(["water","fruit","container"]),content)
		"sanu":
			learn("nalum")
			learn("talumo")
			clear_panel("Sanu")
			text_line("Sanu points into the forest, makes a walking gesture and says:\n\n“Nalum. Kel.”\n\nThen Sanu points toward you: “Talumo.”")
			button("Offer the forest bag",func():
				if inventory.has("forest_bag"):
					consume(["forest_bag"])
					complete("bag")
					message("Sanu recognizes the bag","Sanu thanks you and points north to Tor at the river crossing.")
				else: message("A gesture toward the trees","Look for a blue bag west of the forest path. North is forward from the harbor."),content)
		"tor":
			for word in ["murak","sek","lin","tnaveno"]: learn(word)
			clear_panel("Tor")
			text_line("Tor examines the crossing and points to three materials.\n\n“Murak. Sek. Lin. Tnaveno.”")
			button("Offer repair materials",func():
				if has_items(["wood","stone","rope"]):
					consume(["wood","stone","rope"])
					complete("bridge")
					message("The crossing is repaired","Tor secures the planks. Ask Tor about Neri, and compare the accounts of Lira and Oren.")
				elif completed.has("bridge"): message("Tor nods","The crossing is secure. You can ask about Neri.")
				else: offer_help(["wood","stone","rope"]),content)
			button("Ask about Neri",func(): account("tor","italpada","Tor points to their eyes, then the river crossing. Tor personally saw Neri arrive."),content)
		"lira": account("lira","italpanu","Lira gestures to someone in the distance. Another resident told Lira about Neri's arrival.")
		"oren": account("oren","italpashi","Oren points to fresh footprints in the sand. Oren inferred that Neri arrived.")
		"neri":
			clear_panel("Neri at the northern cove")
			if completed.has("evidence"):
				complete("cove")
				text_line("You found your friend and understood the clues. Neri shows you a notebook of island stories. Your Varnak adventure has begun.")
				button("Practice evidence again",show_evidence,content)
			else:
				text_line("You found Neri by exploring. To understand the journey, compare Tor's, Lira's and Oren's accounts, then return.")
	add_topics(id)
	button("Return to island",close_panel,content)

func account(id: String, phrase: String, gesture: String):
	learn(phrase)
	complete("heard_"+id)
	clear_panel(id.capitalize())
	text_line("“Neri " + phrase + ".”\n\n" + gesture)
	if completed.has("heard_tor") and completed.has("heard_lira") and completed.has("heard_oren"):
		button("Compare the evidence",show_evidence,content)
	button("Return",close_panel,content)

func show_evidence():
	clear_panel("Which account was witnessed?")
	text_line("Three speakers used the same arrival root but different endings. Who saw Neri arrive?")
	var options = ["Lira: italpanu", "Tor: italpada", "Oren: italpashi"]
	options.shuffle()
	for option in options:
		button(option,check_evidence.bind(option),content)
	button("Return",close_panel,content)

func check_evidence(option: String):
	if option.begins_with("Tor"):
		complete("evidence")
		learn("bei")
		message("You understood the source","The ending da marks direct knowledge. Follow the main path bei, north, past the crossing to the cove.")
	else:
		message("Compare the gestures","Lira heard a report. Oren found footprints. Tor pointed to their eyes. Revisit the notebook or compare again.")
		button("Try again",show_evidence,content)

func has_items(items: Array) -> bool:
	for item in items:
		if not inventory.has(item): return false
	return true

func consume(items: Array):
	for item in items: inventory.erase(item)

func offer_help(items: Array):
	var missing: Array = []
	for id in items:
		if not inventory.has(id):
			for e in entities:
				if e["id"] == id: missing.append(e["word"])
	message("The request is repeated", "Still needed: " + ", ".join(missing) + ". Explore beside the main path. You can reveal meanings in the notebook.")

func message(title: String, body: String):
	clear_panel(title)
	text_line(body)
	button("Return",close_panel,content)

# ------------------------------------------------------------ notebook, practice, workshop

func short_gloss(word: String) -> String:
	return str(words.get(word, "")).split(" (")[0]

func show_notebook():
	clear_panel("Field notebook")
	text_line("Collected forms. Tap a word to reveal its meaning and parts.  Words: " + str(discovered.size()) + "   Phrases: " + str(phrases.size()))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	content.add_child(row)
	var b1 = button("Phrasebook", show_phrasebook, row)
	var b2 = button("Workshop", show_workshop, row)
	var b3 = button("Practice", show_practice, row)
	for b in [b1, b2, b3]: b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if discovered.is_empty(): text_line("Examine objects and talk to residents to collect words.")
	for word in discovered:
		button(word + ("  ✓" if mastered.has("w:" + word) else ""),reveal_word.bind(word),content)
	button("Return",close_panel,content)

func reveal_word(word: String):
	clear_panel(word)
	text_line("What do you think this form means?")
	var guess = LineEdit.new()
	guess.placeholder_text = "Write your guess here"
	guess.text = guesses.get(word, "")
	guess.custom_minimum_size.y = 54
	content.add_child(guess)
	button("Save guess",func():
		guesses[word] = guess.text
		save_game(),content)
	button("Reveal meaning",func(): text_line(words.get(word,"")),content)
	text_line("Use this meaning as a hint, then look for the form in another encounter.")
	button("Notebook",show_notebook,content)
	button("Return to island",close_panel,content)

func show_phrasebook():
	clear_panel("Phrasebook")
	if phrases.is_empty(): text_line("Talk to residents, read signs and examine things to collect phrases.")
	else: text_line("Tap a phrase to see it again.")
	for sid in phrases:
		if Data.SENTENCES.has(sid):
			button(Data.SENTENCES[sid]["v"] + ("  ✓" if mastered.has("s:" + sid) else ""), func(): sentence_card(sid, show_phrasebook), content)
	button("Notebook",show_notebook,content)
	button("Return to island",close_panel,content)

func show_practice():
	var pool: Array = []
	for w in discovered:
		if words.has(w): pool.append(w)
	if pool.size() < 3 and phrases.is_empty():
		message("Practice", "Collect a few more words first. Examine objects and talk to residents.")
		return
	if not phrases.is_empty() and (pool.size() < 3 or randf() < 0.4): practice_phrase()
	else: practice_word(pool)

func practice_word(pool: Array):
	var w: String = pool[randi() % pool.size()]
	var good = short_gloss(w)
	var options: Array = [good]
	var others: Array = pool.duplicate()
	others.shuffle()
	for o in others:
		var g = short_gloss(o)
		if g != good and not options.has(g) and options.size() < 3: options.append(g)
	var fillers = ["water", "bridge", "bag", "river", "path", "boat", "stone"]
	for f in fillers:
		if f != good and not options.has(f) and options.size() < 3: options.append(f)
	choice_puzzle("Practice", "What does “" + w + "” mean?", options, 0, func(): master("w:" + w), "That is “" + str(words[w]) + "”.", "Check the notebook for a hint, then try the next one.", show_notebook, func(): button("Next question", show_practice, content))

func practice_phrase():
	var sid: String = phrases[randi() % phrases.size()]
	var s: Dictionary = Data.SENTENCES[sid]
	var options: Array = [s["en"]]
	options.append_array(s["wrong"])
	choice_puzzle("Practice", "What does this mean?\n\n" + s["v"], options, 0, func(): master("s:" + sid), s["parts"], "Think about the endings: -ma, -ru, -ta, -da and -im each add meaning.", show_notebook, func(): button("Next question", show_practice, content))

func show_workshop():
	clear_panel("Word workshop")
	text_line("Attach a case ending to a noun and see how the meaning changes.")
	var any = false
	for root in Data.NOUNS.keys():
		if discovered.has(root):
			any = true
			button(root + "  (" + Data.NOUNS[root][0] + ")", workshop_noun.bind(root), content)
	if any: button("Challenge me", workshop_challenge, content)
	else: text_line("Collect a few nouns first, such as wak, guro or tari.")
	button("Notebook",show_notebook,content)
	button("Return to island",close_panel,content)

func suffix_ok(root: String, suf: String) -> bool:
	return not (suf == "ir" and root.ends_with("i"))

func suffix_meaning(root: String, suf: String) -> String:
	var noun: Array = Data.NOUNS[root]
	var arg = noun[1] if suf == "ir" or suf == "du" else noun[0]
	return Data.SUFFIXES[suf] % arg

func workshop_noun(root: String):
	clear_panel(root + ": " + Data.NOUNS[root][0])
	text_line("Choose an ending.")
	var result = Label.new()
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", 22)
	for suf in Data.SUFFIXES.keys():
		if not suffix_ok(root, suf): continue
		button("-" + suf, func():
			learn("-" + suf)
			result.text = root + suf + "\n" + root + " + " + suf + "  =  " + suffix_meaning(root, suf), content)
	content.add_child(result)
	button("Back to workshop", show_workshop, content)

func workshop_challenge():
	var roots: Array = []
	for r in Data.NOUNS.keys():
		if discovered.has(r): roots.append(r)
	var root: String = roots[randi() % roots.size()]
	var sufs: Array = []
	for s in Data.SUFFIXES.keys():
		if suffix_ok(root, s): sufs.append(s)
	sufs.shuffle()
	var options: Array = [root + sufs[0], root + sufs[1], root + sufs[2]]
	choice_puzzle("Workshop challenge", "How do you say “" + suffix_meaning(root, sufs[0]) + "”?", options, 0, func():
		learn("-" + sufs[0])
		master("w:-" + sufs[0]), root + " + " + sufs[0] + " = " + root + sufs[0] + ".", "Check the endings: -ma in, -ru to, -ta from, -li with, -ni of, -ir plural.", show_workshop, func(): button("Another challenge", workshop_challenge, content))

# ------------------------------------------------------------ inventory, guide, saving

func show_inventory():
	clear_panel("Your bag")
	if inventory.is_empty() and fish_caught == 0: text_line("Your bag is empty.")
	for id in inventory:
		for e in entities:
			if e["id"] == id: text_line(e["word"])
	if fish_caught > 0: text_line("tari × " + str(fish_caught))
	button("Return",close_panel,content)

func show_map():
	clear_panel("Island guide")
	text_line("NORTH\n\nNorthern cove: Neri\nFar bank: Oren\nRiver crossing: Tor\nForest path: Sanu\nVillage: Mira and Lira\nHarbor: Ena\n\nSOUTH\n\nThe light path connects all areas. North is marked bei on the signs.")
	text_line("Current objective:\n" + objective())
	text_line("Progress:  " + str(discovered.size()) + " words,  " + str(phrases.size()) + " phrases,  " + str(solved.size()) + " of 4 doors,  " + str(mastered.size()) + " mastered.")
	button("Return",close_panel,content)
	button("Reset progress",confirm_reset,content)

func confirm_reset():
	clear_panel("Start a new journey?")
	text_line("This clears the saved inventory, notebook and quest progress.")
	button("Keep current game",show_map,content)
	button("Start fresh",func():
		inventory.clear()
		guesses.clear()
		discovered.clear()
		completed.clear()
		mastered.clear()
		phrases.clear()
		solved.clear()
		fish_caught = 0
		for e in entities: e["node"].show()
		player.position = Vector3(0,0.1,36)
		player.rotation = Vector3.ZERO
		camera.rotation = Vector3.ZERO
		refresh_world()
		save_game()
		show_intro(),content)

func save_game():
	var file = FileAccess.open(SAVE,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"guesses":guesses,"inventory":inventory,"discovered":discovered,"completed":completed,"mastered":mastered,"phrases":phrases,"solved":solved,"fish":fish_caught,"position":[player.position.x,player.position.y,player.position.z],"yaw":player.rotation.y,"pitch":camera.rotation.x}))

func load_game():
	if not FileAccess.file_exists(SAVE): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	if not data is Dictionary: return
	guesses = data.get("guesses",{})
	inventory = data.get("inventory",[])
	discovered = data.get("discovered",[])
	completed = data.get("completed",[])
	mastered = data.get("mastered",[])
	phrases = data.get("phrases",[])
	solved = data.get("solved",[])
	fish_caught = int(data.get("fish",0))
	var p = data.get("position",[0,0.1,36])
	player.position = Vector3(p[0],p[1],p[2])
	player.rotation.y = data.get("yaw",0)
	camera.rotation.x = data.get("pitch",0)
	var used: Array = []
	if completed.has("meal"): used.append_array(["water","fruit","container"])
	if completed.has("bag"): used.append("forest_bag")
	if completed.has("bridge"): used.append_array(["wood","stone","rope"])
	for e in entities:
		if inventory.has(e["id"]) or used.has(e["id"]): e["node"].hide()
	refresh_world()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player): save_game()
