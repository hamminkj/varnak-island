extends Node3D

const Art = preload("res://art.gd")
const Data = preload("res://data.gd")
const T = preload("res://terrain.gd")
const SAVE = "user://varnak_island.json"
const REACH = 4.0
const WALK_RANGE = 70.0
# Paths painted on the ground (x1, z1, x2, z2). The main north-south path along x = 0 is drawn by the shader.
const PATHS = [
	Vector4(-2, 18, -38, 15), Vector4(-48, 4, -47, -3), Vector4(-44, -5, -31, -17), Vector4(-30, -17, -30, -29),
	Vector4(-30, -29, -46, -33), Vector4(-46, -33, -59, -37), Vector4(2, -10, 44, -10), Vector4(44, -10, 52, -7),
	Vector4(52, -7, 73, -7), Vector4(50, -7, 46, 14), Vector4(46, 14, 62, 20), Vector4(44, -10, 52, -19),
	Vector4(52, -19, 52, -33), Vector4(52, -33, 34, -40), Vector4(34, -40, 7, -36),
	Vector4(-50, 20, -60, 33), Vector4(52, -33, 61, -33.5)
]
const DAY_LEN = 480.0
const FERRY_HARBOR = Vector3(1.8, 0, 44.6)
const FERRY_ISLET = Vector3(49.8, 0, 66.0)
const STARS = [Vector3(-14, 0, -46), Vector3(-30, 0, -45), Vector3(66, 0, 31), Vector3(55, 0, 86), Vector3(-30, 0, 41), Vector3(30, 0, 40), Vector3(-76, 0, -6), Vector3(-71, 0, 47)]
const HIDE_SPOTS = {"rin": Vector3(-50.5, 0, -13.4), "ola": Vector3(-42.4, 0, 19.9)}
const MAP_X0 = -90.0
const MAP_X1 = 90.0
const MAP_Z0 = -56.0
const MAP_Z1 = 94.0

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
var touches: Dictionary = {}
var last_touch_time: float = -10.0
var mouse_look: bool = false
var left_down: bool = false
var left_drag: float = 0.0
var hint_time: float = 0.0
var toast_time: float = 0.0
var zone: String = ""
var zone_id: String = ""
var entities: Array = []
var inventory: Array = []
var discovered: Array = []
var completed: Array = []
var mastered: Array = []
var phrases: Array = []
var solved: Array = []
var visited: Array = []
var fish_caught: int = 0
var last_skip: Button
var target: Dictionary = {}
var hover: Dictionary = {}
var walk_to: Dictionary = {}
var walk_check: float = 0.0
var walk_last: float = 0.0
var last_safe: Vector3 = Vector3(0, 0.1, 36)
var clock: float = 0.0
var save_clock: float = 0.0
var lesson: String = ""
var guesses: Dictionary = {}
var houses: Dictionary = {}
var bridge_info: Dictionary = {}
var table_node: Node3D
var boat_node: Node3D
var tent_node: Node3D
var lighthouse_node: Node3D
var lookout_node: Node3D
var animals: Array = []
var butterflies: Array = []
var clouds: Array = []
var gulls: Array = []
var steam: Array = []
var blocked: Array = []
var avoid: Array = []
var map_tex: ImageTexture
var top_row: HBoxContainer
var status_small: Label
var cloud_mat: StandardMaterial3D
var hud_small: bool = false
var last_objective: String = ""
var gin: int = 0
var env: Environment
var psm: ProceduralSkyMaterial
var sun: DirectionalLight3D
var day_t: float = 0.12
var night: float = 0.0
var time_word: String = ""
var stars_mat: StandardMaterial3D
var stars_node: Node3D
var moon: MeshInstance3D
var fireflies: Array = []
var shooting: MeshInstance3D
var shoot_t: float = -1.0
var shoot_cd: float = 15.0
var shoot_from: Vector3
var shoot_dir: Vector3
var fireworks: Array = []
var firework_cd: float = 2.0
var rain_fx: CPUParticles3D
var rain_amt: float = 0.0
var raining: float = 0.0
var weather_cd: float = 170.0
var rainbow_mi: MeshInstance3D
var rainbow_t: float = 0.0
var whale_node: Node3D
var whale_t: float = -1.0
var whale_cd: float = 75.0
var whale_pos: Vector3
var whale_dir: Vector3
var whale_seen: bool = false
var splash: CPUParticles3D
var riding: bool = false
var ride_t: float = 0.0
var ride_path: Array = []
var ride_dest: Vector3
var ride_whale: bool = false
var ferry_node: Node3D
var falls_node: Node3D
var chest_node: Node3D
var hiding: Dictionary = {}
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
# id, person, objective text
var side_quests = [
	["market","ketu","Ketu at the market (west) wants mur tari: three fish. Fish at the river, the dock or the lagoon."],
	["school","suri","Answer Suri's four questions at the school, north of the market."],
	["lookout","pomo","Climb the west hill and answer Pomo's direction questions."],
	["healer","vira","Help Vira the healer, east of the village. Her patient needs yok and cha."],
	["lighthouse","yalo","The lighthouse is dark. Bring far (fire) from Neri's campfire to Yalo."],
	["lagoon","desh","Play Desh's drum game at the east lagoon."],
	["riddles","oku","Oku at the old ruins (south-west) has five riddles."],
	["mail","gav","Gav at the harbor needs parcels delivered. Read the labels!"],
	["hide","ola","Rin and Ola at the school want to play hide and seek."],
	["seastars","","Find the eight hai-sao (sea stars) hidden on the beaches."],
	["dog","","The village dog looks hungry. Buy panak (bread) from Ketu and share it."],
	["treasure","tamu","Follow the old map: Gin murak-ni shanma i-esh-da. Tamu at the dock can take you to Sendor."]
]
var secret_quests = ["treasure"]
# skin, hair, hair style, accent
var looks = {
	"ena": [Color("d6ac83"), Color("2b1d14"), 0, Color("e9c46a")],
	"mira": [Color("c68e66"), Color("3b2418"), 2, Color("f2e6c8")],
	"sanu": [Color("e3b98f"), Color("7a4a22"), 3, Color("5b8c5a")],
	"tor": [Color("a87650"), Color("1d1d1d"), 4, Color("c9a46d")],
	"lira": [Color("f0c9a0"), Color("b5651d"), 1, Color("e76f51")],
	"oren": [Color("8d5a3b"), Color("4a4a4a"), 0, Color("a8dadc")],
	"neri": [Color("d9a679"), Color("2e2a5a"), 2, Color("f4a261")],
	"ketu": [Color("b07a52"), Color("2b1d14"), 3, Color("e9c46a")],
	"suri": [Color("e8bf98"), Color("1d1d1d"), 1, Color("f2e6c8")],
	"rin": [Color("c68e66"), Color("3b2418"), 2, Color("e76f51")],
	"ola": [Color("9a6a48"), Color("1d1d1d"), 0, Color("a8dadc")],
	"pomo": [Color("d6ac83"), Color("6b6b6b"), 3, Color("c0392b")],
	"vira": [Color("8d5a3b"), Color("e6e1d6"), 1, Color("9bd06a")],
	"ila": [Color("f0c9a0"), Color("7a4a22"), 2, Color("f4a261")],
	"yalo": [Color("c68e66"), Color("2e2a5a"), 4, Color("f4f1e8")],
	"desh": [Color("7a4a32"), Color("1d1d1d"), 4, Color("2a9d8f")],
	"sair1": [Color("e3b98f"), Color("4a3020"), 1, Color("a78bda")],
	"sair2": [Color("a87650"), Color("1d1d1d"), 0, Color("e9c46a")],
	"sair3": [Color("d9a679"), Color("5a4030"), 3, Color("4f7ca8")],
	"oku": [Color("c68e66"), Color("e6e1d6"), 0, Color("8f5a48")],
	"gav": [Color("e3b98f"), Color("8a3a1a"), 3, Color("2a6f97")],
	"tamu": [Color("8d5a3b"), Color("1d1d1d"), 1, Color("e9c46a")]
}
var names = {"sair1": "sair", "sair2": "sair", "sair3": "sair"}
var house_centers = [Vector3(-9,0,12), Vector3(10,0,7), Vector3(-11,0,1), Vector3(12,0,-4)]
# id, name, centre, radius, travel spawn
var regions = [
	["market", "kur: the market", Vector2(-50, 12), 14.0, Vector3(-44, 0, 13)],
	["school", "senak: the school", Vector2(-47, -5), 9.0, Vector3(-46, 0, 0)],
	["hill", "sang: the west hill", Vector2(-60, -38), 16.0, Vector3(-57, 0, -35)],
	["spring", "The hot spring", Vector2(-44, -21), 7.5, Vector3(-40, 0, -16)],
	["circle", "The stone circle", Vector2(32, -42), 9.0, Vector3(37, 0, -39)],
	["healer", "Vira's garden", Vector2(51, -4), 9.0, Vector3(48, 0, -8)],
	["orchard", "The orchard", Vector2(45, 22), 10.0, Vector3(46, 0, 14)],
	["lagoon", "hai: the east lagoon", Vector2(69, 21), 11.0, Vector3(63, 0, 20)],
	["lighthouse", "fardom: the lighthouse", Vector2(75, -7), 9.0, Vector3(70, 0, -7)],
	["ruins", "The old ruins", Vector2(-62, 40), 11.0, Vector3(-58, 0, 32)],
	["falls", "The waterfall", Vector2(63, -34), 7.0, Vector3(60, 0, -33.5)],
	["islet", "Sendor: the small island", Vector2(50, 80), 13.0, Vector3(48, 0, 71)]
]
var central = {
	"harbor": ["The harbor", Vector3(0, 0, 33)], "village": ["teka: the village", Vector3(0, 0, 16)],
	"forest": ["The forest path", Vector3(0, 0, -11)], "river": ["mora: the river", Vector3(0, 0, -18.5)],
	"farbank": ["The far bank", Vector3(0, 0, -29)], "cove": ["The northern cove", Vector3(1, 0, -38)]
}

func _ready():
	words.merge(Data.WORDS)
	for k in Data.GLOSS_UPDATES.keys(): words[k] = Data.GLOSS_UPDATES[k]
	build_world()
	build_ui()
	load_game()
	refresh_world()
	show_intro()

# ------------------------------------------------------------ world

func gy(x: float, z: float) -> float:
	return maxf(T.height(x, z), -0.08)

func solid(pos: Vector3, size: Vector3, yaw: float = 0.0):
	var body = StaticBody3D.new()
	body.position = pos
	body.rotation_degrees.y = yaw
	var cs = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)

func block(x: float, z: float, r: float):
	blocked.append(Vector3(x, z, r))

func face(from: Vector3, to: Vector3) -> float:
	return rad_to_deg(atan2(to.x - from.x, to.z - from.z))

func entity(id: String, kind: String, word: String, pos: Vector3, color: Color, label_y: float = 1.0, pick: Vector2 = Vector2.ZERO) -> Dictionary:
	var node: Node3D
	var pr = 1.2
	var ph = 1.8
	match kind:
		"npc":
			var look = looks[id]
			node = Art.person(color, look[0], look[1], look[2], look[3])
			label_y = 2.15
			pr = 0.6
			ph = 1.95
		"item":
			node = Art.item_model(id, color)
			node.scale = Vector3.ONE * 1.35
			label_y = 0.95
			pr = 0.75
			ph = 1.2
		"observe":
			node = Art.animal(word)
			label_y = 0.85 if word != "mar" else 2.5
			if word == "tari": label_y = 0.7
			pr = 0.8 if word != "mar" else 1.3
			ph = 1.0 if word != "mar" else 2.2
			if word == "tari":
				pr = 0.9
				ph = 1.6
		"star":
			node = Art.sea_star(color)
			label_y = 0.45
			pr = 0.7
			ph = 0.6
		_:
			node = Node3D.new()
	if pick != Vector2.ZERO:
		pr = pick.x
		ph = pick.y
	if kind != "observe" or word != "tari": pos.y = gy(pos.x, pos.z)
	node.position = pos
	add_child(node)
	var label_text = id.capitalize() if kind == "npc" else word
	if names.has(id): label_text = names[id]
	var label = Art.label3(node, label_text, Vector3(0, label_y / node.scale.y, 0), 38 if kind == "npc" else 34)
	label.visibility_range_end = 34.0 if kind == "npc" else (40.0 if kind == "item" else (7.0 if kind == "star" else 16.0))
	var e = {"id":id,"kind":kind,"word":word,"node":node,"home":pos,"gy":pos.y,"pr":pr,"ph":ph}
	if kind == "item": Art.beacon(node).scale = Vector3.ONE / node.scale.x
	if kind == "npc": e["mark"] = Art.quest_mark(node, 2.75)
	entities.append(e)
	return e

func build_world():
	build_environment()
	build_terrain()
	build_village()
	build_harbor()
	build_river()
	build_cove()
	build_places()
	build_places3()
	build_entities()
	build_forest()
	build_scatter()
	build_sky_life()
	build_player()
	build_night_and_weather()

func build_environment():
	var we = WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	psm = ProceduralSkyMaterial.new()
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
	env.fog_density = 0.003
	env.fog_sky_affect = 0.25
	we.environment = env
	add_child(we)
	sun = DirectionalLight3D.new()
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
	var mesh = T.build_mesh()
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = Art.ground_material(PATHS)
	add_child(mi)
	var body = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	cs.shape = mesh.create_trimesh_shape()
	body.add_child(cs)
	add_child(body)
	var floor_mi = Art.plane(self, Vector3(0, -3.05, 0), Vector2(1400, 1400), Art.mat(Color("0d4660")))
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	Art.plane(self, Vector3(0, -0.08, 0), Vector2(1400, 1400), Art.water_material(Color("0e5a78"), Color("47b9c0"), 0.78))

func near_path(x: float, z: float, d: float) -> bool:
	if absf(x) < d and z > -50.0 and z < 44.0: return true
	var p = Vector2(x, z)
	for s in PATHS:
		if T.seg_dist(p, Vector2(s.x, s.y), Vector2(s.z, s.w)) < d: return true
	return false

func is_blocked(x: float, z: float, pad: float = 0.0) -> bool:
	for b in blocked:
		if Vector2(x - b.x, z - b.y).length() < b.z + pad: return true
	return false

func clearing(x: float, z: float) -> bool:
	if x > -17 and x < 17 and z > -7 and z < 33: return true
	if x > 14 and x < 31 and z > -3 and z < 24: return true
	for r in regions:
		if Vector2(x, z).distance_to(r[2]) < r[3] * 0.85 and r[0] != "hill": return true
	if Vector2(x, z).distance_to(Vector2(-60, -38)) < 6.0: return true
	if Vector2(x, z).distance_to(Vector2(0, -41)) < 9.0: return true
	if Vector2(x, z).distance_to(Vector2(6, -29)) < 4.0: return true
	return false

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
	var placed: Array = []
	for i in range(48):
		var x = rng.randf_range(-30,30)
		if abs(x) < 5: x += 7
		var z = rng.randf_range(-32,-5)
		if near_path(x, z, 3.2) or T.river_dist(x, z) < 4.0 or near_entity(x, z, 2.6): continue
		solid(Vector3(x,1.2,z), Vector3(0.5,2.4,0.5))
		add_tree(Vector3(x,0,z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
		placed.append(Vector2(x, z))
	var tries = 0
	while placed.size() < 330 and tries < 5000:
		tries += 1
		var x = vary.randf_range(-82, 82)
		var z = vary.randf_range(-52, 46)
		if T.coast(x, z) < 9.0 or T.height(x, z) < 0.0: continue
		if T.river_dist(x, z) < 4.5 or Vector2(x, z).distance_to(T.POND) < 7.5: continue
		if near_path(x, z, 3.4) or clearing(x, z) or is_blocked(x, z, 2.0) or near_entity(x, z, 3.0): continue
		var crowded = false
		for q in placed:
			if q.distance_squared_to(Vector2(x, z)) < 9.0:
				crowded = true
				break
		if crowded: continue
		var y = T.height(x, z)
		solid(Vector3(x, y + 1.2, z), Vector3(0.5, 2.4, 0.5))
		add_tree(Vector3(x, y, z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
		placed.append(Vector2(x, z))
	# orchard rows
	for ox in [-5.0, 0.0, 5.0]:
		for oz in [-5.0, 0.0, 5.0]:
			if ox == 0.0 and oz == 0.0: continue
			var p = Vector3(45 + ox, 0, 22 + oz)
			Art.cyl(self, p + Vector3(0, 0.8, 0), 0.14, 0.2, 1.6, Color("6b4f36"), Vector3.ZERO, 7)
			Art.sph(self, p + Vector3(0, 2.1, 0), 1.25, Color("5a9a3e").lerp(Color("7cb84a"), vary.randf()), Vector3(1, 0.85, 1), 10)
			for k in range(4):
				var a = vary.randf() * TAU
				Art.sph(self, p + Vector3(cos(a) * 1.05, 1.8 + vary.randf() * 0.6, sin(a) * 1.05), 0.12, Color("dc8060").lerp(Color("e9c46a"), vary.randf()), Vector3.ONE, 6)
			solid(p + Vector3(0, 0.8, 0), Vector3(0.4, 1.6, 0.4))
	Art.scatter(self, Art.cyl_mesh(0.28, 1.0, 7), trunks, trunk_colors)
	Art.scatter(self, Art.cone_mesh(1.0, 1.0, 8), pines, pine_colors)
	Art.scatter(self, Art.sphere_mesh(1.0, 9), oaks, oak_colors)

func near_entity(x: float, z: float, d: float) -> bool:
	for e in entities:
		var h: Vector3 = e["home"]
		if absf(h.x - x) < d and absf(h.z - z) < d: return true
	return false

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
		block(c.x, c.z, 4.0)
	for z in [28,15,-8,-19,-32]:
		Art.signpost(self, Vector3(3,0,z), "bei-ru")
	Art.signpost(self, Vector3(-3.2,0,21.5), "teka-ma")
	Art.signpost(self, Vector3(-6,0,-18), "mora-ven")
	for p in [Vector3(-2.8,0,22), Vector3(2.8,0,8), Vector3(-2.8,0,-2), Vector3(2.8,0,-14)]:
		Art.lamp(self, p)
	table_node = Art.table(self, Vector3(-6.2,0,7.5))
	block(-6.2, 7.5, 1.8)
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
			Art.cyl(self, Vector3(sx, -0.6, 30.5 + i * 2.6), 0.1, 0.12, 3.0, Color("5b3d28"), Vector3.ZERO, 7)
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
	for sz in [-25.0, -21.0]:
		for sx in [-1.4, 1.4]:
			Art.cyl(self, Vector3(sx, -0.6, sz), 0.12, 0.14, 1.3, Color("5b3d28"), Vector3.ZERO, 7)

func build_cove():
	tent_node = Art.tent(self, Vector3(-4, 0, -42.5))
	block(-4, -42.5, 2.5)
	for p in [Vector3(6,0,-43), Vector3(-9,0,-41), Vector3(10,0,-39.8)]:
		Art.cyl(self, p + Vector3(0,0.15,0), 0.12, 0.16, 2.2, Color("8a7a66"), Vector3(0, 0, 84), 7)

func build_places():
	# ---- market (west) ----
	var mc = Vector3(-50, 0, 12)
	Art.well(self, mc)
	solid(mc + Vector3(0, 0.5, 0), Vector3(1.8, 1.0, 1.8))
	block(mc.x, mc.z, 1.6)
	var stalls = [[Vector3(-45.5, 0, 6.0), "fish", Color("2a9d8f")], [Vector3(-55.5, 0, 6.5), "fruit", Color("e76f51")],
		[Vector3(-56.5, 0, 17.0), "bread", Color("e9c46a")], [Vector3(-44.0, 0, 18.0), "cloth", Color("a78bda")]]
	for s in stalls:
		var yaw = face(s[0], mc)
		Art.stall(self, s[0], yaw, s[2], s[1])
		solid(s[0] + Vector3(0, 0.55, 0), Vector3(2.7, 1.1, 1.1), yaw)
		block(s[0].x, s[0].z, 2.0)
	Art.house(self, Vector3(-63, 0, 4), Color("e6d2b0"), Color("a8584a"), Color("f4ead0"))
	Art.house(self, Vector3(-62, 0, 21), Color("d9c4a2"), Color("6b7f9c"), Color("f4ead0"))
	for c in [Vector2(-63, 4), Vector2(-62, 21)]:
		solid(Vector3(c.x, 1.6, c.y), Vector3(5, 3.2, 5))
		block(c.x, c.y, 4.0)
	for p in [Vector3(-39, 0, 14.2), Vector3(-53, 0, 2.5), Vector3(-45, 0, 22)]:
		Art.lamp(self, p)
	Art.crate(self, Vector3(-41.5, 0, 7.5), 0.7, Color("b58a52"), 20)
	Art.barrel(self, Vector3(-58.5, 0, 9.5), Color("8f6a43"))
	# ---- school ----
	Art.school(self, Vector3(-48, 0, -9), 0.0)
	solid(Vector3(-48, 1.6, -9), Vector3(9.4, 3.2, 5.6))
	block(-48, -9, 6.0)
	# ---- hot spring ----
	for i in range(6):
		var m = MeshInstance3D.new()
		m.mesh = Art.sphere_mesh(0.7, 8)
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1, 1, 1, 0.25)
		m.material_override = mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(m)
		steam.append({"node": m, "mat": mat, "p": i / 6.0, "x": T.POND.x + randf_range(-2.0, 2.0), "z": T.POND.y + randf_range(-2.0, 2.0)})
	for i in range(14):
		var a = i * TAU / 14.0
		var p = Vector3(T.POND.x + cos(a) * 4.6, 0, T.POND.y + sin(a) * 4.6)
		Art.sph(self, Vector3(p.x, T.height(p.x, p.z) + 0.05, p.z), 0.45, Color("8d9394").lerp(Color("b4aea0"), float(i % 3) / 3.0), Vector3(1.3, 0.6, 1), 7)
	# ---- stepping stones across the river (west) ----
	for p in Art.stepping_stones(self, Vector3(-30, 0, -19.6), Vector3(-30, 0, -26.4), 7):
		solid(Vector3(p.x, -0.05, p.z), Vector3(1.15, 0.3, 1.15))
	Art.signpost(self, Vector3(-28, 0, -17.5), "mora-ni\naruma", 180)
	# ---- west hill lookout ----
	var top = Vector3(-61, T.height(-61, -39.5), -39.5)
	lookout_node = Art.lookout(self, top)
	Art.signpost(self, Vector3(-32.5, 0, -29.5), "sang-ru", 90)
	# ---- healer ----
	var hut_pos = Vector3(56, 0, -1)
	Art.hut(self, hut_pos, face(hut_pos, Vector3(51, 0, -5)))
	solid(hut_pos + Vector3(0, 1.3, 0), Vector3(4.6, 2.6, 4.6))
	block(hut_pos.x, hut_pos.z, 3.4)
	var bed = Art.bed(self, Vector3(59.5, 0, -4.8), 90)
	var child = Art.person(Color("f4a261"), Color("e3b98f"), Color("3b2418"), 2, Color("f2e6c8"))
	child.scale = Vector3.ONE * 0.55
	child.rotation_degrees = Vector3(-90, 0, 0)
	child.position = Vector3(0, 0.62, 0.32)
	bed.add_child(child)
	Art.box(bed, Vector3(0, 0.66, 0.35), Vector3(0.96, 0.08, 1.1), Color("2a9d8f"))
	for sx in [-0.7, 0.7]:
		for sz in [-1.2, 1.2]:
			Art.cyl(bed, Vector3(sx, 1.1, sz), 0.04, 0.05, 2.2, Color("6d4a33"), Vector3.ZERO, 6)
	Art.box(bed, Vector3(0, 2.22, 0), Vector3(1.8, 0.06, 2.8), Color("e9c46a"))
	solid(Vector3(59.5, 0.4, -4.8), Vector3(2.0, 0.8, 1.2))
	block(59.5, -4.8, 1.8)
	Art.signpost(self, Vector3(6.5, 0, -12.5), "dong-ru", 90)
	Art.signpost(self, Vector3(60, 0, -9.5), "fardom-ru", 90)
	Art.signpost(self, Vector3(49.5, 0, 8), "hai-ru", 0)
	# ---- lighthouse ----
	lighthouse_node = Art.lighthouse(self, Vector3(77, 0, -8))
	solid(Vector3(77, 3, -8), Vector3(4.4, 6, 4.4))
	block(77, -8, 3.6)
	# ---- lagoon ----
	Art.drum(self, Vector3(65.6, gy(65.6, 18.4), 18.4))
	Art.umbrella(self, Vector3(63.5, gy(63.5, 25.5), 25.5), Color("e76f51"))
	var canoe = Art.boat(self, Vector3(74, 0.0, 28))
	canoe.scale = Vector3(0.7, 0.7, 0.7)
	canoe.rotation_degrees.y = 60
	block(63.5, 25.5, 1.6)
	# ---- east log bridge ----
	Art.log_bridge(self, Vector3(52, 0, -20.6), Vector3(52, 0, -32.4))
	solid(Vector3(52, -0.1, -26.5), Vector3(1.6, 0.3, 11.8))
	# ---- market and other signposts ----
	Art.signpost(self, Vector3(-7, 0, 20.5), "kur-ru", -90)
	Art.signpost(self, Vector3(-45.5, 0, 3.2), "senak-ru", 0)

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
	avoid.clear()
	for e in entities:
		if e["kind"] == "item" or e["kind"] == "object":
			avoid.append(Vector2(e["home"].x, e["home"].z))
	var tries = 0
	while tufts.size() < 6500 and tries < 22000:
		tries += 1
		var x = rs.randf_range(-80, 80)
		var z = rs.randf_range(-52, 44)
		if grass_ok(x, z):
			var s = rs.randf_range(0.6, 1.3)
			var tilt = Basis.from_euler(Vector3(rs.randf_range(-0.25, 0.25), rs.randf() * TAU, rs.randf_range(-0.25, 0.25)))
			tufts.append(Transform3D(tilt.scaled(Vector3(s, s, s)), Vector3(x, T.height(x, z) + 0.13 * s, z)))
			tuft_colors.append(Color("2f6a2a").lerp(Color("86b84a"), rs.randf()))
	var palette = [Color("f2d36b"), Color("f5f0e1"), Color("e8789a"), Color("a78bda"), Color("f2915a")]
	for c in range(90):
		var cx = rs.randf_range(-78, 78)
		var cz = rs.randf_range(-50, 42)
		var col: Color = palette[rs.randi() % palette.size()]
		for k in range(rs.randi_range(4, 8)):
			var x = cx + rs.randf_range(-1.3, 1.3)
			var z = cz + rs.randf_range(-1.3, 1.3)
			if grass_ok(x, z):
				var h = rs.randf_range(0.28, 0.42)
				var y = T.height(x, z)
				stems.append(Transform3D(Basis.from_scale(Vector3(1, h, 1)), Vector3(x, y + h * 0.5, z)))
				stem_colors.append(Color("4f8b3c"))
				heads.append(Transform3D(Basis.IDENTITY, Vector3(x, y + h + 0.02, z)))
				head_colors.append(col.lightened(rs.randf() * 0.15))
	for i in range(160):
		var x = rs.randf_range(-84, 84)
		var z = rs.randf_range(-54, 48)
		if absf(x) < 2.6 or in_house(x, z) or is_blocked(x, z, 0.5) or near_path(x, z, 1.8): continue
		if T.height(x, z) < -0.6: continue
		var s = rs.randf_range(0.18, 0.55)
		if Vector2(x, z).distance_to(Vector2(-60, -38)) < 15.0: s *= 1.8
		rocks.append(Transform3D(Basis.from_scale(Vector3(s * 1.3, s * 0.8, s)).rotated(Vector3.UP, rs.randf() * TAU), Vector3(x, T.height(x, z) + s * 0.3, z)))
		rock_colors.append(Color("8d9394").lerp(Color("b4aea0"), rs.randf()))
	for i in range(420):
		var x = rs.randf_range(-42, 84)
		var side = -1.0 if i % 2 == 0 else 1.0
		var z = T.river_z(x) + side * rs.randf_range(2.3, 3.2)
		if absf(x) < 2.6 or absf(x + 30.0) < 2.0 or absf(x - 52.0) < 2.4: continue
		if T.coast(x, z) < 5.0: continue
		var h = rs.randf_range(0.7, 1.4)
		reeds.append(Transform3D(Basis.from_scale(Vector3(1, h, 1)).rotated(Vector3.RIGHT, rs.randf_range(-0.12, 0.12)), Vector3(x, T.height(x, z) + h * 0.5 - 0.1, z)))
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
	if T.coast(x, z) < 8.0: return false
	if T.height(x, z) < -0.02: return false
	if T.river_dist(x, z) < 3.6: return false
	if Vector2(x, z).distance_to(T.POND) < 6.5: return false
	if near_path(x, z, 2.3): return false
	if is_blocked(x, z, 0.3): return false
	if x > 16.5 and x < 29.5 and z > -1.5 and z < 22.5: return false
	for a in avoid:
		if absf(a.x - x) < 1.3 and absf(a.y - z) < 1.3: return false
	return true

func build_sky_life():
	cloud_mat = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(1, 1, 1, 0.93)
	cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloud_mat.disable_fog = true
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var rc = RandomNumberGenerator.new()
	rc.seed = 321
	for i in range(14):
		var c = Node3D.new()
		c.position = Vector3(rc.randf_range(-160, 160), rc.randf_range(42, 66), rc.randf_range(-140, 80))
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
	for i in range(26):
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
		if i >= 14: center = [Vector3(45, 0, 22), Vector3(46, 0, -3), Vector3(-50, 0, 12), Vector3(-44, 0, -2), Vector3(-55, 0, -32), Vector3(30, 0, -40)][i % 6] + Vector3(rc.randf_range(-4, 4), 0, rc.randf_range(-4, 4))
		center.y = T.height(center.x, center.z)
		butterflies.append({"node": b, "l": wl, "r": wr, "c": center, "a": rc.randf_range(0.4, 0.9), "p": rc.randf() * 20.0, "r2": rc.randf_range(2, 5)})
	var flocks = [Vector3(0, 0, -5), Vector3(0, 0, -5), Vector3(0, 0, -5), Vector3(72, 0, 20), Vector3(72, 0, 20), Vector3(-70, 0, -30)]
	for i in range(flocks.size()):
		var g = Node3D.new()
		var wl = Node3D.new()
		var wr = Node3D.new()
		g.add_child(wl)
		g.add_child(wr)
		Art.box(wl, Vector3(-0.5, 0, 0), Vector3(1.0, 0.05, 0.28), Color("f5f5f0"))
		Art.box(wr, Vector3(0.5, 0, 0), Vector3(1.0, 0.05, 0.28), Color("f5f5f0"))
		Art.box(g, Vector3(0, 0, 0), Vector3(0.22, 0.18, 0.5), Color("f5f5f0"))
		add_child(g)
		gulls.append({"node": g, "l": wl, "r": wr, "p": i * 2.1, "rad": 18 + (i % 3) * 5, "h": 15 + (i % 3) * 3, "c": flocks[i]})

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
	add_animal(entity("bird","observe","par",Vector3(-6,0,-5),Color("ead8a4")), "bird", 2.6, 1.1)
	add_animal(entity("fish","observe","tari",Vector3(6,0,-22),Color("7bb9c7")), "fish", 0.0, 0.0)
	add_animal(entity("dog","observe","gor",Vector3(-1,0,5),Color("c08a54")), "dog", 6.0, 1.9)
	add_animal(entity("horse","observe","mar",Vector3(22,0,17),Color("8b5a3c")), "horse", 3.8, 1.2)
	entity("boat","object","sena",Vector3(-6.3,0,39),Color.WHITE,1.6,Vector2(1.8,1.6))
	for i in range(4):
		var c = house_centers[i]
		entity("house" + str(i + 1),"object","dom",Vector3(c.x, 0, c.z + 3.6),Color.WHITE,2.5,Vector2(1.5,2.6))
	entity("table","object","tab",Vector3(-6.2,0,7.5),Color.WHITE,1.5)
	entity("gira","object","gira",Vector3(0,0,-19.2),Color.WHITE,1.8)
	entity("field","object","mara",Vector3(16.2,0,5),Color.WHITE,1.2)
	entity("sign1","object","bei",Vector3(3,0,28),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign2","object","bei",Vector3(3,0,-8),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign3","object","bei",Vector3(3,0,-32),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_village","object","teka",Vector3(-3.2,0,21.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_river","object","mora",Vector3(-6,0,-18),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("cairn","object","sek",Vector3(-3.2,0,-3.5),Color.WHITE,0.9,Vector2(1.0,0.8))
	entity("flowers","object","fal",Vector3(3.6,0,24),Color.WHITE,0.9,Vector2(1.0,0.9))
	entity("basket","object","guro",Vector3(-1.8,0,9.2),Color.WHITE,0.9,Vector2(0.9,0.8))
	build_count_prop(Vector3(-3.2,0,-3.5), "stone", 3)
	build_count_prop(Vector3(3.6,0,24), "flower", 4)
	build_count_prop(Vector3(-1.8,0,9.2), "fruit", 5)
	# ---- second expansion: people ----
	entity("ketu","npc","Ketu",Vector3(-46.8,0,8.0),Color("e76f51"))
	entity("sair1","npc","sair",Vector3(-53.5,0,15.0),Color("6b7f9c"))
	entity("sair2","npc","sair",Vector3(-46.5,0,15.6),Color("8f5a48"))
	entity("suri","npc","Suri",Vector3(-45.0,0,-3.4),Color("2a9d8f"))
	var rin = entity("rin","npc","Rin",Vector3(-47.4,0,-2.4),Color("f4a261"))
	var ola = entity("ola","npc","Ola",Vector3(-49.6,0,-3.2),Color("e9c46a"))
	for kid in [rin, ola]:
		(kid["node"] as Node3D).scale = Vector3.ONE * 0.78
		kid["ph"] = 1.55
	entity("pomo","npc","Pomo",Vector3(-58.8,0,-36.4),Color("4f7ca8"))
	entity("vira","npc","Vira",Vector3(51.6,0,-4.4),Color("5b8c5a"))
	entity("ila","npc","Ila",Vector3(53.4,0,-1.8),Color("a78bda"))
	entity("yalo","npc","Yalo",Vector3(73.4,0,-5.0),Color("3f5f8a"))
	entity("desh","npc","Desh",Vector3(67.0,0,20.6),Color("e9c46a"))
	entity("sair3","npc","sair",Vector3(64.2,0,15.2),Color("c0392b"))
	# ---- second expansion: things ----
	entity("herb","item","yok",Vector3(-54.5,0,-33.5),Color("5a9a3e"))
	entity("torch","item","far",Vector3(1.6,0,-41.6),Color("ff8a2a"))
	add_animal(entity("dog2","observe","gor",Vector3(-50,0,8.5),Color("c08a54")), "dog", 5.0, 1.7)
	add_animal(entity("bird2","observe","par",Vector3(-55,0,-43),Color("ead8a4")), "bird", 2.2, 1.0)
	add_animal(entity("bird3","observe","par",Vector3(63.5,0,28.5),Color("ead8a4")), "bird", 2.0, 1.0)
	add_animal(entity("fish2","observe","tari",Vector3(-3.4,0,43.8),Color("7bb9c7")), "fish", 0.0, 0.0)
	add_animal(entity("fish3","observe","tari",Vector3(71.0,0,18.0),Color("7bb9c7")), "fish", 0.0, 0.0)
	entity("well","object","wak-kor",Vector3(-50,0,12),Color.WHITE,2.8,Vector2(1.3,2.4))
	entity("stall","object","kur",Vector3(-45.5,0,6.0),Color.WHITE,3.1,Vector2(1.6,2.8))
	entity("loaves","object","panak",Vector3(-58.6,0,13.0),Color.WHITE,1.4,Vector2(0.9,1.1))
	entity("rack","object","tari",Vector3(-41.6,0,10.8),Color.WHITE,2.1,Vector2(1.1,1.9))
	build_count_prop(Vector3(-58.6,0,13.0), "loaves", 7)
	build_count_prop(Vector3(-41.6,0,10.8), "rack", 6)
	entity("school","object","senak",Vector3(-48,0,-6.2),Color.WHITE,3.6,Vector2(2.2,3.0))
	entity("spring","object","wak",Vector3(-41.2,0,-18.4),Color.WHITE,1.2,Vector2(1.5,1.2))
	entity("stones","object","sek",Vector3(-30,0,-19.0),Color.WHITE,1.0,Vector2(1.0,0.8))
	entity("summit","object","sang",Vector3(-62.4,0,-36.4),Color.WHITE,1.5,Vector2(1.0,1.3))
	build_count_prop(Vector3(-62.4,0,-36.4), "cairn", 0)
	entity("bed","object","sulum",Vector3(59.5,0,-4.8),Color.WHITE,1.4,Vector2(1.3,1.2))
	entity("garden","object","fal",Vector3(44.5,0,-3.0),Color.WHITE,1.1,Vector2(1.5,0.9))
	build_count_prop(Vector3(44.5,0,-3.0), "garden", 10)
	entity("fardom","object","fardom",Vector3(77,0,-5.6),Color.WHITE,3.0,Vector2(2.6,14.0))
	entity("sea","object","hai",Vector3(69.2,0,24.4),Color.WHITE,0.8,Vector2(1.4,0.8))
	entity("orchard","object","guro",Vector3(45,0,22),Color.WHITE,3.2,Vector2(1.4,3.0))
	build_count_prop(Vector3(45,0,22), "orchard", 8)
	entity("logbridge","object","gira",Vector3(52,0,-20.4),Color.WHITE,1.4,Vector2(1.2,1.0))
	entity("circle","object","sek",Vector3(32,0,-42),Color.WHITE,2.2,Vector2(2.0,2.0))
	build_count_prop(Vector3(32,0,-42), "circle", 9)
	entity("sign_market","object","kur",Vector3(-7,0,20.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_school","object","senak",Vector3(-45.5,0,3.2),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_hill","object","sang",Vector3(-32.5,0,-29.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_beyond","object","aru",Vector3(-28,0,-17.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_east","object","dong",Vector3(6.5,0,-12.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_light","object","fardom",Vector3(60,0,-9.5),Color.WHITE,2.3,Vector2(0.9,2.0))
	entity("sign_lagoon","object","hai",Vector3(49.5,0,8),Color.WHITE,2.3,Vector2(0.9,2.0))
	# ---- third expansion ----
	entity("oku","npc","Oku",Vector3(-59.6,0,35.8),Color("6b4f36"))
	entity("gav","npc","Gav",Vector3(5.4,0,34.4),Color("2a6f97"))
	var tm = entity("tamu","npc","Tamu",Vector3(-2.4,0,41.0),Color("c0392b"))
	(tm["node"] as Node3D).position.y = 0.11
	tm["home"].y = 0.11
	entity("ruins","object","dom",Vector3(-60.8,0,38.6),Color.WHITE,2.2,Vector2(1.4,1.8))
	entity("falls","object","wak",Vector3(61.8,0,-35.0),Color.WHITE,2.6,Vector2(1.4,2.4))
	entity("cave","object","gan",Vector3(64.0,0,-36.3),Color.WHITE,2.6,Vector2(1.5,2.4))
	entity("islet_small","object","dor",Vector3(49.6,0,75.2),Color.WHITE,2.3,Vector2(0.9,2.0))
	var fe = entity("ferry","object","sena",FERRY_HARBOR,Color.WHITE,2.0,Vector2(1.8,1.8))
	ferry_node.get_parent().remove_child(ferry_node)
	(fe["node"] as Node3D).add_child(ferry_node)
	ferry_node.position = Vector3.ZERO
	for i in range(STARS.size()):
		var sp: Vector3 = STARS[i]
		entity("star" + str(i + 1), "star", "hai-sao", sp, Color("f28c4a").lerp(Color("e8789a"), float(i % 3) / 3.0))
	for id in Data.MOUNDS.keys():
		var mp = {"mound_front": Vector3(50.7,0,82.4), "mound_behind": Vector3(51.4,0,87.6), "mound_side": Vector3(43.4,0,84.6)}[id]
		var me = entity(id, "object", "dor", mp, Color.WHITE, 1.1, Vector2(1.0, 0.8))
		Art.mound(me["node"], Vector3.ZERO)
	chest_node = Art.chest(self, Vector3(51.4, gy(51.4, 87.6), 87.6))
	chest_node.rotation_degrees.y = 180
	chest_node.hide()

func add_animal(e: Dictionary, kind: String, radius: float, speed: float):
	animals.append({"e": e, "kind": kind, "radius": radius, "speed": speed, "tp": e["home"], "wait": 0.0 if kind != "fish" else randf_range(1.0, 3.0)})

func build_count_prop(pos: Vector3, kind: String, n: int):
	var g = Node3D.new()
	pos.y = gy(pos.x, pos.z)
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
		"loaves":
			Art.box(g, Vector3(0, 0.5, 0), Vector3(1.5, 0.08, 0.7), Color("b0814f"))
			for lx in [-0.65, 0.65]:
				for lz in [-0.28, 0.28]:
					Art.box(g, Vector3(lx, 0.25, lz), Vector3(0.08, 0.5, 0.08), Color("8a6a46"))
			for i in range(n):
				Art.sph(g, Vector3(-0.6 + (i % 4) * 0.4, 0.62 + (0.1 if i >= 4 else 0.0), -0.12 + (0.24 if i >= 4 else 0.0)), 0.13, Color("c98a45").lerp(Color("a86a30"), float(i % 3) / 3.0), Vector3(1.4, 0.75, 1), 8)
			solid(pos + Vector3(0, 0.3, 0), Vector3(1.5, 0.6, 0.7))
		"rack":
			for sx in [-0.9, 0.9]:
				Art.cyl(g, Vector3(sx, 0.9, 0), 0.05, 0.06, 1.8, Color("6d4a33"), Vector3.ZERO, 6)
			Art.cyl(g, Vector3(0, 1.75, 0), 0.04, 0.04, 2.0, Color("6d4a33"), Vector3(0, 0, 90), 6)
			for i in range(n):
				var x = -0.75 + i * 0.3
				Art.cyl(g, Vector3(x, 1.55, 0), 0.008, 0.008, 0.4, Color("dfc990"), Vector3.ZERO, 4)
				Art.sph(g, Vector3(x, 1.2, 0), 0.08, Color("9fb8c4"), Vector3(0.7, 2.4, 0.5), 7)
			solid(pos + Vector3(0, 0.9, 0), Vector3(2.0, 1.8, 0.3))
		"cairn":
			for i in range(5):
				Art.sph(g, Vector3(0, 0.18 + i * 0.26, 0), 0.38 - i * 0.06, Color("8d9394").lerp(Color("b4aea0"), float(i) / 5.0), Vector3(1.2, 0.65, 1), 8)
		"garden":
			Art.box(g, Vector3(0, 0.08, 0), Vector3(3.0, 0.16, 1.2), Color("5a4631"))
			var cols = [Color("e8789a"), Color("f2d36b"), Color("a78bda"), Color("f2915a"), Color("f5f0e1")]
			for i in range(n):
				var p = Vector3(-1.2 + (i % 5) * 0.6, 0.16, -0.3 + (0.6 if i >= 5 else 0.0))
				Art.cyl(g, p + Vector3(0, 0.25, 0), 0.02, 0.025, 0.5, Color("4f8b3c"), Vector3.ZERO, 5)
				Art.sph(g, p + Vector3(0, 0.54, 0), 0.1, cols[i % 5], Vector3(1, 0.6, 1), 7)
		"orchard":
			Art.cyl(g, Vector3(0, 0.9, 0), 0.16, 0.24, 1.8, Color("6b4f36"), Vector3.ZERO, 8)
			Art.sph(g, Vector3(0, 2.4, 0), 1.45, Color("5a9a3e"), Vector3(1, 0.85, 1), 12)
			for i in range(n):
				var a = i * TAU / float(n)
				Art.sph(g, Vector3(cos(a) * 1.35, 2.15 + (0.35 if i % 2 == 0 else -0.1), sin(a) * 1.35), 0.15, Color("dc8060").lerp(Color("e9c46a"), float(i % 3) / 3.0), Vector3.ONE, 8)
			solid(pos + Vector3(0, 0.9, 0), Vector3(0.45, 1.8, 0.45))
		"circle":
			for i in range(n):
				var a = i * TAU / float(n)
				var p = Vector3(cos(a) * 4.6, 0, sin(a) * 4.6)
				var hgt = 1.4 + float((i * 7) % 4) * 0.2
				var st = Art.box(g, p + Vector3(0, hgt * 0.5, 0), Vector3(0.7, hgt, 0.45), Color("8d9394").lerp(Color("b4aea0"), float(i % 3) / 3.0))
				st.rotation.y = -a
				solid(pos + p + Vector3(0, hgt * 0.5, 0), Vector3(0.6, hgt, 0.6))
			Art.box(g, Vector3(0, 0.35, 0), Vector3(1.4, 0.7, 0.8), Color("9a9185"))

func build_player():
	player = CharacterBody3D.new()
	player.position = Vector3(0,0.1,36)
	player.floor_snap_length = 0.45
	player.floor_max_angle = deg_to_rad(50.0)
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
	Art.set_lighthouse(lighthouse_node, completed.has("lighthouse"))
	for id in Data.MOUNDS.keys():
		var me = entity_by_id(id)
		if not me.is_empty(): (me["node"] as Node3D).visible = inventory.has("map") and not completed.has("treasure")
	if chest_node:
		chest_node.visible = completed.has("treasure")
		(chest_node.get_meta("lid") as Node3D).rotation_degrees.x = -110.0 if completed.has("treasure") else 0.0
	for a in animals:
		if a["e"]["id"] == "dog": a["follow"] = completed.has("dog")
	update_marks()

# Yellow marks the next step of the main story; blue marks side quests not yet done.
func update_marks():
	var main = ""
	for q in quests:
		if not completed.has(q[0]):
			main = q[0]
			break
	var main_people: Array = []
	match main:
		"belongings": main_people = ["ena"]
		"meal": main_people = ["mira"]
		"bag": main_people = ["sanu"]
		"bridge": main_people = ["tor"]
		"evidence":
			for p in ["tor", "lira", "oren"]:
				if not completed.has("heard_" + p): main_people.append(p)
			if main_people.is_empty(): main_people = ["tor"]
		"cove": main_people = ["neri"]
	for e in entities:
		if not e.has("mark"): continue
		var m = e["mark"] as Label3D
		var id: String = e["id"]
		var side = false
		for s in side_quests:
			if s[1] == id and not completed.has(s[0]) and quest_open(s[0]): side = true
		m.visible = main_people.has(id) or side
		m.modulate = Color(1.0, 0.84, 0.25) if main_people.has(id) else Color(0.55, 0.85, 1.0)

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
	if parent == content: b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	status.size = Vector2(452,84)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_stylebox_override("normal", chip_style())
	status.add_theme_color_override("font_color", Color("fff6df"))
	status.add_theme_font_size_override("font_size", 17)
	status.mouse_filter = Control.MOUSE_FILTER_STOP
	status.gui_input.connect(_on_status_input)
	ui.add_child(status)
	status_small = Label.new()
	status_small.position = Vector2(14,30)
	status_small.size = Vector2(150,40)
	status_small.add_theme_stylebox_override("normal", chip_style(0.7))
	status_small.add_theme_color_override("font_color", Color("fff6df"))
	status_small.add_theme_font_size_override("font_size", 17)
	status_small.mouse_filter = Control.MOUSE_FILTER_STOP
	status_small.gui_input.connect(_on_status_input)
	status_small.hide()
	ui.add_child(status_small)
	top_row = HBoxContainer.new()
	top_row.position = Vector2(14,124)
	ui.add_child(top_row)
	button("Notebook",show_notebook,top_row)
	button("Bag",show_inventory,top_row)
	button("Map",show_map,top_row)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	prompt.position = Vector2(-160,40)
	prompt.size = Vector2(320,70)
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
	toast_label.position = Vector2(-170,186)
	toast_label.size = Vector2(340,40)
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal", chip_style(0.78))
	toast_label.add_theme_color_override("font_color", Color("ffe9a8"))
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.modulate.a = 0.0
	toast_label.z_index = 5
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
	panel.offset_top = 196
	panel.offset_bottom = -35
	ui.add_child(panel)
	var margin = MarginContainer.new()
	for edge in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+edge,16)
	panel.add_child(margin)
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
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
	touches.clear()
	mouse_look = false
	left_down = false
	walk_to = {}
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
	text_line("Tap or click any person, animal or object to walk to it and interact. Things you can pick up glow with a column of light. A yellow ! marks the next step of the story; a blue ! marks someone with a side quest.")
	text_line("Phone: drag the lower left to walk (push farther to run), swipe the right side to look.\n\nDesktop: W/S walk, A/D sidestep, Shift runs, left/right arrows turn, drag with the mouse to look. Click things, or walk up and press E.")
	text_line("Tap the quest box at the top to fold it away; tap it again to read your goal.")
	text_line("The island is big: a market, school and old ruins to the west, a hill with a lookout, a healer, a lighthouse, a waterfall and a lagoon to the east, and a small island you can reach by boat. Days turn to nights, it sometimes rains, and the sea has a few surprises. Open Map to see where everything is, check your quests, and travel to places you have already visited.")
	text_line("In the Notebook, try the Verb builder and the Sentence builder to put Varnak together yourself.")

func learn(word: String):
	if words.has(word) and not discovered.has(word):
		discovered.append(word)
		toast("New word: " + word)

func complete(id: String):
	if not completed.has(id): completed.append(id)
	if id in ["bridge", "meal", "lighthouse"]: refresh_world()
	update_marks()
	save_game()

func objective() -> String:
	for q in quests:
		if not completed.has(q[0]): return q[1]
	for s in side_quests:
		if not completed.has(s[0]) and quest_open(s[0]): return quest_text(s)
	return "Every quest is done. Keep exploring and practicing Varnak."

func quest_open(id: String) -> bool:
	if id == "treasure": return inventory.has("map")
	return true

func quest_text(s: Array) -> String:
	if s[0] == "seastars": return s[2] + " (" + str(stars_found()) + " of " + str(STARS.size()) + ")"
	return s[2]

func stars_found() -> int:
	var n = 0
	for i in range(STARS.size()):
		if solved.has("star" + str(i + 1)): n += 1
	return n

func quests_done() -> int:
	var n = 0
	for q in quests:
		if completed.has(q[0]): n += 1
	for s in side_quests:
		if completed.has(s[0]): n += 1
	return n

func zone_info(p: Vector3) -> Array:
	var best = ""
	var best_name = ""
	var best_score = 1.0
	for r in regions:
		var score = Vector2(p.x, p.z).distance_to(r[2]) / r[3]
		if score < best_score:
			best_score = score
			best = r[0]
			best_name = r[1]
	if best != "": return [best, best_name]
	if T.river_dist(p.x, p.z) < 4.0 and p.x > -40.0: return ["river", central["river"][0]]
	if absf(p.x) < 20.0:
		var id = "cove"
		if p.z > 26: id = "harbor"
		elif p.z > -6: id = "village"
		elif p.z > -20: id = "forest"
		elif p.z > -36: id = "farbank"
		return [id, central[id][0]]
	return ["", "Open country"]

func region_spawn(id: String) -> Vector3:
	if central.has(id): return central[id][1]
	for r in regions:
		if r[0] == id: return r[4]
	return Vector3(0, 0, 33)

func region_name(id: String) -> String:
	if central.has(id): return central[id][0]
	for r in regions:
		if r[0] == id: return r[1]
	return id

# ------------------------------------------------------------ frame loop

func _process(delta):
	clock += delta
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time < 0.6: toast_label.modulate.a = maxf(toast_time / 0.6, 0.0)
	for c in clouds:
		c.position.x += delta * 0.9
		if c.position.x > 170: c.position.x = -170
	for b in butterflies:
		var t = clock * b["a"] + b["p"]
		var cpos: Vector3 = b["c"]
		var np = Vector3(cpos.x + sin(t) * b["r2"], cpos.y + 0.9 + sin(t * 1.7) * 0.35, cpos.z + cos(t * 0.8) * b["r2"])
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
		var c: Vector3 = g["c"]
		var np = Vector3(c.x + sin(t) * g["rad"], g["h"] + sin(t * 2.0), c.z + cos(t) * g["rad"])
		var dir = np - node.position
		node.position = np
		if dir.length() > 0.001: node.rotation.y = atan2(dir.x, dir.z)
		var flap = sin(clock * 4.0 + g["p"]) * 0.5
		(g["l"] as Node3D).rotation.z = flap
		(g["r"] as Node3D).rotation.z = -flap
	for s in steam:
		var u = fmod(clock * 0.18 + s["p"], 1.0)
		var m = s["node"] as MeshInstance3D
		m.position = Vector3(s["x"] + sin(clock + s["p"] * 9.0) * 0.4, -0.1 + u * 3.2, s["z"])
		m.scale = Vector3.ONE * (0.6 + u * 1.6)
		(s["mat"] as StandardMaterial3D).albedo_color.a = 0.3 * sin(u * PI)
	if boat_node:
		boat_node.position.y = 0.04 + sin(clock * 1.3) * 0.04
		boat_node.rotation.z = sin(clock * 1.1) * 0.025
		boat_node.rotation.x = sin(clock * 0.9 + 1.0) * 0.015
	if tent_node:
		var fl = tent_node.get_meta("flame") as Node3D
		fl.scale = Vector3(1.0 + sin(clock * 11.0) * 0.12, 1.0 + sin(clock * 13.0 + 1.0) * 0.18, 1.0 + sin(clock * 9.0) * 0.12)
	if lighthouse_node:
		var beam = lighthouse_node.get_meta("beam") as Node3D
		if beam.visible: beam.rotation.y += delta * 0.7
	if lookout_node:
		(lookout_node.get_meta("flag") as Node3D).rotation.y = sin(clock * 2.3) * 0.25
	animate_people(delta)
	animate_animals(delta)
	animate_items()
	update_marker()
	update_sky(delta)
	update_weather(delta)
	update_whale(delta)
	update_ride(delta)
	update_night_life(delta)

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
		var talk_amt = 0.0
		if not target.is_empty() and target.get("id", "") == e["id"]: talk_amt = 0.5
		var swing = 0.06 + talk_amt * 0.5
		(arms[0] as Node3D).rotation.x = sin(clock * (1.2 + talk_amt * 3.0) + idx) * swing
		(arms[1] as Node3D).rotation.x = -sin(clock * (1.2 + talk_amt * 3.0) + idx) * swing
		(node.get_meta("body") as Node3D).scale.y = 1.0 + sin(clock * 1.6 + idx) * 0.008
		(node.get_meta("head") as Node3D).rotation.z = sin(clock * 0.7 + idx) * 0.04
		if e.has("mark"):
			(e["mark"] as Node3D).position.y = 2.75 + sin(clock * 2.5 + idx) * 0.08

func animate_items():
	var i = 0
	for e in entities:
		if e["kind"] != "item": continue
		i += 1
		var node = e["node"] as Node3D
		node.position.y = e["gy"] + 0.06 + sin(clock * 2.0 + i) * 0.05
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
					node.position.y = -0.45
				elif t < 0.9:
					var u = t / 0.9
					node.position.y = -0.12 + sin(u * PI) * 1.0
					node.rotation.x = lerpf(0.9, -0.9, u)
				else:
					a["wait"] = randf_range(2.5, 5.5)
					node.position.y = -0.45
			_:
				if a.get("follow", false):
					follow_player(a, delta)
					continue
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
						var tp = home + Vector3(cos(ang) * r, 0, sin(ang) * r)
						if T.height(tp.x, tp.z) < -0.05 or is_blocked(tp.x, tp.z, 0.5): tp = home
						a["tp"] = tp
				var ground = gy(node.position.x, node.position.z)
				e["gy"] = ground
				match a["kind"]:
					"bird":
						var wings: Array = node.get_meta("wings")
						var flap = sin(clock * (22.0 if moving else 3.0)) * (0.7 if moving else 0.15)
						(wings[0] as Node3D).rotation.z = flap
						(wings[1] as Node3D).rotation.z = -flap
						node.position.y = ground + 0.05 + (absf(sin(clock * 9.0)) * 0.12 if moving else 0.0)
					"dog":
						var tail = node.get_meta("tail") as Node3D
						tail.rotation.y = sin(clock * 14.0) * 0.6
						node.position.y = ground + (absf(sin(clock * 10.0)) * 0.05 if moving else 0.0)
					"horse":
						var tail = node.get_meta("tail") as Node3D
						tail.rotation.z = sin(clock * 3.0) * 0.15
						node.position.y = ground + (absf(sin(clock * 5.0)) * 0.04 if moving else 0.0)

func update_marker():
	var shown = target
	if not walk_to.is_empty(): shown = walk_to
	elif not hover.is_empty(): shown = hover
	if shown.is_empty() or panel.visible:
		marker.hide()
		return
	var node = shown["node"] as Node3D
	marker.show()
	marker.position = Vector3(node.position.x, maxf(gy(node.position.x, node.position.z), -0.06) + 0.05, node.position.z)
	var pulse = 1.0 + sin(clock * 4.0) * 0.1
	var base = clampf(float(shown["pr"]) * 1.1, 0.6, 2.4)
	marker.scale = Vector3(base * pulse, 1, base * pulse)

func _physics_process(delta):
	save_clock += delta
	if save_clock > 8:
		save_game()
		save_clock = 0
	update_status()
	if riding:
		prompt.visible = false
		interact_button.disabled = true
		return
	if panel.visible: return
	var axis = joy
	var manual = joy != Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): axis.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): axis.y += 1
	if Input.is_physical_key_pressed(KEY_A): axis.x -= 1
	if Input.is_physical_key_pressed(KEY_D): axis.x += 1
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_Q):
		player.rotation.y += 1.9 * delta
		manual = true
	if Input.is_physical_key_pressed(KEY_RIGHT):
		player.rotation.y -= 1.9 * delta
		manual = true
	if axis != Vector2.ZERO: manual = true
	var speed = 4.5
	if Input.is_physical_key_pressed(KEY_SHIFT) or joy.length() > 0.95: speed = 7.5
	if manual: walk_to = {}
	elif not walk_to.is_empty():
		var node = walk_to["node"] as Node3D
		var d = Vector2(node.global_position.x - player.position.x, node.global_position.z - player.position.z)
		var stop = maxf(2.2, float(walk_to["pr"]) + 1.1)
		if d.length() < stop or not node.visible:
			var arrived = walk_to
			walk_to = {}
			if node.visible:
				target = arrived
				interact()
				return
		else:
			var want = atan2(-d.x, -d.y)
			player.rotation.y = lerp_angle(player.rotation.y, want, minf(delta * 8.0, 1.0))
			axis = Vector2(0, -1)
			speed = 6.0
			walk_check -= delta
			if walk_check <= 0.0:
				if walk_last - d.length() < 0.6:
					var stuck_on = walk_to
					walk_to = {}
					if d.length() <= REACH + maxf(float(stuck_on["pr"]) - 0.8, 0.0):
						target = stuck_on
						interact()
						return
					hint("Something is in the way. Walk around it, then click again.")
				walk_last = d.length()
				walk_check = 0.8
	axis = axis.limit_length()
	var direction = player.basis * Vector3(axis.x,0,axis.y)
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	player.velocity.y -= 18 * delta
	if player.is_on_floor(): player.velocity.y = minf(player.velocity.y, 0.0)
	player.move_and_slide()
	player.position.x = clampf(player.position.x,-95,95)
	player.position.z = clampf(player.position.z,-80,65)
	if T.deep(player.position.x, player.position.z) and player.position.y < -0.05:
		player.position = last_safe
		player.velocity = Vector3.ZERO
		walk_to = {}
		hint("The water is too deep here.")
	elif player.is_on_floor():
		last_safe = player.position
	if player.position.y < -5.0:
		player.position = last_safe + Vector3(0, 0.5, 0)
	var z = zone_info(player.position)
	if z[1] != zone:
		if zone != "": toast(z[1])
		zone = z[1]
		zone_id = z[0]
		if zone_id != "" and not visited.has(zone_id): visited.append(zone_id)
	target = {}
	var best = INF
	var fwd = -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var d3 = node.global_position - player.position
		d3.y = 0.0
		var dist = d3.length() - maxf(float(e["pr"]) - 0.8, 0.0)
		if dist < REACH:
			var score = dist + (1.0 - fwd.dot(d3.normalized())) * 1.2
			if score < best:
				best = score
				target = e
	hint_time -= delta
	if hint_time > 0.0: pass
	elif not hover.is_empty(): prompt.text = display_name(hover) + "\n(click to " + verb(hover) + ")"
	elif not walk_to.is_empty(): prompt.text = "Walking to " + display_name(walk_to)
	elif target.is_empty(): prompt.text = ""
	else: prompt.text = display_name(target) + "\n(click it, press E, or tap " + verb(target).capitalize() + ")"
	prompt.visible = prompt.text != ""
	interact_button.disabled = target.is_empty()
	interact_button.text = "Interact" if target.is_empty() else verb(target).capitalize()

func hint(text: String):
	prompt.text = text
	prompt.show()
	hint_time = 2.5

func verb(e: Dictionary) -> String:
	match e["kind"]:
		"npc": return "talk"
		"item", "star": return "pick up"
		"observe": return "watch"
	return "look"

func display_name(e: Dictionary) -> String:
	if e["kind"] == "npc": return names.get(e["id"], str(e["id"]).capitalize())
	return str(e.get("word", ""))

# ------------------------------------------------------------ input

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE: close_panel()
		if event.keycode == KEY_E and not panel.visible: interact()
	if panel.visible: return
	var size = get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		last_touch_time = clock
		if event.pressed:
			touches[event.index] = [event.position, clock, 0.0]
			if event.position.x < size.x * 0.46 and event.position.y > size.y * 0.6 and move_finger == -1:
				move_finger = event.index
				joy_origin = event.position
			elif look_finger == -1:
				look_finger = event.index
		else:
			if touches.has(event.index):
				var t: Array = touches[event.index]
				if t[2] < 14.0 and clock - t[1] < 0.45: tap(event.position)
				touches.erase(event.index)
			if event.index == move_finger:
				move_finger = -1
				joy = Vector2.ZERO
			if event.index == look_finger: look_finger = -1
		return
	if event is InputEventScreenDrag:
		last_touch_time = clock
		if touches.has(event.index): touches[event.index][2] += event.relative.length()
		if event.index == move_finger: joy = ((event.position-joy_origin)/65).limit_length()
		if event.index == look_finger: look(event.relative)
		return
	# Mouse events that a touchscreen emulates are ignored; touches are handled above.
	if event is InputEventMouse and (event.device == -1 or clock - last_touch_time < 0.8): return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		mouse_look = event.pressed
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_down = true
			left_drag = 0.0
		else:
			if left_down and left_drag < 8.0: tap(event.position)
			left_down = false
	if event is InputEventMouseMotion:
		if mouse_look: look(event.relative)
		elif left_down:
			left_drag += event.relative.length()
			if left_drag >= 8.0: look(event.relative)
		else:
			hover = pick_at(event.position)
			Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND if not hover.is_empty() else Input.CURSOR_ARROW)

# Find the person or thing under a screen position: closest approach of the camera ray
# to each entity's upright pick cylinder, falling back to a generous screen-space check.
func pick_at(pos: Vector2) -> Dictionary:
	var o = camera.project_ray_origin(pos)
	var dir = camera.project_ray_normal(pos)
	var best = {}
	var best_t = INF
	var dxz = Vector2(dir.x, dir.z)
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var b = node.global_position
		if e["kind"] == "item" or e["kind"] == "observe": b.y -= 0.15
		var r: float = e["pr"]
		var h: float = e["ph"]
		var t: float
		if dxz.length_squared() > 1e-6: t = Vector2(b.x - o.x, b.z - o.z).dot(dxz) / dxz.length_squared()
		elif absf(dir.y) > 1e-4: t = (b.y + h * 0.5 - o.y) / dir.y
		else: continue
		if t <= 0.0 or t > 150.0: continue
		var p = o + dir * t
		var horiz = Vector2(p.x - b.x, p.z - b.z).length()
		var vy = 0.0
		if p.y < b.y: vy = b.y - p.y
		elif p.y > b.y + h: vy = p.y - b.y - h
		if sqrt(horiz * horiz + vy * vy) < r and t < best_t:
			best_t = t
			best = e
	if not best.is_empty(): return best
	var best_px = 44.0
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var c = node.global_position + Vector3(0, float(e["ph"]) * 0.5, 0)
		if camera.is_position_behind(c) or camera.global_position.distance_to(c) > 60.0: continue
		var d = camera.unproject_position(c).distance_to(pos)
		if d < best_px:
			best_px = d
			best = e
	return best

func tap(pos: Vector2):
	var e = pick_at(pos)
	if e.is_empty(): return
	var node = e["node"] as Node3D
	var d = Vector2(node.global_position.x - player.position.x, node.global_position.z - player.position.z).length()
	if d <= REACH + maxf(float(e["pr"]) - 0.8, 0.0):
		target = e
		interact()
	elif d <= WALK_RANGE:
		walk_to = e
		walk_last = d
		walk_check = 0.8
	else:
		hint("That is far away. Walk closer, or travel from the Map.")

func look(amount: Vector2):
	player.rotation.y -= amount.x * 0.004
	camera.rotation.x = clampf(camera.rotation.x - amount.y * 0.004,-1.05,1.05)

# ------------------------------------------------------------ interaction

func interact():
	if target.is_empty(): return
	var e = target.duplicate()
	hover = {}
	match e["kind"]:
		"npc": talk(e["id"])
		"item":
			learn(e["word"])
			clear_panel(e["word"])
			text_line("You examine the object. Its name is now in your notebook.")
			button("Pick up",func():
				inventory.append(e["id"])
				e["node"].hide()
				toast("In your bag: " + e["word"])
				save_game()
				close_panel(),content)
			button("Return",close_panel,content)
		"observe": observe(e)
		"star": collect_star(e)
		_: examine(e)

func examine(e: Dictionary):
	var id: String = e["id"]
	if id.begins_with("house"):
		door_puzzle(id)
		return
	if id in ["sign1", "sign2", "sign3"]:
		sentence_card("sign_north")
		return
	if Data.SENTENCES.has(id):
		sentence_card(id)
		return
	if Data.COUNTS.has(id):
		count_puzzle(id)
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
		"well": sentence_card("well_full")
		"stall": sentence_card("ketu_sells")
		"school": sentence_card("students_read")
		"spring": sentence_card("spring_hot")
		"stones": sentence_card("stones_cross")
		"summit": sentence_card("summit_highest")
		"bed": sentence_card("child_sleeps")
		"fardom": sentence_card("lighthouse_bright" if completed.has("lighthouse") else "lighthouse_dark")
		"sea": sentence_card("sea_cold")
		"logbridge": sentence_card("log_short")
		"ruins": sentence_card("ruins_old")
		"falls": sentence_card("falls")
		"cave": cave_panel()
		"ferry": ride_puzzle(player.position.z < 60.0)
		"mound_front", "mound_behind", "mound_side": mound_panel(id)
		_: message(e["word"], "You look closely, but there is nothing more to learn here yet.")

func observe(e: Dictionary):
	learn(e["word"])
	if e["id"] == "dog" and not completed.has("dog"):
		clear_panel("gor")
		text_line("The dog sniffs at your bag hopefully and wags its tail.")
		if inventory.has("bread"):
			button("Share the panak", func():
				consume(["bread"])
				complete("dog")
				for a in animals:
					if a["e"]["id"] == "dog": a["follow"] = true
				sentence_card("dog_with_me"), content)
		else:
			text_line("It looks hungry. Ketu at the market sells panak (bread).")
		button("Watch the dog", func(): sentence_card("dog_runs"), content)
		button("Return", close_panel, content)
		return
	match e["word"]:
		"par": sentence_card("bird_sky")
		"gor": sentence_card("dog_runs")
		"mar": sentence_card("horse_fast")
		"tari":
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
	if mastered.has("w:nuk"):
		quick_catch()
		return
	choice_puzzle("tari-nuk: fishing", "You crouch at the water and cast a line. You want to say that you are fishing in general. A fish is not the focus, so the noun joins the verb. Which form fits?",
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
		"A particular fish stays a separate noun, and the one acting takes -ke.", Callable(),
		func(): fish_count_note())

func quick_catch():
	clear_panel("Na-tari-nuk-im.")
	fish_caught += 1
	save_game()
	text_line("You cast your line and wait. A tug! You pull out a silver fish.\n\n“Anke tari k-i-nuk-ak-pa-da.”\nI caught the fish.")
	fish_count_note()
	button("Fish again", quick_catch, content)
	button("Return", close_panel, content)

func fish_count_note():
	var nums = ["nul", "yan", "vel", "mur", "kes", "pan", "luk", "set", "bar", "gov", "dar"]
	var word = nums[fish_caught] if fish_caught < nums.size() else str(fish_caught)
	var line = "Fish in your bag: " + str(fish_caught) + " (" + word + " tari)."
	if not completed.has("market"):
		if fish_caught >= 3: line += "\nThat is mur tari, three fish. Ketu at the market wants them."
		else: line += "\nKetu at the market wants three. Keep fishing."
	text_line(line)

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

# ---- second expansion: quests ----

func school_quiz(i: int):
	var q: Dictionary = Data.SCHOOL[i]
	for w in ["hal", "hama", "han", "hamur", "rav", "-ha"]:
		if q["q"].to_lower().contains(w.trim_prefix("-")): learn(w)
	choice_puzzle("Suri's lesson: " + str(i + 1) + " of 4", q["gesture"] + "\n\n“" + q["q"] + "”" + ("\n\nAnswer Suri in Varnak." if i == 3 else "\n\nWhat is Suri asking?"), q["options"], q["correct"], func():
		master("q:school" + str(i))
		if i == 3:
			learn("vel")
			learn("ravar")
			complete("school"),
		q["why"], "Look at Suri's gesture and the question word: hal who, han what, hama where, hamur how many.", talk.bind("suri"),
		func():
			if i < 3: button("Next question", school_quiz.bind(i + 1), content)
			else: text_line("Suri claps. “Ho!” (Good!) You finished the lesson."))

func lookout_quiz(i: int):
	var q: Dictionary = Data.LOOKOUT[i]
	learn("hama")
	for w in ["bei", "nam", "dong", "sai"]: learn(w)
	choice_puzzle("Pomo's question: " + str(i + 1) + " of 3", q["gesture"] + "\n\n“" + q["q"] + "”  (" + q["en"] + ")\n\nHow do you answer?", q["options"], q["correct"], func():
		master("q:lookout" + str(i))
		if i == 2: complete("lookout"),
		q["why"], "bei is north, nam south, dong east and sai west. Follow Pomo's pointing hand.", talk.bind("pomo"),
		func():
			if i < 2: button("Next question", lookout_quiz.bind(i + 1), content)
			else: text_line("Pomo grins and hands you the telescope. You can see the whole island from here."))

func pain_puzzle():
	var p = Data.PAIN
	for w in ["tong", "dau", "ten", "mal"]: learn(w)
	choice_puzzle("Where does it hurt?", p["gesture"] + "\n\nWhat is Ila telling Vira?", p["options"], p["correct"], func():
		if not solved.has("pain"): solved.append("pain")
		save_game(),
		p["why"], "Look at where Ila holds her hands: dau is head, ten is foot, mal is hand.", talk.bind("vira"),
		func(): button("Continue", talk.bind("vira"), content))

func light_puzzle():
	learn("ling")
	learn("-tir")
	choice_puzzle("Light the lamp", "Yalo carries the torch up the stairs and calls down to you:\n\n“Fardom t-i-ling-tir-o!”\n\nWhat is Yalo asking you to do?",
		["Make the lighthouse bright!", "Make the lighthouse dark!", "Do not touch the lighthouse!"], 0, func():
			consume(["torch"])
			complete("lighthouse"),
		"ling is bright and -tir means cause or make, so ling-tir means make bright. t-i- means you act on it, and -o makes it a command. You pull the lever and the lamp blazes.",
		"Look for ling (bright) and the causative -tir, make.", talk.bind("yalo"))

func desh_round(i: int, order: Array):
	var cmd: Dictionary = order[i]
	var acts: Array = [cmd["act"]]
	var others = Data.DESH.duplicate()
	others.shuffle()
	for o in others:
		if o["act"] != cmd["act"] and acts.size() < 3: acts.append(o["act"])
	for w in cmd["words"]: learn(w)
	choice_puzzle("Desh's game: " + str(i + 1) + " of 4", "Desh beats the drum and shouts:\n\n“" + cmd["v"] + "”\n\nWhat do you do?", acts, 0, func():
		master("q:desh" + str(i))
		if i == 3: complete("lagoon"),
		cmd["v"] + " means " + cmd["en"] + " The prefix ta- is you, and -o makes a command.",
		"Listen for the root: sum swim, pav run, ning sing, nang walk, sul sleep. ma- ... -ki means do not.", talk.bind("desh"),
		func():
			if i < 3: button("Next command", desh_round.bind(i + 1, order), content)
			else: text_line("Desh drums a long roll and laughs. You won the game!"))

func identity_puzzle():
	learn("-ha")
	learn("kelar")
	choice_puzzle("Ti kelar ta-an-ha?", "Ola looks at your bag and dusty boots, then asks:\n\n“Ti kelar ta-an-ha?”\n\nHow do you answer?",
		["An kelar na-an-da.", "An senar na-an-da.", "An ravar na-an-da."], 0, func(): master("q:ola"),
		"An kelar na-an-da: I am a traveler. Ola's question used ta- (you) and -ha (a yes or no question); your answer uses na- (I) and -da.",
		"You are not a teacher (senar) or a student (ravar). You are traveling.", talk.bind("ola"))

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
		"ketu":
			topic("Ask what Ketu sells", "ketu_sells", id)
			topic("Ask about the well", "well_full", id)
		"suri":
			topic("Ask who Suri is", "suri_teacher", id)
			topic("Ask about the students", "students_read", id)
		"rin":
			topic("Ask who Rin is", "rin_student", id)
			topic("Ask what they are doing", "students_read", id)
		"ola": button("Answer Ola's question", identity_puzzle, content)
		"pomo":
			topic("Ask about the hill", "hill_taller", id)
			topic("Ask about the summit", "summit_highest", id)
			topic("Ask about the night sky", "night_sky", id)
		"vira": topic("Ask about the sleeping child", "child_sleeps", id)
		"ila":
			if completed.has("healer"): topic("Ask how Ila feels", "ila_happy", id)
		"yalo":
			if completed.has("lighthouse"):
				topic("Ask about the light", "lighthouse_bright", id)
				topic("Ask about the night", "night_light", id)
			else:
				topic("Ask about the lamp", "lighthouse_dark", id)
				topic("Ask what is wrong", "no_fire", id)
		"desh":
			topic("Ask Desh about swimming", "desh_swims", id)
			topic("Ask about the sea", "sea_cold", id)
		"oku":
			topic("Ask about the ruins", "ruins_old", id)
			if completed.has("riddles"): topic("Ask about the secret", "room_behind", id)
		"gav": topic("Ask Gav about his work", "gav_mail", id)
		"tamu":
			topic("Ask Tamu about the boat", "tamu_ferry", id)
			topic("Ask about the small island", "islet_small", id)

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
				else: message("Ena points again", "Pick up the brown bag beside Ena (it glows), then try again."),content)
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
				elif completed.has("bag"): message("Sanu waves", "Sanu has the bag back. Tor is north at the river crossing.")
				else: offer_help(["forest_bag"]),content)
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
		"lira":
			account("lira","italpanu","Lira gestures to someone in the distance. Another resident told Lira about Neri's arrival.")
			add_topics(id)
			return
		"oren":
			account("oren","italpashi","Oren points to fresh footprints in the sand. Oren inferred that Neri arrived.")
			add_topics(id)
			return
		"neri":
			clear_panel("Neri at the northern cove")
			if completed.has("evidence"):
				complete("cove")
				text_line("You found your friend and understood the clues. Neri shows you a notebook of island stories. Your Varnak adventure has begun.")
				if quests_done() < quests.size() + side_quests.size():
					text_line("“Teka i-var,” Neri says, sweeping an arm across the island. There are more people to meet: open the Map to see who still needs help.")
				else:
					text_line("Neri has heard about everything you did. “Polu,” Neri laughs. Everyone. You helped everyone on the island.")
				button("Tell Neri about your adventure", tile_puzzle.bind(-1, talk.bind("neri")), content)
				button("Practice evidence again",show_evidence,content)
			else:
				text_line("You found Neri by exploring. To understand the journey, compare Tor's, Lira's and Oren's accounts, then return.")
			if not completed.has("lighthouse"):
				learn("far")
				text_line("A torch leans against a stone by the campfire. Neri points at it: “Far.”")
		"ketu":
			for w in ["kur", "tari", "mur", "-ye", "tnaveno"]: learn(w)
			clear_panel("Ketu at the market")
			if completed.has("market"):
				learn("gin")
				text_line("Ketu waves you over. Your fish are drying on the rack: “Tari i-ho!” (The fish are good!)\n\nKetu buys fish (one gin each) and sells panak. You have " + str(gin) + " gin and " + str(fish_caught) + " fish.")
				if fish_caught > 0:
					button("Sell a fish: tari yan, gin yan", func():
						fish_caught -= 1
						gin += 1
						toast("Tari yan, gin yan. (+1 gin)")
						save_game()
						talk("ketu"), content)
				button("Buy panak (bread)", buy_bread, content)
			else:
				text_line("Ketu holds up three fingers, then mimes a fish wriggling.\n\n“Mur tari t-na-ven-o-ye.”\n\nYou have " + str(fish_caught) + " fish.")
				button("Give mur tari (3 fish)", func():
					if fish_caught >= 3:
						fish_caught -= 3
						inventory.append("tea")
						complete("market")
						learn("cha")
						message("Ketu is delighted", "Ketu counts the fish: “Yan, vel, mur!” Then Ketu hands you a cup of cha wrapped in cloth. “Cha i-ret.” Hot tea. Someone who is unwell might need it.")
					else:
						message("Ketu counts your fish", "You have " + str(fish_caught) + ". Ketu needs mur: three. Watch for jumping fish at the river by the bridge, at the end of the harbor dock, or in the east lagoon, then tap one and try fishing."), content)
		"sair1":
			sentence_card("buy_bread", close_panel)
			return
		"sair2":
			sentence_card("tea_hot", close_panel)
			return
		"sair3":
			learn("ser")
			sentence_card("rain_starts", close_panel)
			return
		"suri":
			learn("senak")
			learn("senar")
			clear_panel("Suri at the school")
			if completed.has("school"):
				text_line("Suri smiles. “Ho!” You know the question words now: hal who, han what, hama where, hamur how many.")
				button("Repeat the lesson", school_quiz.bind(0), content)
			else:
				text_line("Suri points to the chalkboard, then hands you a slate with four questions on it. She waves you toward a bench.")
				button("Start the lesson", school_quiz.bind(0), content)
		"rin", "ola":
			if hiding.get(id, false):
				found_puzzle(id)
				return
	match id:
		"rin":
			clear_panel("Rin")
			text_line("Rin looks up from a book and waves. “Puka!” Rin says, holding it up.")
			learn("puka")
		"ola":
			clear_panel("Ola")
			text_line("Ola studies you with great curiosity.")
			if not completed.has("hide"):
				button("Play hide and seek", start_hide, content)
		"pomo":
			for w in ["sang", "bei", "nam", "dong", "sai"]: learn(w)
			clear_panel("Pomo at the lookout")
			text_line("Pomo hands you the telescope. “Bei, nam, dong, sai,” Pomo says, pointing north, south, east and west in turn.")
			if completed.has("lookout"): text_line("“Ho!” You already know your directions.")
			button("Repeat the questions" if completed.has("lookout") else "Answer Pomo's questions", lookout_quiz.bind(0), content)
		"vira":
			learn("yok")
			clear_panel("Vira the healer")
			if completed.has("healer"):
				text_line("Vira is grinding herbs. Ila is up and about. “Ila i-seng-da.”")
			elif not solved.has("pain"):
				text_line("Vira kneels beside Ila, who looks miserable. Vira asks Ila where it hurts, then turns to you.")
				button("Listen to Ila", pain_puzzle, content)
			else:
				learn("cha")
				learn("e")
				text_line("Vira mimes crushing leaves into a steaming cup.\n\n“Yok e cha t-na-ven-o-ye.”")
				button("Offer yok and cha", func():
					if has_items(["herb", "tea"]):
						consume(["herb", "tea"])
						complete("healer")
						learn("seng")
						message("Ila feels better", "Vira brews the herb in the hot tea. Ila sips it, and slowly the frown fades. “Ila i-seng-da.” Ila is happy.")
					else:
						var miss: Array = []
						if not inventory.has("herb"): miss.append("yok: a healing herb that grows on the west hill (it glows)")
						if not inventory.has("tea"): miss.append("cha: Ketu at the market trades tea for three fish")
						message("Vira repeats the request", "Still needed:\n" + "\n".join(miss)), content)
		"ila":
			clear_panel("Ila")
			if completed.has("healer"): text_line("Ila stretches and smiles at you.")
			else: text_line("Ila holds her head and groans quietly. Vira the healer is looking after her.")
		"yalo":
			for w in ["fardom", "far", "tar", "-ye"]: learn(w)
			clear_panel("Yalo the lighthouse keeper")
			if completed.has("lighthouse"):
				text_line("The beam sweeps the water. Yalo grins and gives you a thumbs up.")
			else:
				text_line("Yalo points up at the lamp room. “Fardom i-dam-da. Far ma-i-esh-ki-da.” Then he looks at you hopefully:\n\n“Far t-na-tar-o-ye.”")
				button("Offer far (fire)", func():
					if inventory.has("torch"): light_puzzle()
					else: message("Yalo shakes his head", "No far yet. Neri keeps a campfire at the northern cove; a torch there would do. It glows, so you can spot it."), content)
		"oku":
			clear_panel("Oku at the old ruins")
			learn("shora")
			if completed.has("riddles"):
				text_line("Oku smiles among the old stones. “Ho!” Then Oku whispers again about the big water in the north-east.")
				button("Hear the riddles again", riddle_quiz.bind(0), content)
			else:
				text_line("Oku sits among the broken columns. “Ki dom i-shora,” Oku says, patting a stone. Then Oku taps your notebook: “Han? Han?” Oku loves riddles.")
				button("Hear a riddle", riddle_quiz.bind(0), content)
		"gav":
			clear_panel("Gav the mail carrier")
			for w in ["kel", "-ru", "tar"]: learn(w)
			if completed.has("mail"):
				text_line("Gav tips his cap. “K-ta-har-da!” You were a great help.")
			elif not solved.has("mail_start"):
				text_line("Gav's satchel is overflowing. “Anke polu-ru kel-ir k-ri-tar-ur-da,” he sighs. He holds out three parcels, each with a label.")
				button("Take the parcels", func():
					solved.append("mail_start")
					for p in Data.PARCELS.keys(): inventory.append(p)
					save_game()
					message("Three parcels", "The labels say:\nKetu-ru\nYalo-ru\nOku-ru\n\nThe ending -ru means to. Find each person and choose Give a parcel. Ketu is at the market, Yalo at the lighthouse, Oku at the old ruins in the south-west."), content)
			else:
				var left: Array = []
				for p in Data.PARCELS.keys():
					if inventory.has(p): left.append(item_word(p))
				if left.is_empty():
					complete("mail")
					gin += 5
					learn("gin")
					learn("har")
					text_line("Gav beams. “K-ta-har-da!” He presses pan gin, five coins, into your hand.")
				else:
					text_line("Parcels still to deliver:\n" + "\n".join(left))
		"tamu":
			clear_panel("Tamu the boatman")
			learn("sena")
			text_line("Tamu leans on the oar and nods toward the sea. Far out, a small island with one tree.")
			if inventory.has("map") and not completed.has("treasure"):
				text_line("Tamu glances at your old map and raises his eyebrows.")
			button("Ask for a ride", ride_puzzle.bind(player.position.z < 60.0), content)
		"desh":
			for w in ["hai", "-o"]: learn(w)
			clear_panel("Desh at the lagoon")
			if completed.has("lagoon"):
				text_line("Desh drums a victory beat. “Ho!”")
				var again = Data.DESH.duplicate()
				again.shuffle()
				button("Play again", desh_round.bind(0, again), content)
			else:
				text_line("Desh bangs the drum. “Ta-nang-o! Ta-pav-o! Ta-sum-o!” He wants to play a game: he calls a command, and you do it.")
				var order = Data.DESH.duplicate()
				order.shuffle()
				button("Play Desh's game", desh_round.bind(0, order), content)
	for p in Data.PARCELS.keys():
		if inventory.has(p) and id != "gav":
			button("Give a parcel", give_parcel.bind(id), content)
			break
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

func item_word(id: String) -> String:
	if id == "tea": return "cha"
	if id == "bread": return "panak"
	if id == "map": return "pai (an old map)"
	if Data.PARCELS.has(id): return "kel: " + str(Data.PARCELS[id]).capitalize() + "-ru"
	for e in entities:
		if e["id"] == id: return e["word"]
	return id

func offer_help(items: Array):
	var missing: Array = []
	for id in items:
		if not inventory.has(id): missing.append(item_word(id))
	message("The request is repeated", "Still needed: " + ", ".join(missing) + ". Look for glowing columns of light beside the main path. You can reveal meanings in the notebook.")

func message(title: String, body: String):
	clear_panel(title)
	text_line(body)
	button("Return",close_panel,content)

# ------------------------------------------------------------ notebook, practice, workshop

func short_gloss(word: String) -> String:
	return str(words.get(word, "")).split(" (")[0]

func show_notebook():
	clear_panel("Field notebook")
	text_line("Collected forms. Tap a word to reveal its meaning and parts. [ok] marks forms you have mastered.  Words: " + str(discovered.size()) + "   Phrases: " + str(phrases.size()))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	content.add_child(row)
	var b1 = button("Phrasebook", show_phrasebook, row)
	var b2 = button("Workshop", show_workshop, row)
	var b3 = button("Practice", show_practice, row)
	for b in [b1, b2, b3]: b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row2 = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	content.add_child(row2)
	var b4 = button("Verb builder", show_verb_builder.bind(-1), row2)
	var b5 = button("Sentence builder", tile_puzzle.bind(-1, Callable()), row2)
	for b in [b4, b5]: b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if discovered.is_empty(): text_line("Examine objects and talk to residents to collect words.")
	for word in discovered:
		button(word + ("  [ok]" if mastered.has("w:" + word) else ""),reveal_word.bind(word),content)
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
			button(Data.SENTENCES[sid]["v"] + ("  [ok]" if mastered.has("s:" + sid) else ""), func(): sentence_card(sid, show_phrasebook), content)
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

# ------------------------------------------------------------ inventory, map, saving

func show_inventory():
	clear_panel("Your bag")
	if inventory.is_empty() and fish_caught == 0: text_line("Your bag is empty.")
	for id in inventory: text_line(item_word(id))
	if fish_caught > 0: text_line("tari × " + str(fish_caught))
	if gin > 0: text_line("gin × " + str(gin) + "  (coins)")
	var n = stars_found()
	if n > 0: text_line("hai-sao × " + str(n) + "  (sea stars)")
	if inventory.has("map"): button("Read the old map", func(): sentence_card("treasure_map", show_inventory), content)
	button("Return",close_panel,content)

func map_point(x: float, z: float, rect: Rect2) -> Vector2:
	return rect.position + Vector2((x - MAP_X0) / (MAP_X1 - MAP_X0) * rect.size.x, (z - MAP_Z0) / (MAP_Z1 - MAP_Z0) * rect.size.y)

func make_map_texture() -> ImageTexture:
	var w = int(MAP_X1 - MAP_X0)
	var h = int(MAP_Z1 - MAP_Z0)
	var img = Image.create(w, h, false, Image.FORMAT_RGB8)
	for py in range(h):
		for px in range(w):
			var x = MAP_X0 + px + 0.5
			var z = MAP_Z0 + py + 0.5
			var ht = T.height(x, z)
			var c: Color
			if ht < -0.08:
				c = Color("6cc9cc").lerp(Color("1f6f8c"), clampf(-ht / 1.6, 0.0, 1.0))
			else:
				var sd = T.sand(x, z) * (1.0 - smoothstep(0.6, 1.6, ht))
				c = Color("8fbf5a").lerp(Color("4f8a3c"), clampf(ht / 6.0, 0.0, 1.0))
				if ht > 6.5: c = c.lerp(Color("a6a196"), 0.6)
				c = c.lerp(Color("e6d3a0"), smoothstep(0.3, 0.7, sd))
				if near_path(x, z, 1.3): c = Color("c9a46d")
				if is_blocked(x, z, -1.2): c = Color("a8584a")
			img.set_pixel(px, py, c)
	return ImageTexture.create_from_image(img)

func map_view() -> Control:
	if map_tex == null: map_tex = make_map_texture()
	var holder = Control.new()
	holder.custom_minimum_size = Vector2(0, 340)
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tr = TextureRect.new()
	tr.texture = map_tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	holder.add_child(tr)
	var ov = Control.new()
	ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(ov)
	ov.draw.connect(draw_map_overlay.bind(ov))
	return holder

func draw_map_overlay(ov: Control):
	var tw = MAP_X1 - MAP_X0
	var th = MAP_Z1 - MAP_Z0
	var s = minf(ov.size.x / tw, ov.size.y / th)
	var rect = Rect2((ov.size - Vector2(tw, th) * s) * 0.5, Vector2(tw, th) * s)
	ov.draw_rect(rect, Color("5b3d28"), false, 2.0)
	var font = ThemeDB.fallback_font
	var labels = [["teka", 0, 8], ["kur", -50, 4], ["senak", -48, -14], ["sang", -60, -47], ["harbor", 0, 46], ["mora", 22, -18],
		["fardom", 72, -15], ["hai", 72, 32], ["cove", 0, -48], ["ruins", -62, 50], ["falls", 64, -27], ["Sendor", 50, 93], ["stones", 32, -50], ["orchard", 45, 30]]
	for l in labels:
		var p = map_point(l[1], l[2], rect)
		ov.draw_string_outline(font, p + Vector2(-40, 4), l[0], HORIZONTAL_ALIGNMENT_CENTER, 80, 12, 4, Color(1, 1, 1, 0.85))
		ov.draw_string(font, p + Vector2(-40, 4), l[0], HORIZONTAL_ALIGNMENT_CENTER, 80, 12, Color("2e1c0c"))
	for e in entities:
		if e["kind"] != "npc": continue
		var node = e["node"] as Node3D
		var p = map_point(node.position.x, node.position.z, rect)
		var marked = e.has("mark") and (e["mark"] as Label3D).visible
		var col = Color("3b2d25")
		if marked: col = (e["mark"] as Label3D).modulate
		ov.draw_circle(p, 4.5 if marked else 3.0, col)
		if marked:
			ov.draw_arc(p, 5.0, 0, TAU, 14, Color("2e1c0c"), 1.2)
			ov.draw_string_outline(font, p + Vector2(6, -4), display_name(e), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, 3, Color(1, 1, 1, 0.9))
			ov.draw_string(font, p + Vector2(6, -4), display_name(e), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("2e1c0c"))
	for e in entities:
		if e["kind"] != "item" or not (e["node"] as Node3D).visible: continue
		var p = map_point(e["node"].position.x, e["node"].position.z, rect)
		ov.draw_rect(Rect2(p - Vector2(2.5, 2.5), Vector2(5, 5)), Color("ffd27a"))
		ov.draw_rect(Rect2(p - Vector2(2.5, 2.5), Vector2(5, 5)), Color("5b3d28"), false, 1.0)
	var pp = map_point(player.position.x, player.position.z, rect)
	var f = -player.global_transform.basis.z
	var fd = Vector2(f.x, f.z).normalized()
	var side = Vector2(-fd.y, fd.x)
	ov.draw_colored_polygon(PackedVector2Array([pp + fd * 9.0, pp - fd * 5.0 + side * 5.0, pp - fd * 5.0 - side * 5.0]), Color("ffffff"))
	ov.draw_polyline(PackedVector2Array([pp + fd * 9.0, pp - fd * 5.0 + side * 5.0, pp - fd * 5.0 - side * 5.0, pp + fd * 9.0]), Color("c0392b"), 2.0)

func show_map():
	clear_panel("Island map")
	content.add_child(map_view())
	text_line("You are the white arrow. North is up. Yellow dots: the next step of the story. Blue dots: side quests. Small gold squares: things to pick up.", 16)
	text_line("Quests", 22)
	var reached = false
	for q in quests:
		if completed.has(q[0]): text_line("Done: " + q[1], 17)
		elif not reached:
			text_line("Now: " + q[1], 17)
			reached = true
	for sq in side_quests:
		if completed.has(sq[0]): text_line("Done: " + sq[2], 17)
		elif quest_open(sq[0]): text_line("• " + quest_text(sq), 17)
		else: text_line("• ??? Something on this island is still a secret.", 17)
	text_line("It is " + time_word + " (" + Data.TIMES.get(time_word, "") + "). Coins: " + str(gin) + " gin.", 17)
	text_line("Travel", 22)
	var any = false
	for id in visited:
		if id == zone_id: continue
		any = true
		button("Go to " + region_name(id), travel.bind(id), content)
	if not any: text_line("Places you visit appear here so you can travel back quickly.", 17)
	text_line("Progress:  " + str(discovered.size()) + " words,  " + str(phrases.size()) + " phrases,  " + str(solved.size()) + " doors and puzzles,  " + str(mastered.size()) + " mastered.", 17)
	button("Return",close_panel,content)
	button("Reset progress",confirm_reset,content)

func travel(id: String):
	var p = region_spawn(id)
	player.position = Vector3(p.x, T.height(p.x, p.z) + 0.3, p.z)
	player.velocity = Vector3.ZERO
	last_safe = player.position
	camera.rotation.x = 0.0
	close_panel()
	toast(region_name(id))

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
		visited.clear()
		fish_caught = 0
		gin = 0
		hiding.clear()
		for e in entities: e["node"].show()
		player.position = Vector3(0,0.1,36)
		player.rotation = Vector3.ZERO
		camera.rotation = Vector3.ZERO
		refresh_world()
		save_game()
		show_intro(),content)

func save_game():
	var file = FileAccess.open(SAVE,FileAccess.WRITE)
	var keep = player.position
	if riding: player.position = ride_dest
	if file:
		file.store_string(JSON.stringify({"guesses":guesses,"inventory":inventory,"discovered":discovered,"completed":completed,"mastered":mastered,"phrases":phrases,"solved":solved,"visited":visited,"fish":fish_caught,"gin":gin,"day":day_t,"hud_small":hud_small,"whale":whale_seen,"position":[player.position.x,player.position.y,player.position.z],"yaw":player.rotation.y,"pitch":camera.rotation.x}))
	player.position = keep

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
	visited = data.get("visited",[])
	fish_caught = int(data.get("fish",0))
	gin = int(data.get("gin", 0))
	day_t = float(data.get("day", 0.12))
	hud_small = bool(data.get("hud_small", false))
	whale_seen = bool(data.get("whale", false))
	var p = data.get("position",[0,0.1,36])
	player.position = Vector3(p[0],p[1],p[2])
	if T.deep(player.position.x, player.position.z) and not near_dock(player.position): player.position = Vector3(0, 0.1, 36)
	player.position.y = maxf(player.position.y, T.height(player.position.x, player.position.z) + 0.05)
	last_safe = player.position
	player.rotation.y = data.get("yaw",0)
	camera.rotation.x = data.get("pitch",0)
	var used: Array = []
	if completed.has("meal"): used.append_array(["water","fruit","container"])
	if completed.has("bag"): used.append("forest_bag")
	if completed.has("bridge"): used.append_array(["wood","stone","rope"])
	if completed.has("healer"): used.append("herb")
	if completed.has("lighthouse"): used.append("torch")
	for e in entities:
		if inventory.has(e["id"]) or used.has(e["id"]) or (e["kind"] == "star" and solved.has(e["id"])): e["node"].hide()
		elif e["kind"] == "item" or e["kind"] == "star": e["node"].show()
	if player.position.z > 60.0: (ferry_node.get_parent() as Node3D).position = Vector3(FERRY_ISLET.x, -0.08, FERRY_ISLET.z)
	if ui: layout_hud()
	refresh_world()

func _notification(what):
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player): save_game()

# ------------------------------------------------------------ third expansion: places

func build_places3():
	# ---- south-west ruins ----
	for c in Art.ruins(self, Vector3(-62, 0, 40)):
		solid(Vector3(c.x, 1.5, c.z), Vector3(0.8, 3.0, 0.8))
	solid(Vector3(-60.8, 0.8, 38.6), Vector3(2.0, 1.6, 1.8))
	block(-62, 40, 5.2)
	# ---- north-east waterfall and hidden room ----
	var fz = -35.7
	var top = T.height(64, -37.2)
	falls_node = Art.waterfall(self, Vector3(64, -0.12, fz), 2.6, top + 0.5)
	Art.cave_mouth(self, Vector3(64, 0.75, -36.25))
	for i in range(6):
		var a = PI + i * PI / 5.0
		var p = Vector3(64 + cos(a) * 3.6, 0, -32.4 + sin(a) * 3.6)
		Art.sph(self, Vector3(p.x, T.height(p.x, p.z) + 0.05, p.z), 0.5, Color("8d9394"), Vector3(1.3, 0.6, 1), 7)
	# ---- Sendor, the small island ----
	var plank_t: Array = []
	var plank_c: Array = []
	for i in range(16):
		plank_t.append(Transform3D(Basis.IDENTITY, Vector3(48, 0.07, 66.3 + i * 0.5)))
		plank_c.append(Color("a77b4f").lerp(Color("8f6a43"), float(i % 4) / 4.0))
	var pm = BoxMesh.new()
	pm.size = Vector3(2.6, 0.08, 0.485)
	Art.scatter(self, pm, plank_t, plank_c, false)
	for i in range(4):
		for sx in [-1.25, 1.25]:
			Art.cyl(self, Vector3(48 + sx, -0.6, 66.6 + i * 2.4), 0.09, 0.11, 2.8, Color("5b3d28"), Vector3.ZERO, 7)
	solid(Vector3(48, 0.04, 70.0), Vector3(2.6, 0.08, 8.0))
	var palm_y = T.height(51, 85)
	Art.palm(self, Vector3(51, palm_y, 85), 0.3)
	solid(Vector3(51, palm_y + 1.5, 85), Vector3(0.5, 3.0, 0.5))
	Art.sph(self, Vector3(45, T.height(45, 84) + 0.4, 84), 1.0, Color("8d9394"), Vector3(1.4, 1.0, 1.2), 10)
	solid(Vector3(45, 0.6, 84), Vector3(2.4, 1.2, 2.0))
	block(45, 84, 1.6)
	block(51, 85, 0.8)
	Art.signpost(self, Vector3(49.6, T.height(49.6, 75.2), 75.2), "Sendor", 180)
	Art.crate(self, Vector3(46.4, T.height(46.4, 76), 76), 0.6, Color("b58a52"), 25)
	ferry_node = Art.boat(self, FERRY_HARBOR)
	ferry_node.scale = Vector3(0.75, 0.75, 0.75)
	# more sea birds and beach things
	Art.umbrella(self, Vector3(53.5, T.height(53.5, 81), 81), Color("2a9d8f"))

func build_night_and_weather():
	# stars on a dome that follows the player
	stars_node = Node3D.new()
	add_child(stars_node)
	var rs = RandomNumberGenerator.new()
	rs.seed = 777
	var st: Array = []
	var sc: Array = []
	for i in range(420):
		var a = rs.randf() * TAU
		var el = asin(rs.randf_range(0.08, 1.0))
		var d = Vector3(cos(a) * cos(el), sin(el), sin(a) * cos(el))
		var s = rs.randf_range(0.6, 1.6)
		st.append(Transform3D(Basis.from_scale(Vector3(s, s, s)), d * 380.0))
		sc.append(Color(1, 1, 1))
	var mm = Art.scatter(stars_node, Art.sphere_mesh(0.9, 4), st, sc, false)
	stars_mat = Art.unshaded(Color(1, 1, 0.92, 0.0), true)
	mm.material_override = stars_mat
	moon = MeshInstance3D.new()
	moon.mesh = Art.sphere_mesh(14.0, 16)
	moon.material_override = Art.unshaded(Color("f4f1dc"))
	moon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stars_node.add_child(moon)
	moon.position = Vector3(-0.55, 0.6, -0.58).normalized() * 360.0
	shooting = MeshInstance3D.new()
	var sm = BoxMesh.new()
	sm.size = Vector3(0.6, 0.6, 26.0)
	shooting.mesh = sm
	shooting.material_override = Art.unshaded(Color(1, 1, 0.9, 0.85), true)
	shooting.visible = false
	add_child(shooting)
	var fm = Art.unshaded(Color("ffe680"))
	for i in range(46):
		var f = MeshInstance3D.new()
		f.mesh = Art.sphere_mesh(0.06, 5)
		f.material_override = fm
		f.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		f.visible = false
		add_child(f)
		var c = [Vector2(0, -14), Vector2(12, -24), Vector2(-14, -12), Vector2(45, 22), Vector2(-44, -18), Vector2(64, -32)][i % 6] + Vector2(rs.randf_range(-6, 6), rs.randf_range(-6, 6))
		fireflies.append({"node": f, "c": Vector3(c.x, T.height(c.x, c.y), c.y), "p": rs.randf() * 20.0})
	for i in range(3):
		fireworks.append(Art.burst(self, 70, 0.12))
	splash = Art.burst(self, 50, 0.22)
	splash.direction = Vector3.UP
	splash.spread = 35.0
	splash.gravity = Vector3(0, -12, 0)
	splash.initial_velocity_min = 5.0
	splash.initial_velocity_max = 8.0
	whale_node = Art.whale()
	whale_node.visible = false
	add_child(whale_node)
	rain_fx = Art.rain(player)
	rainbow_mi = Art.rainbow(self)

# ------------------------------------------------------------ third expansion: time, weather, surprises

func time_phase(t: float) -> String:
	if t < 0.06 or t >= 0.94: return "salma"
	if t < 0.25: return "monar"
	if t < 0.58: return "yar"
	if t < 0.68: return "wanar"
	return "yesh"

func update_sky(delta: float):
	day_t = fmod(day_t + delta / DAY_LEN, 1.0)
	var t2 = day_t + (1.0 if day_t < 0.1 else 0.0)
	night = smoothstep(0.58, 0.7, t2) * (1.0 - smoothstep(0.92, 1.06, t2))
	var warm = maxf(maxf(1.0 - absf(t2 - 0.63) / 0.07, 1.0 - absf(t2 - 1.0) / 0.07), 0.0)
	var u = clampf((day_t + 0.03) / 0.7, 0.0, 1.0)
	if day_t > 0.9: u = 0.0
	var el = 5.0 + sin(u * PI) * 55.0
	if night > 0.5: el = 48.0
	sun.rotation_degrees = Vector3(-el, -32.0 - (u - 0.5) * 120.0 if night <= 0.5 else 150.0, 0)
	sun.light_energy = lerpf(0.9, 0.24, night) * lerpf(1.0, 0.62, rain_amt)
	sun.light_color = Color("fff0d8").lerp(Color("ffb27a"), warm * 0.8).lerp(Color("a8bcff"), night)
	sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY if night > 0.5 else DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY
	psm.sky_top_color = Color("3f86d0").lerp(Color("7c8ca0"), rain_amt * 0.6).lerp(Color("0b1433"), night)
	var hz = Color("bfe4f2").lerp(Color("f2b27a"), warm * 0.75).lerp(Color("aab4bf"), rain_amt * 0.5).lerp(Color("1d2c4c"), night)
	psm.sky_horizon_color = hz
	psm.ground_horizon_color = hz
	psm.ground_bottom_color = Color("86b9c9").lerp(Color("0d1a30"), night)
	env.ambient_light_energy = lerpf(0.55, 0.34, night)
	env.tonemap_exposure = lerpf(0.82, 1.05, night)
	env.fog_light_color = Color("c9e7f0").lerp(Color("f0c8a0"), warm * 0.5).lerp(Color("aab4bf"), rain_amt * 0.4).lerp(Color("1c2a44"), night)
	stars_mat.albedo_color.a = clampf(night * 1.2 - 0.1, 0.0, 1.0) * (1.0 - rain_amt)
	stars_node.position = player.position
	cloud_mat.albedo_color = Color(1, 1, 1, 0.93).lerp(Color(0.62, 0.66, 0.72, 0.95), rain_amt).lerp(Color(0.2, 0.25, 0.38, 0.85), night)
	moon.visible = night > 0.15
	var w = time_phase(day_t)
	if w != time_word:
		if time_word != "":
			learn(w)
			toast(w.capitalize() + ": " + Data.TIMES[w])
		time_word = w

func update_night_life(delta: float):
	for f in fireflies:
		var n = f["node"] as Node3D
		n.visible = night > 0.45
		if not n.visible: continue
		var t = clock * 0.5 + f["p"]
		var c: Vector3 = f["c"]
		n.position = c + Vector3(sin(t * 1.3) * 2.5, 0.8 + sin(t * 2.1) * 0.5, cos(t * 0.9) * 2.5)
		n.scale = Vector3.ONE * (0.6 + 0.6 * absf(sin(t * 3.0 + f["p"])))
	if falls_node:
		var foam = falls_node.get_meta("foam") as Node3D
		foam.scale = Vector3(1.4, 0.25, 0.9) * (1.0 + sin(clock * 6.0) * 0.06)
	# shooting stars
	if night > 0.8 and rain_amt < 0.2:
		shoot_cd -= delta
		if shoot_cd <= 0.0 and shoot_t < 0.0:
			shoot_t = 0.0
			shoot_cd = randf_range(10.0, 25.0)
			var a = randf() * TAU
			shoot_from = player.position + Vector3(cos(a) * 180.0, randf_range(110.0, 160.0), sin(a) * 180.0)
			shoot_dir = Vector3(-sin(a), -0.35, cos(a)).normalized()
	if shoot_t >= 0.0:
		shoot_t += delta
		shooting.visible = shoot_t < 1.2
		shooting.position = shoot_from + shoot_dir * shoot_t * 140.0
		shooting.look_at(shooting.position + shoot_dir, Vector3.UP)
		if shoot_t > 1.2: shoot_t = -1.0
	# fireworks once Neri has been found
	if completed.has("cove") and night > 0.7:
		firework_cd -= delta
		if firework_cd <= 0.0:
			firework_cd = randf_range(1.6, 3.4)
			var fw: CPUParticles3D = fireworks[randi() % fireworks.size()]
			fw.position = Vector3(randf_range(-14, 14), randf_range(24, 32), randf_range(0, 22))
			fw.color = [Color("ff5d5d"), Color("ffd34d"), Color("6de0ff"), Color("b38bff"), Color("7dff8a"), Color("ff8ad8")][randi() % 6]
			fw.restart()

func update_weather(delta: float):
	if raining > 0.0:
		raining -= delta
		rain_amt = minf(rain_amt + delta * 0.4, 1.0)
		if raining <= 0.0:
			rain_fx.emitting = false
			weather_cd = randf_range(220.0, 340.0)
			if night < 0.3:
				rainbow_t = 50.0
				var f = sun.global_transform.basis.z
				var d = Vector3(-f.x, 0, -f.z).normalized()
				rainbow_mi.position = player.position + d * 150.0
				rainbow_mi.position.y = 0.0
				rainbow_mi.look_at(Vector3(player.position.x, 0.0, player.position.z), Vector3.UP)
				rainbow_mi.position.y = 60.0
				rainbow_mi.visible = true
				toast("Hen-ma! Look at the sky.")
	else:
		rain_amt = maxf(rain_amt - delta * 0.3, 0.0)
		weather_cd -= delta
		if weather_cd <= 0.0:
			if randf() < 0.6: start_rain()
			else: weather_cd = randf_range(120.0, 200.0)
	if rainbow_t > 0.0:
		rainbow_t -= delta
		var s = clampf(minf(50.0 - rainbow_t, rainbow_t) / 6.0, 0.0, 1.0)
		(rainbow_mi.material_override as ShaderMaterial).set_shader_parameter("strength", s)
		if rainbow_t <= 0.0: rainbow_mi.visible = false

func start_rain():
	raining = randf_range(30.0, 45.0)
	rain_fx.emitting = true
	learn("ser")
	learn("-ng")
	if not phrases.has("rain_starts"): phrases.append("rain_starts")
	toast("I-ser-ng! It is beginning to rain.")

func try_whale(force: bool = false) -> bool:
	var fwd = -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var best = Vector3.ZERO
	var best_score = -9.0
	for i in range(16):
		var a = i * TAU / 16.0
		var d = Vector3(cos(a), 0, sin(a))
		var p = player.position + d * (30.0 if force else 44.0)
		if T.height(p.x, p.z) > -2.0: continue
		var sc = d.dot(fwd)
		if sc > best_score:
			best_score = sc
			best = p
	if best_score < -1.5: return false
	whale_pos = Vector3(best.x, 0, best.z)
	var to = (whale_pos - player.position).normalized()
	whale_dir = Vector3(-to.z, 0, to.x)
	whale_t = 0.0
	whale_node.visible = true
	return true

func update_whale(delta: float):
	if whale_t < 0.0:
		if panel.visible: return
		whale_cd -= delta
		if whale_cd <= 0.0:
			whale_cd = randf_range(120.0, 210.0)
			if T.coast(player.position.x, player.position.z) < 22.0 or riding: try_whale()
		return
	whale_t += delta
	var u = whale_t / 5.0
	if u >= 1.0:
		whale_t = -1.0
		whale_node.visible = false
		return
	var prev_y = whale_node.position.y
	whale_node.position = whale_pos + whale_dir * (u - 0.5) * 12.0 + Vector3(0, sin(u * PI) * 6.5 - 4.6, 0)
	whale_node.rotation = Vector3(0, atan2(whale_dir.x, whale_dir.z), 0)
	(whale_node.get_meta("body") as Node3D).rotation.x = -cos(u * PI) * 1.05
	(whale_node.get_meta("body") as Node3D).rotation.z = sin(u * PI) * 0.5
	if (prev_y < -0.1 and whale_node.position.y >= -0.1) or (prev_y > -0.1 and whale_node.position.y <= -0.1):
		splash.position = Vector3(whale_node.position.x, 0.0, whale_node.position.z)
		splash.color = Color(0.92, 0.97, 1.0)
		splash.restart()
	if u > 0.35 and not whale_seen:
		whale_seen = true
		learn("var")
		learn("tari")
		if not phrases.has("big_fish"): phrases.append("big_fish")
		toast("Var tari! A big fish! (in your phrasebook)")
	elif u > 0.35 and u < 0.37:
		toast("Var tari!")

# ---- the ferry to Sendor ----

func ride_puzzle(to_islet: bool):
	learn("sendor")
	learn("tar")
	learn("-ru")
	var place = "Sendor" if to_islet else "Teka"
	var opts = [place + "-ru t-na-tar-o-ye.", place + "-ta t-na-tar-o-ye.", place + "-ma t-na-tar-o-ye."]
	choice_puzzle("Tamu's boat", ("Tamu points out to sea, toward a small island with one tree.\n\nAsk Tamu to take you to Sendor." if to_islet else "Tamu waits by the boat, ready to row home.\n\nAsk Tamu to take you back to the village."), opts, 0, func(): master("q:ride"),
		opts[0] + " means Please take me to " + ("Sendor." if to_islet else "the village.") + " The ending -ru means to; -ta would mean from and -ma in.",
		"Which ending means to? -ru is to, -ta is from, -ma is in.", Callable(),
		func(): button("Set off!", start_ride.bind(to_islet), content))

func start_ride(to_islet: bool):
	close_panel()
	riding = true
	ride_t = 0.0
	walk_to = {}
	target = {}
	hover = {}
	ride_path = [FERRY_HARBOR, Vector3(12, 0, 55), Vector3(31, 0, 62.5), FERRY_ISLET]
	if not to_islet: ride_path.reverse()
	ride_dest = Vector3(48, 0.15, 70.5) if to_islet else Vector3(0.5, 0.15, 41.2)
	ride_whale = not whale_seen
	toast("Sena-li! By boat!")

func path_point(path: Array, t: float) -> Vector3:
	var segs = path.size() - 1
	var f = clampf(t, 0.0, 1.0) * segs
	var i = mini(int(f), segs - 1)
	return (path[i] as Vector3).lerp(path[i + 1], f - i)

func update_ride(delta: float):
	var fe = ferry_node.get_parent() as Node3D
	ferry_node.position.y = 0.04 + sin(clock * 1.3 + 2.0) * 0.04
	ferry_node.rotation.z = sin(clock * 1.1) * 0.03
	if not riding: return
	ride_t += delta / 10.0
	var e = smoothstep(0.0, 1.0, ride_t)
	var p = path_point(ride_path, e)
	var ahead = path_point(ride_path, minf(e + 0.02, 1.0))
	fe.position = Vector3(p.x, -0.08, p.z)
	if ahead.distance_to(p) > 0.01: fe.rotation.y = lerp_angle(fe.rotation.y, atan2(ahead.x - p.x, ahead.z - p.z), minf(delta * 3.0, 1.0))
	player.position = Vector3(p.x, 0.45, p.z)
	player.velocity = Vector3.ZERO
	if ride_whale and ride_t > 0.4:
		ride_whale = false
		try_whale(true)
	if ride_t >= 1.0:
		riding = false
		player.position = ride_dest
		last_safe = ride_dest
		fe.position = Vector3(ride_path[-1].x, -0.08, ride_path[-1].z)
		for a in animals:
			if a.get("follow", false): (a["e"]["node"] as Node3D).position = ride_dest + Vector3(1.0, 0, -1.0)
		save_game()

# ---- the quest box folds away when tapped ----

func _on_status_input(ev: InputEvent):
	var tapped = (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed)
	if tapped:
		hud_small = not hud_small
		layout_hud()
		save_game()
		status.accept_event()

func layout_hud():
	update_status()
	status.visible = not hud_small
	status_small.visible = hud_small
	top_row.position = Vector2(174, 30) if hud_small else Vector2(14, 124)

func update_status():
	var obj = objective()
	var total = quests.size() + side_quests.size()
	status_small.text = "Quests " + str(quests_done()) + "/" + str(total)
	status.text = obj + "\nDone: " + str(quests_done()) + " of " + str(total) + ".  Tap this box to fold it."
	if hud_small and obj != last_objective and last_objective != "": toast("New goal! Tap Quests to read it.")
	last_objective = obj

# ---- third expansion: quests and mini-games ----

func buy_bread():
	for w in ["yan", "panak", "gin", "vel"]: learn(w)
	choice_puzzle("Buying bread", "Ketu waits for your request. How do you ask politely for one loaf?",
		["Yan panak t-na-ven-o-ye.", "Panak yan-ru t-na-ven-o-ye.", "Yan panak k-i-mai-pa-da."], 0, func(): master("q:buy"),
		"Yan panak t-na-ven-o-ye: please give me one bread. Ketu answers: “Vel gin.” Two coins.",
		"The number comes before the noun, and a polite request ends in -o-ye. k-i-mai-pa-da would mean I bought it.", talk.bind("ketu"),
		func():
			button("Pay vel gin (2 coins)", func():
				if gin >= 2:
					gin -= 2
					inventory.append("bread")
					save_game()
					message("Panak!", "Ketu wraps a warm loaf for you. You have " + str(gin) + " gin left. The village dog would love some.")
				else:
					message("Not enough gin", "You have " + str(gin) + " gin. Sell fish to Ketu (one gin each), or help Gav deliver parcels."), content))

func give_parcel(id: String):
	learn("-ru")
	clear_panel("Which parcel?")
	text_line("Read the labels. The ending -ru means to.")
	for p in Data.PARCELS.keys():
		if not inventory.has(p): continue
		var who: String = Data.PARCELS[p]
		button(item_word(p), func():
			if who == id:
				consume([p])
				solved.append("mail_" + id)
				learn("har")
				if not phrases.has("thank_you"): phrases.append("thank_you")
				save_game()
				message("“K-ta-har-da!”", id.capitalize() + " takes the parcel and bows. K-ta-har-da means I thank you: k- is I acting, ta- is you receiving." + ("\n\nAll parcels delivered. Go back to Gav at the harbor." if not has_any_parcel() else ""))
			else:
				learn("maki")
				message("“Maki.”", "Maki means no. This label says " + who.capitalize() + "-ru: to " + who.capitalize() + "."), content)
	button("Return", talk.bind(id), content)

func has_any_parcel() -> bool:
	for p in Data.PARCELS.keys():
		if inventory.has(p): return true
	return false

func entity_by_id(id: String) -> Dictionary:
	for e in entities:
		if e["id"] == id: return e
	return {}

func start_hide():
	learn("pal")
	for kid in ["rin", "ola"]:
		var e = entity_by_id(kid)
		var spot: Vector3 = HIDE_SPOTS[kid]
		(e["node"] as Node3D).position = Vector3(spot.x, gy(spot.x, spot.z), spot.z)
		hiding[kid] = true
	message("Ma-ta-pal-o-ki!", "Ola covers your eyes and shouts “Ma-ta-pal-o-ki!” Don't look! When you turn around, Rin and Ola are gone. One hid near the school, one near the market. Find them!")

func found_puzzle(id: String):
	choice_puzzle("Found you!", id.capitalize() + " is crouching out of sight, giggling. What do you shout?",
		["K-ta-pal-da!", "T-na-pal-da!", "Ma-k-ta-pal-ki-da!"], 0, func():
			hiding[id] = false
			var e = entity_by_id(id)
			(e["node"] as Node3D).position = e["home"]
			if not hiding.get("rin", false) and not hiding.get("ola", false):
				complete("hide"),
		"K-ta-pal-da: I see you! k- is I acting and ta- is you being seen. T-na-pal-da would mean you see me, and ma- ... -ki says not.",
		"Who sees whom? k- is I as the one acting, ta- is you receiving. ma- ... -ki means not.")

func riddle_quiz(i: int):
	var r: Dictionary = Data.RIDDLES[i]
	for w in r["options"]: learn(w)
	for w in ["yar", "hen", "yesh", "sa"]: learn(w)
	choice_puzzle("Oku's riddle: " + str(i + 1) + " of 5", "Oku chants:\n\n“" + r["q"] + " Han?”\n\nWhat is it?", r["options"], r["correct"], func():
		master("q:riddle" + str(i))
		if i == 4:
			complete("riddles")
			if not phrases.has("room_behind"): phrases.append("room_behind"),
		r["why"] + " (" + r["en"] + ")", "Read the clues one at a time. hen-ma is in the sky, wak-ma in the water, yesh-ma at night, yar-ma in the day.", talk.bind("oku"),
		func():
			if i < 4: button("Next riddle", riddle_quiz.bind(i + 1), content)
			else:
				for w in ["shan", "gan", "-nu"]: learn(w)
				text_line("Oku leans close and whispers a secret: “Var wak-ni shanma gan i-esh-nu.” They say there is a room behind the big water. Oku glances toward the north-east hills."))

func cave_panel():
	clear_panel("gan: a hidden room")
	learn("gan")
	text_line("You squeeze behind the falling water. Inside is a small room, and blue crystals glow in the walls.")
	button("What do you see?", func(): sentence_card("cave_glow", cave_panel), content)
	if not inventory.has("map") and not completed.has("treasure"):
		button("Search behind the crystals", func():
			inventory.append("map")
			learn("pai")
			if not phrases.has("treasure_map"): phrases.append("treasure_map")
			refresh_world()
			save_game()
			sentence_card("treasure_map", close_panel), content)
	button("Shout into the room", func():
		var w = discovered[discovered.size() - 1] if not discovered.is_empty() else "ho"
		message("Echo!", "You shout “" + w + "!”\n\n“" + w + "... " + w + "... " + w + "...” the room answers."), content)
	button("Return", close_panel, content)

func mound_panel(id: String):
	var md: Dictionary = Data.MOUNDS[id]
	for w in ["murak", "sek", "-ni", "men", "shan", "dal"]: learn(w)
	clear_panel("A sandy mound")
	text_line("A little stick marks a mound of sand. Where is this spot?\n\n“" + md["v"] + "”\n\nThe map says: Gin murak-ni shanma i-esh-da.")
	button("Dig here", func():
		if md["right"]: dig_treasure()
		else: message("Only sand", "Nothing here. This spot is " + md["v"] + " (" + md["en"] + "). The map says murak-ni shanma: behind the tree, on the far side from the dock."), content)
	button("Read the map again", func(): sentence_card("treasure_map", mound_panel.bind(id)), content)
	button("Return", close_panel, content)

func dig_treasure():
	consume(["map"])
	gin += 10
	complete("treasure")
	refresh_world()
	var fw: CPUParticles3D = fireworks[0]
	fw.position = chest_node.global_position + Vector3(0, 1.0, 0)
	fw.color = Color("ffd34d")
	fw.restart()
	message("Dar gin!", "Your shovel hits wood. A chest! Inside are dar gin: ten coins, and a note in Neri's handwriting: “Ho! Ti kelar i-ho.” Good, you are a good traveler.")

func collect_star(e: Dictionary):
	(e["node"] as Node3D).hide()
	if not solved.has(e["id"]): solved.append(e["id"])
	var n = stars_found()
	var ords = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth"]
	var o: String = Data.ORDINALS[n - 1]
	learn("hai-sao")
	learn("-ve")
	learn(o)
	toast(o.capitalize() + " hai-sao! (the " + ords[n - 1] + " sea star)")
	if n >= STARS.size():
		complete("seastars")
		message("Barve hai-sao!", "The eighth sea star! You found them all. The ending -ve makes order words: yan-ve first, vel-ve second, bar-ve eighth.")
	save_game()

# ---- production practice: sentence tiles and the verb builder ----

func tile_puzzle(i: int = -1, back: Callable = Callable()):
	if i < 0: i = randi() % Data.TILES.size()
	var tp: Dictionary = Data.TILES[i]
	if not back.is_valid(): back = show_notebook
	clear_panel("Sentence builder")
	text_line("Build this sentence in Varnak:\n“" + tp["en"] + "”")
	var built: Array = []
	var shown = text_line("…", 24)
	var flow = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 8)
	content.add_child(flow)
	var pool: Array = tp["tiles"].duplicate()
	pool.append_array(tp["decoys"])
	pool.shuffle()
	var used: Array = []
	var feedback = text_line("", 19)
	for w in pool:
		var b = Button.new()
		b.text = w
		b.custom_minimum_size = Vector2(70, 50)
		flow.add_child(b)
		b.pressed.connect(func():
			built.append(w)
			used.append(b)
			b.disabled = true
			shown.text = " ".join(built))
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	content.add_child(row)
	var undo = button("Undo", func():
		if built.is_empty(): return
		built.pop_back()
		(used.pop_back() as Button).disabled = false
		shown.text = " ".join(built) if not built.is_empty() else "…", row)
	var check = button("Check", func():
		if built == tp["tiles"]:
			feedback.text = "Correct! " + " ".join(tp["tiles"])
			feedback.add_theme_color_override("font_color", Color("2f6b2f"))
			master("t:" + str(i))
		else:
			feedback.text = "Not quite. " + tp["tip"] + " The usual order is: the one acting, the thing acted on, places, then the verb."
			feedback.add_theme_color_override("font_color", Color("8a2f1f")), row)
	undo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.move_child(feedback, content.get_child_count() - 1)
	button("Another sentence", tile_puzzle.bind(-1, back), content)
	button("Back", back, content)

func verb_form(choice: Dictionary) -> String:
	var parts: Array = []
	var neg = choice.get(0, "") == "ma-"
	if neg: parts.append("ma")
	parts.append(str(choice.get(1, "na-")).trim_suffix("-"))
	parts.append(choice.get(2, "lum"))
	for k in [3, 4]:
		if choice.get(k, "") != "": parts.append(str(choice[k]).trim_prefix("-"))
	if neg: parts.append("ki")
	if choice.get(5, "") != "": parts.append(str(choice[5]).trim_prefix("-"))
	return "-".join(parts)

func show_verb_builder(i: int = -1):
	if i < 0: i = randi() % Data.VERBS.size()
	var ch: Array = Data.VERBS[i]
	for w in ["na-", "ta-", "i-", "ri-", "lum", "pav", "sul", "sum", "tal", "nang"]: learn(w)
	clear_panel("Verb builder")
	text_line("Build one Varnak verb that means:\n“" + ch[0] + "”")
	text_line("lum go · pav run · sul sleep · sum swim · tal arrive · nang walk\n-im in progress · -ak completed · -ur usually · -pa past · -fu future · -da seen · -shi apparently · -nu reportedly · ma- ... -ki not", 15)
	var choice: Dictionary = {}
	var preview = text_line("", 28)
	for si in range(Data.VERB_SLOTS.size()):
		var slot: Array = Data.VERB_SLOTS[si]
		text_line(slot[0], 16)
		var flow = HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		content.add_child(flow)
		var group = ButtonGroup.new()
		var first: Button = null
		for opt in slot[1]:
			var b = Button.new()
			b.toggle_mode = true
			b.button_group = group
			b.text = opt if opt != "" else "none"
			b.custom_minimum_size = Vector2(58, 46)
			flow.add_child(b)
			b.toggled.connect(func(on):
				if on:
					choice[si] = opt
					preview.text = verb_form(choice))
			if first == null: first = b
		first.button_pressed = true
	var feedback = text_line("", 19)
	button("Check", func():
		if verb_form(choice) == ch[1]:
			feedback.text = "Correct! " + ch[1]
			feedback.add_theme_color_override("font_color", Color("2f6b2f"))
			master("vb:" + str(i))
		else:
			feedback.text = "Not quite. Look at each slot: who acts, which action, when, and how you know it."
			feedback.add_theme_color_override("font_color", Color("8a2f1f")), content)
	button("Show me", func(): feedback.text = "The answer is " + ch[1] + ".", content)
	button("Another verb", show_verb_builder.bind(-1), content)
	button("Notebook", show_notebook, content)

func follow_player(a: Dictionary, delta: float):
	var node = a["e"]["node"] as Node3D
	var fwd = -player.global_transform.basis.z
	fwd.y = 0.0
	fwd = fwd.normalized()
	var side = Vector3(-fwd.z, 0, fwd.x)
	var tp = player.position - fwd * 1.8 + side * 0.9
	if riding: tp = node.position
	var to = tp - node.position
	to.y = 0.0
	if to.length() > 30.0:
		node.position = tp
		to = Vector3.ZERO
	var moving = to.length() > 0.5
	if moving:
		node.position += to.normalized() * minf(to.length(), (1.5 + to.length() * 1.6) * delta * 1.0)
		node.rotation.y = lerp_angle(node.rotation.y, atan2(to.x, to.z), minf(delta * 8.0, 1.0))
	var ground = gy(node.position.x, node.position.z)
	if T.deep(node.position.x, node.position.z) and not riding: ground = maxf(ground, 0.05)
	node.position.y = ground + (absf(sin(clock * 12.0)) * 0.06 if moving else 0.0)
	(node.get_meta("tail") as Node3D).rotation.y = sin(clock * 16.0) * 0.7

func near_dock(p: Vector3) -> bool:
	if absf(p.x) < 4.2 and p.z > 29.5 and p.z < 42.5: return true
	if absf(p.x - 48.0) < 1.5 and p.z > 65.8 and p.z < 74.2: return true
	return false
