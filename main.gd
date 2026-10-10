extends Node3D

const Art = preload("res://art.gd")
const Data = preload("res://data.gd")
const T = preload("res://terrain.gd")
const SAVE = "user://varnak_island.json"
const REACH = 4.0
# River crossings: [village-side end, far-side end]
const CROSSINGS = [[Vector3(0, 0, -18.4), Vector3(0, 0, -27.6)], [Vector3(-30, 0, -18.0), Vector3(-30, 0, -28.0)], [Vector3(52, 0, -19.4), Vector3(52, 0, -33.6)]]
const WALK_RANGE = 70.0
# Paths painted on the ground (x1, z1, x2, z2). The main north-south path along x = 0 is drawn by the shader.
const PATHS = [
	Vector4(-2, 18, -38, 15), Vector4(-48, 4, -47, -3), Vector4(-44, -5, -31, -17), Vector4(-30, -17, -30, -29),
	Vector4(-30, -29, -46, -33), Vector4(-46, -33, -59, -37), Vector4(2, -10, 44, -10), Vector4(44, -10, 52, -7),
	Vector4(52, -7, 73, -7), Vector4(50, -7, 46, 14), Vector4(46, 14, 62, 20), Vector4(44, -10, 52, -19),
	Vector4(52, -19, 52, -33), Vector4(52, -33, 34, -40), Vector4(34, -40, 7, -36),
	Vector4(-50, 20, -60, 33), Vector4(52, -33, 61, -33.5),
	Vector4(-56, 9, -88, 3), Vector4(-88, 3, -101, 2), Vector4(-101, 2, -98, 14), Vector4(-101, 2, -99, -16)
]
const DAY_LEN = 480.0
const FERRY_HARBOR = Vector3(1.8, 0, 44.6)
const FERRY_ISLET = Vector3(49.8, 0, 66.0)
const STARS = [Vector3(-14, 0, -46), Vector3(-30, 0, -45), Vector3(66, 0, 31), Vector3(55, 0, 86), Vector3(-30, 0, 41), Vector3(30, 0, 40), Vector3(-134, 0, 6), Vector3(-71, 0, 47)]
const HIDE_SPOTS = {"rin": Vector3(-50.5, 0, -13.4), "ola": Vector3(-42.4, 0, 19.9)}
const MAP_X0 = -143.0
const MAP_X1 = 90.0
const MAP_Z0 = -56.0
const MAP_Z1 = 94.0

var player: CharacterBody3D
var camera: Camera3D
var ui: Control
var status: Label
var prompt: Button
var prompt_text_since: float = 0.0
var prompt_last: String = ""
var toast_label: Label
var panel: PanelContainer
var close_x: Button
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
var walk_via: Array = []
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
var diff_bias: int = 0
var last_level: int = 0
var best_speed: int = 0
var mg: Dictionary = {}
var quote_re: RegEx
var bubble_range: float = 9.0
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
	["gossip","lira","Village gossip! Hear six pieces of gossip (ask people: Any gossip?) and ask three people about what was said."],
	["strange","","Something odd is going on. Find eight strange things around the island."],
	["rumor","","Start three rumors of your own (Tell some gossip), then hear one come back from someone else (What's the news?)."],
	["poems","","Find glowing ning-guro berries and sao-dau mushrooms. Eat them or give them to people, and collect five poems."],
	["friends","","Make five friends. Chat with people (compliment them, tell jokes, give gifts) until they call you palar, friend."],
	["chonies","gav","Gav has lost six chonies all over the island! Ask Gav for clues (Ask about the lost chonies) and find them all."],
	["hirimara","","Explore Hirimara, the prank field, far to the west past the market. Find its five secrets."],
	["letters","gav","Mystery letters! Someone keeps writing to you. Gav at the harbor delivers them. Write back, listen in when villagers whisper, and work out who it is."],
	["survey","","Find someone who can... Ask people Ti ta-___-kan-ha? (Can you ___?) until you find someone who can swim, sing, cook, read, build things and run fast. (Chat, then Ask or tell.)"],
	["wand","oku","Oku at the old ruins has an old stick that makes sentences come true. Make five different sentences come true with it."],
	["relay","","Pass it on! Lira, Gav and Desh have news. Pass each story to two people without changing it (you heard it, so: -nu)."],
	["guesswho","neri","Play Guess who with Neri and win three times."],
	["yesen","","Yesen! Do improv scenes with villagers (Chat, then Yesen) and get big applause in five of them. Level 2 and up."],
	["kirmel","suri","The lost writing. Deep in the cenote in the far north-east there are carvings no one can read. Read them, find the one who remembers, and bring the writing back to the village."],
	["treasure","tamu","Follow the old map: Gin murak-ni shanma i-esh-da. Tamu at the dock can take you to Sendor."]
]
var secret_quests = ["treasure"]
var rumors: Array = []
var rumor_count: int = 0
var guro_node: Node3D
var guro_t: float = -1.0
var guro_cd: float = 140.0
var fish_rain_t: float = -1.0
var choni_rain_t: float = -1.0
var choni_fx: CPUParticles3D
var choni_line: Node3D
var maze_chest: Node3D
var ghost_things: Array = []
var last_msg: Array = []
var fish_fx: CPUParticles3D
var odd_nodes: Dictionary = {}
var friend: Dictionary = {}
var mood: Dictionary = {}
var chat_day: Dictionary = {}
var day_count: int = 0
var firefly_told: bool = false
var ff_order: Array = []
var ff_i: int = 0
var mood_clock: float = 0.0
var portrait_vp: SubViewport
var portrait_cam: Camera3D
var portrait_id: String = ""
var panel_title: Control
var ambient_cd: float = 20.0
var talk_partner: String = ""
var pending_ext: Array = []
var berries: int = 0
var shrooms: int = 0
var poems: Array = []
const PLANTS = [
	["berry1", "ning-guro", Vector3(8, 0, 18.5)], ["berry2", "ning-guro", Vector3(-36, 0, 9)], ["berry3", "ning-guro", Vector3(39, 0, -6.5)],
	["berry4", "ning-guro", Vector3(57, 0, 13)], ["berry5", "ning-guro", Vector3(-56, 0, -29)], ["berry6", "ning-guro", Vector3(46.5, 0, 79)],
	["berry7", "ning-guro", Vector3(-67, 0, 36)], ["berry8", "ning-guro", Vector3(18, 0, -37)],
	["shroom1", "sao-dau", Vector3(12, 0, -15.5)], ["shroom2", "sao-dau", Vector3(-17, 0, -11)], ["shroom3", "sao-dau", Vector3(-38, 0, -29)],
	["shroom4", "sao-dau", Vector3(58, 0, -36.5)], ["shroom5", "sao-dau", Vector3(70, 0, -15)], ["shroom6", "sao-dau", Vector3(-66, 0, 27.5)],
	["berry9", "ning-guro", Vector3(-120, 0, 17)], ["shroom7", "sao-dau", Vector3(-106, 0, -24)]
]
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
	"rin": [Color("c68e66"), Color("3b2418"), 5, Color("e76f51")],
	"ola": [Color("9a6a48"), Color("1d1d1d"), 6, Color("a8dadc")],
	"pomo": [Color("d6ac83"), Color("6b6b6b"), 3, Color("c0392b")],
	"vira": [Color("8d5a3b"), Color("e6e1d6"), 1, Color("9bd06a")],
	"ila": [Color("f0c9a0"), Color("7a4a22"), 2, Color("f4a261")],
	"yalo": [Color("c68e66"), Color("2e2a5a"), 4, Color("f4f1e8")],
	"desh": [Color("7a4a32"), Color("1d1d1d"), 5, Color("2a9d8f")],
	"sair1": [Color("e3b98f"), Color("4a3020"), 1, Color("a78bda")],
	"sair2": [Color("a87650"), Color("1d1d1d"), 0, Color("e9c46a")],
	"sair3": [Color("d9a679"), Color("5a4030"), 3, Color("4f7ca8")],
	"oku": [Color("c68e66"), Color("e6e1d6"), 7, Color("8f5a48")],
	"gav": [Color("e3b98f"), Color("8a3a1a"), 3, Color("2a6f97")],
	"tamu": [Color("8d5a3b"), Color("1d1d1d"), 1, Color("e9c46a")]
}
# Extra features so every villager has their own silhouette.
var person_ex = {
	"ena": {"shirt": Color("f4f1e8"), "stripe": Color("1d3557"), "hat": "cap", "hat_color": Color("1d3557"), "pants": Color("2b3a55"), "style": 9, "prop": "clipboard", "freckles": true, "brows": "raised", "mouth": "smile"},
	"mira": {"shirt": Color("bb714b"), "apron": Color("f4f1e8"), "hat": "toque", "build": "round", "w": 1.15, "h": 0.95, "prop": "ladle", "brows": "raised", "mouth": "o", "earrings": true},
	"sanu": {"shirt": Color("8ecae6"), "stripe": Color("f4f1e8"), "pants": Color("8ecae6"), "hat": "nightcap", "hat_color": Color("5b8c5a"), "h": 0.8, "cheeks": true, "prop": "pillow", "eye_kind": "sleepy"},
	"tor": {"shirt": Color("c0392b"), "overalls": Color("4a5d78"), "pants": Color("4a5d78"), "w": 1.25, "h": 1.08, "beard": Color("1d1d1d"), "hat": "band", "hat_color": Color("e9c46a"), "prop": "hammer", "brows": "flat", "thick": true, "mouth": "grin"},
	"lira": {"shirt": Color("9678a5"), "dress": Color("7d5a94"), "face": "glasses", "frame": Color("b5651d"), "earrings": true, "h": 0.95, "scarf": Color("e9c46a"), "prop": "cup", "brows": "raised", "mouth": "grin"},
	"oren": {"shirt": Color("7e9975"), "vest": Color("6d4a33"), "mustache": Color("4a4a4a"), "hat": "cowboy", "hat_color": Color("8c5a3c"), "w": 0.95, "h": 1.1, "prop": "carrot", "brows": "angry", "thick": true, "mouth": "frown"},
	"neri": {"shirt": Color("bd795f"), "backpack": Color("c0392b"), "scarf": Color("f4a261"), "prop": "map", "mouth": "smile", "brows": "flat"},
	"ketu": {"shirt": Color("e76f51"), "build": "round", "w": 1.3, "h": 0.97, "apron": Color("e9c46a"), "mustache": Color("2b1d14"), "prop": "fish", "mouth": "grin", "brows": "raised"},
	"suri": {"shirt": Color("2a9d8f"), "dress": Color("21867a"), "h": 1.14, "w": 0.9, "face": "glasses", "earrings": true, "prop": "book", "brows": "raised", "mouth": "line"},
	"rin": {"shirt": Color("f4a261"), "h": 0.74, "freckles": true, "eye_kind": "big", "prop": "pencil", "mouth": "grin", "cheeks": true},
	"ola": {"shirt": Color("e9c46a"), "dress": Color("e9c46a"), "h": 0.72, "eye_kind": "big", "cheeks": true, "prop": "fruit", "mouth": "grin"},
	"pomo": {"shirt": Color("4f7ca8"), "robe": Color("3d6590"), "beard": Color("d9d9d9"), "h": 0.98, "w": 1.12, "build": "round", "hat": "beanie", "hat_color": Color("c0392b"), "prop": "telescope", "eye_kind": "sleepy", "style": 0},
	"vira": {"shirt": Color("5b8c5a"), "robe": Color("4f7d4e"), "belt": Color("e9c46a"), "face": "glasses", "frame": Color("6b4f36"), "style": 9, "prop": "basket", "mouth": "smile", "brows": "flat"},
	"ila": {"shirt": Color("a78bda"), "scarf": Color("f4f1e8"), "hat": "band", "hat_color": Color("f4f1e8"), "h": 0.92, "cheeks": true, "prop": "mug", "brows": "worried", "mouth": "o"},
	"yalo": {"shirt": Color("f2c14e"), "robe": Color("e0ac2a"), "h": 1.18, "w": 0.85, "hat": "captain", "mustache": Color("2e2a5a"), "prop": "lantern", "brows": "worried", "mouth": "o"},
	"desh": {"shirt": Color("ff5d8f"), "stripe": Color("f4f1e8"), "face": "sunglasses", "style": 8, "prop": "drum", "mouth": "grin", "w": 1.05},
	"sair1": {"h": 0.93, "scarf": Color("a78bda")},
	"sair2": {"w": 1.2, "hat": "beanie", "hat_color": Color("e9c46a")},
	"sair3": {"h": 1.07, "face": "glasses"},
	"oku": {"shirt": Color("6b4f36"), "robe": Color("5a4030"), "belt": Color("c9a46d"), "beard": Color("e6e1d6"), "face": "glasses", "h": 0.93, "w": 0.9, "prop": "cane", "brows": "flat", "thick": true, "brow_color": Color("e6e1d6")},
	"gav": {"shirt": Color("2a6f97"), "hat": "cap", "hat_color": Color("e9c46a"), "bag": Color("8c5a3c"), "style": 0, "prop": "letter", "freckles": true, "mouth": "smile", "brows": "raised"},
	"tamu": {"shirt": Color("f4f1e8"), "stripe": Color("c0392b"), "vest": Color("1d3557"), "hat": "beanie", "hat_color": Color("c0392b"), "beard": Color("1d1d1d"), "w": 1.18, "build": "round", "prop": "oar", "brows": "angry", "thick": true, "mouth": "frown"}
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
	["islet", "Sendor: the small island", Vector2(50, 80), 13.0, Vector3(48, 0, 71)],
	["hirimara", "Hirimara: the prank field", Vector2(-108, 0), 22.0, Vector3(-96, 0, 3)]
]
var central = {
	"harbor": ["The harbor", Vector3(0, 0, 33)], "village": ["teka: the village", Vector3(0, 0, 16)],
	"forest": ["The forest path", Vector3(0, 0, -11)], "river": ["mora: the river", Vector3(0, 0, -18.5)],
	"farbank": ["The far bank", Vector3(0, 0, -29)], "cove": ["The northern cove", Vector3(1, 0, -38)]
}

func _ready():
	words.merge(Data.WORDS)
	words.merge(Data.WORDS9)
	words.merge(Data.WORDS10)
	words.merge(Data.WORDS11)
	words.merge(Data.WORDS12)
	words.merge(Data.WORDS13)
	words.merge(Data.WORDS14)
	words["kachaka"] = str(words.get("kachaka", "")) + "; as a verb root, dance (ta-kachaka-o!, dance!)"
	for k in Data.GLOSS_UPDATES.keys(): words[k] = Data.GLOSS_UPDATES[k]
	build_world()
	build_ui()
	build_swim_ui()
	load_game()
	setup_audio()
	load_log()
	if completed.has("kirmel"): apply_kirmel_signs()
	log_event("session", {"level": level(), "words": discovered.size(), "web": OS.has_feature("web")})
	refresh_world()
	last_level = level()
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

# Invisible rails along a north-south crossing, with short funnels at each end
# that guide a walker onto the deck instead of stopping them.
func guard_rails(cx: float, z_near: float, z_far: float, hw: float):
	var mid = (z_near + z_far) * 0.5
	for sx in [-1.0, 1.0]:
		solid(Vector3(cx + sx * hw, 0.6, mid), Vector3(0.12, 1.2, absf(z_near - z_far)))
		for end in [[z_near, 1.0], [z_far, -1.0]]:
			var a = Vector2(cx + sx * hw, end[0])
			var b = Vector2(cx + sx * (hw + 0.9), end[0] + end[1] * 1.5)
			var c = (a + b) * 0.5
			var d = b - a
			solid(Vector3(c.x, 0.6, c.y), Vector3(0.12, 1.2, d.length()), rad_to_deg(atan2(d.x, d.y)))

# A sloped walkway from a (low end) to b (top end), so the player can step onto a bridge deck.
func ramp(a: Vector3, b: Vector3, width: float, color: Color = Color(0, 0, 0, 0)):
	var d = b - a
	var body = StaticBody3D.new()
	var fwd = d.normalized()
	var right = Vector3.UP.cross(-fwd).normalized()
	var up = fwd.cross(right).normalized() * -1.0
	if up.y < 0.0: up = -up
	var basis = Basis(right, up, -fwd).orthonormalized()
	body.transform = Transform3D(basis, (a + b) * 0.5 - up * 0.1)
	var cs = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(width, 0.2, d.length())
	cs.shape = shape
	body.add_child(cs)
	add_child(body)
	if color.a > 0.0:
		var mi = MeshInstance3D.new()
		var bm = BoxMesh.new()
		bm.size = Vector3(width, 0.1, d.length())
		mi.mesh = bm
		mi.material_override = Art.mat(color)
		mi.transform = Transform3D(basis, (a + b) * 0.5 - up * 0.05)
		add_child(mi)

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
			var pex: Dictionary = person_ex.get(id, {})
			node = Art.person(color, look[0], look[1], look[2], look[3], pex)
			label_y = 2.15 * maxf(1.0, float(pex.get("h", 1.0)))
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
		"plant":
			node = Art.berry_bush() if word == "ning-guro" else Art.mushroom_patch()
			label_y = 1.25 if word == "ning-guro" else 0.85
			pr = 0.9
			ph = 1.1
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
	if kind == "npc":
		label.layers = 2
		e["mark"] = Art.quest_mark(node, 2.75)
		(e["mark"] as Label3D).layers = 2
	entities.append(e)
	if kind == "npc": make_bubble(e)
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
	build_places5()
	build_entities()
	build_hirimara()
	T.extra_lobe = false
	build_forest()
	build_scatter()
	T.extra_lobe = true
	build_cenote()
	build_sky_life()
	build_player()
	build_night_and_weather()
	build_portrait()

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
	var hole = Vector3(T.CENOTE.x, T.CENOTE.y, 18.5)
	var floor_mi = Art.plane(self, Vector3(0, -3.05, 0), Vector2(1400, 1400), Art.floor_material(Color("0d4660"), hole))
	floor_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var sea_mat = Art.water_material(Color("0e5a78"), Color("47b9c0"), 0.78).duplicate()
	sea_mat.set_shader_parameter("hole", hole)
	Art.plane(self, Vector3(0, -0.08, 0), Vector2(1400, 1400), sea_mat)

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

var tree_pts: Array = []

func add_tree(p: Vector3, vary: RandomNumberGenerator, trunks: Array, trunk_colors: Array, pines: Array, pine_colors: Array, oaks: Array, oak_colors: Array):
	tree_pts.append(Vector2(p.x, p.z))
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
	# invisible rails so nobody tumbles off the side
	guard_rails(0.0, -19.5, -26.5, 1.55)
	ramp(Vector3(0, -0.4, -17.3), Vector3(0, 0.08, -19.5), 3.0, Color("8f6a43"))
	ramp(Vector3(0, -0.4, -28.7), Vector3(0, 0.08, -26.5), 3.0, Color("8f6a43"))
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
		solid(Vector3(p.x, -0.05, p.z), Vector3(1.8, 0.3, 1.8))
	solid(Vector3(-30, -0.05, -23), Vector3(2.4, 0.3, 8.6))
	guard_rails(-30.0, -18.9, -27.1, 1.25)
	ramp(Vector3(-30, -0.4, -16.6), Vector3(-30, 0.1, -18.7), 2.4)
	ramp(Vector3(-30, -0.4, -29.4), Vector3(-30, 0.1, -27.3), 2.4)
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
	solid(Vector3(52, -0.1, -26.5), Vector3(2.4, 0.3, 11.8))
	guard_rails(52.0, -21.0, -32.0, 1.25)
	ramp(Vector3(52, -0.4, -18.4), Vector3(52, 0.05, -20.6), 2.4)
	ramp(Vector3(52, -0.4, -34.6), Vector3(52, 0.05, -32.4), 2.4)
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
	# Hirimara, the far-west peninsula
	tries = 0
	var hiri_tufts = 0
	while hiri_tufts < 1400 and tries < 5000:
		tries += 1
		var x = rs.randf_range(-140, -82)
		var z = rs.randf_range(-30, 30)
		if not grass_ok(x, z): continue
		if x > MAZE_O.x - 0.5 and x < MAZE_O.x + MAZE_N * MAZE_CELL + 0.5 and z > MAZE_O.y - 0.5 and z < MAZE_O.y + MAZE_N * MAZE_CELL + 0.5: continue
		var s = rs.randf_range(0.6, 1.3)
		var tilt = Basis.from_euler(Vector3(rs.randf_range(-0.25, 0.25), rs.randf() * TAU, rs.randf_range(-0.25, 0.25)))
		tufts.append(Transform3D(tilt.scaled(Vector3(s, s, s)), Vector3(x, T.height(x, z) + 0.13 * s, z)))
		tuft_colors.append(Color("2f6a2a").lerp(Color("86b84a"), rs.randf()))
		hiri_tufts += 1
	for c in range(26):
		var cx = rs.randf_range(-138, -86)
		var cz = rs.randf_range(-28, 28)
		if cx > MAZE_O.x - 1.0 and cx < MAZE_O.x + MAZE_N * MAZE_CELL + 1.0 and cz > MAZE_O.y - 1.0 and cz < MAZE_O.y + MAZE_N * MAZE_CELL + 1.0: continue
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
	# ---- fifth expansion: strange things and a parrot ----
	entity("odd_fish","object","tari",Vector3(-50.4,0,12.9),Color.WHITE,1.9,Vector2(0.8,1.6))
	entity("odd_chair","object","ket",Vector3(10,0,7),Color.WHITE,6.0,Vector2(1.6,6.0))
	entity("odd_clothes","object","yir",Vector3(40.9,0,27.9),Color.WHITE,3.6,Vector2(1.2,3.4))
	entity("odd_book","object","puka",Vector3(70.4,0,26.6),Color.WHITE,0.9,Vector2(1.0,0.8))
	entity("odd_bed","object","sulum",Vector3(20,0,-23.2),Color.WHITE,1.6,Vector2(1.6,1.2))
	entity("odd_fruit","object","guro",Vector3(26,0,-13.4),Color.WHITE,3.4,Vector2(1.7,2.8))
	entity("odd_teapot","object","cha-kor",Vector3(1.55,0,-21.4),Color.WHITE,1.7,Vector2(0.8,1.5))
	entity("odd_choni","object","choni",Vector3(74.6,0,-6.0),Color.WHITE,15.6,Vector2(2.4,16.0))
	for pl in PLANTS:
		var pe = entity(pl[0], "plant", pl[1], pl[2], Color.WHITE)
		pe["ripe_at"] = 0.0
	var parrot = entity("parrot","observe","par",Vector3(-41.5,0,7.5),Color("e76f51"))
	(parrot["node"] as Node3D).scale = Vector3.ONE * 1.5
	add_animal(parrot, "bird", 0.0, 0.0)
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
	talk_cam = Camera3D.new()
	talk_cam.fov = 75
	talk_cam.far = 400.0
	talk_cam.cull_mask = 0xFFFFF & ~2
	add_child(talk_cam)

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
	if choni_line: choni_line.visible = completed.has("chonies")
	if maze_chest: (maze_chest.get_meta("lid") as Node3D).rotation_degrees.x = -110.0 if solved.has("ch:choni_maze") else 0.0
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
	sb.content_margin_top = 7
	sb.content_margin_bottom = 7
	return sb

func make_theme() -> Theme:
	var theme = Theme.new()
	theme.default_font_size = 18
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
	b.custom_minimum_size.y = 46
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
	status_small.size = Vector2(148,40)
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
	top_row.add_theme_constant_override("separation", 6)
	for tb in [["Notebook", show_notebook], ["Bag", show_inventory], ["Map", show_map], ["", show_more]]:
		var b = button(tb[0], tb[1], top_row)
		b.custom_minimum_size = Vector2(44, 38)
		b.add_theme_font_size_override("font_size", 15)
		for st in ["normal", "hover", "pressed", "focus"]:
			var sb = (b.get_theme_stylebox(st) as StyleBoxFlat).duplicate()
			sb.content_margin_left = 9
			sb.content_margin_right = 9
			sb.content_margin_top = 4
			sb.content_margin_bottom = 4
			b.add_theme_stylebox_override(st, sb)
		if tb[0] == "":
			b.name = "MoreButton"
			b.tooltip_text = "More"
			b.icon = menu_icon()
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# a small chip in the lower right: what is in reach, and a tap target to use it
	prompt = Button.new()
	prompt.name = "TargetChip"
	prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	prompt.offset_left = -290
	prompt.offset_right = -16
	prompt.offset_top = -78
	prompt.offset_bottom = -26
	prompt.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	prompt.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt.add_theme_font_size_override("font_size", 16)
	for st in ["normal", "hover", "pressed", "focus"]: prompt.add_theme_stylebox_override(st, chip_style(0.55 if st != "pressed" else 0.8))
	prompt.add_theme_color_override("font_color", Color("fff6df"))
	prompt.add_theme_color_override("font_hover_color", Color("fff6df"))
	prompt.focus_mode = Control.FOCUS_NONE
	prompt.pressed.connect(chip_pressed)
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
	toast_label.position = Vector2(-200,180)
	toast_label.custom_minimum_size = Vector2(400, 0)
	toast_label.size = Vector2(400,40)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal", chip_style(0.78))
	toast_label.add_theme_color_override("font_color", Color("ffe9a8"))
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.modulate.a = 0.0
	toast_label.z_index = 5
	ui.add_child(toast_label)
	# Move pad: a joystick icon instead of text (outer ring, centre knob, four arrows).
	var move = Control.new()
	move.name = "MovePad"
	move.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	move.position = Vector2(48, -166)
	move.size = Vector2(116, 116)
	move.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move.draw.connect(func():
		var c = Vector2(58, 58)
		move.draw_circle(c, 56.0, Color(0, 0, 0, 0.16))
		move.draw_arc(c, 54.0, 0.0, TAU, 48, Color(1, 1, 1, 0.75), 3.0, true)
		move.draw_circle(c, 18.0, Color(1, 1, 1, 0.55))
		move.draw_arc(c, 18.0, 0.0, TAU, 32, Color(0, 0, 0, 0.35), 2.0, true)
		for k in range(4):
			var d = Vector2.UP.rotated(k * PI / 2.0)
			var side = d.orthogonal()
			var tip = c + d * 46.0
			var base = c + d * 32.0
			move.draw_colored_polygon(PackedVector2Array([tip, base + side * 9.0, base - side * 9.0]), Color(1, 1, 1, 0.85)))
	ui.add_child(move)
	interact_button = button("Interact",interact,ui)
	interact_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.position = Vector2(-160,-138)
	interact_button.size = Vector2(140,64)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 18
	panel.offset_right = -18
	panel.offset_top = 226
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
	content.add_theme_constant_override("separation",8)
	scroll.add_child(content)
	panel.hide()
	close_x = Button.new()
	close_x.name = "CloseX"
	close_x.text = "X"
	close_x.add_theme_font_size_override("font_size", 26)
	close_x.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	close_x.offset_left = -78
	close_x.offset_right = -24
	close_x.offset_top = 232
	close_x.offset_bottom = 284
	for st in ["normal", "hover", "pressed"]:
		var xsb = StyleBoxFlat.new()
		xsb.bg_color = Color("8a2f1f") if st != "pressed" else Color("5e1f15")
		xsb.set_corner_radius_all(26)
		xsb.set_border_width_all(2)
		xsb.border_color = Color("f4e9d0")
		close_x.add_theme_stylebox_override(st, xsb)
	close_x.add_theme_color_override("font_color", Color.WHITE)
	close_x.add_theme_color_override("font_hover_color", Color.WHITE)
	close_x.tooltip_text = "Close"
	close_x.pressed.connect(close_panel)
	close_x.hide()
	ui.add_child(close_x)
	listen_button = button("Listen in", listen_in, ui)
	listen_button.name = "ListenButton"
	listen_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	listen_button.offset_left = -176
	listen_button.offset_right = -20
	listen_button.offset_top = -160
	listen_button.offset_bottom = -96
	listen_button.add_theme_font_size_override("font_size", 20)
	var lsb = StyleBoxFlat.new()
	lsb.bg_color = Color("7a1f3d")
	lsb.set_corner_radius_all(10)
	lsb.set_border_width_all(2)
	lsb.border_color = Color("e9c46a")
	listen_button.add_theme_stylebox_override("normal", lsb)
	listen_button.add_theme_color_override("font_color", Color.WHITE)
	listen_button.hide()
	panel.visibility_changed.connect(func(): close_x.visible = panel.visible)
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
	if text.contains("gin") and text.contains("+"): play_sfx("coin", -6.0)
	toast_label.reset_size()
	toast_label.modulate.a = 1.0
	toast_label.position.y = 180.0
	if talk_view_id != "": toast_label.position.y = get_viewport().get_visible_rect().size.y * TALK_TOP - toast_label.size.y - 8.0
	toast_time = 2.6

func clear_panel(title: String, keep_game: bool = false):
	dnd_on = false
	if not keep_game: mg = {}
	joy = Vector2.ZERO
	move_finger = -1
	look_finger = -1
	touches.clear()
	mouse_look = false
	left_down = false
	walk_to = {}
	for c in content.get_children():
		if c.is_queued_for_deletion(): continue
		c.hide()
		c.queue_free()
	panel.show()
	portrait_id = ""
	cur_title = title
	panel_title = text_line(title,23)

func text_line(text: String, font_size: int = 20) -> Control:
	if text.contains("“"): return rich_line(text, font_size)
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(label)
	return label

func close_panel():
	mg = {}
	portrait_id = ""
	talk_partner = ""
	panel.hide()
	lesson = ""

func show_intro():
	clear_panel("Tujuju Island")
	var by = text_line("by je hammink", 18)
	by.add_theme_color_override("font_color", Color("6b4a2e"))
	text_line("Tujuju Island is a game about how languages work. Everyone here speaks Tujuju, an invented language, so you figure it out from gestures, objects and clues, then use it yourself. Along the way you notice patterns, guess meanings and build sentences, and the villagers are silly about all of it.")
	text_line("Your friend Neri is somewhere on this island. Find them.")
	button("Explore",close_panel,content)
	text_line("Tap a person, animal or object to walk to it. Phone: drag the joystick (lower left) to walk, swipe the right side to look. Desktop: W A S D to move, drag to look, E to interact. When something is in reach, its name shows in the lower right: tap it to use it.")
	text_line("Tap the speaker button, or any dark red Tujuju words, to hear them read aloud by your device's voice.", 16)
	text_line("Tap the quest box to fold it. The menu button (three lines, top row) has games, difficulty, About Tujuju and Reset progress.")

func learn(word: String):
	if words.has(word) and not discovered.has(word):
		discovered.append(word)
		log_event("word_found", word)
		play_sfx("newword", -10.0)
		toast("New word: " + word)
		if talk_partner != "" and ext_kind(word) != "" and not pending_ext.has(word): pending_ext.append(word)

func complete(id: String):
	if not completed.has(id):
		completed.append(id)
		log_event("quest", id)
		play_sfx("fanfare", -4.0)
		var giver = {"belongings": "ena", "meal": "mira", "bag": "sanu", "bridge": "tor", "evidence": "tor", "cove": "neri"}.get(id, "")
		for s in side_quests:
			if s[0] == id: giver = s[1]
		if giver != "" and Data.PEOPLE.has(giver):
			emote(giver, "love" if Data.PEOPLE[giver]["trait"] != "proud" else "proud", 3.5)
			add_friend(giver, 2)
	if id in ["bridge", "meal", "lighthouse"]: refresh_world()
	update_marks()
	save_game()

func objective() -> String:
	for q in quests:
		if not completed.has(q[0]): return q[1]
	for s in side_quests:
		if not completed.has(s[0]) and quest_open(s[0]): return quest_text(s)
	return "Every quest is done. Keep exploring and practicing Tujuju."

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
	update_bubbles()
	update_minigame(delta)
	update_silly(delta)
	update_hirimara(delta)
	update_portrait()
	update_ambient(delta)
	update_overhear(delta)
	update_audio(delta)
	update_cenote(delta)
	update_guardian(delta)
	update_underwater(delta)
	update_acts(delta)
	if not wand_pending.is_empty(): wand_tick()
	update_talk_view(delta)

func animate_people(delta: float):
	var idx = 0
	for e in entities:
		if e["kind"] != "npc": continue
		idx += 1
		var node = e["node"] as Node3D
		var d = player.position - node.position
		var yaw = sin(clock * 0.35 + float(idx)) * 0.12
		var near = Vector2(d.x, d.z).length() < 9.0
		if e["id"] == talk_view_id:
			var dc = talk_cam.global_position - node.position
			yaw = atan2(dc.x, dc.z)
		elif near: yaw = atan2(d.x, d.z)
		node.rotation.y = lerp_angle(node.rotation.y, yaw, minf(delta * 3.0, 1.0))
		var arms: Array = node.get_meta("arms")
		var talk_amt = 0.0
		if not target.is_empty() and target.get("id", "") == e["id"]: talk_amt = 0.5
		var swing = 0.06 + talk_amt * 0.5
		(arms[0] as Node3D).rotation.x = sin(clock * (1.2 + talk_amt * 3.0) + idx) * swing
		(arms[1] as Node3D).rotation.x = -sin(clock * (1.2 + talk_amt * 3.0) + idx) * swing
		(node.get_meta("body") as Node3D).scale.y = 1.0 + sin(clock * 1.6 + idx) * 0.008
		(node.get_meta("head") as Node3D).rotation.z = sin(clock * 0.7 + idx) * 0.04
		apply_emote(e, delta)

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
	if panel.visible:
		prompt.visible = false
		return
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
	if manual:
		walk_to = {}
		walk_via.clear()
	elif not walk_to.is_empty():
		var node = walk_to["node"] as Node3D
		var d = Vector2(node.global_position.x - player.position.x, node.global_position.z - player.position.z)
		var stop = maxf(2.2, float(walk_to["pr"]) + 1.1)
		# head for the next bridge end first, if the way crosses the river
		while not walk_via.is_empty():
			var wp: Vector3 = walk_via[0]
			var dv = Vector2(wp.x - player.position.x, wp.z - player.position.z)
			if dv.length() < 0.9:
				walk_via.pop_front()
				walk_last = INF
				continue
			d = dv
			stop = -1.0
			break
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
					if walk_via.is_empty() and d.length() <= REACH + maxf(float(stuck_on["pr"]) - 0.8, 0.0):
						target = stuck_on
						interact()
						return
					hint("Something is in the way. Walk around it, then click again.")
				walk_last = d.length()
				walk_check = 0.8
	axis = axis.limit_length()
	if in_cenote_water(player.position):
		swim_physics(delta, axis)
		return
	chip_action = Callable()
	if swimming:
		swimming = false
		swim_up_held = false
		swim_down_held = false
	var direction = player.basis * Vector3(axis.x,0,axis.y)
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	player.velocity.y -= 18 * delta
	if player.is_on_floor(): player.velocity.y = minf(player.velocity.y, 0.0)
	player.move_and_slide()
	player.position.x = clampf(player.position.x,-142,95)
	player.position.z = clampf(player.position.z,-80,98)
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
	elif not hover.is_empty(): prompt.text = display_name(hover) + "  ·  click to " + verb(hover)
	elif not walk_to.is_empty(): prompt.text = "Walking to " + display_name(walk_to)
	elif target.is_empty(): prompt.text = ""
	else: prompt.text = display_name(target) + "  ·  tap to " + verb(target)
	prompt.visible = prompt.text != "" and not panel.visible
	if prompt.text != prompt_last:
		prompt_last = prompt.text
		prompt_text_since = clock
		fit_prompt()
	# fade to a quiet chip once it has been read
	prompt.modulate.a = 1.0 if clock - prompt_text_since < 2.0 else 0.55
	interact_button.disabled = target.is_empty()
	interact_button.text = "Interact" if target.is_empty() else verb(target).capitalize()

func fit_prompt():
	var long = prompt.text.length() > 34
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if long else TextServer.AUTOWRAP_OFF
	prompt.offset_left = -300 if long else -16
	prompt.offset_top = -78
	prompt.offset_bottom = -26
	prompt.reset_size()

func hint(text: String):
	prompt.text = text
	fit_prompt()
	prompt.show()
	hint_time = 2.5

func verb(e: Dictionary) -> String:
	match e["kind"]:
		"npc": return "talk"
		"item", "star", "plant": return "pick up"
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
		walk_via = plan_route(player.position, node.global_position)
		walk_last = INF if not walk_via.is_empty() else d
		walk_check = 0.8
	else:
		hint("That is far away. Walk closer, or travel from the Map.")

func on_crossing(p: Vector3) -> bool:
	for c in CROSSINGS:
		var a: Vector3 = c[0]
		var b: Vector3 = c[1]
		if absf(p.x - a.x) < 1.4 and p.z <= a.z + 0.5 and p.z >= b.z - 0.5: return true
	return false

# If a straight walk would go through the river, route it over the nearest crossing.
func plan_route(from: Vector3, to: Vector3) -> Array:
	var wet = false
	for i in range(1, 40):
		var p = from.lerp(to, i / 40.0)
		if T.deep(p.x, p.z) and T.river_dist(p.x, p.z) < 4.5 and not on_crossing(p):
			wet = true
			break
	if not wet: return []
	var from_south = from.z > T.river_z(from.x)
	var best: Array = []
	var best_cost = INF
	for c in CROSSINGS:
		var near: Vector3 = c[0] if from_south else c[1]
		var far: Vector3 = c[1] if from_south else c[0]
		var cost = Vector2(from.x - near.x, from.z - near.z).length() + near.distance_to(far) + Vector2(far.x - to.x, far.z - to.z).length()
		if cost < best_cost:
			best_cost = cost
			best = [near, far]
	return best

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
		"plant": pick_plant(entity_by_id(e["id"]))
		"choni": choni_kind_pick(e)
		_: examine(e)

func examine(e: Dictionary):
	var id: String = e["id"]
	if id.begins_with("house"):
		door_puzzle(id)
		return
	if id == "scarecrow": hiri_secret("scarecrow")
	match id:
		"karaoke":
			karaoke_panel()
			return
		"ghost_hut":
			ghost_panel()
			return
		"dopel":
			dopel_panel()
			return
		"maze_chest":
			maze_chest_panel()
			return
		"lavir":
			sentence_card("maze_hedge")
			return
		"deshavu":
			learn("deshavu")
			learn("deshavu-sek")
			if last_msg.is_empty(): message("Deshavu!", "You touch the purple stone and feel as if you have been here before... (deshavu is borrowed from French deja vu, already seen)")
			else: message("Deshavu! " + str(last_msg[0]), str(last_msg[1]) + "\n\n(Deshavu! You touch the purple stone and that moment happens all over again. Deshavu is borrowed from French deja vu, already seen.)")
			return
	if id in ["sign1", "sign2", "sign3"]:
		sentence_card("sign_north")
		return
	if Data.SENTENCES.has(id):
		if id.begins_with("odd_") and not solved.has("odd:" + id):
			solved.append("odd:" + id)
			var found = 0
			for k in Data.SENTENCES.keys():
				if k.begins_with("odd_") and solved.has("odd:" + k): found += 1
			var total = 0
			for k in Data.SENTENCES.keys():
				if k.begins_with("odd_"): total += 1
			toast("Strange thing " + str(found) + " of " + str(total) + "!")
			if found >= total: complete("strange")
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
		"parrot": parrot_panel()
		"ruins": sentence_card("ruins_old")
		"falls": sentence_card("falls")
		"cave": cave_panel()
		"ferry": ride_puzzle(player.position.z < 60.0)
		"mound_front", "mound_behind", "mound_side": mound_panel(id)
		_: message(e["word"], "You look closely, but there is nothing more to learn here yet.")

func observe(e: Dictionary):
	learn(e["word"])
	if e["id"] == "parrot":
		parrot_panel()
		return
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

var cur_item: String = ""

func ask(situation: String, options: Array, correct: int, on_right: Callable, right_text: String, wrong_text: String, back: Callable = Callable(), extra: Callable = Callable()):
	cur_item = situation.substr(0, 160)
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
	log_event("answer", {"activity": cur_title, "item": cur_item, "chose": opt, "correct": answer}, opt == answer)
	play_sfx("correct" if opt == answer else "wrong", -4.0)
	if opt == answer:
		for b in buttons: b.disabled = true
		feedback.text = "Correct. " + right_text
		feedback.add_theme_color_override("font_color", Color("2f6b2f"))
		if talk_partner != "": emote(talk_partner, "happy", 2.0)
		if on_right.is_valid(): on_right.call()
		if extra.is_valid(): extra.call()
		last_skip.text = "Return"
		content.move_child(last_skip, -1)
	else:
		feedback.text = "Not quite. " + wrong_text
		feedback.add_theme_color_override("font_color", Color("8a2f1f"))
		if talk_partner != "": emote(talk_partner, "confused", 2.0)

func choice_puzzle(title: String, situation: String, options: Array, correct: int, on_right: Callable, right_text: String, wrong_text: String, back: Callable = Callable(), extra: Callable = Callable()):
	clear_panel(title)
	ask(situation, options, correct, on_right, right_text, wrong_text, back, extra)

func master(key: String):
	if not mastered.has(key):
		mastered.append(key)
		log_event("mastered", key)
		save_game()

func sentence_card(sid: String, back: Callable = Callable()):
	var s: Dictionary = Data.SENTENCES[sid]
	for w in s["words"]: learn(w)
	clear_panel("What does it mean?")
	varnak_banner(s["v"])
	var lv = level()
	var g = text_line(s["gesture"], 18)
	g.add_theme_color_override("font_color", Color("6b4a2e"))
	if lv >= 3:
		g.visible = false
		var hb = Button.new()
		hb.text = "Show the gesture (hint)"
		hb.custom_minimum_size.y = 46
		hb.pressed.connect(func():
			g.visible = true
			hb.visible = false)
		content.add_child(hb)
	if not phrases.has(sid):
		phrases.append(sid)
		toast("Added to your phrasebook")
		save_game()
	var options: Array = [s["en"]]
	options.append_array(s["wrong"])
	if lv >= 2:
		var others = Data.SENTENCES.keys()
		others.shuffle()
		for o in others:
			var en: String = Data.SENTENCES[o]["en"]
			if o != sid and not options.has(en):
				options.append(en)
				break
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
	if level() >= 2:
		for nw in Data.NUMBERS.slice(1):
			if not options.has(nw) and randf() < 0.3:
				options.append(nw)
				break
	var phrase = c["numword"].capitalize() + " " + c["noun"] + "."
	choice_puzzle(c["noun"], "You count " + str(c["n"]) + " " + c["en"] + " here. Which number word is right?", options, 0, func():
		learn(c["noun"])
		learn(c["numword"])
		master("w:" + c["numword"])
		save_game(), phrase + " (" + str(c["n"]) + " " + c["en"] + ")", "Count again, then try another number word. They are in your notebook once you learn them.")

func fishing():
	if mastered.has("w:nuk"):
		fishing_game()
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
			play_sfx("splash", -4.0)
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
	choice_puzzle("Suri's lesson: " + str(i + 1) + " of 4", q["gesture"] + "\n\n“" + q["q"] + "”" + ("\n\nAnswer Suri in Tujuju." if i == 3 else "\n\nWhat is Suri asking?"), q["options"], q["correct"], func():
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
			topic("Ask about that noise", "mira_sizzle", id)
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
			topic("Ask about the campfire", "fire_pops", id)
			button("Teach Neri some Tujuju", teach_neri.bind(talk.bind("neri")), content)
			button("Play Guess who: Hal i-an-ha?", guess_start, content)
		"ketu":
			topic("Ask what Ketu sells", "ketu_sells", id)
			topic("Ask about the well", "well_full", id)
			topic("Ask about the fruit", "fruit_variety", id)
			if completed.has("market"): topic("Ask about the ret-gor", "hot_dog", id)
		"suri":
			topic("Ask who Suri is", "suri_teacher", id)
			topic("Ask about the students", "students_read", id)
			topic("Ask why Rin and Ola are giggling", "suri_kinder", id)
			if mastered.has("kir:taught") and not completed.has("kirmel"): button("Show Suri the old writing", suri_kirmel.bind(0), content)
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
			topic("Ask about the party", "party_noise", id)
			topic("Ask about the trumpet noise", "desh_toot", id)
			topic("Ask Desh about swimming", "desh_swims", id)
			topic("Ask about the sea", "sea_cold", id)
		"oku":
			topic("Ask about the ruins", "ruins_old", id)
			topic("Ask why Oku's hair is a mess", "oku_brainstorm", id)
			button("Ask about the old stick" if not solved.has("wand") else "Use the word wand", oku_wand, content)
			if completed.has("riddles"): topic("Ask about the secret", "room_behind", id)
		"gav":
			topic("Ask Gav about his work", "gav_mail", id)
			button("Ask about the lost chonies" + ("  [ok]" if completed.has("chonies") else ""), choni_hints, content)
		"tamu":
			topic("Ask Tamu about the boat", "tamu_ferry", id)
			topic("Ask about the small island", "islet_small", id)

func topic(label: String, sid: String, npc: String):
	button(label, func(): sentence_card(sid, talk.bind(npc)), content)

func talk(id: String):
	compact_buttons.call_deferred()
	if talk_partner != id: log_event("talk", id)
	talk_partner = id
	match id:
		"ena":
			learn("kel")
			learn("anni")
			learn("tekaru")
			clear_panel("Ena")
			text_line("Ena points to your bag, then gestures toward you.\n\n“Kel.”\n\nTry telling Ena: \"My bag.\"")
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
			gossip_buttons(id)
			add_topics(id)
			return
		"oren":
			account("oren","italpashi","Oren points to fresh footprints in the sand. Oren inferred that Neri arrived.")
			gossip_buttons(id)
			add_topics(id)
			return
		"neri":
			clear_panel("Neri at the northern cove")
			if completed.has("evidence"):
				complete("cove")
				text_line("You found your friend and understood the clues. Neri shows you a notebook of island stories. Your Tujuju adventure has begun.")
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
				button("Buy bombom (candy): gin yan", func():
					if gin >= 1:
						gin -= 1
						inventory.append("candy")
						learn("bombom")
						toast("Bombom! (-1 gin)")
						save_game()
						talk("ketu")
					else: message("Not enough gin", "Candy costs one coin. Sell a fish to Ketu first."), content)
				button("Buy ret-gor (hot dog): gin yan", func():
					if gin >= 1:
						gin -= 1
						inventory.append("hotdog")
						learn("ret-gor")
						toast("Ret-gor! hot + dog. The village gor looks horrified. (-1 gin)")
						save_game()
						talk("ketu")
					else: message("Not enough gin", "A hot dog costs one coin. Sell a fish to Ketu first."), content)
				button("Buy cha (tea): gin yan", func():
					if gin >= 1:
						gin -= 1
						inventory.append("tea")
						toast("Cha! (-1 gin)")
						save_game()
						talk("ketu")
					else: message("Not enough gin", "Tea costs one coin. Sell a fish to Ketu first."), content)
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
			var nlt = next_letter()
			if nlt >= 0:
				text_line("Gav waves an envelope. “Ti-ru pai! Hal-ta? Ma-na-zen-ki-da.” A letter for you! From whom? He doesn't know.", 17)
				button("Read the mystery letter", letter_panel.bind(nlt), content)
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
	if Data.PEOPLE.has(id):
		button("Chat with " + id.capitalize(), chat_menu.bind(id), content)
		add_portrait(id)
	gossip_buttons(id)
	if Data.CHALLENGES.has(id):
		button("Say it yourself" + ("  [ok]" if mastered.has("c:" + id) else ""), challenge.bind(id), content)
	for p in Data.PARCELS.keys():
		if inventory.has(p) and id != "gav":
			button("Give a parcel", give_parcel.bind(id), content)
			break
	add_topics(id)
	extension_box(talk.bind(id))
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
	if id == "candy": return "bombom"
	if id == "hotdog": return "ret-gor"
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
	if not title.begins_with("Deshavu"): last_msg = [title, body]
	clear_panel(title)
	text_line(body)
	button("Return",close_panel,content)

# ------------------------------------------------------------ notebook, practice, workshop

func short_gloss(word: String) -> String:
	return str(words.get(word, "")).split(" (")[0]

func show_notebook():
	compact_buttons.call_deferred()
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
	var b5 = button("Games", show_games, row2)
	var b6 = button("Poems", show_poems, row2)
	b6.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Word play: borrowings, calques, false friends, doubling", show_loans, content)
	var row3 = HBoxContainer.new()
	row3.add_theme_constant_override("separation", 8)
	content.add_child(row3)
	var b7 = button("Letters" + (" (new!)" if next_letter() >= 0 else ""), show_letters, row3)
	var b8 = button("Overheard", show_overheard, row3)
	var b9 = button("My learning", show_progress, row3)
	button("Survey: find someone who can...", show_survey, content)
	if kir_known_count() > 0: button("Kirmel: the old writing", show_kir_chart, content)
	for b in [b7, b8, b9]: b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for b in [b4, b5]: b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if discovered.is_empty(): text_line("Examine objects and talk to residents to collect words.")
	for word in discovered:
		button(word + ("  [ok]" if mastered.has("w:" + word) else ""),reveal_word.bind(word),content)
	button("Return",close_panel,content)

func reveal_word(word: String):
	clear_panel(word)
	text_line("What do you think this form means?")
	var guess = text_field("Write your guess here", guesses.get(word, ""))
	button("Save guess",func():
		guesses[word] = guess.text
		save_game(),content)
	button("Reveal meaning",func(): text_line(words.get(word,"")),content)
	if ext_kind(word) != "":
		button("Use it in a new form", ext_form.bind(word, reveal_word.bind(word)), content)
		button("Build a new sentence with it", ext_build.bind(word, reveal_word.bind(word)), content)
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
	var lv = level()
	if lv >= 2 and randf() < 0.5 and pool.size() >= 4:
		var opts: Array = [w]
		var sh = pool.duplicate()
		sh.shuffle()
		for o in sh:
			if o != w and short_gloss(o) != short_gloss(w) and opts.size() < (3 if lv < 3 else 4): opts.append(o)
		choice_puzzle("Practice", "Which Tujuju form means \"" + short_gloss(w) + "\"?", opts, 0, func(): master("w:" + w), "“" + w + "” means " + str(words[w]) + ".", "Check the notebook for a hint, then try the next one.", show_notebook, func(): button("Next question", show_practice, content))
		return
	var good = short_gloss(w)
	var options: Array = [good]
	var others: Array = pool.duplicate()
	others.shuffle()
	for o in others:
		var g = short_gloss(o)
		if g != good and not options.has(g) and options.size() < 3: options.append(g)
	var fillers = ["water", "bridge", "bag", "river", "path", "boat", "stone", "fire", "sea"]
	var n_opts = 3 if lv < 3 else 4
	for o in others:
		var g2 = short_gloss(o)
		if g2 != good and not options.has(g2) and options.size() < n_opts: options.append(g2)
	for f in fillers:
		if f != good and not options.has(f) and options.size() < n_opts: options.append(f)
	choice_puzzle("Practice", "What does “" + w + "” mean?", options, 0, func(): master("w:" + w), "That is \"" + str(words[w]) + "\".", "Check the notebook for a hint, then try the next one.", show_notebook, func(): button("Next question", show_practice, content))

func practice_phrase():
	var sid: String = phrases[randi() % phrases.size()]
	var s: Dictionary = Data.SENTENCES[sid]
	var options: Array = [s["en"]]
	options.append_array(s["wrong"])
	if level() >= 2:
		for o in Data.SENTENCES.keys():
			var en2: String = Data.SENTENCES[o]["en"]
			if o != sid and not options.has(en2) and randf() < 0.2:
				options.append(en2)
				break
	choice_puzzle("Practice", "What does this mean?\n\n“" + s["v"] + "”", options, 0, func(): master("s:" + sid), s["parts"], "Think about the endings: -ma, -ru, -ta, -da and -im each add meaning.", show_notebook, func(): button("Next question", show_practice, content))

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
	choice_puzzle("Workshop challenge", "How do you say \"" + suffix_meaning(root, sufs[0]) + "\"?", options, 0, func():
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
	if berries > 0:
		text_line("ning-guro × " + str(berries) + "  (song-berries)")
		button("Eat a ning-guro", eat_poem.bind("ning-guro"), content)
	if shrooms > 0:
		text_line("sao-dau × " + str(shrooms) + "  (star-head mushrooms)")
		button("Eat a sao-dau", eat_poem.bind("sao-dau"), content)
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
		["fardom", 72, -15], ["hai", 72, 32], ["cove", 0, -48], ["ruins", -62, 50], ["falls", 64, -27], ["Sendor", 50, 93], ["stones", 32, -50], ["orchard", 45, 30], ["Hirimara", -110, 26], ["lavir", -114, -16]]
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
		log_event("reset", "")
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
		best_speed = 0
		rumors.clear()
		rumor_count = 0
		friend.clear()
		mood.clear()
		poems.clear()
		berries = 0
		shrooms = 0
		chat_day.clear()
		hiding.clear()
		last_level = 1
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
		file.store_string(JSON.stringify({"guesses":guesses,"inventory":inventory,"discovered":discovered,"completed":completed,"mastered":mastered,"phrases":phrases,"solved":solved,"visited":visited,"fish":fish_caught,"gin":gin,"berries":berries,"shrooms":shrooms,"poems":poems,"friend":friend,"mood":mood,"chat_day":chat_day,"day_count":day_count,"rumors":rumors,"rumor_count":rumor_count,"day":day_t,"bias":diff_bias,"best_speed":best_speed,"hud_small":hud_small,"sound":sound_on,"whale":whale_seen,"position":[player.position.x,player.position.y,player.position.z],"yaw":player.rotation.y,"pitch":camera.rotation.x}))
	player.position = keep
	save_log()

func load_game():
	if not FileAccess.file_exists(SAVE): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	if not data is Dictionary: return
	guesses = data.get("guesses",{})
	inventory = data.get("inventory",[])
	discovered = data.get("discovered",[]).filter(func(w): return words.has(w))
	completed = data.get("completed",[])
	mastered = data.get("mastered",[])
	phrases = data.get("phrases",[])
	solved = data.get("solved",[])
	visited = data.get("visited",[])
	fish_caught = int(data.get("fish",0))
	gin = int(data.get("gin", 0))
	day_t = float(data.get("day", 0.12))
	hud_small = bool(data.get("hud_small", false))
	sound_on = bool(data.get("sound", true))
	whale_seen = bool(data.get("whale", false))
	diff_bias = int(data.get("bias", 0))
	rumors = data.get("rumors", [])
	friend = data.get("friend", {})
	berries = int(data.get("berries", 0))
	shrooms = int(data.get("shrooms", 0))
	poems = data.get("poems", [])
	mood = data.get("mood", {})
	chat_day = data.get("chat_day", {})
	day_count = int(data.get("day_count", 0))
	rumor_count = int(data.get("rumor_count", 0))
	best_speed = int(data.get("best_speed", 0))
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
		if inventory.has(e["id"]) or used.has(e["id"]) or (e["kind"] == "star" and solved.has(e["id"])) or (e["kind"] == "choni" and solved.has("ch:" + e["id"])): e["node"].hide()
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
	var before = day_t
	day_t = fmod(day_t + delta / DAY_LEN, 1.0)
	if day_t < before: day_count += 1
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
		if not firefly_told and n.global_position.distance_to(player.position) < 9.0 and not panel.visible:
			firefly_told = true
			learn("far-par")
			toast("Far-par-ir! Fireflies! (far fire + par bird: a calque)")
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
	var rr = randf()
	if rr < 0.25: fish_rain_t = 12.0
	elif rr < 0.42: choni_rain_t = 14.0
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

# Three short lines, drawn in code (the font has no menu symbol).
func menu_icon() -> ImageTexture:
	var img = Image.create(22, 18, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for k in range(3):
		for y in range(3):
			for x in range(22):
				var edge = (x == 0 or x == 21) and (y == 0 or y == 2)
				if not edge: img.set_pixel(x, k * 7 + y, Color("2e1c0c"))
	return ImageTexture.create_from_image(img)

func layout_hud():
	update_status()
	status.visible = not hud_small
	status_small.visible = hud_small
	top_row.position = Vector2(170, 30) if hud_small else Vector2(14, 124)

func update_status():
	var obj = objective()
	var total = quests.size() + side_quests.size()
	status_small.text = "Quests " + str(quests_done()) + "/" + str(total)
	var lv = level()
	status.text = obj + "\nLevel " + str(lv) + " " + Data.LEVEL_NAMES[lv] + ".  Done " + str(quests_done()) + " of " + str(total) + ".  Tap to fold."
	check_level()
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
		if e.has("emote"): e.erase("emote")
		hiding[kid] = true
	message("Ma-ta-pal-o-ki!", "Ola covers your eyes and shouts “Ma-ta-pal-o-ki!” Don't look! When you turn around, Rin and Ola are gone. One hid near the school, one near the market. Find them!")

func found_puzzle(id: String):
	choice_puzzle("Found you!", id.capitalize() + " is crouching out of sight, giggling. What do you shout?",
		["K-ta-pal-da!", "T-na-pal-da!", "Ma-k-ta-pal-ki-da!"], 0, func():
			hiding[id] = false
			var e = entity_by_id(id)
			if e.has("emote"): e.erase("emote")
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
	learn("wala")
	message("Wala! Dar gin!", "Your shovel hits wood. A chest! Inside are dar gin: ten coins, and a note in Neri's handwriting: “Ho! Ti kelar i-ho.” Good, you are a good traveler.")

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
		message("Barve hai-sao!", "The eighth sea star! You found them all. The ending -ve makes order words: yan-ve first, vel-ve second, bar-ve eighth.\n\nYoung islanders call them sao-tari, star-fish. That is a calque: English starfish translated piece by piece.")
		learn("sao-tari")
	save_game()

# ---- production practice: sentence tiles and the verb builder ----

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
	text_line("Build one Tujuju verb that means:\n\"" + ch[0] + "\"")
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

# ------------------------------------------------------------ fourth expansion: salient Tujuju, levels, options

# Tujuju inside curly quotes is drawn larger, bold and highlighted so it stands out from English.
func rich_line(text: String, font_size: int = 20) -> RichTextLabel:
	if quote_re == null: quote_re = RegEx.create_from_string("“([^”]*)”")
	var r = RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_theme_font_size_override("normal_font_size", font_size)
	r.add_theme_font_size_override("bold_font_size", font_size + 7)
	r.add_theme_color_override("default_color", Color("2e1c0c"))
	var safe = text.replace("[", "[lb]")
	r.text = quote_re.sub(safe, "[bgcolor=#f3d9a0][b][color=#7a1f3d][url]$1[/url][/color][/b][/bgcolor]", true)
	r.meta_underlined = false
	r.meta_clicked.connect(func(m): speak(str(m)))
	content.add_child(r)
	return r

func varnak_banner(text: String, size: int = 30) -> PanelContainer:
	var pc = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("24495a")
	sb.border_color = Color("e9c46a")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	pc.add_theme_stylebox_override("panel", sb)
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("fff3c4"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pc.add_child(l)
	sb.content_margin_right = 56
	if completed.has("kirmel") and kir_show:
		var strip = Control.new()
		var lay = K.layout(K.syllables(text), 22.0, 380.0)
		strip.custom_minimum_size = Vector2(0, lay["size"].y)
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.draw.connect(func(): K.draw_on(strip, text, Vector2(maxf(0.0, (strip.size.x - lay["size"].x) * 0.5), 0), 22.0, 380.0, Color("2f6f74"), 2.0))
		content.add_child(strip)
	var spk = speaker_button()
	spk.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	spk.position = Vector2(0, -20)
	l.add_child(spk)
	l.resized.connect(func(): spk.position = Vector2(l.size.x + 6, l.size.y * 0.5 - 20))
	spk.pressed.connect(func(): speak(l.text))
	content.add_child(pc)
	return pc

func level_points() -> int:
	return quests_done() * 3 + mastered.size()

func level() -> int:
	var pts = level_points()
	var lv = 1
	if pts >= 25: lv = 2
	if pts >= 60: lv = 3
	if pts >= 110: lv = 4
	return clampi(lv + diff_bias, 1, 4)

func check_level():
	var lv = level()
	if last_level != 0 and lv > last_level:
		toast("Wala! Level up! " + Data.LEVEL_NAMES[lv])
		play_sfx("fanfare", 0.0, 1.12)
		for i in range(2):
			var fw: CPUParticles3D = fireworks[i]
			fw.position = player.position + Vector3(randf_range(-4, 4), 9, randf_range(-6, -2)).rotated(Vector3.UP, player.rotation.y)
			fw.color = Color("ffd34d") if i == 0 else Color("6de0ff")
			fw.restart()
	last_level = lv

func level_note(lv: int) -> String:
	match lv:
		1: return "Explorer: three answer choices, gestures and tips shown, short sentences."
		2: return "Speaker: an extra wrong choice, residents ask you to build sentences yourself, longer sentences and more decoy tiles."
		3: return "Storyteller: gestures hidden until you ask, tips only after a second try, timed market orders, a faster fishing line."
	return "Elder: the hardest sentences, the most decoys and the shortest timers."

func show_more():
	compact_buttons.call_deferred()
	clear_panel("More")
	var lv = level()
	text_line("Your level: " + str(lv) + ", " + Data.LEVEL_NAMES[lv] + ". Points: " + str(level_points()) + ". You earn points by finishing quests and mastering words, phrases and games. The game gets harder as you level up.")
	text_line(level_note(lv), 17)
	text_line("Difficulty", 22)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	content.add_child(row)
	for d in [[-1, "Easier"], [0, "Automatic"], [1, "Harder"]]:
		var b = button(d[1] + (" (on)" if diff_bias == d[0] else ""), func():
			diff_bias = d[0]
			last_level = level()
			save_game()
			show_more(), row)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Games and activities", show_games, content)
	button("My learning and data export", show_progress, content)
	button("How to play", show_intro, content)
	button("About the Tujuju language", show_varnak, content)
	button("Credits", show_credits, content)
	if completed.has("kirmel"):
		button("Kirmel writing: on" if kir_show else "Kirmel writing: off", func():
			kir_show = not kir_show
			show_more(), content)
	button("Sound: on" if sound_on else "Sound: off", func():
		sound_on = not sound_on
		apply_sound_setting()
		save_game()
		show_more(), content)
	button("Fold the quest box" if not hud_small else "Unfold the quest box", func():
		hud_small = not hud_small
		layout_hud()
		save_game()
		show_more(), content)
	button("Reset progress (start over)", confirm_reset, content)
	button("Return", close_panel, content)

func greeting(id: String) -> String:
	if guro_t >= 0.0: return "Var guro!" if id.length() % 2 == 0 else "Buruhaha!"
	var e = entity_by_id(id)
	if e.has("say") and clock < float(e["say"][1]): return e["say"][0]
	if mood.get(id, 0) <= -2: return "Hmph!"
	if completed.has("chonies") and Data.PEOPLE.has(id) and (day_count + id.length()) % 3 == 1: return "Choni-na! Bravo!"
	if Data.PEOPLE.has(id) and int(friend.get(id, 0)) >= 8 and (day_count + id.length()) % 2 == 0:
		return Data.ENDEAR[Data.PEOPLE[id]["trait"]]
	match id:
		"ena": return "Anni kel."
		"mira": return "Yamat i-nav."
		"sanu": return "Sava ruk."
		"tor": return "Gira i-sava-da." if completed.has("bridge") else "Gira ma-i-sava-ki-da."
		"lira": return "Teka i-var."
		"oren": return "Mar hala i-pav."
		"neri": return "Teka i-var!"
		"ketu": return "Mur tari t-na-ven-o-ye." if not completed.has("market") else "Tari i-ho!"
		"suri": return "Ravarir ri-puka-rav-im-da."
		"rin": return "An ravar na-an-da."
		"ola": return "Ti kelar ta-an-ha?"
		"pomo": return "Bei, nam, dong, sai."
		"vira": return "Yok e cha t-na-ven-o-ye." if not completed.has("healer") else "Ila i-seng-da."
		"ila": return "Anni dauma tong i-esh-da." if not completed.has("healer") else "An na-seng-da."
		"yalo": return "Far t-na-tar-o-ye." if not completed.has("lighthouse") else "Fardom i-ling-da."
		"desh": return "Aloha! Ta-sum-o!"
		"sair1": return "Anke panak k-i-mai-fu."
		"sair2": return "Cha i-ret."
		"sair3": return "I-ser-ng."
		"oku": return "Ki dom i-shora."
		"gav": return "Kel-ir! Kel-ir!" if not completed.has("mail") else "K-ta-har-da!"
		"tamu": return "Chau... Sendor-ru?"
	return ""

func make_bubble(e: Dictionary):
	var l = Label3D.new()
	l.font_size = 30
	l.pixel_size = 0.0075
	l.outline_size = 12
	l.outline_modulate = Color(0.16, 0.06, 0.12, 1.0)
	l.modulate = Color("ffe08a")
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.position = Vector3(0, 2.5, 0)
	l.visible = false
	(e["node"] as Node3D).add_child(l)
	e["bubble"] = l

func update_bubbles():
	for e in entities:
		if not e.has("bubble"): continue
		var b = e["bubble"] as Label3D
		var node = e["node"] as Node3D
		var near = not panel.visible and not riding and node.visible and Vector2(node.position.x - player.position.x, node.position.z - player.position.z).length() < bubble_range
		b.visible = near
		if near:
			b.text = "“" + greeting(e["id"]) + "”"
			b.position.y = 2.48 + sin(clock * 1.7 + node.position.x) * 0.03
		if e.has("mark"): (e["mark"] as Node3D).position.y = (3.15 if near else 2.75) + sin(clock * 2.5) * 0.08

# ------------------------------------------------------------ drag and drop activities

var dd: Dictionary = {}

func tile_box(c: Color, border: Color) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = c
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func make_tile(text: String) -> PanelContainer:
	var t = PanelContainer.new()
	t.add_theme_stylebox_override("panel", tile_box(Color("f2d27e"), Color("8a5a2b")))
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("4a1530"))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	t.add_child(l)
	t.custom_minimum_size = Vector2(46, 50)
	t.mouse_filter = Control.MOUSE_FILTER_STOP
	t.set_meta("word", text)
	t.set_drag_forwarding(func(_at):
		var pv = Label.new()
		pv.text = text
		pv.add_theme_font_size_override("font_size", 24)
		pv.add_theme_color_override("font_color", Color("4a1530"))
		pv.add_theme_stylebox_override("normal", tile_box(Color("ffe39a"), Color("8a5a2b")))
		t.set_drag_preview(pv)
		return {"tile": t},
		func(_at, data): return data is Dictionary and data.has("tile") and t.get_parent() != dd.get("tray"),
		func(_at, data): drop_on.call_deferred(t.get_parent(), data["tile"]))
	t.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed: t.set_meta("down", ev.global_position)
			elif t.has_meta("down") and (ev.global_position - t.get_meta("down")).length() < 10.0: tile_tapped(t))
	return t

func make_slot(locked_text: String) -> PanelContainer:
	var s = PanelContainer.new()
	var locked = locked_text != ""
	s.add_theme_stylebox_override("panel", tile_box(Color("dcd3c0") if locked else Color("fff8e6"), Color("8a7a66") if locked else Color("b08850")))
	s.custom_minimum_size = Vector2(70, 54)
	var l = Label.new()
	l.text = locked_text if locked else "   ?   "
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", Color("3b2d25") if locked else Color("c2a878"))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.add_child(l)
	s.set_meta("locked", locked)
	s.set_meta("placeholder", l)
	if not locked:
		s.set_drag_forwarding(Callable(),
			func(_at, data): return data is Dictionary and data.has("tile"),
			func(_at, data): drop_on.call_deferred(s, data["tile"]))
	return s

func slot_tile(s: Control) -> Control:
	for c in s.get_children():
		if c.has_meta("word"): return c
	return null

func drop_on(target: Control, t: Control):
	if target == null or t == null: return
	if target == dd.get("tray"):
		move_tile(t, target)
	elif target.has_meta("locked") and not target.get_meta("locked"):
		var old = slot_tile(target)
		if old == t: return
		var from = t.get_parent()
		if old != null:
			if from != null and from.has_meta("locked"): move_tile(old, from)
			else: move_tile(old, dd["tray"])
		move_tile(t, target)
	dd_refresh()

func move_tile(t: Control, to: Control):
	var from = t.get_parent()
	if from: from.remove_child(t)
	to.add_child(t)

func tile_tapped(t: Control):
	var parent = t.get_parent()
	if parent == dd.get("tray"):
		for s in dd["slots"]:
			if not s.get_meta("locked") and slot_tile(s) == null:
				move_tile(t, s)
				break
	else:
		move_tile(t, dd["tray"])
	dd_refresh()

func dd_words() -> Array:
	var out: Array = []
	for s in dd["slots"]:
		if s.get_meta("locked"): out.append((s.get_meta("placeholder") as Label).text)
		else:
			var t = slot_tile(s)
			out.append(t.get_meta("word") if t else "")
	return out

func dd_join(ws: Array) -> String:
	var parts: Array = []
	for w in ws:
		if w != "": parts.append(w)
	if dd.get("pieces", false):
		var j = "".join(parts).replace("--", "-")
		return j.trim_prefix("-").trim_suffix("-")
	return " ".join(parts)

func dd_refresh():
	for s in dd["slots"]:
		var ph = s.get_meta("placeholder") as Label
		ph.visible = s.get_meta("locked") or slot_tile(s) == null
		s.add_theme_stylebox_override("panel", tile_box(Color("dcd3c0") if s.get_meta("locked") else Color("fff8e6"), Color("8a7a66") if s.get_meta("locked") else Color("b08850")))
	var shown: String = dd_join(dd_words())
	(dd["preview"] as Label).text = shown if shown != "" else "..."

# One engine for every drag-and-drop activity.
# cfg: title, prompt, answers (Array), locked (Array of bool), hints (Array of row labels), pool (extra tiles),
#      pieces (join word pieces without spaces), tip, key, back, again, on_right
func dnd(cfg: Dictionary):
	clear_panel(cfg["title"], true)
	dnd_on = true
	text_line(cfg["prompt"])
	var hint_text = text_line("Drag each tile into a box, or tap a tile to place it. Tap a placed tile to take it back.", 15)
	hint_text.add_theme_color_override("font_color", Color("6b4a2e"))
	var preview = Label.new()
	preview.add_theme_font_size_override("font_size", 24)
	preview.add_theme_color_override("font_color", Color("7a1f3d"))
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var answers: Array = cfg["answers"]
	var locked: Array = cfg.get("locked", [])
	var hints: Array = cfg.get("hints", [])
	var slots: Array = []
	if hints.is_empty():
		var row = HFlowContainer.new()
		row.add_theme_constant_override("h_separation", 6)
		row.add_theme_constant_override("v_separation", 6)
		content.add_child(row)
		for i in range(answers.size()):
			var s = make_slot(answers[i] if (i < locked.size() and locked[i]) else "")
			row.add_child(s)
			slots.append(s)
	else:
		for i in range(answers.size()):
			var hr = HBoxContainer.new()
			hr.add_theme_constant_override("separation", 10)
			content.add_child(hr)
			var hl = Label.new()
			hl.text = hints[i]
			hl.custom_minimum_size.x = 150
			hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hl.add_theme_font_size_override("font_size", 19)
			hr.add_child(hl)
			var s = make_slot("")
			s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hr.add_child(s)
			slots.append(s)
	content.add_child(preview)
	var tl = text_line("Tiles", 16)
	tl.add_theme_color_override("font_color", Color("6b4a2e"))
	var tray = HFlowContainer.new()
	tray.add_theme_constant_override("h_separation", 8)
	tray.add_theme_constant_override("v_separation", 8)
	tray.custom_minimum_size.y = 60
	tray.mouse_filter = Control.MOUSE_FILTER_STOP
	content.add_child(tray)
	tray.set_drag_forwarding(Callable(),
		func(_at, data): return data is Dictionary and data.has("tile"),
		func(_at, data): drop_on.call_deferred(tray, data["tile"]))
	var pool: Array = []
	for i in range(answers.size()):
		if not (i < locked.size() and locked[i]): pool.append(answers[i])
	for x in cfg.get("pool", []):
		if not pool.has(x): pool.append(x)
	pool.shuffle()
	dd = {"slots": slots, "tray": tray, "preview": preview, "answers": answers, "pieces": cfg.get("pieces", false), "tries": 0}
	for w in pool: tray.add_child(make_tile(w))
	var feedback = text_line("", 19)
	var row2 = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	content.add_child(row2)
	var clear_b = button("Clear", func():
		for s in slots:
			var t = slot_tile(s)
			if t: move_tile(t, tray)
		dd_refresh(), row2)
	var check_b = button("Check", func():
		var got = dd_words()
		if got.has(""):
			feedback.text = "Fill every box first."
			feedback.add_theme_color_override("font_color", Color("8a2f1f"))
			return
		play_sfx("correct" if got == answers else "wrong", -4.0)
		log_event("build", {"activity": cfg["title"], "key": cfg.get("key", ""), "item": str(cfg["prompt"]).substr(0, 160), "built": dd_join(got), "target": dd_join(answers)}, got == answers)
		if got == answers:
			feedback.text = "Correct!  " + dd_join(answers)
			feedback.add_theme_color_override("font_color", Color("2f6b2f"))
			if cfg.has("key"): master(cfg["key"])
			if cfg.has("on_right") and (cfg["on_right"] as Callable).is_valid(): (cfg["on_right"] as Callable).call()
			for s in slots: s.add_theme_stylebox_override("panel", tile_box(Color("cfe8c4"), Color("2f6b2f")))
		else:
			dd["tries"] += 1
			var tip: String = cfg.get("tip", "")
			var show_tip = level() < 3 or dd["tries"] >= 2
			feedback.text = "Not quite. " + (tip if show_tip else "Look again at the endings and the order.")
			feedback.add_theme_color_override("font_color", Color("8a2f1f"))
			if level() <= 2:
				for i in range(slots.size()):
					if not slots[i].get_meta("locked") and got[i] != answers[i]:
						slots[i].add_theme_stylebox_override("panel", tile_box(Color("f6d0c4"), Color("8a2f1f"))), row2)
	clear_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	check_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if cfg.has("again"): button(cfg.get("again_label", "Another one"), cfg["again"], content)
	button("Back", cfg.get("back", show_games), content)
	dd_refresh()

func auto_decoys(tiles: Array, n: int) -> Array:
	var out: Array = []
	var cands: Array = []
	for w in tiles:
		var s: String = w
		var dot = s.ends_with(".")
		var core = s.trim_suffix(".")
		if s.contains("-") and dot:
			if core.ends_with("-da"): cands.append(core.trim_suffix("-da") + "-nu.")
			if core.begins_with("k-i-"): cands.append("t-i-" + core.substr(4) + ".")
			elif core.begins_with("i-"): cands.append("ri-" + core.substr(2) + ".")
			continue
		if core.ends_with("ke") and core.length() > 3: cands.append(core.substr(0, core.length() - 2))
		elif core.ends_with("ma"): cands.append(core.substr(0, core.length() - 2) + "ru")
		elif core.ends_with("ru"): cands.append(core.substr(0, core.length() - 2) + "ta")
		elif core.ends_with("ta"): cands.append(core.substr(0, core.length() - 2) + "ma")
		elif not core.contains("-"): cands.append(core + "ke")
	cands.shuffle()
	for c in cands:
		if not tiles.has(c) and not out.has(c) and out.size() < n: out.append(c)
	return out

func pick_tile_index() -> int:
	var lv = level()
	var ok: Array = []
	var top: Array = []
	for i in range(Data.TILES.size()):
		var tl = int(Data.TILES[i].get("lv", 1))
		if tl <= lv: ok.append(i)
		if tl == lv: top.append(i)
	if not top.is_empty() and lv > 1 and randf() < 0.6: return top[randi() % top.size()]
	return ok[randi() % ok.size()]

func tile_pool(tp: Dictionary) -> Array:
	var lv = level()
	var given: Array = tp["decoys"]
	var pool: Array = given.slice(0, 1) if lv == 1 else given.duplicate()
	pool.append_array(auto_decoys(tp["tiles"], [0, 0, 1, 2, 3][lv]))
	return pool

func tile_puzzle(i: int = -1, back: Callable = Callable()):
	if i < 0: i = pick_tile_index()
	var tp: Dictionary = Data.TILES[i]
	if not back.is_valid(): back = show_games
	dnd({"title": "Sentence builder", "prompt": "Put the words in order to say:\n\"" + tp["en"] + "\"", "answers": tp["tiles"], "pool": tile_pool(tp),
		"tip": tp["tip"] + " Usual order: the one acting, the thing acted on, places, then the verb.", "key": "t:" + str(i),
		"again": tile_puzzle.bind(-1, back), "again_label": "Another sentence", "back": back})

func challenge(id: String):
	var i: int = Data.CHALLENGES[id]
	var tp: Dictionary = Data.TILES[i]
	var who = names.get(id, id.capitalize())
	dnd({"title": "Say it yourself", "prompt": who + " wants to hear you say it in Tujuju:\n\"" + tp["en"] + "\"", "answers": tp["tiles"], "pool": tile_pool(tp),
		"tip": tp["tip"], "key": "t:" + str(i), "back": talk.bind(id),
		"on_right": func():
			if not mastered.has("c:" + id):
				master("c:" + id)
				gin += 1
				toast(who + " is impressed! +1 gin")
				save_game()})

func gap_fill(back: Callable = Callable()):
	var i = pick_tile_index()
	var tp: Dictionary = Data.TILES[i]
	if tp["tiles"].size() < 2:
		gap_fill(back)
		return
	var n = tp["tiles"].size()
	var gaps = 1 if level() < 3 or n < 3 else 2
	var idx: Array = range(n)
	idx.shuffle()
	var locked: Array = []
	for k in range(n): locked.append(not idx.slice(0, gaps).has(k))
	if not back.is_valid(): back = show_games
	dnd({"title": "Fill the gap", "prompt": "Complete the sentence:\n\"" + tp["en"] + "\"", "answers": tp["tiles"], "locked": locked, "pool": tile_pool(tp),
		"tip": tp["tip"], "key": "f:" + str(i), "again": gap_fill.bind(back), "again_label": "Another gap", "back": back})

func word_forge(back: Callable = Callable()):
	if not back.is_valid(): back = show_games
	var lv = level()
	if lv >= 2 and randf() < 0.55:
		var vi = randi() % Data.VERBS.size()
		var target: String = Data.VERBS[vi][1]
		var parts = target.split("-")
		var pieces: Array = []
		for k in range(parts.size()):
			var pc: String = parts[k]
			if k == 0 and pc == "ma": pieces.append("ma-")
			elif pc in ["na", "ta", "i", "ri"] and pieces.size() <= 1: pieces.append(pc + "-")
			elif pc in ["lum", "pav", "sul", "sum", "tal", "nang"]: pieces.append(pc)
			else: pieces.append("-" + pc)
		var decoys: Array = []
		for d in ["na-", "ta-", "i-", "ri-", "-pa", "-fu", "-da", "-nu", "-im", "-ur", "-ak"]:
			if not pieces.has(d): decoys.append(d)
		decoys.shuffle()
		dnd({"title": "Word forge: verbs", "prompt": "Build one verb that means:\n\"" + Data.VERBS[vi][0] + "\"\n\nlum go, pav run, sul sleep, sum swim, tal arrive, nang walk", "answers": pieces, "pool": decoys.slice(0, lv),
			"pieces": true, "tip": "Order: ma- (not), who, action, -im/-ak/-ur, -pa/-fu, -ki, then -da/-shi/-nu.", "key": "vb:" + str(vi), "again": word_forge.bind(back), "again_label": "Another word", "back": back})
		return
	var roots: Array = []
	for r in Data.NOUNS.keys():
		if discovered.has(r): roots.append(r)
	if roots.size() < 3: roots = Data.NOUNS.keys()
	var root: String = roots[randi() % roots.size()]
	var sufs: Array = []
	for s in ["ma", "ru", "ta", "li", "ni", "su", "ven", "ir"]:
		if suffix_ok(root, s): sufs.append(s)
	sufs.shuffle()
	var decoys: Array = []
	for s in sufs.slice(1, 1 + lv + 1): decoys.append("-" + s)
	dnd({"title": "Word forge: endings", "prompt": "Build the word for:\n\"" + suffix_meaning(root, sufs[0]) + "\"", "answers": [root, "-" + sufs[0]], "pool": decoys,
		"pieces": true, "tip": "-ma in, -ru to, -ta from, -li with, -ni of, -su together with, -ven as far as, -ir plural.", "key": "w:-" + sufs[0], "again": word_forge.bind(back), "again_label": "Another word", "back": back})

func glossed_pool(n: int) -> Array:
	var pool: Array = []
	var seen: Array = []
	var cand = discovered.duplicate()
	cand.shuffle()
	for w in cand:
		var g = short_gloss(w)
		if g == "" or w.begins_with("-") or w.ends_with("-") or seen.has(g) or w.contains(" "): continue
		pool.append(w)
		seen.append(g)
		if pool.size() >= n: break
	return pool

func word_match(back: Callable = Callable()):
	if not back.is_valid(): back = show_games
	var lv = level()
	var n = [0, 4, 5, 6, 6][lv]
	var ws = glossed_pool(n + 1)
	if ws.size() < 4:
		message("Word match", "Collect a few more words first: talk to people and examine things.")
		return
	var use = ws.slice(0, mini(n, ws.size()))
	var hints: Array = []
	for w in use: hints.append(short_gloss(w))
	var extra: Array = ws.slice(use.size()) if lv >= 2 else []
	dnd({"title": "Word match", "prompt": "Drag each Tujuju word next to its meaning.", "answers": use, "hints": hints, "pool": extra,
		"tip": "Check the notebook for any word you are unsure of.", "key": "g:match", "again": word_match.bind(back), "again_label": "New words", "back": back})

# ------------------------------------------------------------ mini-games with timers and cards

func update_minigame(delta: float):
	if mg.is_empty() or not panel.visible: return
	match mg.get("type", ""):
		"fish":
			mg["t"] += delta * mg["speed"]
			var bar = mg["bar"] as Control
			var w = bar.size.x
			var u = (sin(mg["t"]) + 1.0) * 0.5
			mg["u"] = u
			(mg["marker"] as Control).position = Vector2(u * (w - 10.0), 0)
			var zone = mg["zone"] as Control
			zone.position = Vector2(mg["zx"] * w, 0)
			zone.size = Vector2(mg["zw"] * w, bar.size.y)
		"market", "speed":
			if mg.get("time", 0.0) > 0.0:
				mg["time"] -= delta
				if mg.has("clock_label") and is_instance_valid(mg["clock_label"]): (mg["clock_label"] as Label).text = "Time: " + str(int(ceil(mg["time"])))
				if mg["time"] <= 0.0:
					if mg["type"] == "market":
						toast("Too slow! The customer left.")
						mg["i"] += 1
						market_next()
					else: speed_end()

func fishing_game():
	clear_panel("Na-tari-nuk-im.", true)
	var lv = level()
	text_line("You cast your line. Tap Pull! when the white marker is inside the green zone.")
	var bar = Panel.new()
	bar.custom_minimum_size = Vector2(0, 46)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("2f7f96")
	sb.set_corner_radius_all(8)
	bar.add_theme_stylebox_override("panel", sb)
	content.add_child(bar)
	var zone = ColorRect.new()
	zone.color = Color(0.45, 0.85, 0.45, 0.85)
	bar.add_child(zone)
	var marker = ColorRect.new()
	marker.color = Color(1, 1, 1)
	marker.size = Vector2(10, 46)
	bar.add_child(marker)
	var zw = [0.0, 0.3, 0.22, 0.16, 0.12][lv]
	mg = {"type": "fish", "t": randf() * TAU, "speed": [0.0, 1.6, 2.1, 2.7, 3.3][lv], "zw": zw, "zx": randf_range(0.05, 0.95 - zw), "bar": bar, "zone": zone, "marker": marker}
	button("Pull!", fish_pull, content)
	text_line("Fish in your bag: " + str(fish_caught) + ".", 17)
	button("Stop fishing", close_panel, content)

func fish_pull():
	if mg.get("type", "") != "fish": return
	var u: float = mg.get("u", -1.0)
	var hit = u >= mg["zx"] - 0.02 and u <= mg["zx"] + mg["zw"] + 0.02
	if hit:
		fish_caught += 1
		master("g:fish")
		save_game()
		clear_panel("A catch!")
		text_line("You pull out a silver fish.\n\n“Anke tari k-i-nuk-ak-pa-da.”\nI caught the fish.")
		fish_count_note()
		button("Fish again", fishing_game, content)
		button("Return", close_panel, content)
	else:
		toast("It got away! Try again.")
		mg["zx"] = randf_range(0.05, 0.95 - mg["zw"])

func memory_game(back: Callable = Callable()):
	if not back.is_valid(): back = show_games
	var lv = level()
	var n = [0, 4, 6, 8, 8][lv]
	var ws = glossed_pool(n)
	if ws.size() < 4:
		message("Memory cards", "Collect a few more words first: talk to people and examine things.")
		return
	clear_panel("Memory cards", true)
	text_line("Turn over two cards at a time. Match each Tujuju word with its meaning.")
	var info = text_line("Moves: 0", 17)
	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	content.add_child(grid)
	var cards: Array = []
	for i in range(ws.size()):
		cards.append({"t": ws[i], "pair": i, "v": true})
		cards.append({"t": short_gloss(ws[i]), "pair": i, "v": false})
	cards.shuffle()
	mg = {"type": "memory", "open": [], "moves": 0, "left": ws.size(), "busy": false}
	for c in cards:
		var b = Button.new()
		b.text = "?"
		b.custom_minimum_size = Vector2(92, 74)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 17)
		grid.add_child(b)
		b.pressed.connect(func():
			if mg.get("type", "") != "memory" or mg["busy"] or b.text != "?": return
			b.text = c["t"]
			if c["v"]: b.add_theme_color_override("font_color", Color("7a1f3d"))
			mg["open"].append([b, c])
			if mg["open"].size() == 2:
				mg["moves"] += 1
				info.text = "Moves: " + str(mg["moves"])
				var a1 = mg["open"][0]
				var a2 = mg["open"][1]
				if a1[1]["pair"] == a2[1]["pair"] and a1[1]["v"] != a2[1]["v"]:
					for x in [a1[0], a2[0]]: x.disabled = true
					mg["open"] = []
					mg["left"] -= 1
					if mg["left"] == 0:
						var reward = maxi(1, ws.size() / 2)
						gin += reward
						master("g:memory")
						save_game()
						info.text = "All pairs in " + str(mg["moves"]) + " moves! +" + str(reward) + " gin"
				else:
					mg["busy"] = true
					get_tree().create_timer(0.9).timeout.connect(func():
						if mg.get("type", "") != "memory": return
						for x in [a1[0], a2[0]]:
							if is_instance_valid(x): x.text = "?"
						mg["open"] = []
						mg["busy"] = false))
	button("New cards", memory_game.bind(back), content)
	button("Back", back, content)

func market_rush():
	var lv = level()
	mg = {"type": "market", "i": 0, "n": [0, 3, 4, 5, 6][lv], "score": 0, "per": [0.0, 0.0, 0.0, 25.0, 18.0][lv]}
	market_next()

func market_next():
	if mg.get("type", "") != "market": return
	if mg["i"] >= mg["n"]:
		var s: int = mg["score"]
		mg = {}
		if s >= 3: master("g:market")
		gin += s
		save_game()
		message("Ketu counts the takings", "You served " + str(s) + " of the customers correctly and earned " + str(s) + " gin. “Ho!” says Ketu.")
		return
	var lv = level()
	var goods = Data.GOODS.keys()
	goods.shuffle()
	var k = randi_range(1, [0, 1, 2, 2, 3][lv])
	var order: Dictionary = {}
	var said: Array = []
	for g in goods.slice(0, k):
		var q = randi_range(1, 3 if lv < 3 else 5)
		order[g] = q
		said.append(Data.NUMBERS[q] + " " + g)
	mg["order"] = order
	mg["counts"] = {}
	for g in Data.GOODS.keys(): mg["counts"][g] = 0
	mg["time"] = mg["per"]
	clear_panel("Market rush: customer " + str(mg["i"] + 1) + " of " + str(mg["n"]), true)
	var line = " e ".join(said)
	text_line("A customer says:\n\n“" + line.substr(0, 1).to_upper() + line.substr(1) + " t-na-ven-o-ye.”")
	if mg["per"] > 0.0:
		mg["clock_label"] = text_line("Time: " + str(int(mg["per"])), 18)
	for g in Data.GOODS.keys():
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		content.add_child(row)
		var name_l = Label.new()
		name_l.text = g + "  (" + Data.GOODS[g] + ")"
		name_l.custom_minimum_size.x = 150
		name_l.add_theme_font_size_override("font_size", 19)
		row.add_child(name_l)
		var count_l = Label.new()
		count_l.text = "nul"
		count_l.custom_minimum_size.x = 70
		count_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_l.add_theme_font_size_override("font_size", 22)
		count_l.add_theme_color_override("font_color", Color("7a1f3d"))
		var minus = button("-", func():
			mg["counts"][g] = maxi(0, mg["counts"][g] - 1)
			count_l.text = Data.NUMBERS[mg["counts"][g]], row)
		row.add_child(count_l)
		var plus = button("+", func():
			mg["counts"][g] = mini(10, mg["counts"][g] + 1)
			count_l.text = Data.NUMBERS[mg["counts"][g]], row)
		minus.custom_minimum_size.x = 54
		plus.custom_minimum_size.x = 54
	button("Hand it over", func():
		var ok = true
		for g in Data.GOODS.keys():
			if mg["counts"][g] != mg["order"].get(g, 0): ok = false
		if ok:
			mg["score"] += 1
			toast("“K-ta-har-da!” Correct order.")
		else:
			var want: Array = []
			for g in mg["order"].keys(): want.append(str(mg["order"][g]) + " " + Data.GOODS[g])
			toast("Not quite: they wanted " + ", ".join(want) + ".")
		mg["i"] += 1
		market_next(), content)
	button("Stop", close_panel, content)

func speed_round():
	var ws = glossed_pool(40)
	if ws.size() < 6:
		message("Speed round", "Collect at least six words first.")
		return
	mg = {"type": "speed", "time": 60.0, "score": 0, "pool": ws}
	speed_next()

func speed_next():
	if mg.get("type", "") != "speed": return
	var lv = level()
	var ws: Array = mg["pool"]
	var w: String = ws[randi() % ws.size()]
	var opts: Array = [short_gloss(w)]
	var sh = ws.duplicate()
	sh.shuffle()
	for o in sh:
		var g = short_gloss(o)
		if not opts.has(g) and opts.size() < [0, 3, 4, 4, 5][lv]: opts.append(g)
	var right = opts[0]
	opts.shuffle()
	clear_panel("Speed round", true)
	mg["clock_label"] = text_line("Time: " + str(int(ceil(mg["time"]))) + "     Score: " + str(mg["score"]) + "     Best: " + str(best_speed), 18)
	varnak_banner(w, 34)
	for o in opts:
		button(o, func():
			if mg.get("type", "") != "speed": return
			if o == right:
				mg["score"] += 1
				master("w:" + w)
			else:
				mg["time"] -= 3.0
				toast("“" + w + "” = " + right + "  (-3 s)")
			speed_next(), content)
	button("Stop", speed_end, content)

func speed_end():
	if mg.get("type", "") != "speed": return
	var s: int = mg["score"]
	mg = {}
	var best = s > best_speed
	best_speed = maxi(best_speed, s)
	if s >= 10: master("g:speed")
	if s >= 15:
		gin += 2
	save_game()
	message("Time!", "You scored " + str(s) + "." + (" A new best!" if best else " Best: " + str(best_speed) + ".") + (" Suri gives you vel gin for a great round." if s >= 15 else ""))

func show_games():
	compact_buttons.call_deferred()
	clear_panel("Games and activities")
	var lv = level()
	text_line("Level " + str(lv) + ": " + Data.LEVEL_NAMES[lv] + ". Games get harder as your level rises. You have " + str(gin) + " gin.", 17)
	var n = glossed_pool(8).size()
	var games = [
		["Sentence builder (drag and drop)", tile_puzzle.bind(-1, show_games), true, "Put words in order."],
		["Fill the gap (drag and drop)", gap_fill.bind(show_games), true, "Drag the missing word into the sentence."],
		["Word forge (drag and drop)", word_forge.bind(show_games), true, "Build words from roots and endings."],
		["Word match (drag and drop)", word_match.bind(show_games), n >= 4, "Match Tujuju words with meanings."],
		["Memory cards", memory_game.bind(show_games), n >= 4, "Find the pairs. Earn gin."],
		["Speed round", speed_round, glossed_pool(6).size() >= 6, "60 seconds. How many can you get?"],
		["Market rush", market_rush, completed.has("market"), "Serve Ketu's customers. Unlocks after Ketu's quest."],
		["Verb builder", show_verb_builder.bind(-1), true, "Choose the pieces of a verb."],
		["False friends", false_friends.bind(true), true, "Tujuju words that look like English. Don't be fooled!"],
		["What's that sound?", sound_game.bind(true), true, "Match sound words borrowed from Guarani to what you hear."],
		["Yesen! (improv)", show_yesen_list, level() >= YESEN_LEVEL, "Short, silly improv scenes. Say yes, and... in Tujuju and win over a crowd. Level 2 and up."],
		["Word wand", wand_panel, solved.has("wand"), "Say a sentence and it comes true. Get the wand from Oku at the old ruins."],
		["Guess who", guess_start, true, "Ask Neri yes or no questions and work out who they are thinking of."],
		["Teach Neri", teach_neri.bind(show_games), true, "Neri makes a mistake in Tujuju. Find it and fix it."],
		["Review rusty words", review_rusty, discovered.size() >= 3, "Words you have found but not yet mastered."]
	]
	for g in games:
		var b = button(g[0] + ("" if g[2] else "  (locked)"), g[1], content)
		b.disabled = not g[2]
		var d = text_line(g[3], 15)
		d.add_theme_color_override("font_color", Color("6b4a2e"))
	text_line("Fishing: tap a jumping fish at the river, the dock or the lagoon.", 16)
	button("Return", close_panel, content)

# ------------------------------------------------------------ fifth expansion: nonsense, gossip and rumors

func build_places5():
	# a fish living in the market well
	var f = Art.animal("tari")
	f.position = Vector3(-50.3, 0.55, 12.6)
	f.rotation_degrees = Vector3(-70, 160, 0)
	f.scale = Vector3.ONE * 1.3
	add_child(f)
	odd_nodes["odd_fish"] = f
	# a chair on a roof
	var c = Node3D.new()
	c.position = Vector3(10, 4.62, 7.2)
	c.rotation_degrees.y = 180
	add_child(c)
	Art.box(c, Vector3(0, 0.45, 0), Vector3(0.55, 0.08, 0.55), Color("b0814f"))
	Art.box(c, Vector3(0, 0.8, -0.25), Vector3(0.55, 0.65, 0.07), Color("b0814f"))
	for lx in [-0.23, 0.23]:
		for lz in [-0.23, 0.23]:
			Art.box(c, Vector3(lx, 0.22, lz), Vector3(0.06, 0.45, 0.06), Color("8a6a46"))
	# Ketu's striped shirt up a tree
	var s = Node3D.new()
	s.position = Vector3(40.9, 2.5, 27.9)
	s.rotation_degrees = Vector3(0, 30, 12)
	add_child(s)
	for i in range(4):
		Art.box(s, Vector3(0, 0.3 - i * 0.16, 0), Vector3(0.7, 0.16, 0.08), Color("e76f51") if i % 2 == 0 else Color("f4ead0"))
	Art.box(s, Vector3(-0.45, 0.32, 0), Vector3(0.3, 0.16, 0.08), Color("e76f51"))
	Art.box(s, Vector3(0.45, 0.32, 0), Vector3(0.3, 0.16, 0.08), Color("e76f51"))
	odd_nodes["odd_clothes"] = s
	# Suri's book floating in the lagoon
	var b = Node3D.new()
	b.position = Vector3(70.4, -0.06, 26.6)
	add_child(b)
	Art.box(b, Vector3(0, 0.04, 0), Vector3(0.5, 0.08, 0.36), Color("2a6f97"))
	Art.box(b, Vector3(0, 0.085, 0), Vector3(0.46, 0.02, 0.32), Color("f2e8d0"))
	odd_nodes["odd_book"] = b
	# a bed floating down the river
	var bed = Art.bed(self, Vector3(20, -0.32, -23.2), 90)
	odd_nodes["odd_bed"] = bed
	# a giant fruit by the east road
	var gf = Art.sph(self, Vector3(26, 1.35, -13.4), 1.45, Color("e07a4f"), Vector3(1, 0.95, 1), 16)
	Art.box(self, Vector3(26.2, 2.85, -13.4), Vector3(0.2, 0.5, 0.2), Color("6b4f36"), Vector3(0, 0, 12))
	Art.box(self, Vector3(26.6, 2.9, -13.4), Vector3(0.7, 0.06, 0.35), Color("4f8b3c"), Vector3(0, 20, -20))
	solid(Vector3(26, 1.3, -13.4), Vector3(2.4, 2.6, 2.4))
	block(26, -13.4, 1.6)
	# a steaming teapot on the bridge rail
	var tp = Node3D.new()
	tp.position = Vector3(1.5, 1.0, -21.4)
	add_child(tp)
	Art.sph(tp, Vector3(0, 0.12, 0), 0.15, Color("2a9d8f"), Vector3(1, 0.85, 1), 10)
	Art.cyl(tp, Vector3(0.17, 0.14, 0), 0.02, 0.035, 0.18, Color("2a9d8f"), Vector3(0, 0, -55), 6)
	Art.sph(tp, Vector3(0, 0.27, 0), 0.04, Color("e9c46a"), Vector3.ONE, 6)
	odd_nodes["odd_teapot"] = tp
	# Gav's chonies flying from the lighthouse
	var ch = Node3D.new()
	ch.position = Vector3(77.4, 12.2, -6.25)
	add_child(ch)
	Art.cyl(ch, Vector3(0, 0.6, 0), 0.025, 0.025, 1.2, Color("3b2d25"), Vector3.ZERO, 5)
	var flag = Node3D.new()
	flag.position = Vector3(0.05, 1.05, 0)
	flag.scale = Vector3.ONE * 2.0
	ch.add_child(flag)
	Art.box(flag, Vector3(0.35, 0, 0), Vector3(0.6, 0.32, 0.04), Color("f2f2f2"))
	for i in range(5):
		Art.sph(flag, Vector3(0.12 + (i % 3) * 0.2, -0.08 + (i / 3) * 0.16, 0.025), 0.04, Color("e76f51"), Vector3(1, 1, 0.3), 5)
	Art.box(flag, Vector3(0.35, -0.2, 0), Vector3(0.22, 0.14, 0.04), Color("f2f2f2"))
	odd_nodes["odd_choni"] = flag
	# the rolling giant fruit (an event)
	guro_node = Node3D.new()
	add_child(guro_node)
	Art.sph(guro_node, Vector3.ZERO, 0.95, Color("dc8060"), Vector3.ONE, 14)
	Art.box(guro_node, Vector3(0, 0.95, 0), Vector3(0.14, 0.35, 0.14), Color("6b4f36"))
	Art.sph(guro_node, Vector3(0.5, 0.5, 0.5), 0.18, Color("f0a070"), Vector3.ONE, 6)
	guro_node.visible = false
	# fish falling from the sky (rare rain)
	fish_fx = CPUParticles3D.new()
	fish_fx.amount = 40
	fish_fx.lifetime = 1.8
	fish_fx.emitting = false
	fish_fx.local_coords = false
	fish_fx.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	fish_fx.emission_box_extents = Vector3(12, 0.5, 12)
	fish_fx.direction = Vector3(0, -1, 0)
	fish_fx.initial_velocity_min = 4.0
	fish_fx.initial_velocity_max = 7.0
	fish_fx.angular_velocity_min = -300.0
	fish_fx.angular_velocity_max = 300.0
	fish_fx.gravity = Vector3(0, -9.8, 0)
	var fm = SphereMesh.new()
	fm.radius = 0.12
	fm.height = 0.5
	fm.radial_segments = 6
	fm.rings = 3
	fish_fx.mesh = fm
	fish_fx.material_override = Art.mat(Color("9fc4d4"), 0.3)
	fish_fx.position = Vector3(0, 12, 0)

func update_silly(delta: float):
	for e in entities:
		if e["kind"] == "plant":
			var fr = (e["node"] as Node3D).get_meta("fruit") as Node3D
			fr.visible = clock >= float(e.get("ripe_at", 0.0))
	if fish_fx.get_parent() == null and player: player.add_child(fish_fx)
	if odd_nodes.has("odd_bed"):
		var bed = odd_nodes["odd_bed"] as Node3D
		bed.position.y = -0.32 + sin(clock * 1.2) * 0.05
		bed.rotation_degrees.z = sin(clock * 0.9) * 3.0
	if odd_nodes.has("odd_book"): (odd_nodes["odd_book"] as Node3D).position.y = -0.06 + sin(clock * 1.7) * 0.03
	if odd_nodes.has("odd_fish"): (odd_nodes["odd_fish"] as Node3D).rotation_degrees.z = sin(clock * 2.0) * 12.0
	if odd_nodes.has("odd_choni"): (odd_nodes["odd_choni"] as Node3D).rotation_degrees.y = sin(clock * 2.6) * 25.0
	# fish rain
	if fish_rain_t > 0.0:
		if not fish_fx.emitting:
			fish_fx.emitting = true
			learn("kar")
			if not phrases.has("fish_rain"): phrases.append("fish_rain")
			toast("Halabalu! Tari-ir hen-ta ri-kar-im-da! It is raining fish!")
		fish_rain_t -= delta
		if fish_rain_t <= 0.0:
			fish_fx.emitting = false
			fish_caught += 3
			toast("You picked up three fish that fell from the sky. (+3 tari)")
			save_game()
	# the runaway fruit
	if guro_t < 0.0:
		if panel.visible or riding or night > 0.5: return
		guro_cd -= delta
		if guro_cd <= 0.0:
			guro_cd = randf_range(160.0, 280.0)
			if absf(player.position.x) < 22.0 and player.position.z > -8.0 and player.position.z < 34.0:
				guro_t = 0.0
				guro_node.visible = true
				learn("var")
				learn("guro")
				if not phrases.has("rolling_fruit"): phrases.append("rolling_fruit")
				toast("Var guro hala i-pav-im-da! A giant fruit is rolling!")
		return
	guro_t += delta
	var u = guro_t / 11.0
	if u >= 1.0:
		guro_t = -1.0
		guro_node.visible = false
		return
	var z = lerpf(-7.0, 31.0, u)
	guro_node.position = Vector3(0.6 + sin(u * 9.0) * 0.6, 0.95 + absf(sin(u * 30.0)) * 0.25, z)
	guro_node.rotation.x += delta * 7.0

# ---- gossip ----

func gossip_by(id: String) -> Array:
	var out: Array = []
	for g in Data.GOSSIP:
		if g["by"] == id: out.append(g)
	return out

func gossip_count(prefix: String) -> int:
	var n = 0
	for g in Data.GOSSIP:
		if solved.has(prefix + g["id"]): n += 1
	return n

func check_gossip_quest():
	if gossip_count("gh:") >= 6 and gossip_count("gc:") >= 3 and not completed.has("gossip"):
		complete("gossip")
		toast("Gossip quest complete! Everyone talks about everyone.")

func gossip_buttons(id: String):
	if not relay.is_empty():
		var rr: Dictionary = Data.RELAYS[relay["i"]]
		if rr["to"].has(id) and not relay["done"].has(id): button("Pass on " + str(rr["src"]).capitalize() + "'s news", relay_tell.bind(id), content)
		if rr["src"] == id and relay["done"].size() >= 2: button("Ask how the story came back", relay_end, content)
	elif relay_for(id) >= 0:
		button("Any news? (pass it on)" + ("  [ok]" if mastered.has("relay:" + id) else ""), relay_start.bind(relay_for(id)), content)
	for g in gossip_by(id):
		button("Any gossip?" + ("  [ok]" if solved.has("gh:" + g["id"]) else ""), gossip_card.bind(g, 0), content)
	for g in Data.GOSSIP:
		if g["about"] == id and solved.has("gh:" + g["id"]):
			button("Ask about what " + str(g["by"]).capitalize() + " said" + ("  [ok]" if solved.has("gc:" + g["id"]) else ""), gossip_reply.bind(g), content)
	if gossip_count("gh:") >= 1 and not names.has(id) and id != "ila" and id != "rin":
		button("Tell some gossip", rumor_composer.bind(id), content)
	if not rumors.is_empty():
		button("What's the news?", news.bind(id), content)

func gossip_card(g: Dictionary, step: int):
	var by = str(g["by"]).capitalize()
	for w in ["mel", "-nu", "-shi", "-da", "-ur"]: learn(w)
	if step == 0:
		var opts: Array = [g["en"]]
		var others = Data.GOSSIP.duplicate()
		others.shuffle()
		for o in others:
			if o["id"] != g["id"] and opts.size() < (3 if level() < 2 else 4): opts.append(o["en"])
		clear_panel("Gossip from " + by)
		varnak_banner(g["v"])
		text_line(g["gesture"], 18)
		ask("What is " + by + " saying?", opts, 0, Callable(), "", "Look at the names and the verb root. The endings tell you how " + by + " knows.", talk.bind(g["by"]),
			func(): button("Next: how does " + by + " know?", gossip_card.bind(g, 1), content))
	else:
		var ev: String = g["ev"]
		var answer = {"da": by + " saw it or knows it firsthand (-da)", "shi": by + " is guessing from clues (-shi)", "nu": "Someone told " + by + " (-nu)"}
		choice_puzzle("How does " + by + " know?", "“" + g["v"] + "”\n\nLook at the very last ending of the verb.", [answer[ev], answer["da" if ev != "da" else "shi"], answer["nu" if ev != "nu" else "shi"]], 0, func():
			if not solved.has("gh:" + g["id"]):
				solved.append("gh:" + g["id"])
				master("gh:" + g["id"])
				check_gossip_quest()
				save_game(),
			"-da means seen or known firsthand, -shi means guessed from evidence, -nu means heard from someone else. Gossip is great for evidentials!",
			"Find the last ending: -da (I saw it), -shi (apparently), -nu (people say).", talk.bind(g["by"]),
			func(): text_line("Now go and ask " + str(g["about"]).capitalize() + " about it..."))

func gossip_reply(g: Dictionary):
	var r: Dictionary = g["reply"]
	learn("maki")
	clear_panel(str(g["about"]).capitalize() + " hears the gossip")
	add_portrait(g["about"])
	var gk = {"oren_horse": "angry", "tor_bridge": "proud", "mira_food": "embarrassed", "ketu_fish": "happy", "yalo_night": "shocked", "desh_sea": "laugh",
		"pomo_sleep": "sleepy", "oku_stones": "dizzy", "gav_food": "embarrassed", "sanu_bag": "confused", "ola_fruit": "embarrassed", "vira_medicine": "happy", "lira_story": "laugh"}.get(g["id"], g.get("emote", "shocked"))
	emote(g["about"], gk, 3.5)
	text_line("You repeat what " + str(g["by"]).capitalize() + " said: “" + g["v"] + "”")
	text_line(reaction_text(g["about"], gk), 17)
	varnak_banner(r["v"])
	text_line(r["gesture"], 18)
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = r["en"], content)
	if not solved.has("gc:" + g["id"]):
		solved.append("gc:" + g["id"])
		master("gc:" + g["id"])
		check_gossip_quest()
		save_game()
	button("Back", talk.bind(g["about"]), content)

# ---- rumors: open-ended sentences that spread around the village ----

func rumor_parts(rc: Dictionary) -> Dictionary:
	var who: String = rc["who"]
	var tense: String = rc["tense"]
	var verb: Array = []
	if rc["neg"]: verb.append("ma")
	verb.append("na" if who == "An" else "i")
	verb.append(rc["verb"])
	if rc.get("dbl", false): verb.append(rc["verb"])
	verb.append({"now": "im", "past": "pa", "usual": "ur", "will": "fu"}[tense])
	if rc["neg"]: verb.append("ki")
	var words: Array = [who]
	if rc["place"] != "": words.append(rc["place"])
	if rc["adv"] != "": words.append(rc["adv"])
	var vtext = "-".join(verb)
	var v_core = " ".join(words) + " " + vtext
	return {"v": v_core + "-" + rc["ev"] + ".", "nu": v_core + "-nu."}

func rumor_en(rc: Dictionary) -> String:
	var who: String = rc["who"]
	var i_form = who == "An"
	var subj: String = Data.RUMOR_WHO_EN.get(who, who)
	var f: Array = Data.RUMOR_VERBS[rc["verb"]]
	var neg: bool = rc["neg"]
	var s = subj
	match rc["tense"]:
		"now": s += (" am" if i_form else " is") + (" not " if neg else " ") + f[1]
		"past": s += (" did not " + f[0]) if neg else (" " + f[2])
		"usual":
			if neg: s += (" do not usually " if i_form else " does not usually ") + f[0]
			else: s += " usually " + (f[0] if i_form else f[3])
		"will": s += (" will not " if neg else " will ") + f[0]
	if rc.get("dbl", false): s += " again and again"
	for pl in Data.RUMOR_PLACES:
		if pl[0] == rc["place"] and pl[0] != "": s += " " + pl[1]
	if rc["adv"] == "hala": s += " fast"
	elif rc["adv"] == "sela": s += " alone"
	s += {"da": " (I saw it!)", "shi": " (apparently)", "nu": " (people say)"}[rc["ev"]]
	return s

func rumor_composer(listener: String):
	var rc = {"who": "Tor", "place": "haima", "adv": "", "verb": "ning", "dbl": false, "tense": "usual", "neg": false, "ev": "nu"}
	for w in ["mel", "sela", "hala", "-nu", "-shi", "-da"]: learn(w)
	clear_panel("Tell " + listener.capitalize() + " some gossip")
	text_line("Make up any rumor you like. Choose the pieces; the Tujuju and its meaning update as you go.", 17)
	var banner = varnak_banner("", 26)
	var en_l = text_line("", 18)
	en_l.add_theme_color_override("font_color", Color("6b4a2e"))
	var refresh = func():
		(banner.get_child(0) as Label).text = rumor_parts(rc)["v"]
		en_l.text = rumor_en(rc)
	var rows = [
		["Who", "who", Data.RUMOR_WHO, Data.RUMOR_WHO],
		["Where", "place", Data.RUMOR_PLACES.map(func(p): return p[0]), Data.RUMOR_PLACES.map(func(p): return p[0] if p[0] != "" else "(nowhere)")],
		["How", "adv", ["", "hala", "sela"], ["(plain)", "hala (fast)", "sela (alone)"]],
		["Doing what", "verb", Data.RUMOR_VERBS.keys(), Data.RUMOR_VERBS.keys().map(func(k): return k + " (" + Data.RUMOR_VERBS[k][0] + ")")],
		["Again and again?", "dbl", [false, true], ["(once)", "doubled: ning-ning"]],
		["When", "tense", ["now", "past", "usual", "will"], ["-im now", "-pa past", "-ur usually", "-fu will"]],
		["Not?", "neg", [false, true], ["(yes)", "ma- ... -ki (not)"]],
		["How do you know?", "ev", ["da", "shi", "nu"], ["-da I saw it", "-shi apparently", "-nu people say"]]
	]
	for row in rows:
		text_line(row[0], 16)
		var flow = HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 6)
		flow.add_theme_constant_override("v_separation", 6)
		content.add_child(flow)
		var group = ButtonGroup.new()
		for k in range(row[2].size()):
			var val = row[2][k]
			var b = Button.new()
			b.toggle_mode = true
			b.button_group = group
			b.text = row[3][k]
			b.custom_minimum_size = Vector2(48, 44)
			b.add_theme_font_size_override("font_size", 17)
			flow.add_child(b)
			if rc[row[1]] == val: b.button_pressed = true
			b.toggled.connect(func(on):
				if on:
					rc[row[1]] = val
					refresh.call())
	refresh.call()
	button("Whisper it to " + listener.capitalize(), func(): rumor_react(listener, rc.duplicate()), content)
	button("Back", talk.bind(listener), content)

func rumor_react(listener: String, rc: Dictionary):
	var parts = rumor_parts(rc)
	var en = rumor_en(rc)
	var who: String = rc["who"]
	var silly = false
	for pl in Data.RUMOR_PLACES:
		if pl[0] == rc["place"] and pl[2] == "silly": silly = true
	clear_panel(listener.capitalize() + " listens")
	text_line("You whisper: “" + parts["v"] + "”")
	text_line(en, 17)
	var line = ""
	var gesture = ""
	if who.to_lower() == listener:
		var deny: Array = ["ma", "na", rc["verb"] + ("-" + rc["verb"] if rc.get("dbl", false) else ""), {"now": "im", "past": "pa", "usual": "ur", "will": "fu"}[rc["tense"]], "ki", "da"]
		var dj = "-".join(deny)
		line = "Maki! Maki! " + dj.substr(0, 1).to_upper() + dj.substr(1) + "!"
		if Data.PEOPLE.has(listener):
			line += " " + Data.INSULT[Data.PEOPLE[listener]["trait"]]
			learn("puts")
		gesture = listener.capitalize() + " turns bright red. It is about them! (They say: No! I do not!)"
	elif rc["ev"] == "da":
		line = "T-i-pal-pa-ha?!"
		gesture = listener.capitalize() + "'s eyes go wide: You saw it yourself?!"
	elif rc["ev"] == "shi":
		line = "Haku?"
		gesture = listener.capitalize() + " squints: Why do you think so?"
	else:
		line = "Hal-ta?"
		gesture = listener.capitalize() + " leans in: Who told you? (hal-ta: from whom?)"
	if who == "An": gesture += " Also, you are gossiping about yourself."
	if silly: gesture += " Then " + listener.capitalize() + " laughs so hard they have to sit down. “Ha! Ha!”"
	add_portrait(listener)
	var rk = "happy"
	if who.to_lower() == listener: rk = "angry"
	elif silly: rk = "laugh"
	elif rc["ev"] == "da": rk = "shocked"
	elif rc["ev"] == "shi": rk = "confused"
	emote(listener, rk, 3.5)
	if who.to_lower() != "an" and Data.PEOPLE.has(who.to_lower()) and who.to_lower() != listener:
		mood[who.to_lower()] = mood.get(who.to_lower(), 0) - 1
	varnak_banner(line)
	text_line(gesture, 18)
	text_line(reaction_text(listener, rk), 16)
	for w in ["haku", "maki", "pal", "-ha"]: learn(w)
	rumors.append({"who": who, "v": parts["nu"], "en": en.replace(" (I saw it!)", "").replace(" (apparently)", "").replace(" (people say)", "") + " (people say)", "teller": listener})
	if rumors.size() > 12: rumors.pop_front()
	rumor_count += 1
	master("r:" + parts["v"])
	save_game()
	text_line("Now the rumor will spread. Ask other people: What's the news?", 16)
	button("Start another rumor", rumor_composer.bind(listener), content)
	button("Back", talk.bind(listener), content)

func news(id: String):
	var pick = {}
	for i in range(rumors.size() - 1, -1, -1):
		var r: Dictionary = rumors[i]
		if r["teller"] != id:
			pick = r
			break
	clear_panel("What's the news?")
	if pick.is_empty():
		text_line(id.capitalize() + " shrugs. They have not heard anything new. Tell your gossip to someone else first.")
		button("Back", talk.bind(id), content)
		return
	learn("-nu")
	add_portrait(id)
	if str(pick["who"]).to_lower() == id:
		emote(id, "angry", 4.0)
		mood[id] = mood.get(id, 0) - 1
		varnak_banner("Halke ki tovu i-gao-pa-ha?!")
		text_line(id.capitalize() + " has heard a rumor about themselves: “" + pick["v"] + "” and is furious. Who told this story?! (halke: who, acting; gao: tell; -ha: a question)", 18)
	else:
		text_line(id.capitalize() + " leans in close and whispers:")
		varnak_banner(pick["v"])
		text_line(pick["en"], 17)
		text_line("Your rumor came back with -nu: now it is only something people say.", 16)
	if rumor_count >= 3 and not completed.has("rumor"): complete("rumor")
	button("Back", talk.bind(id), content)

# ---- typing on phones ----
# Phone browsers often send nothing to a web game's text box, so on touch screens the box
# opens the phone's own text prompt instead, and the answer is copied into the box.
var last_prompt_ms: int = 0

func touch_web() -> bool:
	return OS.has_feature("web") and DisplayServer.is_touchscreen_available()

func text_field(placeholder: String, initial: String = "") -> LineEdit:
	var le = LineEdit.new()
	le.placeholder_text = placeholder
	le.text = initial
	le.custom_minimum_size.y = 54
	content.add_child(le)
	if touch_web():
		le.editable = false
		le.virtual_keyboard_enabled = false
		le.placeholder_text = placeholder + " (tap to type)"
		le.add_theme_color_override("font_uneditable_color", Color("2e1c0c"))
		le.gui_input.connect(func(ev):
			var down = (ev is InputEventScreenTouch and ev.pressed) or (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT)
			if not down or Time.get_ticks_msec() - last_prompt_ms < 800: return
			last_prompt_ms = Time.get_ticks_msec()
			var r = JavaScriptBridge.eval("window.prompt(" + JSON.stringify(placeholder) + ", " + JSON.stringify(le.text) + ")", true)
			last_prompt_ms = Time.get_ticks_msec()
			if r != null: le.text = str(r))
	return le

# ---- a parrot that repeats anything ----

func parrot_panel():
	clear_panel("par: a parrot")
	text_line("A big red parrot on a crate tilts its head at you. Type something in Tujuju and it will say it back.")
	var input = text_field("Type Tujuju here")
	var out = text_line("", 20)
	if mastered.has("lt:solved") and not completed.has("letters"):
		button("Show the parrot one of its letters", parrot_reveal, content)
	button("Say it to the parrot", func():
		var t = input.text.strip_edges()
		if t == "":
			out.text = "The parrot waits."
			return
		var known: Array = []
		for w in t.to_lower().replace(".", "").replace("!", "").replace("?", "").split(" "):
			if words.has(w) and discovered.has(w): known.append(w + " = " + short_gloss(w))
		var gossip = Data.GOSSIP[randi() % Data.GOSSIP.size()]["v"]
		var lines = ["Kraa! " + t + " " + t + "!"]
		if not known.is_empty(): lines.append("(You recognize: " + ", ".join(known) + ")")
		if randf() < 0.5: lines.append("Kraa! " + gossip + " Kraa!  (The parrot has been listening to the village gossip.)")
		else: lines.append("Kraa! Par i-ho! Par i-ho!  (Parrot is good!)")
		out.text = "\n".join(lines)
		master("p:parrot"), content)
	button("Return", close_panel, content)

# ------------------------------------------------------------ sixth expansion: feelings, friendship and big reactions

func build_portrait():
	portrait_vp = SubViewport.new()
	portrait_vp.size = Vector2i(420, 210)
	portrait_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	portrait_vp.msaa_3d = Viewport.MSAA_2X
	add_child(portrait_vp)
	portrait_cam = Camera3D.new()
	portrait_cam.fov = 38
	portrait_cam.near = 0.05
	portrait_cam.far = 200.0
	portrait_vp.add_child(portrait_cam)
	portrait_cam.current = true

func add_portrait(id: String):
	var e = entity_by_id(id)
	if e.is_empty(): return
	portrait_id = id
	if is_instance_valid(panel_title) and panel_title.get_parent() != content:
		portrait_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		return
	var head = HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	var frame = PanelContainer.new()
	frame.add_theme_stylebox_override("panel", tile_box(Color("24495a"), Color("e9c46a")))
	portrait_frame = frame
	frame.visible = talk_view_id == ""
	var tr = TextureRect.new()
	tr.texture = portrait_vp.get_texture()
	tr.custom_minimum_size = Vector2(118, 104)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(tr)
	head.add_child(frame)
	var side = VBoxContainer.new()
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side.alignment = BoxContainer.ALIGNMENT_CENTER
	side.add_theme_constant_override("separation", 4)
	head.add_child(side)
	var at = panel_title.get_index() if is_instance_valid(panel_title) else 0
	content.add_child(head)
	content.move_child(head, at)
	if is_instance_valid(panel_title):
		content.remove_child(panel_title)
		side.add_child(panel_title)
		panel_title.add_theme_font_size_override("font_size", 21)
		panel_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if Data.PEOPLE.has(id):
		for c in hearts_row(id): side.add_child(c)
	portrait_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func hearts_row(id: String) -> Array:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	var f: int = friend.get(id, 0)
	for i in range(10):
		var c = Panel.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color("ff4f81") if i < f else Color("e6d8bf")
		sb.set_corner_radius_all(7)
		c.add_theme_stylebox_override("panel", sb)
		c.custom_minimum_size = Vector2(12, 12)
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(c)
	var md = Label.new()
	var mv: int = mood.get(id, 0)
	md.text = "Friendship " + str(f) + "/10.  Mood: " + ("seng (happy)" if mv >= 1 else ("grumpy" if mv <= -1 else "fine"))
	md.add_theme_font_size_override("font_size", 14)
	md.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return [row, md]

# Regroup runs of plain buttons in the panel into a compact two-column grid (phones).
func compact_buttons():
	var run: Array = []
	var groups: Array = []
	for c in content.get_children():
		if c.is_queued_for_deletion(): continue
		if c is Button and c != last_skip and c.visible:
			run.append(c)
		else:
			if run.size() > 0: groups.append(run)
			run = []
	if run.size() > 0: groups.append(run)
	for g in groups:
		for b in g:
			b.custom_minimum_size.y = 42
			b.add_theme_font_size_override("font_size", 16)
		var plain = g.filter(func(b): return not b.text.contains("“") and b.text.length() <= 44)
		if g.size() < 2 or plain.size() != g.size(): continue
		var grid = GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 6)
		grid.add_theme_constant_override("v_separation", 6)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var at = (g[0] as Node).get_index()
		content.add_child(grid)
		content.move_child(grid, at)
		for b in g:
			content.remove_child(b)
			grid.add_child(b)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func update_portrait():
	if portrait_id == "" or not panel.visible:
		if portrait_vp and portrait_vp.render_target_update_mode != SubViewport.UPDATE_DISABLED:
			portrait_vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return
	var e = entity_by_id(portrait_id)
	if e.is_empty(): return
	var node = e["node"] as Node3D
	var head = node.get_meta("head") as Node3D
	var target = head.global_position + Vector3(0, 0.3, 0)
	var d = player.global_position - node.global_position
	d.y = 0.0
	if d.length() < 0.1: d = Vector3(0, 0, 1)
	d = d.normalized()
	var want = target + d * 2.7 + Vector3(0, 0.2, 0)
	portrait_cam.global_position = portrait_cam.global_position.lerp(want, 0.25) if portrait_cam.global_position.distance_to(want) < 4.0 else want
	portrait_cam.look_at(target, Vector3.UP)

func ensure_fx(e: Dictionary):
	if e.has("fx"): return
	var node = e["node"] as Node3D
	e["fx"] = Art.emote_fx(node)
	var head = node.get_meta("head") as Node3D
	var skin = head.get_child(0) as MeshInstance3D
	var m = (skin.material_override as StandardMaterial3D).duplicate()
	skin.material_override = m
	e["face"] = m
	e["skin"] = m.albedo_color
	e["base_scale"] = node.scale.x

func emote(id: String, kind: String, dur: float = 2.8):
	if near_player(id, 18.0):
		var snd = {"sleepy": ["kororo", -12.0], "shocked": ["pop", -6.0], "love": ["piriri", -10.0], "faint": ["vava", -6.0], "angry": ["guarara", -16.0], "embarrassed": ["pop", -10.0]}
		if snd.has(kind): play_sfx(snd[kind][0], snd[kind][1])
	var e = entity_by_id(id)
	if e.is_empty() or e["kind"] != "npc": return
	ensure_fx(e)
	var node0 = e["node"] as Node3D
	var x0 = node0.position.x
	var y0 = node0.position.y
	if e.has("emote") and absf(float(e["emote"]["x0"]) - x0) < 0.3 and absf(float(e["emote"]["y0"]) - y0) < 0.8:
		# undo a shake or a hop, unless the person has really moved somewhere else
		x0 = e["emote"]["x0"]
		y0 = e["emote"]["y0"]
	clear_fx(e)
	node0.position.x = x0
	node0.position.y = y0
	e["emote"] = {"kind": kind, "t": 0.0, "dur": dur, "x0": x0, "y0": y0}
	var fx = e["fx"] as Node3D
	var labels: Dictionary = fx.get_meta("labels")
	match kind:
		"love", "happy": (fx.get_meta("hearts") as Node3D).visible = true
		"angry": (fx.get_meta("steam") as Node3D).visible = true
		"sad": (fx.get_meta("cloud") as Node3D).visible = true
		"dizzy", "faint": (fx.get_meta("stars") as Node3D).visible = true
		"embarrassed": (fx.get_meta("sweat") as Node3D).visible = true
		"shocked": (labels["!"] as Node3D).visible = true
		"confused": (labels["?"] as Node3D).visible = true
		"sleepy": (labels["zzz"] as Node3D).visible = true
		"laugh": (labels["Ha!"] as Node3D).visible = true
		"sneeze": (labels["!"] as Node3D).visible = true
	if kind == "happy": (fx.get_meta("hearts") as Node3D).visible = randf() < 0.5

func clear_fx(e: Dictionary):
	var fx = e["fx"] as Node3D
	for c in fx.get_children(): c.visible = false
	(e["face"] as StandardMaterial3D).albedo_color = e["skin"]
	var node = e["node"] as Node3D
	(node.get_meta("head") as Node3D).scale = Vector3.ONE
	(node.get_meta("head") as Node3D).rotation.x = 0.0
	node.rotation.x = 0.0
	node.rotation.z = 0.0
	node.scale = Vector3.ONE * float(e.get("base_scale", node.scale.x))

func apply_emote(e: Dictionary, delta: float):
	if not e.has("emote"): return
	var em: Dictionary = e["emote"]
	em["t"] += delta
	var t: float = em["t"]
	var node = e["node"] as Node3D
	var arms: Array = node.get_meta("arms")
	var head = node.get_meta("head") as Node3D
	var fx = e["fx"] as Node3D
	var face = e["face"] as StandardMaterial3D
	var skin: Color = e["skin"]
	var bs: float = e.get("base_scale", 1.0)
	var y0: float = em["y0"]
	if t >= em["dur"]:
		e.erase("emote")
		clear_fx(e)
		if absf(node.position.x - float(em["x0"])) < 0.3 and absf(node.position.y - y0) < 0.8:
			node.position.y = y0
			node.position.x = em["x0"]
		return
	var end_fade = clampf((em["dur"] - t) / 0.4, 0.0, 1.0)
	node.position.y = y0
	match em["kind"]:
		"happy":
			node.position.y = y0 + absf(sin(t * 9.0)) * 0.45
			if t < 0.9: node.rotation.y += delta * 14.0
			(arms[0] as Node3D).rotation.z = -2.4 + sin(t * 14.0) * 0.4
			(arms[1] as Node3D).rotation.z = 2.4 - sin(t * 14.0) * 0.4
			(fx.get_meta("hearts") as Node3D).position.y = fmod(t * 0.6, 0.6)
		"love":
			node.rotation.z = sin(t * 4.0) * 0.18
			face.albedo_color = skin.lerp(Color("ff8fb1"), 0.55 * end_fade)
			(fx.get_meta("hearts") as Node3D).position.y = fmod(t * 0.5, 0.7)
			(fx.get_meta("hearts") as Node3D).rotation.y = t * 2.0
			node.scale = Vector3.ONE * bs * (1.0 + absf(sin(t * 6.0)) * 0.06)
			(arms[0] as Node3D).rotation.x = -1.2
			(arms[1] as Node3D).rotation.x = -1.2
		"angry":
			node.position.x = float(em["x0"]) + sin(t * 70.0) * 0.05
			node.position.y = y0 + absf(sin(t * 15.0)) * 0.12
			face.albedo_color = skin.lerp(Color("e0302a"), 0.75 * end_fade)
			node.scale = Vector3.ONE * bs * (1.0 + minf(t, 1.0) * 0.15 * end_fade)
			var st = fx.get_meta("steam") as Node3D
			st.scale = Vector3.ONE * (1.0 + absf(sin(t * 10.0)) * 1.2)
			st.position.y = absf(sin(t * 10.0)) * 0.2
			(arms[0] as Node3D).rotation.z = -2.6 + sin(t * 25.0) * 0.3
			(arms[1] as Node3D).rotation.z = 2.6 + sin(t * 25.0) * 0.3
		"shocked":
			var j = clampf(t / 0.45, 0.0, 1.0)
			node.position.y = y0 + sin(j * PI) * 1.1
			node.scale = Vector3(bs * 0.85, bs * 1.28, bs * 0.85) if t < 1.6 else Vector3.ONE * bs
			face.albedo_color = skin.lerp(Color("f4f4ff"), 0.5 * end_fade)
			(arms[0] as Node3D).rotation.z = -1.5
			(arms[1] as Node3D).rotation.z = 1.5
		"sad":
			node.scale = Vector3(bs, bs * 0.9, bs)
			head.rotation.x = 0.45
			node.rotation.z = sin(t * 1.5) * 0.06
			var drops: Array = fx.get_meta("drops")
			for i in range(drops.size()):
				(drops[i] as Node3D).position.y = 0.55 - fmod(t * 1.6 + i * 0.27, 1.0) * 0.55
			face.albedo_color = skin.lerp(Color("9fb8d8"), 0.4 * end_fade)
		"embarrassed":
			face.albedo_color = skin.lerp(Color("ff4040"), 0.7 * end_fade)
			node.scale = Vector3.ONE * bs * 0.82
			node.rotation.y += sin(t * 3.0) * delta * 3.0 + delta * 2.5
			(arms[0] as Node3D).rotation.x = -2.2
			(arms[1] as Node3D).rotation.x = -2.2
		"laugh":
			var tt: String = Data.PEOPLE.get(e["id"], {}).get("trait", "cheerful")
			(fx.get_meta("labels")["Ha!"] as Node3D).position.y = 0.55 + absf(sin(t * 8.0)) * 0.2
			if tt == "giggly" and t > 0.9 and t < em["dur"] - 0.5:
				node.rotation.x = lerpf(node.rotation.x, -1.5, minf(delta * 8.0, 1.0))
				(arms[0] as Node3D).rotation.x = sin(t * 20.0) * 1.2
				(arms[1] as Node3D).rotation.x = -sin(t * 20.0) * 1.2
			else:
				node.rotation.x = -sin(t * 7.0) * 0.3
				node.position.y = y0 + absf(sin(t * 7.0)) * 0.15
		"faint":
			if t < 0.6:
				node.rotation.z = sin(t * 18.0) * 0.2
			elif t < em["dur"] - 0.5:
				node.rotation.x = lerpf(node.rotation.x, -1.55, minf(delta * 7.0, 1.0))
				(fx.get_meta("stars") as Node3D).rotation.y += delta * 6.0
			else:
				node.rotation.x = lerpf(node.rotation.x, 0.0, minf(delta * 12.0, 1.0))
			face.albedo_color = skin.lerp(Color("ff8fb1"), 0.4 * end_fade)
		"dizzy":
			(fx.get_meta("stars") as Node3D).rotation.y += delta * 6.0
			node.rotation.z = sin(t * 5.0) * 0.25
			node.rotation.x = cos(t * 4.0) * 0.12
		"confused":
			head.rotation.z = 0.45
			(arms[1] as Node3D).rotation.z = 2.4
			(arms[1] as Node3D).rotation.x = sin(t * 18.0) * 0.3
		"sleepy":
			head.rotation.x = 0.35 + sin(t * 2.0) * 0.15
			(fx.get_meta("labels")["zzz"] as Node3D).position.y = 0.55 + fmod(t * 0.4, 0.4)
			node.rotation.z = sin(t * 1.2) * 0.08
		"proud":
			head.scale = Vector3.ONE * (1.0 + minf(t * 1.5, 0.7) * end_fade)
			node.scale = Vector3(bs * 1.12, bs, bs * 1.12)
			(arms[0] as Node3D).rotation.z = 0.9
			(arms[1] as Node3D).rotation.z = -0.9
			node.position.y = y0 + minf(t, 0.3) * 0.3
		"disgust":
			face.albedo_color = skin.lerp(Color("7fc75a"), 0.75 * end_fade)
			node.rotation.x = -0.3
			(arms[0] as Node3D).rotation.x = -1.4
			(arms[1] as Node3D).rotation.x = -1.4
		"sneeze":
			if t < 0.7: node.rotation.x = -t * 0.5
			elif t < 0.9: node.rotation.x = 0.6
			else: node.rotation.x = lerpf(node.rotation.x, 0.0, minf(delta * 8.0, 1.0))

func reaction_text(id: String, kind: String) -> String:
	var n = names.get(id, id.capitalize())
	match kind:
		"faint": return n + " faints dramatically from joy!"
		"love": return "Hearts float around " + n + "."
		"proud": return n + "'s head swells with pride. Literally."
		"angry": return "Steam shoots out of " + n + "'s ears!"
		"sad": return "A tiny rain cloud appears over " + n + "."
		"laugh": return n + " laughs so hard they fall over."
		"shocked": return n + " jumps a meter into the air!"
		"embarrassed": return n + " turns bright red and tries to hide."
		"confused": return n + " scratches their head."
		"sleepy": return n + " has fallen asleep standing up."
		"disgust": return n + " turns green."
		"happy": return n + " does a happy little spin."
		"dizzy": return "Stars spin around " + n + "'s head."
	return ""

func add_friend(id: String, n: int):
	if not Data.PEOPLE.has(id): return
	var before: int = friend.get(id, 0)
	var after = clampi(before + n, 0, 10)
	friend[id] = after
	if before < 5 and after >= 5: toast(id.capitalize() + " likes you! Ask about a secret.")
	if before < 8 and after >= 8:
		toast("“Anni palar ta-an-da!” " + id.capitalize() + " calls you a friend!")
		learn("palar")
		var count = 0
		for k in friend.keys():
			if int(friend[k]) >= 8: count += 1
		if count >= 5 and not completed.has("friends"): complete("friends")

func once_today(id: String, what: String) -> bool:
	var key = id + ":" + what
	if int(chat_day.get(key, -1)) == day_count: return false
	chat_day[key] = day_count
	return true

func chat_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	var pp: Dictionary = Data.PEOPLE[id]
	clear_panel("Chat with " + id.capitalize())
	add_portrait(id)
	text_line(id.capitalize() + " is " + {"cheerful": "cheerful", "dramatic": "very dramatic", "sleepy": "always sleepy", "proud": "rather proud", "giggly": "giggly", "grumpy": "grumpy"}[pp["trait"]] + ". What do you say?", 17)
	button("Compliment", compliment.bind(id), content)
	button("Tease", tease.bind(id), content)
	button("Call them a putz", putz.bind(id), content)
	button("Play a prank", prank_menu.bind(id), content)
	button("Tell a joke", joke_menu.bind(id), content)
	button("Give a gift", gift_menu.bind(id), content)
	button("Ask for an errand", errand_menu.bind(id), content)
	button("Ask: Ti ta-seng-ha?", feel.bind(id), content)
	button("Ask or tell...", ask_menu.bind(id), content)
	if true:
		var yb = button("Yesen! (improv)" + ("" if level() >= YESEN_LEVEL else "  (level 2)"), yesen_open.bind(id), content)
		if level() < YESEN_LEVEL: yb.modulate.a = 0.6
	if int(friend.get(id, 0)) >= 5:
		button("Ask about a secret" + ("  [ok]" if mastered.has("sec:" + id) else ""), secret.bind(id), content)
	button("Back", talk.bind(id), content)

func react(id: String, said_v: String, said_en: String, reply_v: String, reply_en: String, kind: String, gain: int):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel(id.capitalize())
	add_friend(id, gain)
	if gain < 0: mood[id] = mood.get(id, 0) + gain
	elif gain > 0: mood[id] = mini(mood.get(id, 0) + 1, 3)
	add_portrait(id)
	emote(id, kind, 3.6)
	text_line("You say: “" + said_v + "”")
	var se = text_line("(" + said_en + ")", 15)
	se.add_theme_color_override("font_color", Color("6b4a2e"))
	varnak_banner(reply_v)
	text_line(reply_en, 16)
	var rt = text_line(reaction_text(id, kind) + ("  Friendship +" + str(gain) if gain > 0 else ("  Friendship " + str(gain) if gain < 0 else "")), 17)
	rt.add_theme_color_override("font_color", Color("7a1f3d"))
	master("chat:" + id + ":" + kind)
	save_game()
	button("Keep chatting", chat_menu.bind(id), content)
	button("Return", close_panel, content)

func compliment(id: String):
	compact_buttons.call_deferred()
	var pp: Dictionary = Data.PEOPLE[id]
	var thing: Array = pp["thing"]
	for w in ["ti-ni", "ho", "dau", "var", thing[0]]: learn(w)
	clear_panel("Compliment " + id.capitalize())
	add_portrait(id)
	text_line("Choose what to say. (Think about what each one means!)", 17)
	learn("kawai")
	var opts = [["Ti-ni " + thing[0] + " i-ho!", "Your " + thing[1] + " is good!", "thing"], ["Ti ta-ho-da!", "You are good!", "you"], ["Ti-ni dau i-var!", "Your head is big!", "head"], ["Ti ta-kawai-da!", "You are cute! (kawai is borrowed)", "cute"], ["Habibi!", "Darling! (habibi is borrowed from Arabic)", "habibi"]]
	opts.shuffle()
	for o in opts:
		button("“" + o[0] + "”", func(): do_compliment(id, o), content)
	button("Back", chat_menu.bind(id), content)

func do_compliment(id: String, o: Array):
	var tt: String = Data.PEOPLE[id]["trait"]
	var fresh = once_today(id, "compliment:" + o[2])
	if not fresh:
		react(id, o[0], o[1], "Ho, ho... ti ta-mel-pa-da.", "Yes, yes... you already said that.", "sleepy" if tt == "sleepy" else "confused", 0)
		return
	match o[2]:
		"thing":
			var k = {"dramatic": "faint", "proud": "proud", "grumpy": "embarrassed", "sleepy": "sleepy"}.get(tt, "love")
			var rv = {"dramatic": "Ho! Ho!! ...ho...", "proud": "I-zen-da! Polu i-zen-da!", "grumpy": "Hmph. ...K-ta-har-da.", "sleepy": "Ho... zzz"}.get(tt, "K-ta-har-da! Na-seng-da!")
			var re = {"dramatic": "Yes! YES!! ...yes...", "proud": "It's true! Everyone knows it!", "grumpy": "Hmph. ...Thank you.", "sleepy": "Nice... zzz"}.get(tt, "Thank you! I'm happy!")
			react(id, o[0], o[1], rv, re, k, 2)
		"you":
			react(id, o[0], o[1], "Ti ta-ho-da!", "You are good too!", "happy", 1)
		"habibi":
			learn("habibi")
			var ew = {"cheerful": "habibi", "dramatic": "bubala", "giggly": "shatsi", "proud": "monshu", "sleepy": "habibi", "grumpy": "shatsi"}[tt]
			learn(ew)
			match tt:
				"dramatic": react(id, o[0], o[1], "Bubala!! Bubala!!", "Darling!! Darling!! (bubala is borrowed from Yiddish. They swoon.)", "faint", 2)
				"proud": react(id, o[0], o[1], "Monshu! Ho, an na-kawai-da.", "My cabbage! Yes, I am cute. (monshu is French mon chou, my cabbage: a sweet name!)", "proud", 2)
				"giggly": react(id, o[0], o[1], "Shatsi! Ha! Ha!", "Sweetie! Ha ha! (shatsi is German Schatzi, little treasure)", "laugh", 2)
				"grumpy": react(id, o[0], o[1], "Hmph. ...shatsi.", "Hmph. ...sweetie. (Grumbles, but is secretly pleased.)", "embarrassed", 1)
				"sleepy": react(id, o[0], o[1], "Habibi... zzz", "Darling... zzz", "sleepy", 1)
				_: react(id, o[0], o[1], "Habibi! Habibi!", "Darling! Darling! (They hug you.)", "love", 2)
		"cute":
			match tt:
				"proud": react(id, o[0], o[1], "I-zen-da. An na-kawai-da.", "True. I am cute.", "proud", 2)
				"grumpy": react(id, o[0], o[1], "Hmph... ho.", "Hmph... thanks.", "embarrassed", 1)
				"dramatic": react(id, o[0], o[1], "Ho!! Ho!!", "(Overwhelmed by cuteness.)", "faint", 2)
				"sleepy": react(id, o[0], o[1], "Kawai... zzz", "Cute... zzz", "sleepy", 1)
				_: react(id, o[0], o[1], "Ha! Ti ta-kawai-da!", "Ha! YOU are cute!", "embarrassed", 2)
		"head":
			match tt:
				"proud": react(id, o[0], o[1], "Ho! Anni dau i-var-da!", "Yes! My head IS big!", "proud", 1)
				"giggly": react(id, o[0], o[1], "Ha! Ha! Ha!", "(Laughs uncontrollably.)", "laugh", 1)
				"dramatic": react(id, o[0], o[1], "Haku?! Haku?!", "Why?! Why would you say that?!", "shocked", -1)
				"grumpy": react(id, o[0], o[1], "Ti-ni dau i-var!", "YOUR head is big!", "angry", -1)
				"sleepy": react(id, o[0], o[1], "Han...? zzz", "What...? zzz", "sleepy", 0)
				_: react(id, o[0], o[1], "Han?", "What?", "confused", 0)

func tease(id: String):
	var pp: Dictionary = Data.PEOPLE[id]
	var thing: Array = pp["thing"]
	learn("wai")
	var sv = "Ti-ni " + thing[0] + " i-wai!"
	var se = "Your " + thing[1] + " is bad!"
	var tr = randf()
	if tr >= 0.3 and tr < 0.65:
		var ts: Array = Data.TEASES[randi() % Data.TEASES.size()]
		learn(ts[2])
		var ttr: String = Data.PEOPLE[id]["trait"]
		match ttr:
			"dramatic": react(id, ts[0], ts[1], "Maki... maki... MAKI!", "No... no... NO!", "sad", -1)
			"proud": react(id, ts[0], ts[1], "Maki! " + ts[0], "No! YOU are! (They say it right back.)", "angry", -1)
			"grumpy": react(id, ts[0], ts[1], "Hmph! " + ts[0], "Hmph! Same to you!", "angry", -1)
			"giggly": react(id, ts[0], ts[1], "Ha! Ha! I-zen-da!", "Ha ha! It's true!", "laugh", 1)
			"sleepy": react(id, ts[0], ts[1], "Han...? zzz", "What...? zzz", "sleepy", 0)
			_: react(id, ts[0], ts[1], "Ha! Ups... i-zen-da.", "Ha! Oops... it's true.", "embarrassed", 0)
		return
	if tr < 0.3:
		learn("choni")
		learn("kawai")
		sv = "Ti-ni choni i-kawai!"
		se = "Your chonies are cute! (choni and kawai are borrowed words)"
		match Data.PEOPLE[id]["trait"]:
			"dramatic": react(id, sv, se, "Hal-ta?! Hal-ta?!", "From whom?! Who told you?!", "shocked", -1)
			"proud": react(id, sv, se, "I-zen-da...", "That's... true.", "embarrassed", 0)
			"grumpy": react(id, sv, se, "Hutspa! Ti-ni hutspa i-var!", "The nerve! Your nerve is big!", "angry", -1)
			"giggly": react(id, sv, se, "Ha! Ha! Ha!", "(Laughs until they cry.)", "laugh", 1)
			"sleepy": react(id, sv, se, "Choni...? zzz", "Chonies...? zzz", "sleepy", 0)
			_: react(id, sv, se, "Shenani! Ha!", "Mischief! Ha!", "embarrassed", 0)
		return
	if id == "vira":
		react(id, sv, se, "Ho! Yok i-wai-da! Polu i-zen-da!", "Yes! The medicine is bad! Everyone knows!", "laugh", 1)
		return
	match pp["trait"]:
		"dramatic": react(id, sv, se, "Maki... maki... MAKI!", "No... no... NO!", "sad", -2)
		"proud": react(id, sv, se, "Ma-i-wai-ki-da! I-ho-da!", "It is NOT bad! It is good!", "angry", -2)
		"grumpy": react(id, sv, se, "Hmph! Ti-ni dau i-var!", "Hmph! YOUR head is big!", "angry", -1)
		"giggly": react(id, sv, se, "Ha! Ha! I-wai-da!", "Ha ha! It IS bad!", "laugh", 0)
		"sleepy": react(id, sv, se, "Han...? zzz", "What...? zzz", "sleepy", 0)
		_: react(id, sv, se, "Haku?!", "Why?!", "shocked", -1)

func putz(id: String):
	var tt: String = Data.PEOPLE[id]["trait"]
	learn("puts")
	var sv = "Ti puts ta-an-da!"
	var se = "You are a putz! (puts is borrowed from Yiddish putz: a fool. Playful, not polite!)"
	match tt:
		"grumpy":
			learn("puts-puts")
			react(id, sv, se, "Ti puts-puts ta-an-da!", "YOU are a total putz! (Doubling the word makes it stronger.)", "angry", -1)
		"giggly":
			learn("baka")
			react(id, sv, se, "Baka! Ha! Ha! Ti baka ta-an-da!", "Silly! Ha ha! YOU are silly! (baka is borrowed from Japanese)", "laugh", 1)
		"proud":
			learn("shlemil")
			react(id, sv, se, "An puts ma-na-an-ki-da! Ti shlemil ta-an-da!", "I am NOT a putz! You are a clumsy fool! (shlemil is Yiddish schlemiel)", "angry", -1)
		"dramatic":
			learn("puts-puts")
			react(id, sv, se, "Puts-puts?! An?! ...Ho!", "A total putz?! Me?! ...(Faints onto the ground.)", "faint", -1)
		"sleepy": react(id, sv, se, "...puts. zzz", "...putz yourself. zzz", "sleepy", 0)
		_:
			learn("baka")
			if int(friend.get(id, 0)) >= 5:
				learn("habibi")
				react(id, sv, se, "Ha! Baka! ...Habibi.", "Ha! Silly! ...Darling. (Friends can tease like this.)", "laugh", 1)
			else:
				react(id, sv, se, "Han? ...Baka!", "What? ...You silly!", "confused", 0)

func joke_menu(id: String):
	compact_buttons.call_deferred()
	clear_panel("Tell " + id.capitalize() + " a joke")
	add_portrait(id)
	text_line("Pick a silly sentence to say.", 17)
	var jokes = Data.JOKES.duplicate()
	jokes.shuffle()
	for j in jokes.slice(0, 3):
		button("“" + j["v"] + "”", func(): do_joke(id, j), content)
	button("Back", chat_menu.bind(id), content)

func do_joke(id: String, j: Dictionary):
	var tt: String = Data.PEOPLE[id]["trait"]
	var fresh = once_today(id, "joke:" + j["v"])
	var g = 1 if fresh else 0
	match tt:
		"giggly": react(id, j["v"], j["en"], "Ha! Ha! Ha! Ha!", "(Rolls on the ground laughing.)", "laugh", g + (1 if fresh else 0))
		"grumpy":
			if randf() < 0.3: react(id, j["v"], j["en"], "Ha... HA! HA! HA!", "(Tries not to laugh, then explodes.)", "laugh", g + 1)
			else: react(id, j["v"], j["en"], "Ha. Ha.", "(Not amused.)", "confused", 0)
		"sleepy": react(id, j["v"], j["en"], "Ha... ha... zzz", "(Falls asleep in the middle of laughing.)", "sleepy", g)
		"dramatic": react(id, j["v"], j["en"], "HA! HA! ...Ho!", "(Laughs so hard they faint.)", "faint", g)
		"proud": react(id, j["v"], j["en"], "Han? ...Ha.", "What? ...Oh. Ha.", "confused", g)
		_: react(id, j["v"], j["en"], "Ha! Ha! I-ho-da!", "Ha ha! That's good!", "laugh", g)

func gift_menu(id: String):
	compact_buttons.call_deferred()
	clear_panel("Give " + id.capitalize() + " a gift")
	add_portrait(id)
	text_line("You have: " + str(fish_caught) + " tari, " + str(inventory.count("bread")) + " panak, " + str(inventory.count("tea")) + " cha, " + str(inventory.count("candy")) + " bombom, " + str(inventory.count("hotdog")) + " ret-gor, " + str(gin) + " gin. (Ketu sells panak, cha, bombom and ret-gor.)", 17)
	var have = {"tari": fish_caught > 0, "panak": inventory.has("bread"), "cha": inventory.has("tea"), "gin": gin > 0, "bombom": inventory.has("candy"), "ret-gor": inventory.has("hotdog")}
	text_line("You will say “Ki tari ti-ru!” (This fish, for you!) with the gift you choose.", 16)
	for g in ["tari", "panak", "cha", "bombom", "ret-gor", "gin"]:
		var b = button(g + " (" + Data.GIFT_WORDS[g].trim_prefix("a ") + ")", give_gift.bind(id, g), content)
		b.disabled = not have[g]
	if berries > 0: button("ning-guro (song-berry)", villager_poem.bind(id, "ning-guro"), content)
	if shrooms > 0: button("sao-dau (mushroom)", villager_poem.bind(id, "sao-dau"), content)
	button("Back", chat_menu.bind(id), content)

func give_gift(id: String, g: String):
	match g:
		"tari": fish_caught -= 1
		"panak": inventory.erase("bread")
		"cha": inventory.erase("tea")
		"bombom": inventory.erase("candy")
		"ret-gor": inventory.erase("hotdog")
		"gin": gin -= 1
	learn("ti-ru")
	var pp: Dictionary = Data.PEOPLE[id]
	var sv = "Ki " + g + " ti-ru!"
	var se = "This " + Data.GIFT_WORDS[g] + ", for you!"
	if pp["likes"].has(g):
		var k = "faint" if pp["trait"] == "dramatic" else "love"
		react(id, sv, se, "K-ta-har-da! " + g.capitalize() + " i-ho! I-ho!!", "Thank you! " + Data.GIFT_WORDS[g].capitalize() + " is good! So good!!", k, 3)
	elif pp["hates"].has(g):
		react(id, sv, se, "Maki! " + g.capitalize() + " i-wai!", "No! " + Data.GIFT_WORDS[g].capitalize() + " is bad!", "disgust", -1)
	else:
		react(id, sv, se, "K-ta-har-da.", "Thank you.", "happy", 1)

var errand: Dictionary = {}

func errands_done() -> int:
	var n = 0
	for m in mastered:
		if str(m).begins_with("errand:"): n += 1
	return n

func errand_have(g: String) -> int:
	match g:
		"tari": return fish_caught
		"panak": return inventory.count("bread")
		"cha": return inventory.count("tea")
		"bombom": return inventory.count("candy")
		"ret-gor": return inventory.count("hotdog")
	return 0

func errand_take(g: String, n: int):
	for i in range(n):
		match g:
			"tari": fish_caught -= 1
			"panak": inventory.erase("bread")
			"cha": inventory.erase("tea")
			"bombom": inventory.erase("candy")
			"ret-gor": inventory.erase("hotdog")

func errand_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel(id.capitalize() + "'s errand")
	add_portrait(id)
	var nums = ["", "yan", "vel", "mur"]
	if errand.is_empty() or errand.get("npc", "") != id:
		var pp: Dictionary = Data.PEOPLE[id]
		var pool: Array = []
		for g in ["tari", "panak", "cha", "bombom", "ret-gor"]:
			if not pp["hates"].has(g): pool.append(g)
		var lv = level()
		var maxn = 1 if lv < 2 else (2 if lv < 3 else 3)
		errand = {"npc": id, "item": pool[randi() % pool.size()], "n": 1 + randi() % maxn}
	var g: String = errand["item"]
	var n: int = errand["n"]
	for w in ["yan", "vel", "mur", "tnaveno", g]: learn(w)
	text_line(id.capitalize() + " has a request. Listen carefully:", 17)
	varnak_banner(nums[n].capitalize() + " " + g + " t-na-ven-o-ye.")
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = "(Please give me " + str(n) + " " + Data.GIFT_WORDS[g].trim_prefix("a ") + ".)", content)
	text_line("You have " + str(errand_have(g)) + " " + g + ". Ketu sells panak, cha, bombom and ret-gor for one gin each. Fish come from the river.", 16)
	var b = button("Deliver: " + nums[n] + " " + g, errand_deliver.bind(id), content)
	b.disabled = errand_have(g) < n
	button("Not now", chat_menu.bind(id), content)

func errand_deliver(id: String):
	var g: String = errand["item"]
	var n: int = errand["n"]
	if errand_have(g) < n: return
	errand_take(g, n)
	log_event("errand", {"npc": id, "item": g, "n": n})
	errand = {}
	var nums = ["", "yan", "vel", "mur"]
	var reward = n
	gin += reward
	master("errand:" + str(errands_done() + 1))
	react(id, nums[n] + " " + g + " ki-ru!", str(n) + " " + Data.GIFT_WORDS[g].trim_prefix("a ") + ", here!", "K-ta-har-da! " + nums[n].capitalize() + " " + g + "! I-ho!", "Thank you! Exactly what I asked for! (+" + str(reward) + " gin, errands done: " + str(errands_done()) + ")", "happy", 2)

func review_rusty():
	var pool: Array = []
	for w in discovered:
		if words.has(w) and not mastered.has("w:" + w): pool.append(w)
	if pool.is_empty():
		message("Nothing rusty", "Every word you have found is mastered. Explore for new ones, or try Practice for phrases.")
		return
	practice_word(pool)

func feel(id: String):
	learn("-ha")
	learn("seng")
	var mv: int = mood.get(id, 0)
	var tt: String = Data.PEOPLE[id]["trait"]
	var about_me = false
	for r in rumors:
		if str(r["who"]).to_lower() == id: about_me = true
	if mv >= 1:
		react(id, "Ti ta-seng-ha?", "Are you happy?", "Ho! Na-seng-da!", "Yes! I'm happy!", "happy", 0)
	elif mv <= -1:
		if about_me: react(id, "Ti ta-seng-ha?", "Are you happy?", "Ma-na-seng-ki-da! Tovu i-wai!", "I'm NOT happy! That story is bad! (Someone spread a rumor about them.)", "angry", 0)
		else: react(id, "Ti ta-seng-ha?", "Are you happy?", "Ma-na-seng-ki-da... Ti!", "I'm not happy... YOU! (You teased them. Try a gift or a compliment.)", "sad", 0)
	else:
		if tt == "sleepy": react(id, "Ti ta-seng-ha?", "Are you happy?", "Na-lei-da... zzz", "I'm tired... zzz", "sleepy", 0)
		else: react(id, "Ti ta-seng-ha?", "Are you happy?", "Na-seng... shi.", "I'm happy... apparently.", "confused", 0)

func secret(id: String):
	compact_buttons.call_deferred()
	var sc: Dictionary = Data.PEOPLE[id]["secret"]
	talk_partner = id
	clear_panel(id.capitalize() + "'s secret")
	add_portrait(id)
	emote(id, "embarrassed", 4.0)
	text_line(id.capitalize() + " checks that nobody is listening, then whispers:", 17)
	varnak_banner(sc["v"])
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = sc["en"], content)
	if not mastered.has("sec:" + id):
		master("sec:" + id)
		gin += 2
		toast("A secret! " + id.capitalize() + " also gives you vel gin.")
		save_game()
	button("Keep chatting", chat_menu.bind(id), content)

# Every so often someone nearby does something silly.
func update_ambient(delta: float):
	mood_clock += delta
	if mood_clock > 45.0:
		mood_clock = 0.0
		for k in mood.keys():
			var v: int = mood[k]
			if v > 0: mood[k] = v - 1
			elif v < 0: mood[k] = v + 1
	ambient_cd -= delta
	if ambient_cd > 0.0 or panel.visible or riding: return
	ambient_cd = randf_range(14.0, 28.0)
	var near: Array = []
	for e in entities:
		if e["kind"] == "npc" and Data.PEOPLE.has(e["id"]) and not e.has("emote"):
			var n = e["node"] as Node3D
			if n.visible and n.position.distance_to(player.position) < 22.0: near.append(e)
	if near.is_empty(): return
	var e = near[randi() % near.size()]
	var tt: String = Data.PEOPLE[e["id"]]["trait"]
	var pick = ["sneeze", "Ha-chu!"]
	var r = randf()
	if e["id"] == "desh" and r < 0.25: pick = ["laugh", "Tarara! Tarara!"]
	elif e["id"] == "desh" and r < 0.5: pick = ["happy", "Kachaka! Kachaka! (dances)"]
	elif e["id"] == "mira" and r < 0.5: pick = ["happy", "Chiriri... chiriri..."]
	elif tt == "sleepy" and r < 0.6: pick = ["sleepy", "Kororo... kororo... zzz"]
	elif tt == "giggly" and r < 0.6: pick = ["laugh", "Ha! Ha!"]
	elif tt == "dramatic" and r < 0.5: pick = ["shocked", "Haku?!"]
	elif tt == "grumpy" and r < 0.5: pick = ["angry", "Hmph!"]
	elif tt == "proud" and r < 0.5: pick = ["proud", "Ho!"]
	elif r < 0.5: pick = ["happy", "Ho! Ho!"]
	if randf() < 0.07:
		var lines = make_poem("ning-guro" if randf() < 0.5 else "sao-dau", e["id"])
		emote(e["id"], "love", 4.0)
		e["say"] = [lines[0][0], clock + 6.0]
		record_poem(lines, e["id"])
		toast(str(e["id"]).capitalize() + " suddenly recites a poem! (It is in your Poem book.)")
		return
	if tt in ["giggly", "cheerful", "dramatic"] and randf() < 0.14:
		pick = ["laugh", "Ti-ni dau-ma sipu i-esh-da! ...Hiri!"]
		learn("sipu")
		learn("hiri")
		toast(str(e["id"]).capitalize() + ": There's a spider on your head! ...Hiri! (Gotcha!)")
	emote(e["id"], pick[0], 2.6)
	e["say"] = [pick[1], clock + 2.6]
	for sw in ["tarara", "chiriri", "kororo", "kachaka"]:
		if pick[1].to_lower().begins_with(sw):
			learn(sw)
			play_sfx(sw, -8.0)
	if pick[0] == "sneeze":
		for o in near:
			if o != e:
				o["say"] = ["Gesunhait!", clock + 2.8]
				learn("gesunhait")
				break

# ------------------------------------------------------------ seventh expansion: using new words, poem plants

func ext_kind(w: String) -> String:
	if Data.EXT_VERBS_I.has(w): return "vi"
	if Data.EXT_VERBS_T.has(w): return "vt"
	if Data.EXT_STATIVES.has(w): return "st"
	if Data.NOUNS.has(w) or Data.EXT_NOUNS_EXTRA.has(w): return "n"
	if Data.NUMBERS.has(w) and w != "nul": return "num"
	return ""

func noun_en(w: String) -> Array:
	if Data.NOUNS.has(w): return Data.NOUNS[w]
	return Data.EXT_NOUNS_EXTRA[w]

func cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1) if s != "" else s

func extension_box(back: Callable):
	if pending_ext.is_empty(): return
	var ws: Array = pending_ext.slice(maxi(0, pending_ext.size() - 2))
	pending_ext.clear()
	var pc = PanelContainer.new()
	pc.add_theme_stylebox_override("panel", tile_box(Color("e3f0d4"), Color("5b8c5a")))
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	pc.add_child(vb)
	var head = Label.new()
	head.text = "New word" + ("s" if ws.size() > 1 else "") + "! Quick practice (optional):"
	head.add_theme_font_size_override("font_size", 17)
	head.add_theme_color_override("font_color", Color("2f5a2f"))
	vb.add_child(head)
	for w in ws:
		var l = Label.new()
		l.text = w + "  (" + short_gloss(w) + ")"
		l.add_theme_font_size_override("font_size", 21)
		l.add_theme_color_override("font_color", Color("7a1f3d"))
		vb.add_child(l)
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vb.add_child(row)
		var b1 = button("Use it in a new form", ext_form.bind(w, back), row)
		var b2 = button("Build a sentence", ext_build.bind(w, back), row)
		for b in [b1, b2]:
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.add_theme_font_size_override("font_size", 16)
	content.add_child(pc)

func ext_items(w: String) -> Dictionary:
	var k = ext_kind(w)
	var forms: Array = []
	var builds: Array = []
	match k:
		"n":
			var en = noun_en(w)
			var sg: String = en[0]
			var pl: String = en[1]
			forms = [["to the " + sg, w + "ru", [w + "ma", w + "ta"], "-ru means to."],
				["in the " + sg, w + "ma", [w + "ru", w + "li"], "-ma means in or at."],
				["from the " + sg, w + "ta", [w + "ma", w + "su"], "-ta means from."],
				["my " + sg, "anni " + w, [w + " anni", "anke " + w], "The owner comes first and takes -ni: an-ni."],
				["three " + pl, "mur " + w, [w + " mur", "mur " + w + "ke"], "Numbers come before the noun."],
				["together with the " + sg, w + "su", [w + "ni", w + "ta"], "-su means together with."]]
			builds = [{"en": "The " + sg + " is big.", "tiles": [cap(w), "i-var."], "decoys": [cap(w) + "ke", "i-sen."], "tip": "Describing verbs like var take i- and the subject takes no -ke."},
				{"en": "The " + sg + " is in the village.", "tiles": [cap(w), "tekama", "i-esh-da."], "decoys": ["tekaru"], "tip": "In the village is teka-ma; esh means be located."},
				{"en": "I see the " + sg + ".", "tiles": ["Anke", w, "k-i-pal-da."], "decoys": ["An", w + "ke"], "tip": "I act on it: anke, and the verb takes k-i-."},
				{"en": "Please give me the " + sg + ".", "tiles": [cap(w), "t-na-ven-o-ye."], "decoys": [w + "ru", "k-i-ven-o-ye."], "tip": "You give to me: t-na-ven, and please is -o-ye."}]
		"vi":
			var f: Array = Data.EXT_VERBS_I[w]
			forms = [["I will " + f[0], "na-" + w + "-fu", ["ta-" + w + "-fu", "na-" + w + "-pa"], "na- is I, -fu is the future."],
				["Don't " + f[0] + "!", "ma-ta-" + w + "-o-ki!", ["ta-" + w + "-o!", "ma-ta-" + w + "-ki-o!"], "Don't: ma- in front, -o for the command, -ki after it."],
				["They are " + f[2], "ri-" + w + "-im", ["i-" + w + "-im", "ri-" + w + "-pa"], "ri- is they, -im is in progress."],
				["She " + f[1] + " (I saw it)", "i-" + w + "-pa-da", ["i-" + w + "-pa-nu", "na-" + w + "-pa-da"], "-pa is past, -da means I saw it."]]
			builds = [{"en": "Tor " + f[1] + " at the market (people say).", "tiles": ["Tor", "kurma", "i-" + w + "-pa-nu."], "decoys": ["Torke", "kurru", "i-" + w + "-pa-da."], "tip": "No -ke: this verb acts on nothing. People say is -nu."},
				{"en": "The dog is " + f[2] + " in the sea.", "tiles": ["Gor", "haima", "i-" + w + "-im-da."], "decoys": ["Gorke", "haita"], "tip": "In the sea is hai-ma, and in progress is -im."}]
		"vt":
			var f: Array = Data.EXT_VERBS_T[w]
			forms = [["I " + f[1] + " it", "k-i-" + w + "-pa", ["na-" + w + "-pa", "t-i-" + w + "-pa"], "k- is I acting, i- is it receiving."],
				[cap(f[0]) + " it!", "t-i-" + w + "-o!", ["k-i-" + w + "-o!", "ta-" + w + "-o!"], "t- you act, i- on it, -o makes a command."],
				["You " + f[1] + " me", "t-na-" + w + "-pa", ["k-ta-" + w + "-pa", "na-" + w + "-pa"], "t- you act, na- on me."]]
			builds = [{"en": "Mira " + f[1] + " the book.", "tiles": ["Mirake", "puka", "i-" + w + "-pa-da."], "decoys": ["Mira", "pukake"], "tip": "The one acting takes -ke; the book takes nothing."}]
		"st":
			var adj: String = Data.EXT_STATIVES[w]
			forms = [["The house is not " + adj, "Dom ma-i-" + w + "-ki.", ["Dom i-" + w + "-ki.", "Ma-dom i-" + w + "."], "Not: ma- ... -ki wraps the verb."],
				["The house is very, very " + adj, "Dom i-" + w + "-" + w + ".", ["Dom i-" + w + ".", "Dom-dom i-" + w + "."], "Doubling a describing root makes it stronger: var-var, huge."],
				["a " + adj + " house", w + " dom", ["dom " + w, "dom-" + w + "-ma"], "Describing words come right before the noun."],
				["The boat is more " + adj + " than the house", "Sena dom-ta i-u-" + w + ".", ["Sena dom-ma i-u-" + w + ".", "Sena dom-ta i-" + w + "-u."], "Compare with -ta (from) and u- before the root."]]
			builds = [{"en": "My food is " + adj + ".", "tiles": ["Anni", "yamat", "i-" + w + "."], "decoys": ["An", "i-" + w + "-ki."], "tip": "My is anni; is " + adj + " is i-" + w + "."},
				{"en": "The fish are " + adj + ".", "tiles": ["Tari-ir", "ri-" + w + "."], "decoys": ["i-" + w + "."], "tip": "Many fish are they, so the verb takes ri-."}]
		"num":
			var idx = Data.NUMBERS.find(w)
			var ords = ["", "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"]
			forms = [["the " + ords[idx], w + "ve", [w, "ve" + w], "Add -ve to make order words: yan-ve, first."],
				[str(idx) + " fish", w + " tari", ["tari " + w, w + "-tari"], "Numbers come before the noun."]]
			builds = [{"en": "Please give me " + str(idx) + " fish.", "tiles": [cap(w), "tari", "t-na-ven-o-ye."], "decoys": ["Tarike", "tari-ir"], "tip": "The number comes first, then the noun, then the request."}]
	return {"forms": forms, "builds": builds}

func ext_form(w: String, back: Callable):
	var it = ext_items(w)
	var fs: Array = it["forms"]
	if fs.is_empty(): return
	var f: Array = fs[randi() % fs.size()]
	var opts: Array = [f[1]]
	opts.append_array(f[2])
	choice_puzzle("Use it: " + w, "You know " + w + " (" + short_gloss(w) + "). How do you say:\n\n\"" + f[0] + "\"", opts, 0, func():
		master("x:" + w), f[1] + ": " + f[3], f[3], back,
		func():
			button("Another form", ext_form.bind(w, back), content)
			button("Build a sentence with " + w, ext_build.bind(w, back), content))

func ext_build(w: String, back: Callable):
	var it = ext_items(w)
	var bs: Array = it["builds"]
	if bs.is_empty(): return
	var b: Dictionary = bs[randi() % bs.size()]
	dnd({"title": "Build it: " + w, "prompt": "Use your new word " + w + " in a new sentence:\n\"" + b["en"] + "\"", "answers": b["tiles"], "pool": b["decoys"],
		"tip": b["tip"], "key": "xb:" + w, "again": ext_build.bind(w, back), "again_label": "Another sentence with " + w, "back": back,
		"on_right": func(): master("x:" + w)})

# ---- poem plants ----

func pick_plant(e: Dictionary):
	var w: String = e["word"]
	learn(w)
	if clock < float(e.get("ripe_at", 0.0)):
		message(w, "Nothing to pick yet. " + ("The berries" if w == "ning-guro" else "The mushrooms") + " grow back in a couple of minutes.")
		return
	e["ripe_at"] = clock + 120.0
	if w == "ning-guro": berries += 1
	else: shrooms += 1
	save_game()
	clear_panel(w)
	text_line("You pick a glowing " + w + " (" + ("a song-berry" if w == "ning-guro" else "a star-head mushroom") + "). It hums faintly.\n\nPeople say that whoever eats one starts speaking in poems.")
	button("Eat it now", eat_poem.bind(w), content)
	button("Keep it (you can give it to someone)", close_panel, content)

func s3(base: String) -> String:
	if base == "go": return "goes"
	return base + "s"

func comparative(adj: String) -> String:
	var c = {"big": "bigger", "small": "smaller", "warm": "warmer", "hot": "hotter", "cold": "colder", "tall": "taller", "good": "better", "bad": "worse",
		"happy": "happier", "safe": "safer", "bright": "brighter", "dark": "darker", "short": "shorter", "old": "older", "new": "newer", "full": "fuller", "fast": "faster", "cute": "cuter"}
	return c.get(adj, "more " + adj)

func poem_line(t: int, rng: RandomNumberGenerator, force_noun: String = "") -> Array:
	var nouns = Data.POEM_NOUNS.keys()
	var n: String = force_noun if force_noun != "" and Data.POEM_NOUNS.has(force_noun) else nouns[rng.randi() % nouns.size()]
	var n2: String = nouns[rng.randi() % nouns.size()]
	while n2 == n: n2 = nouns[rng.randi() % nouns.size()]
	var places = Data.POEM_PLACES.keys()
	var pl: String = places[rng.randi() % places.size()]
	var sts = ["var", "sen", "nav", "ret", "len", "gao", "ho", "seng", "ling", "dam", "shora", "nava", "lei", "mar"]
	var s: String = sts[rng.randi() % sts.size()]
	var adj: String = Data.EXT_STATIVES[s]
	var vis = Data.EXT_VERBS_I.keys()
	var v: String = vis[rng.randi() % vis.size()]
	var v2: String = vis[rng.randi() % vis.size()]
	while v2 == v: v2 = vis[rng.randi() % vis.size()]
	var fv: Array = Data.EXT_VERBS_I[v]
	var fv2: Array = Data.EXT_VERBS_I[v2]
	var ns: Array = Data.POEM_NOUNS[n]
	var ns2: Array = Data.POEM_NOUNS[n2]
	match t:
		0:
			var ev = ["da", "shi", "nu"][rng.randi() % 3]
			var pre = {"da": "", "shi": "Apparently ", "nu": "They say "}[ev]
			var post = " (I saw it)" if ev == "da" else ""
			if rng.randf() < 0.4:
				return [cap(n) + " " + pl + "-ma i-" + s + "-" + s + "-" + ev + ".", cap(pre + ns[0] + " " + Data.POEM_PLACES[pl] + " is very, very " + adj + post + "."), "Doubling: i-" + s + "-" + s + " is extra " + adj + ". -" + ev + " tells how the poet knows."]
			return [cap(n) + " " + pl + "-ma i-" + s + "-" + ev + ".", cap(pre + ns[0] + " " + Data.POEM_PLACES[pl] + " is " + adj + post + "."), "-" + ev + " tells how the poet knows."]
		1:
			return [cap(n) + "-ir " + n2 + "-su ri-" + v + "-ur-da.", cap(ns[1] + " usually " + fv[0] + " with " + ns2[0] + "."), "-ir makes many, so the verb takes ri- (they); -su means together with."]
		2:
			return [cap(n) + " " + n2 + "-ta i-u-" + s + ".", cap(ns[0] + " is " + comparative(adj) + " than " + ns2[0] + "."), "Comparing: -ta (from) on the other thing, u- before the root."]
		3:
			return ["Ti ta-" + v + "-fu shi, " + n + " i-" + s + "-fu.", "If you " + fv[0] + ", " + ns[0] + " will be " + adj + ".", "shi after a clause means if; -fu is the future."]
		4:
			return ["I-" + v + "-im-en " + n + " " + pl + "-ma i-esh-da.", cap(ns[0] + " that is " + fv[2] + " is " + Data.POEM_PLACES[pl] + "."), "-en turns a verb into a describer: i-" + v + "-im-en " + n + ", the " + n + " that is " + fv[2] + "."]
		5:
			var tos = ["hen", "hai", "mora", "teka", "sang"]
			var to: String = tos[rng.randi() % tos.size()]
			var to_en = {"hen": "the sky", "hai": "the sea", "mora": "the river", "teka": "the village", "sang": "the hill"}[to]
			return [cap(n) + " i-" + v + "-ak-ka, " + to + "-ru i-lum-pa-da.", cap(ns[0] + " " + fv[1] + ", and then went to " + to_en + "."), "-ka links two actions by the same one: did this, and then that."]
		6:
			return [cap(n) + " ma-i-" + v + "-ki-da, dan i-" + v2 + "-ur-da.", cap(ns[0] + " does not " + fv[0] + ", but it usually " + s3(fv2[0]) + "."), "ma- ... -ki says not; dan means but."]
		7:
			var inc: Array = Data.POEM_INC[rng.randi() % Data.POEM_INC.size()]
			return [cap(n) + " i-" + inc[0] + "-ur-da.", cap(ns[0] + " usually " + inc[1] + "."), "The noun hides inside the verb: " + inc[0] + " is one word."]
		8:
			return ["An " + pl + "-ma na-" + v + "-fu, " + n + "-su.", "I will " + fv[0] + " " + Data.POEM_PLACES[pl] + ", with " + ns[0] + ".", "na- is I; -su is together with."]
		9:
			return [cap(n) + ", ta-" + v + "-o-ye!", cap(ns[0].trim_prefix("the ").trim_prefix("a ")) + ", please " + fv[0] + "!", "Talking to " + ns[0] + ": ta- (you), -o (command), -ye (please)."]
		11:
			return [cap(n) + " i-" + v + "-" + v + "-ur-da.", cap(ns[0] + " " + s3(fv[0]) + " and " + s3(fv[0]) + " and " + s3(fv[0]) + "."), "Doubling the verb root (" + v + "-" + v + ") means again and again."]
		12:
			return ["Haku " + n + " " + pl + "-ma i-" + v + "-im-ha?", "Why is " + ns[0] + " " + fv[2] + " " + Data.POEM_PLACES[pl] + "?", "Haku means why; -ha turns the line into a question."]
		13:
			return ["Bravo, " + n + "! Ti ta-" + v + "-pa-da!", cap("bravo, " + ns[0].trim_prefix("the ").trim_prefix("a ") + "! You " + fv[1] + "!"), "Bravo is borrowed from Italian; ta- means you."]
		14:
			return ["Choni-ir " + pl + "-ma ri-" + v + "-im-shi!", cap("apparently the chonies are " + fv[2] + " " + Data.POEM_PLACES[pl] + "!"), "Every poet on this island mentions chonies eventually. -shi means apparently."]
		_:
			return [cap(n) + "-ir " + pl + "-ma ri-esh-shi!", cap("apparently " + ns[1] + " are " + Data.POEM_PLACES[pl] + "!"), "Plural subject: ri-. Apparently: -shi."]

func make_poem(kind: String, who: String = "") -> Array:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var pool = [0, 1, 3, 4, 5, 9, 11, 13] if kind == "ning-guro" else [2, 6, 7, 8, 10, 4, 12, 14]
	pool.shuffle()
	var lines: Array = []
	var thing = ""
	if who != "" and Data.PEOPLE.has(who): thing = Data.PEOPLE[who]["thing"][0]
	for i in range(4):
		lines.append(poem_line(pool[i], rng, thing if i == 0 else ""))
	if who != "" and Data.PEOPLE.has(who):
		var tail = {"dramatic": ["Ho! Ho!!", "(dramatic sigh)"], "giggly": ["Ha! Ha!", "(giggles)"], "grumpy": ["Hmph.", "(grumbles)"],
			"sleepy": ["zzz...", "(falls asleep)"], "proud": ["I-zen-da!", "It's true!"], "cheerful": ["Ho!", "Great!"]}[Data.PEOPLE[who]["trait"]]
		lines.append([tail[0], tail[1], ""])
	return lines

func show_poem_lines(lines: Array):
	var ens: Array = []
	for ln in lines:
		varnak_banner(ln[0], 22)
		var e = text_line(ln[1], 16)
		e.add_theme_color_override("font_color", Color("6b4a2e"))
		e.visible = level() < 3
		ens.append(e)
	button("Show or hide meanings", func():
		for e in ens: e.visible = not e.visible, content)
	var notes: Array = []
	for ln in lines:
		if ln[2] != "" and not notes.has(ln[2]): notes.append(ln[2])
	var nl = text_line("How the poem works:\n- " + "\n- ".join(notes), 15)
	nl.add_theme_color_override("font_color", Color("2f5a2f"))

func record_poem(lines: Array, by: String):
	var vs: Array = []
	var es: Array = []
	for ln in lines:
		vs.append(ln[0])
		es.append(ln[1])
	poems.append({"by": by, "v": vs, "en": es})
	if poems.size() > 30: poems.pop_front()
	master("poem:" + vs[0])
	if poems.size() >= 5 and not completed.has("poems"): complete("poems")
	save_game()

func eat_poem(kind: String):
	if kind == "ning-guro":
		if berries <= 0: return
		berries -= 1
	else:
		if shrooms <= 0: return
		shrooms -= 1
	for w in ["ning", "-en", "-ka"]: learn(w)
	var lines = make_poem(kind)
	clear_panel("You eat the " + kind + "...")
	text_line(("Your mouth tingles and the world turns purple. Words start rhyming on their own. You stand up and recite:" if kind == "ning-guro" else "The trees lean closer. The sky winks at you. Strange words tumble out:"), 17)
	show_poem_lines(lines)
	record_poem(lines, "you")
	button("Return", close_panel, content)

func villager_poem(id: String, kind: String):
	compact_buttons.call_deferred()
	if kind == "ning-guro": berries -= 1
	else: shrooms -= 1
	talk_partner = id
	var lines = make_poem(kind, id)
	clear_panel(id.capitalize() + " eats the " + kind)
	add_portrait(id)
	emote(id, "dizzy" if kind == "sao-dau" else "love", 6.0)
	var e = entity_by_id(id)
	e["say"] = [lines[0][0], clock + 10.0]
	add_friend(id, 1)
	text_line("You say: “Ki " + kind + " ti-ru!” (This " + ("song-berry" if kind == "ning-guro" else "mushroom") + ", for you!)", 17)
	text_line(id.capitalize() + "'s eyes go swirly. " + id.capitalize() + " climbs onto an imaginary stage and recites:", 17)
	show_poem_lines(lines)
	record_poem(lines, id)
	button("Keep chatting", chat_menu.bind(id), content)
	button("Return", close_panel, content)

func show_poems():
	clear_panel("Poem book")
	if poems.is_empty():
		text_line("No poems yet. Look for glowing purple ning-guro bushes and blue sao-dau mushrooms. Eat them, or give them to someone.")
	for i in range(poems.size() - 1, -1, -1):
		var pm: Dictionary = poems[i]
		button(("Your poem" if pm["by"] == "you" else str(pm["by"]).capitalize() + "'s poem") + ": " + str(pm["v"][0]), func():
			clear_panel(("Your poem" if pm["by"] == "you" else str(pm["by"]).capitalize() + "'s poem"))
			var lines: Array = []
			for k in range(pm["v"].size()): lines.append([pm["v"][k], pm["en"][k], ""])
			show_poem_lines(lines)
			button("Poem book", show_poems, content), content)
	button("Notebook", show_notebook, content)

func false_friends(start: bool = true):
	if start:
		ff_order = Data.FALSE_FRIENDS.duplicate()
		ff_order.shuffle()
		ff_order = ff_order.slice(0, 8)
		ff_i = 0
	if ff_i >= ff_order.size():
		clear_panel("False friends: done!")
		text_line("You weren't fooled! False friends are words that look like words you know but mean something else. In Tujuju, gin is money, hen is the sky, and ten is a foot.", 18)
		gin += 2
		toast("+2 gin")
		save_game()
		button("Play again", false_friends.bind(true), content)
		button("Games", show_games, content)
		return
	var f: Array = ff_order[ff_i]
	learn(f[0])
	var opts: Array = [f[2]]
	opts.append_array(f[3])
	choice_puzzle("False friend " + str(ff_i + 1) + " of " + str(ff_order.size()), "This Tujuju word looks like " + f[1] + ":\n\n" + f[0] + "\n\nWhat does it really mean in Tujuju?", opts, 0, func():
		master("ff:" + f[0])
		ff_i += 1, f[0] + " means " + f[2] + ", not " + f[1] + "!", "Careful: it only looks like " + f[1] + ". Check the notebook.", show_games,
		func(): button("Next false friend", false_friends.bind(false), content))

func sound_game(start: bool = true):
	if start:
		ff_order = Data.SOUND_SCENES.duplicate()
		ff_order.shuffle()
		ff_order = ff_order.slice(0, 6)
		ff_i = 0
	if ff_i >= ff_order.size():
		clear_panel("What's that sound? Done!")
		text_line("Great ears! These sound words come from Guarani, a language of Paraguay that is full of them. Repeating the last syllable (po-ro-ro, ta-ra-ra) echoes a sound that repeats.", 18)
		gin += 2
		toast("+2 gin")
		save_game()
		button("Play again", sound_game.bind(true), content)
		button("Sound words", show_sounds, content)
		button("Games", show_games, content)
		return
	var f: Array = ff_order[ff_i]
	var opts: Array = [f[0]]
	opts.append_array(f[2])
	for o in opts: learn(o)
	play_sfx(str(f[0]), 0.0)
	choice_puzzle("What's that sound? " + str(ff_i + 1) + " of " + str(ff_order.size()), f[1] + "\n\nWhich sound word fits?", opts, 0, func():
		master("snd:" + f[0])
		ff_i += 1, f[0] + ": " + short_gloss(f[0]) + ".", "Listen again. Check the sound words page in the notebook.", show_games,
		func(): button("Next sound", sound_game.bind(false), content))
	var hb = button("Hear it again", func(): play_sfx(str(f[0]), 0.0), content)
	content.move_child(hb, 1)

func show_sounds():
	clear_panel("Sound words")
	text_line("Tujuju borrowed a family of sound words from Guarani, a language spoken by millions of people in Paraguay. Many repeat their last syllable, the way the sound itself repeats.", 17)
	var h = text_line("How they work in Tujuju:\n- the sound itself: pororo! (pop!)\n- as a verb: Far i-pororo-im-da. (The fire is popping.)\n- doubled, again and again: i-pororo-pororo-im-da (popping and popping)\n- in the past, people say: i-pororo-pa-nu (it popped, they say)", 17)
	h.add_theme_color_override("font_color", Color("2f5a2f"))
	for w in ["pororo", "piriri", "chiriri", "guarara", "kororo", "tarara", "pururu", "siri", "vava", "sununu"]:
		var known = discovered.has(w)
		var l = text_line((w + "  " + short_gloss(w) + "   i-" + w + "-im-da, " + w + "-" + w) if known else "???  (not heard yet)", 18)
		if known: l.add_theme_color_override("font_color", Color("7a1f3d"))
	text_line("Listen for them around the island: Mira's pan, Neri's campfire, Desh's parties, and anyone who naps.", 16)
	button("Play: What's that sound?", sound_game.bind(true), content)
	button("Word play", show_loans, content)
	button("Notebook", show_notebook, content)

func show_varnak():
	clear_panel("About Tujuju")
	text_line("Tujuju is an invented language built to work the way many real languages do. This page lists its main features. The game uses a simplified version, and the doubling and sound words were added for the game.", 17)
	var secs = [
		["Sounds and spelling", "Five vowels (a e i o u), and the letter y sounds like the y in yes. Words end only in m, n, ng, l, r, s, k or t, so borrowed words get respelled: brouhaha becomes buruhaha.", []],
		["Words are built from pieces", "Tujuju glues small meaningful pieces together. One verb can say who did what, when, and how you know. Hyphens show the pieces.", ["“Ma-k-i-pal-pa-ki-da.” = ma- not, k- I, i- it, pal see, -pa past, -ki not, -da I know it directly: I did not see it."]],
		["Verbs show people", "A prefix tells who is acting. Na- is I, ta- is you, i- is he, she or it, ri- is they. With two people, the doer comes first: k-i- is I (do it to) it, t-na- is you (do it to) me.", ["“Na-lum.” I go.   “Ta-lum.” You go.   “Ri-lum.” They go."]],
		["Time and aspect", "Endings after the verb show when and how: -pa past, -fu future, -im happening now, -ur usually, -ak finished.", ["“I-nang-pa.” walked.   “I-nang-fu.” will walk.   “I-nang-im.” is walking.   “I-nang-ur.” usually walks."]],
		["How do you know?", "Evidentials are endings that say how you know something: -da I saw it myself, -shi I infer it from evidence, -nu people say. They are the heart of Tujuju gossip.", ["“Tor kurma i-tal-pa-da.” I saw Tor arrive at the market.   “...i-tal-pa-shi.” Apparently he arrived.   “...i-tal-pa-nu.” They say he arrived."]],
		["Who did what to whom", "Tujuju marks the doer of an action on another thing with -ke. This is called ergative marking. Someone who just goes, sleeps or is, takes no ending.", ["“Sanu i-lum-pa-da.” The child went.   “Mirake puka i-rav-pa-da.” Mira read the book."]],
		["Case endings", "Short endings on nouns do the work of English words like to, in, from and with: -ni of, -ru to, -ma in or at, -ta from, -su together with, -li by means of.", ["“Tekama” in the village.   “Moraru” to the river.   “Tisu” with you."]],
		["Many and ordinal", "-ir makes a plural. A number comes before its noun, and -ve makes ordinal numbers.", ["“Tari-ir” fish (many).   “Mur tari” three fish.   “Bar-ve hai-sao” the eighth sea star."]],
		["No and please", "Not is wrapped around the verb: ma- before it and -ki after it. A command ends in -o, and -ye makes it polite.", ["“Ma-na-lum-ki-da.” I am not going.   “Ta-lum-o-ye.” Please go.   “Ma-ta-pav-o-ki!” Do not run!"]],
		["Questions", "-ha makes a yes or no question. Question words stay where the answer would go.", ["“Ta-lum-fu-ha?” Will you go?   “Ti hama ta-esh-ha?” Where are you?"]],
		["Describing words are verbs", "Words like big or warm act like verbs, so they take the same prefixes. Before a noun, they stay bare.", ["“Teka i-var.” The village is big.   “Var teka.” a big village."]],
		["Nouns inside verbs", "A noun can move inside the verb, making a single word for the whole activity.", ["“Tari-nuk” fish-catch, go fishing.   “Wak-ta” water-drink."]],
		["Compounds and calques", "Joining two words makes a new one, sometimes by translating another language piece by piece (a calque).", ["“Hai-sao” sea-star.   “Far-par” fire-bird, firefly.   “Ret-gor” hot-dog."]],
		["Doubling", "Repeating a word makes it stronger or repeats the action. This is a game addition.", ["“Var-var” huge.   “Pav-pav” run around and around.   “Guro-guro” fruit of all kinds."]],
		["Can and want (new)", "Two endings added for the game go right after the verb root: -kan means can, and -vai means want to. They work with every other ending.", ["“Na-sum-kan-da.” I can swim.   “Ti ta-ning-kan-ha?” Can you sing?   “Anke cha k-i-nuk-vai-da.” I want tea."]],
		["Telling people what to do", "A command takes -o. Adding -ye makes it polite, and grumpy or proud people may ignore you without it. -ka means and then, for a second action by the same person.", ["“Ta-pul-o!” Jump!   “Ta-pul-o-ye!” Please jump!   “Ta-pul-o-ka ta-ning-o-ye!” Please jump and then sing!   “Ansu ta-kar-o-ye!” Please come with me!"]],
		["Directions", "Bei north, nam south, dong east and sai west take -ma for in: bei-ma, in the north. To ask where, use hama with -ha.", ["“Kur hama i-esh-ha?” Where is the market?   “Kur sai-ma i-esh-da.” The market is in the west."]],
		["Borrowed words and sound words", "Tujuju borrows from other languages (choni, kawai, habibi, puts, pororo from Guarani) and respells them with its own sounds.", []]
	]
	for sec in secs:
		var h = text_line(sec[0], 21)
		h.add_theme_color_override("font_color", Color("7a1f3d"))
		text_line(sec[1], 17)
		for ex in sec[2]:
			var e = text_line(ex, 18)
			e.add_theme_color_override("font_color", Color("3b2a1a"))
	button("Word play: borrowings, calques, false friends, doubling", show_loans, content)
	button("Verb builder", show_verb_builder.bind(-1), content)
	button("Back", show_more, content)
	button("Return", close_panel, content)

func show_credits():
	clear_panel("Credits")
	text_line("Tujuju Island", 24)
	text_line("A game by je hammink.")
	text_line("Created and directed by je hammink: concept, Tujuju language design, learning design and playtesting.")
	text_line("Built in Godot 4 with Claude, an AI model by Anthropic, as a coding assistant.", 17)
	text_line("Every model, effect and piece of island nonsense is built from simple shapes in code. No outside assets are used.", 16)
	button("Back", show_more, content)
	button("Return", close_panel, content)

func show_loans():
	clear_panel("Word play")
	text_line("Borrowed words. Tujuju borrows words from other languages and respells them with Tujuju sounds: five vowels (a e i o u), y for the sound in yes, and only m, n, ng, l, r, s, k or t at the end of a word. Hard clusters get an extra vowel: brouhaha becomes buruhaha.", 17)
	var any = false
	for w in words.keys():
		if str(words[w]).contains("borrow"):
			any = true
			var known = discovered.has(w)
			var l = text_line((w if known else "???") + "  " + (str(words[w]) if known else "(not found yet)"), 18)
			if known: l.add_theme_color_override("font_color", Color("7a1f3d"))
	if not any: text_line("None yet.")
	var groups = [["calque", "Calques. A calque translates another language's word piece by piece: far-par (fire-bird) is a firefly, ret-gor (hot-dog) is a hot dog."],
		["false friend", "False friends. These look like English words but mean something else. Don't be fooled!"],
		["doubled", "Doubling. Say a word twice to make it stronger or to mean again and again: var big, var-var huge; pav run, pav-pav run around and around."]]
	for g in groups:
		var h = text_line(g[1], 17)
		h.add_theme_color_override("font_color", Color("2f5a2f"))
		var n = 0
		for w in words.keys():
			if str(words[w]).contains(g[0]):
				n += 1
				var known = discovered.has(w)
				var l = text_line((w if known else "???") + "  " + (str(words[w]) if known else "(not found yet)"), 18)
				if known: l.add_theme_color_override("font_color", Color("7a1f3d"))
		if n == 0: text_line("None yet.")
	button("Sound words from Guarani", show_sounds, content)
	button("Play False friends", false_friends.bind(true), content)
	button("Notebook", show_notebook, content)

# ------------------------------------------------------------ eighth expansion: Hirimara, pranks, the great choni hunt

const MAZE_O = Vector2(-125.0, -13.0)
const MAZE_N = 6
const MAZE_CELL = 3.6
const HIRI_SECRETS = ["karaoke", "ghost", "dopel", "maze", "scarecrow"]

func build_hirimara():
	Art.signpost(self, Vector3(-84.5, gy(-84.5, 6.5), 6.5), "Hirimara", 90)
	# ---- the hedge maze (a perfect maze from a fixed seed) ----
	var rng = RandomNumberGenerator.new()
	rng.seed = 4242
	var open: Dictionary = {}
	var seen: Dictionary = {Vector2i(0, 0): true}
	var stack: Array = [Vector2i(0, 0)]
	while not stack.is_empty():
		var c: Vector2i = stack[-1]
		var nb: Array = []
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x >= 0 and n.y >= 0 and n.x < MAZE_N and n.y < MAZE_N and not seen.has(n): nb.append(n)
		if nb.is_empty():
			stack.pop_back()
			continue
		var n2: Vector2i = nb[rng.randi() % nb.size()]
		seen[n2] = true
		open[maze_key(c, n2)] = true
		stack.append(n2)
	var entrance = Vector2i(MAZE_N - 1, 3)
	var hedge = Color("3f7d3a")
	var wall = func(x: float, z: float, along_x: bool):
		var wl = MAZE_CELL + 0.6
		var size = Vector3(wl, 2.5, 0.7) if along_x else Vector3(0.7, 2.5, wl)
		var y = gy(x, z)
		var hc = hedge.lerp(Color("2f6a2c"), rng.randf() * 0.6)
		Art.box(self, Vector3(x, y + 1.15, z), size, hc)
		Art.box(self, Vector3(x, y + 2.45, z), size * Vector3(0.96, 0.05, 0.96) + Vector3(0, 0.05, 0), hc.lightened(0.25))
		solid(Vector3(x, y + 1.15, z), size)
	for i in range(MAZE_N):
		for j in range(MAZE_N):
			var cx = MAZE_O.x + (i + 0.5) * MAZE_CELL
			var cz = MAZE_O.y + (j + 0.5) * MAZE_CELL
			# wall to the east of this cell
			if i < MAZE_N - 1:
				if not open.has(maze_key(Vector2i(i, j), Vector2i(i + 1, j))): wall.call(cx + MAZE_CELL * 0.5, cz, false)
			elif Vector2i(i, j) != entrance:
				wall.call(cx + MAZE_CELL * 0.5, cz, false)
			# wall to the south of this cell
			if j < MAZE_N - 1:
				if not open.has(maze_key(Vector2i(i, j), Vector2i(i, j + 1))): wall.call(cx, cz + MAZE_CELL * 0.5, true)
			else:
				wall.call(cx, cz + MAZE_CELL * 0.5, true)
			if i == 0: wall.call(cx - MAZE_CELL * 0.5, cz, false)
			if j == 0: wall.call(cx, cz - MAZE_CELL * 0.5, true)
	# the chest goes in the cell farthest from the entrance
	var dist: Dictionary = {entrance: 0}
	var q: Array = [entrance]
	var far = entrance
	while not q.is_empty():
		var c: Vector2i = q.pop_front()
		if dist[c] > dist[far]: far = c
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if n.x < 0 or n.y < 0 or n.x >= MAZE_N or n.y >= MAZE_N or dist.has(n): continue
			if open.has(maze_key(c, n)):
				dist[n] = dist[c] + 1
				q.append(n)
	var cp = Vector3(MAZE_O.x + (far.x + 0.5) * MAZE_CELL, 0, MAZE_O.y + (far.y + 0.5) * MAZE_CELL)
	maze_chest = Art.chest(self, Vector3(cp.x, gy(cp.x, cp.z), cp.z))
	entity("maze_chest", "object", "lavir", cp, Color.WHITE, 1.3, Vector2(0.9, 1.0))
	var ent = Vector3(MAZE_O.x + MAZE_N * MAZE_CELL + 1.6, 0, MAZE_O.y + (entrance.y + 0.5) * MAZE_CELL)
	Art.signpost(self, Vector3(ent.x + 0.6, gy(ent.x, ent.z - 2.4), ent.z - 2.4), "lavir", 90)
	entity("lavir", "object", "lavir", Vector3(ent.x + 0.6, 0, ent.z - 2.4), Color.WHITE, 2.4, Vector2(1.0, 2.2))
	# ---- karaoke stage ----
	var ks = Vector3(-96.0, gy(-96.0, 16.0), 16.0)
	Art.box(self, ks + Vector3(0, 0.2, 0), Vector3(4.0, 0.4, 2.6), Color("8a5a3c"))
	Art.box(self, ks + Vector3(0, 1.6, 1.2), Vector3(4.0, 2.8, 0.2), Color("6a2c70"))
	for k in range(6):
		Art.sph(self, ks + Vector3(-1.7 + k * 0.68, 3.05, 1.05), 0.12, [Color("ff5d5d"), Color("ffd34d"), Color("6de0ff"), Color("b38bff"), Color("7dff8a"), Color("ff8ad8")][k], Vector3.ONE, 8, 1.5)
	Art.cyl(self, ks + Vector3(0, 0.95, -0.2), 0.03, 0.03, 1.1, Color("333333"))
	Art.sph(self, ks + Vector3(0, 1.55, -0.2), 0.11, Color("f2e6c8"), Vector3(1, 1.2, 1), 10)
	for sx in [-1.6, 1.6]:
		Art.box(self, ks + Vector3(sx, 0.85, 0.6), Vector3(0.6, 0.9, 0.5), Color("222222"))
		Art.cyl(self, ks + Vector3(sx, 0.95, 0.34), 0.18, 0.18, 0.04, Color("555555"), Vector3(90, 0, 0))
	solid(ks + Vector3(0, 0.2, 0), Vector3(4.0, 0.4, 2.6))
	entity("karaoke", "object", "karaoke", ks + Vector3(0, 0, -1.8), Color.WHITE, 2.0, Vector2(1.6, 2.0))
	# ---- the poltergeist's bungalow ----
	var hp = Vector3(-100.0, 0, -19.0)
	Art.hut(self, hp, face(hp, Vector3(-100, 0, -10)))
	solid(hp + Vector3(0, 1.3, 0), Vector3(4.6, 2.6, 4.6))
	block(hp.x, hp.z, 3.4)
	ghost_things.clear()
	for k in range(3):
		var g = Node3D.new()
		add_child(g)
		if k == 0:
			Art.sph(g, Vector3.ZERO, 0.28, Color("2a9d8f"), Vector3(1, 0.8, 1), 10)
			Art.cyl(g, Vector3(0.3, 0.05, 0), 0.04, 0.06, 0.3, Color("2a9d8f"), Vector3(0, 0, -50))
		elif k == 1:
			Art.box(g, Vector3.ZERO, Vector3(0.5, 0.08, 0.5), Color("8a5a3c"))
			Art.box(g, Vector3(0, 0.3, -0.22), Vector3(0.5, 0.6, 0.08), Color("8a5a3c"))
		else:
			Art.box(g, Vector3(0, 0, 0), Vector3(0.5, 0.3, 0.04), Color("f2f2f2"))
			for d in range(3): Art.sph(g, Vector3(-0.14 + d * 0.14, 0.02, 0.025), 0.04, Color("e76f51"), Vector3(1, 1, 0.3), 5)
		ghost_things.append(g)
	entity("ghost_hut", "object", "bungalo", Vector3(-100, 0, -15.6), Color.WHITE, 2.8, Vector2(1.6, 2.4))
	# ---- the scarecrow with chonies on its head ----
	var sc = Node3D.new()
	sc.position = Vector3(-92.0, gy(-92.0, -7.0), -7.0)
	sc.rotation_degrees.y = 70
	add_child(sc)
	Art.cyl(sc, Vector3(0, 1.0, 0), 0.06, 0.07, 2.0, Color("6b4f36"))
	Art.cyl(sc, Vector3(0, 1.45, 0), 0.04, 0.04, 1.6, Color("6b4f36"), Vector3(0, 0, 90))
	Art.box(sc, Vector3(0, 1.3, 0), Vector3(0.7, 0.7, 0.3), Color("c0392b"))
	Art.sph(sc, Vector3(0, 1.95, 0), 0.25, Color("e9c46a"), Vector3.ONE, 10)
	Art.box(sc, Vector3(0, 2.22, 0), Vector3(0.52, 0.22, 0.4), Color("f2f2f2"))
	for d in range(4): Art.sph(sc, Vector3(-0.18 + d * 0.12, 2.24, 0.205), 0.04, Color("e76f51"), Vector3(1, 1, 0.3), 5)
	solid(sc.position + Vector3(0, 1.0, 0), Vector3(0.4, 2.0, 0.4))
	entity("scarecrow", "object", "choni", Vector3(-92.0, 0, -5.8), Color.WHITE, 2.7, Vector2(1.0, 2.4))
	# ---- Pomo's doppelganger, standing very still on a rock ----
	var dp = Vector3(-127.0, gy(-127.0, 14.0), 14.0)
	Art.sph(self, dp + Vector3(0, 0.2, 0), 1.0, Color("8d9394"), Vector3(1.3, 0.5, 1.1), 9)
	var dopel = Art.person(Color("4f7ca8"), Color("d6ac83"), Color("6b6b6b"), 3, Color("c0392b"), person_ex["pomo"])
	dopel.position = dp + Vector3(0, 0.45, 0)
	dopel.rotation_degrees.y = 90
	add_child(dopel)
	entity("dopel", "object", "Pomo?", Vector3(-126.0, 0, 14.0), Color.WHITE, 2.7, Vector2(1.0, 2.6))
	# ---- the deja vu stone in the stone circle ----
	var dv = Vector3(34.6, 0, -44.2)
	Art.sph(self, Vector3(dv.x, gy(dv.x, dv.z) + 0.45, dv.z), 0.55, Color("8f5fd0"), Vector3(0.8, 1.3, 0.8), 10, 0.6)
	entity("deshavu", "object", "deshavu-sek", dv, Color.WHITE, 1.6, Vector2(0.8, 1.4))
	# ---- a few palms and stones so the peninsula feels lived-in ----
	for p in [Vector3(-131, 0, 20), Vector3(-136, 0, -6), Vector3(-118, 0, 24), Vector3(-90, 0, 18), Vector3(-108, 0, -26), Vector3(-123, 0, -20)]:
		if T.coast(p.x, p.z) > 3.0: Art.palm(self, Vector3(p.x, gy(p.x, p.z), p.z), randf_range(-8, 8))
	# ---- the lost chonies (four lie around the island; two are won) ----
	for c in Data.CHONI_HUNT:
		if c[0] in ["choni_ghost", "choni_maze"]: continue
		var ce = entity(c[0], "choni", "choni", Vector3(c[1], 0, c[2]), Color.WHITE, 0.7, Vector2(0.8, 0.8))
		var n = ce["node"] as Node3D
		var cm = Node3D.new()
		cm.position = Vector3(0, 0.15, 0)
		cm.rotation_degrees = Vector3(-70, randf() * 360.0, 0)
		cm.scale = Vector3.ONE * 1.5
		n.add_child(cm)
		Art.box(cm, Vector3(0, 0, 0), Vector3(0.5, 0.3, 0.04), Color("f2f2f2"))
		Art.box(cm, Vector3(0, -0.2, 0), Vector3(0.2, 0.14, 0.04), Color("f2f2f2"))
		for d in range(5): Art.sph(cm, Vector3(-0.16 + (d % 3) * 0.16, -0.06 + (d / 3) * 0.14, 0.025), 0.04, Color("ff5d8f"), Vector3(1, 1, 0.3), 5)
	# ---- Gav's clothesline (fills up when the chonies come home) ----
	choni_line = Node3D.new()
	choni_line.position = Vector3(8.6, gy(8.6, 36.6), 36.6)
	add_child(choni_line)
	for sx in [-2.2, 2.2]: Art.cyl(choni_line, Vector3(sx, 1.0, 0), 0.04, 0.05, 2.0, Color("6b4f36"))
	Art.cyl(choni_line, Vector3(0, 1.9, 0), 0.01, 0.01, 4.4, Color("ddd5c4"), Vector3(0, 0, 90))
	for k in range(6):
		var cc = Node3D.new()
		cc.position = Vector3(-1.75 + k * 0.7, 1.72, 0)
		choni_line.add_child(cc)
		Art.box(cc, Vector3.ZERO, Vector3(0.45, 0.28, 0.03), [Color("f2f2f2"), Color("ffd6e0"), Color("cde7f0")][k % 3])
		for d in range(3): Art.sph(cc, Vector3(-0.12 + d * 0.12, 0.02, 0.02), 0.035, Color("e76f51"), Vector3(1, 1, 0.3), 5)
	choni_line.visible = false
	# ---- choni rain (a rare kind of rain) ----
	choni_fx = CPUParticles3D.new()
	choni_fx.amount = 30
	choni_fx.lifetime = 2.6
	choni_fx.emitting = false
	choni_fx.local_coords = false
	choni_fx.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	choni_fx.emission_box_extents = Vector3(12, 0.5, 12)
	choni_fx.direction = Vector3(0, -1, 0)
	choni_fx.initial_velocity_min = 1.0
	choni_fx.initial_velocity_max = 2.5
	choni_fx.angular_velocity_min = -200.0
	choni_fx.angular_velocity_max = 200.0
	choni_fx.gravity = Vector3(0, -2.5, 0)
	var bm = BoxMesh.new()
	bm.size = Vector3(0.4, 0.26, 0.03)
	choni_fx.mesh = bm
	choni_fx.material_override = Art.mat(Color("ffd6e0"), 0.6)
	choni_fx.position = Vector3(0, 12, 0)

func maze_key(a: Vector2i, b: Vector2i) -> String:
	if a.x > b.x or (a.x == b.x and a.y > b.y):
		var t = a
		a = b
		b = t
	return str(a) + "|" + str(b)

func update_hirimara(delta: float):
	if choni_fx and choni_fx.get_parent() == null and player: player.add_child(choni_fx)
	var hp = Vector3(-100.0, 0, -19.0)
	for k in range(ghost_things.size()):
		var g = ghost_things[k] as Node3D
		var a = clock * (0.7 + k * 0.25) + k * 2.1
		g.position = hp + Vector3(cos(a) * 3.4, gy(hp.x, hp.z) + 1.6 + sin(clock * 1.6 + k) * 0.5, sin(a) * 3.4)
		g.rotation.y = clock * (1.0 + k)
	if choni_rain_t > 0.0:
		if not choni_fx.emitting:
			choni_fx.emitting = true
			learn("choni")
			learn("kar")
			hiri_secret("rain")
			toast("Buruhaha! Choni-ir hen-ta ri-kar-im-da! It is raining chonies!")
		choni_rain_t -= delta
		if choni_rain_t <= 0.0:
			choni_fx.emitting = false
			var g = entity_by_id("gav")
			if not g.is_empty(): g["say"] = ["Anni choni-ir?! Hen-ta?!", clock + 6.0]
			toast("Somewhere, Gav shouts: Anni choni-ir?! Hen-ta?! (My chonies?! From the sky?!)")

func hiri_secret(k: String):
	if solved.has("hs:" + k): return
	solved.append("hs:" + k)
	var n = 0
	for s in HIRI_SECRETS:
		if solved.has("hs:" + s): n += 1
	if HIRI_SECRETS.has(k):
		toast("Secret of Hirimara: " + str(n) + " of " + str(HIRI_SECRETS.size()) + "!")
		if n >= HIRI_SECRETS.size(): complete("hirimara")
	save_game()

func chonies_found() -> int:
	var n = 0
	for c in Data.CHONI_HUNT:
		if solved.has("ch:" + c[0]): n += 1
	return n

func find_choni(id: String):
	if solved.has("ch:" + id): return
	solved.append("ch:" + id)
	var e = entity_by_id(id)
	if not e.is_empty(): (e["node"] as Node3D).hide()
	var n = chonies_found()
	learn("choni")
	learn("yureka")
	learn("-ve")
	toast("Yureka! " + str(Data.ORDINALS[n - 1]).capitalize() + " choni! (" + str(n) + " of " + str(Data.CHONI_HUNT.size()) + ")")
	if n >= Data.CHONI_HUNT.size(): toast("Yureka! All six chonies! Take them back to Gav at the harbor.")
	save_game()

func choni_hints():
	talk_partner = "gav"
	clear_panel("Gav's lost chonies")
	add_portrait("gav")
	emote("gav", "sad" if chonies_found() < Data.CHONI_HUNT.size() else "love", 4.0)
	learn("choni")
	learn("-shi")
	learn("-nu")
	var n = chonies_found()
	text_line("Gav sniffles. " + str(n) + " of " + str(Data.CHONI_HUNT.size()) + " found. His clues (how does Gav know each one?):", 16)
	var ens: Array = []
	for c in Data.CHONI_HUNT:
		if solved.has("ch:" + c[0]):
			text_line("[found]  " + c[3], 14)
			continue
		text_line("“" + c[3] + "”", 15)
		var en = text_line(c[4], 14)
		en.add_theme_color_override("font_color", Color("6b4a2e"))
		en.visible = false
		ens.append(en)
	if not ens.is_empty():
		button("Show or hide meanings", func():
			for e in ens: e.visible = not e.visible, content)
	if n >= Data.CHONI_HUNT.size() and not completed.has("chonies"):
		button("Give Gav the chonies", func():
			complete("chonies")
			gin += 5
			for w in ["choni-na", "-na", "yureka", "bravo"]: learn(w)
			choni_line.visible = true
			react("gav", "Ki choni-ir ti-ru!", "These chonies, for you!", "Choni-ir! Anni choni-ir!! Bravo! Ti choni-na ta-an-da!", "My chonies! My CHONIES!! Bravo! You are a choni-na, a choni person! (-na makes a person word. +5 gin)", "love", 3), content)
	elif completed.has("chonies"):
		text_line("All six chonies flap proudly on Gav's clothesline by the harbor. You are officially a choni-na.", 16)
	button("Back", talk.bind("gav"), content)

# ---- pranks ----

func prank_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel("Prank " + id.capitalize())
	add_portrait(id)
	learn("hiri")
	text_line("Choose a prank. Then shout “Hiri!” (Gotcha!)", 16)
	for p in Data.PRANKS:
		button(p["label"], do_prank.bind(id, p), content)
	button("Back", chat_menu.bind(id), content)

func do_prank(id: String, p: Dictionary):
	var pp: Dictionary = Data.PEOPLE[id]
	var tt: String = pp["trait"]
	var thing: Array = pp["thing"]
	var sv = str(p["v"]).replace("{thing}", thing[0])
	var se = str(p["en"]).replace("{thing_en}", thing[1])
	for w in p["words"]: learn(w)
	learn("hiri")
	var act = str(p["act"]).replace("{name}", id.capitalize())
	if not once_today(id, "prank"):
		if tt in ["giggly", "cheerful"]:
			learn("hiri-hiri")
			react(id, sv, se, "Hiri-hiri! Ha! Ha!", "Prank after prank! Ha ha! (doubling: hiri-hiri)", "laugh", 0)
		else:
			react(id, sv, se, "Ma-ta-hiri-o-ki!", "Don't prank me! (ma- ... -o-ki makes a don't-command)", "angry", -1)
		return
	if id == "gav" and p["id"] == "choni":
		react(id, sv, se, "Anni choni?! Hama?! HAMA?! ...Hiri? Ha! Ha!", "(" + act + ") My chonies?! Where?! WHERE?! ...A prank? Ha ha!", "shocked", 1)
		return
	if id == "yalo" and p["id"] == "ghost":
		react(id, sv, se, "AAAH! Poltergais! ...Ti?! Hiri?! Maki...", "(Yalo hides under his own coat.) AAAH! A poltergeist! ...You?! A prank?! No...", "faint", 0)
		return
	var r: Array = Data.PRANKED[tt]
	react(id, sv + "  ...Hiri!", se + " ...Gotcha!", r[0], "(" + act + ") " + r[1], r[2], r[3])

# ---- Hirimara places ----

func karaoke_panel():
	for w in ["karaoke", "bravo", "ning"]: learn(w)
	hiri_secret("karaoke")
	play_sfx("kachaka", -2.0)
	clear_panel("karaoke")
	varnak_banner("Ta-ning-o! Bravo!", 26)
	text_line("A seashell microphone on a tiny stage. The scarecrow is your audience. Here is tonight's song:", 17)
	var lines = make_poem("ning-guro")
	show_poem_lines(lines)
	button("Sing it! (Ta-ning-o!)", func():
		record_poem(lines, "you")
		var cheer: Array = []
		for e in entities:
			if e["kind"] == "npc" and (e["node"] as Node3D).position.distance_to(player.position) < 30.0:
				e["say"] = ["Bravo! Bravo!", clock + 5.0]
				cheer.append(e["id"])
		message("Bravo! Bravo!", "You sing with all your heart. " + ("The scarecrow's chonies flap in applause." if cheer.is_empty() else ", ".join(cheer.map(func(x): return x.capitalize())) + " cheer: Bravo! Bravo!") + "\n\nThe song is saved in your Poem book."), content)
	button("About this stage", sentence_card.bind("karaoke_stage"), content)
	button("Return", close_panel, content)

func ghost_panel():
	for w in ["poltergais", "bungalo", "ven", "-o", "-ye"]: learn(w)
	hiri_secret("ghost")
	clear_panel("The poltergeist's bungalo")
	text_line("A teapot, a chair and something spotted circle the little house. A voice giggles from inside:", 17)
	if solved.has("ch:choni_ghost"):
		varnak_banner("Uuuu... Hiri! Hiri!", 26)
		text_line("(Woooo... Gotcha! Gotcha!) The poltergeist has nothing left to steal. For now.", 16)
		button("About this house", sentence_card.bind("ghost_hut"), content)
		button("Return", close_panel, content)
		return
	varnak_banner("Uuuu... Anke Gav-ni choni k-i-nuk-pa-da! Hi hi!", 24)
	ask("What do you say to get the choni back?", ["T-na-ven-o-ye!", "Ta-sul-o-ye!", "K-i-nuk-pa-da.", "Ti poltergais ta-an-da."], 0, func():
		find_choni("choni_ghost"), "T-na-ven-o-ye! means Please give it to me! The poltergeist sighs, “Uuuu... ho,” and a spotted choni floats down into your hands.",
		"The poltergeist just giggles. You want it to GIVE (ven) the choni to YOU: t- (you act), na- (to me), -o (command), -ye (please).", close_panel)

func dopel_panel():
	for w in ["dopelgenger", "hal", "an", "-ha"]: learn(w)
	hiri_secret("dopel")
	clear_panel("Pomo...?")
	text_line("It looks exactly like Pomo. It is wide awake, and it has not blinked once. It says Pomo's directions backwards:", 17)
	varnak_banner("Sai, dong, nam, bei.", 28)
	button("Ask: Ti hal ta-an-ha? (Who are you?)", func():
		clear_panel("The doppelganger")
		varnak_banner("An dopelgenger na-an-da! Pomo i-sul-im-da. An ma-na-sul-ur-ki-da!", 24)
		var en = text_line("(Tap Show meaning if you need it.)", 16)
		button("Show meaning", func(): en.text = "I am the doppelganger! Pomo is sleeping. I never sleep! (dopelgenger is borrowed from German Doppelganger, double-goer)", content)
		button("Say: Ti Pomo ma-ta-an-ki-da! (You are not Pomo!)", func():
			message("Hiri!", "The doppelganger grins: “Hiri!” (Gotcha!) Then it stands perfectly still again, pretending to be a statue. Somewhere on the west hill, the real Pomo snores."), content)
		button("Return", close_panel, content), content)
	button("Return", close_panel, content)

func maze_chest_panel():
	for w in ["lavir", "yureka", "chochke"]: learn(w)
	hiri_secret("maze")
	if solved.has("ch:choni_maze"):
		message("lavir", "The chest is empty except for a note: “Hiri!” Someone was here before you. (It was you.)")
		return
	(maze_chest.get_meta("lid") as Node3D).rotation_degrees.x = -110.0
	find_choni("choni_maze")
	inventory.append("chochke")
	gin += 3
	save_game()
	message("Yureka!", "You reach the middle of the lavir (maze). Inside the chest: one of Gav's chonies, a chochke (a little trinket, from Yiddish tchotchke) and vel e yan gin, three coins. Oku would want to talk to that trinket.")

func choni_kind_pick(e: Dictionary):
	find_choni(e["id"])
	clear_panel("choni")
	varnak_banner("Yureka! Choni!", 28)
	text_line("A pair of Gav's spotted chonies, right here. How did they get here? Nobody knows. Everyone suspects the poltergeist.", 17)
	button("Return", close_panel, content)

# ------------------------------------------------------------ ninth expansion: learning log, overheard talk, letters, Teach Neri

const LOG_FILE = "user://varnak_log.json"
var events: Array = []
var log_dirty: bool = false
var cur_title: String = ""
var listen_button: Button
var overhear_now: Dictionary = {}
var overhear_cd: float = 30.0

func log_event(kind: String, detail, ok = null):
	var e = {"t": int(Time.get_unix_time_from_system()), "k": kind, "d": detail}
	if ok != null: e["ok"] = ok
	events.append(e)
	if events.size() > 5000: events = events.slice(events.size() - 5000)
	log_dirty = true

func save_log():
	if not log_dirty: return
	var f = FileAccess.open(LOG_FILE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(events))
		log_dirty = false

func load_log():
	if not FileAccess.file_exists(LOG_FILE): return
	var d = JSON.parse_string(FileAccess.get_file_as_string(LOG_FILE))
	if d is Array: events = d

func iso(t: int) -> String:
	return Time.get_datetime_string_from_unix_time(t).replace("T", " ")

func accuracy_by_activity() -> Dictionary:
	var out = {}
	for e in events:
		if not (e["k"] in ["answer", "build"]) or not e.has("ok"): continue
		var a = str(e["d"].get("activity", "?")) if e["d"] is Dictionary else "?"
		if not out.has(a): out[a] = [0, 0]
		if e["ok"]: out[a][0] += 1
		else: out[a][1] += 1
	return out

func missed_words() -> Dictionary:
	# words that appear in items the player got wrong
	var out = {}
	for e in events:
		if e["k"] in ["answer", "build"] and e.has("ok") and not e["ok"] and e["d"] is Dictionary:
			var txt = (str(e["d"].get("item", "")) + " " + str(e["d"].get("target", ""))).to_lower()
			for w in discovered:
				if str(w).length() >= 3 and not str(w).begins_with("-") and txt.contains(str(w)):
					out[w] = int(out.get(w, 0)) + 1
	return out

func learning_summary() -> Dictionary:
	var wm = 0
	for w in discovered:
		if mastered.has("w:" + w): wm += 1
	var pm = 0
	for p in phrases:
		if mastered.has("s:" + p): pm += 1
	var right = 0
	var wrong = 0
	var sessions = 0
	for e in events:
		if e["k"] == "session": sessions += 1
		if e.has("ok"):
			if e["ok"]: right += 1
			else: wrong += 1
	return {"words_found": discovered.size(), "words_mastered": wm, "phrases_found": phrases.size(), "phrases_mastered": pm,
		"answers_right": right, "answers_wrong": wrong, "sessions": sessions, "quests_done": quests_done(),
		"level": level(), "overheard": overheard_count(), "letters_answered": letters_answered(), "errands": errands_done(),
		"neri_corrections": count_mastered("tn:"), "first_played": iso(int(events[0]["t"])) if not events.is_empty() else ""}

func count_mastered(prefix: String) -> int:
	var n = 0
	for m in mastered:
		if str(m).begins_with(prefix): n += 1
	return n

func show_progress():
	compact_buttons.call_deferred()
	clear_panel("My learning")
	var s = learning_summary()
	text_line("Words: " + str(s["words_found"]) + " found, " + str(s["words_mastered"]) + " mastered.  Phrases: " + str(s["phrases_found"]) + " found, " + str(s["phrases_mastered"]) + " mastered.", 18)
	var tot = int(s["answers_right"]) + int(s["answers_wrong"])
	text_line("Answers and sentences: " + str(s["answers_right"]) + " right, " + str(s["answers_wrong"]) + " not yet" + ((" (" + str(int(round(100.0 * s["answers_right"] / tot))) + "% right)") if tot > 0 else "") + ".", 18)
	text_line("Quests: " + str(s["quests_done"]) + ".  Conversations overheard: " + str(s["overheard"]) + ".  Letters answered: " + str(s["letters_answered"]) + ".  Errands: " + str(s["errands"]) + ".  Neri's mistakes fixed: " + str(s["neri_corrections"]) + ".  Play sessions: " + str(s["sessions"]) + ".", 17)
	var acc = accuracy_by_activity()
	if not acc.is_empty():
		text_line("By activity", 21)
		var keys = acc.keys()
		keys.sort_custom(func(x, y): return acc[x][0] + acc[x][1] > acc[y][0] + acc[y][1])
		for k in keys.slice(0, 10):
			var r: int = acc[k][0]
			var w: int = acc[k][1]
			var l = text_line(str(k) + ": " + str(r) + " of " + str(r + w) + " right", 16)
			l.add_theme_color_override("font_color", Color("2f6b2f") if r >= w * 3 else Color("8a2f1f") if w > r else Color("6b4a2e"))
	var mw = missed_words()
	if not mw.is_empty():
		var ks = mw.keys()
		ks.sort_custom(func(x, y): return mw[x] > mw[y])
		text_line("Words in questions you missed most: " + ", ".join(ks.slice(0, 8)), 16)
	button("Review rusty words", review_rusty, content)
	text_line("Your data stays on this device. Export it to keep a record or share it with a teacher.", 16)
	button("Export data (JSON)", export_data.bind("json"), content)
	button("Export data (CSV)", export_data.bind("csv"), content)
	button("Return", close_panel, content)

func export_payload(fmt: String) -> String:
	if fmt == "csv":
		var rows: PackedStringArray = ["time_utc,kind,activity,item,answer,target,ok"]
		for e in events:
			var d = e["d"]
			var act = ""
			var item = ""
			var ans = ""
			var tgt = ""
			if d is Dictionary:
				act = str(d.get("activity", ""))
				item = str(d.get("item", d.get("key", d.get("id", ""))))
				ans = str(d.get("chose", d.get("built", "")))
				tgt = str(d.get("correct", d.get("target", "")))
			else: item = str(d)
			var okv = ""
			if e.has("ok"): okv = "1" if e["ok"] else "0"
			var cells = [iso(int(e["t"])), str(e["k"]), act, item, ans, tgt, okv]
			for i in range(cells.size()): cells[i] = "\"" + str(cells[i]).replace("\"", "\"\"").replace("\n", " ") + "\""
			rows.append(",".join(cells))
		return "\n".join(rows)
	var wl: Array = []
	for w in discovered: wl.append({"word": w, "meaning": short_gloss(w), "mastered": mastered.has("w:" + w)})
	var pl: Array = []
	for p in phrases: pl.append({"phrase": Data.SENTENCES[p]["v"], "meaning": Data.SENTENCES[p]["en"], "mastered": mastered.has("s:" + p)})
	return JSON.stringify({"game": "Tujuju Island", "exported_utc": iso(int(Time.get_unix_time_from_system())), "summary": learning_summary(),
		"accuracy_by_activity": accuracy_by_activity(), "words": wl, "phrases": pl, "quests_done": completed, "mastered_keys": mastered, "events": events}, "  ")

func export_data(fmt: String):
	log_event("export", fmt)
	var text = export_payload(fmt)
	var stamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var fname = "tujuju-learning-" + stamp + "." + fmt
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(text.to_utf8_buffer(), fname, "text/csv" if fmt == "csv" else "application/json")
		toast("Downloading " + fname)
	else:
		var path = "user://" + fname
		var f = FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(text)
			f.close()
		message("Data exported", "Saved to:\n" + ProjectSettings.globalize_path(path))
	last_export = text

var last_export: String = ""

# ---- overheard conversations ----

func overheard_count() -> int:
	return count_mastered("ov:")

func update_overhear(delta: float):
	if listen_button == null: return
	if not overhear_now.is_empty():
		var o: Dictionary = overhear_now["o"]
		var ea = entity_by_id(o["a"])
		var far = ea.is_empty() or (ea["node"] as Node3D).position.distance_to(player.position) > 30.0
		if clock > float(overhear_now["until"]) or far:
			overhear_now = {}
		listen_button.visible = not overhear_now.is_empty() and not panel.visible
		return
	listen_button.visible = false
	overhear_cd -= delta
	if overhear_cd > 0.0 or panel.visible or riding: return
	overhear_cd = 5.0
	for o in Data.OVERHEAR:
		if mastered.has("ov:" + o["id"]): continue
		var ea = entity_by_id(o["a"])
		var eb = entity_by_id(o["b"])
		if ea.is_empty() or eb.is_empty(): continue
		var na = ea["node"] as Node3D
		var nb = eb["node"] as Node3D
		if not na.visible or not nb.visible: continue
		var mid = (na.position + nb.position) * 0.5
		if player.position.distance_to(mid) < 18.0 and na.position.distance_to(nb.position) < 32.0:
			start_overhear(o)
			return

func start_overhear(o: Dictionary):
	overhear_now = {"o": o, "until": clock + 40.0}
	overhear_cd = 45.0
	var ea = entity_by_id(o["a"])
	var eb = entity_by_id(o["b"])
	ea["say"] = ["Psst... psst...", clock + 40.0]
	eb["say"] = ["...ho? ho!", clock + 40.0]
	emote(o["a"], "embarrassed", 4.0)
	play_sfx("piriri", -8.0)
	toast(str(o["a"]).capitalize() + " and " + str(o["b"]).capitalize() + " are whispering. Tap Listen in!")
	listen_button.show()

func listen_in():
	if overhear_now.is_empty(): return
	var o: Dictionary = overhear_now["o"]
	overhear_now = {}
	listen_button.hide()
	overhear_panel(o, true)

func overhear_panel(o: Dictionary, live: bool):
	compact_buttons.call_deferred()
	for w in o["words"]: learn(w)
	clear_panel("Listening in: " + str(o["a"]).capitalize() + " and " + str(o["b"]).capitalize())
	talk_partner = ""
	var t = text_line("You stand nearby and pretend to admire a tree. They don't notice you." if live else "You remember what you overheard.", 16)
	t.add_theme_color_override("font_color", Color("6b4a2e"))
	var ens: Array = []
	for ln in o["lines"]:
		text_line(str(ln[0]).capitalize() + ":  " + str(ln[1]), 21)
		var e = text_line("(" + str(ln[2]) + ")", 15)
		e.add_theme_color_override("font_color", Color("6b4a2e"))
		e.visible = false
		ens.append(e)
	var shown = [false]
	var sb = button("Show what they meant", func():
		shown[0] = true
		for e in ens: e.visible = true, content)
	var first = not mastered.has("ov:" + o["id"])
	log_event("overheard", {"id": o["id"], "live": live})
	ask(o["q"], o["opts"], 0, func():
		sb.disabled = true
		if first:
			master("ov:" + o["id"])
			var bonus = 1 if shown[0] else 2
			gin += bonus
			toast("You understood! +" + str(bonus) + " gin" + ("" if shown[0] else " (bonus: no peeking)"))
			if o.has("clue"): toast("New clue for the mystery letters! (Notebook, Letters)")
			check_letter_ready()
			save_game(), "You followed the whole conversation.", "Listen again: look for the question words and the endings.", show_overheard if not live else close_panel)

func show_overheard():
	compact_buttons.call_deferred()
	clear_panel("Overheard")
	text_line("Conversations you listened in on. Walk near two villagers standing close together and wait: sometimes they whisper.", 16)
	var any = false
	for o in Data.OVERHEAR:
		if mastered.has("ov:" + o["id"]):
			any = true
			button(str(o["a"]).capitalize() + " and " + str(o["b"]).capitalize() + ": " + str(o["lines"][0][1]), overhear_panel.bind(o, false), content)
	if not any: text_line("Nothing yet. Try the market, the school, the harbor or the village center.", 17)
	text_line(str(overheard_count()) + " of " + str(Data.OVERHEAR.size()) + " conversations heard.", 16)
	button("Back", show_notebook, content)

# ---- mystery letters ----

func clue_list() -> Array:
	var out: Array = []
	for o in Data.OVERHEAR:
		if o.has("clue") and mastered.has("ov:" + o["id"]): out.append(o["clue"])
	return out

func letters_answered() -> int:
	return count_mastered("lt:reply:")

func letter_available(k: int) -> bool:
	if k >= Data.LETTERS.size(): return false
	if k == 0: return discovered.size() >= 8
	return mastered.has("lt:reply:" + str(k - 1)) and clue_list().size() >= k

func next_letter() -> int:
	# the letter Gav should hand over now, or -1
	for k in range(Data.LETTERS.size()):
		if not mastered.has("lt:read:" + str(k)):
			return k if letter_available(k) else -1
	return -1

func check_letter_ready():
	if next_letter() >= 0: toast("Gav has a letter for you at the harbor!")

func letter_panel(k: int):
	play_sfx("page", -4.0)
	compact_buttons.call_deferred()
	var lt: Dictionary = Data.LETTERS[k]
	if not mastered.has("lt:read:" + str(k)):
		master("lt:read:" + str(k))
		log_event("letter_read", k)
	for w in lt["words"]: learn(w)
	clear_panel("Letter " + str(k + 1) + " of " + str(Data.LETTERS.size()))
	talk_partner = ""
	var t = text_line("No name on the envelope. The handwriting is very scratchy." + (" A small feather is stuck to the paper." if k >= 3 else ""), 16)
	t.add_theme_color_override("font_color", Color("6b4a2e"))
	if k > 0:
		var said = ""
		for m in mastered:
			if str(m).begins_with("lt:said:" + str(k - 1) + ":"): said = str(m).split(":")[3]
		if said != "":
			var y = text_line("You wrote: " + said, 16)
			y.add_theme_color_override("font_color", Color("6b4a2e"))
	varnak_banner(lt["v"], 22)
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = lt["en"], content)
	var after = func():
		if not lt["replies"].is_empty():
			if mastered.has("lt:reply:" + str(k)): text_line("You already answered this letter.", 16)
			else: button("Write back", reply_menu.bind(k), content)
		elif not completed.has("letters"):
			button("Who is it? Solve the mystery", solve_mystery, content)
		button("Letters", show_letters, content)
	ask(lt["q"], lt["opts"], 0, func(): master("lt:q:" + str(k)), "", "Read it again, slowly. Show meaning can help.", show_letters, after)

func reply_menu(k: int):
	compact_buttons.call_deferred()
	var lt: Dictionary = Data.LETTERS[k]
	clear_panel("Write back")
	text_line("What do you want to say? Then build it in Tujuju.", 17)
	for i in range(lt["replies"].size()):
		var r: Dictionary = lt["replies"][i]
		button(r["en"], reply_build.bind(k, i), content)
	button("Back", letter_panel.bind(k), content)

func reply_build(k: int, i: int):
	var r: Dictionary = Data.LETTERS[k]["replies"][i]
	dnd({"title": "Write back", "prompt": "Write in Tujuju:\n\"" + r["en"] + "\"", "answers": r["tiles"], "pool": r["decoys"], "tip": r["tip"], "key": "lt:b:" + str(k) + ":" + str(i),
		"back": show_letters, "on_right": func():
			if not mastered.has("lt:reply:" + str(k)):
				master("lt:said:" + str(k) + ":" + " ".join(r["tiles"]))
				master("lt:reply:" + str(k))
				gin += 1
				log_event("letter_reply", {"letter": k, "reply": " ".join(r["tiles"])})
				toast("You fold the letter and drop it in Gav's bag. +1 gin")
				save_game()
				if next_letter() >= 0: check_letter_ready()
				elif k + 1 < Data.LETTERS.size(): toast("The next letter will come when you know more. Listen in on villagers for clues.")})

func show_letters():
	compact_buttons.call_deferred()
	clear_panel("Mystery letters")
	if not mastered.has("lt:read:0"):
		text_line("No letters yet. " + ("Gav at the harbor has one for you!" if letter_available(0) else "Collect a few more words first."), 17)
	else:
		text_line("Someone keeps writing to you and signing “Ti-ni palar,” your friend. Who is it?", 17)
	for k in range(Data.LETTERS.size()):
		if mastered.has("lt:read:" + str(k)):
			var done = mastered.has("lt:reply:" + str(k)) or Data.LETTERS[k]["replies"].is_empty()
			button("Letter " + str(k + 1) + ("  [ok]" if done else "  (answer it)"), letter_panel.bind(k), content)
	var nl = next_letter()
	if nl >= 0: text_line("A new letter is waiting with Gav at the harbor.", 17)
	elif mastered.has("lt:read:0") and not mastered.has("lt:read:" + str(Data.LETTERS.size() - 1)):
		var lastk = 0
		for k in range(Data.LETTERS.size()):
			if mastered.has("lt:read:" + str(k)): lastk = k
		if mastered.has("lt:reply:" + str(lastk)): text_line("The next letter comes when you have found more clues. Listen in on villagers who are whispering.", 16)
	var cl = clue_list()
	text_line("Clues (" + str(cl.size()) + " of " + str(Data.LETTER_CLUES.size()) + ")", 21)
	if cl.is_empty(): text_line("None yet. Listen in when villagers whisper.", 16)
	for c in cl: text_line("• " + Data.LETTER_CLUES[c], 16)
	if completed.has("letters"): text_line("Solved: Ketu's parrot wrote them all. Kraa!", 17)
	elif mastered.has("lt:solved"): text_line("You worked it out. Go tell the parrot at the market!", 17)
	elif mastered.has("lt:read:" + str(Data.LETTERS.size() - 1)): button("Who is it? Solve the mystery", solve_mystery, content)
	button("Overheard conversations", show_overheard, content)
	button("Back", show_notebook, content)

func solve_mystery():
	compact_buttons.call_deferred()
	clear_panel("Who writes the letters?")
	text_line("Think about your clues:", 17)
	for c in clue_list(): text_line("• " + Data.LETTER_CLUES[c], 15)
	text_line("Who is “Ti-ni palar”?", 19)
	for s in Data.SUSPECTS:
		button(s[0] + " (" + s[1] + ")", solve_how.bind(s), content)
	button("Back", show_letters, content)

func solve_how(s: Array):
	compact_buttons.call_deferred()
	clear_panel("How do you know?")
	text_line("Say it in Tujuju. Which ending fits how you know?", 17)
	var base = s[0] + " ti-ni palar i-an-"
	for ev in [["da", "I saw it with my own eyes"], ["shi", "The clues show it"], ["nu", "Somebody told me"]]:
		button(base + ev[0] + ".  (" + ev[1] + ")", solve_check.bind(s[0], ev[0]), content)
	button("Back", solve_mystery, content)

func solve_check(who: String, ev: String):
	log_event("mystery_guess", {"who": who, "ending": ev}, who == "Par" and ev == "shi")
	if who != "Par":
		var why = {"Gav": "Gav only carries the letters. He was as puzzled as anyone when Ena asked.", "Poltergais": "Ila says the poltergeist never says “kraa.”", "Oku": "Oku talks to stones and trinkets, not paper. And nobody has seen a feather at the ruins."}.get(who, "")
		message("Hmm, not quite", why + " Look at your clues again: feathers, kraa, and someone who goes out at night.")
		button("Try again", solve_mystery, content)
		return
	if ev == "da":
		message("Right suspect, wrong ending", "You never saw the parrot write anything! You worked it out from clues, so use the inferred ending, -shi.")
		button("Try again", solve_how.bind(Data.SUSPECTS[0]), content)
		return
	if ev == "nu":
		message("Right suspect, wrong ending", "Nobody told you this. You figured it out yourself from clues, so use -shi: apparently.")
		button("Try again", solve_how.bind(Data.SUSPECTS[0]), content)
		return
	master("lt:solved")
	learn("par-yir")
	message("Par ti-ni palar i-an-shi!", "Apparently the parrot is your secret friend! Feathers, paper, “kraa” and nights away from the market. Go to Ketu's market and show the parrot one of its letters.")

func parrot_reveal():
	complete("letters")
	gin += 5
	inventory.append("feather")
	log_event("mystery_solved", "par")
	clear_panel("Par: your secret friend")
	text_line("You hold up a letter. The parrot freezes. Then it puffs up every feather it has.", 17)
	varnak_banner("Kraa! Ti-ni palar! Ti-ni palar! ...Hiri!", 24)
	text_line("(Your friend! Your friend! ...Gotcha!)", 16)
	text_line("The parrot pulls a huge red feather from under its wing and drops it in your hand: a par-yir, a bird's clothes. Then it says, very clearly, “K-ta-har-da.” Thank you. Kraa. (+5 gin)", 17)
	button("Return", close_panel, content)

# ---- Teach Neri: spot and fix the mistake ----

func common_prefix(a: String, b: String) -> int:
	var x = a.to_lower()
	var y = b.to_lower()
	var n = 0
	while n < mini(x.length(), y.length()) and x[n] == y[n]: n += 1
	return n

func neri_mistake(tp: Dictionary) -> Dictionary:
	var tiles: Array = tp["tiles"]
	var cands: Array = []
	for d in tp["decoys"]:
		var best = -1
		var bl = 1
		for i in range(tiles.size()):
			var cp = common_prefix(d, tiles[i])
			if cp > bl and d != tiles[i]:
				bl = cp
				best = i
		if best >= 0 and not tiles.has(d): cands.append({"slot": best, "wrong": d})
	for i in range(tiles.size()):
		var ad = auto_decoys([tiles[i]], 1)
		if not ad.is_empty() and not tiles.has(ad[0]): cands.append({"slot": i, "wrong": ad[0]})
	if tiles.size() >= 3:
		cands.append({"slot": tiles.size() - 1, "swap": true})
	if cands.is_empty(): return {}
	return cands[randi() % cands.size()]

func teach_neri(back: Callable = Callable()):
	if not back.is_valid(): back = show_games
	var tries = 0
	var i = pick_tile_index()
	var m = neri_mistake(Data.TILES[i])
	while m.is_empty() and tries < 10:
		i = pick_tile_index()
		m = neri_mistake(Data.TILES[i])
		tries += 1
	var tp: Dictionary = Data.TILES[i]
	var tiles: Array = tp["tiles"]
	var said: Array = tiles.duplicate()
	if m.get("swap", false):
		var v = said.pop_back()
		said.insert(said.size() - 1, v)
	else:
		said[m["slot"]] = m["wrong"]
	compact_buttons.call_deferred()
	clear_panel("Teach Neri")
	talk_partner = "neri"
	learn("senar")
	text_line("Neri is practicing Tujuju and wants to say:\n\"" + tp["en"] + "\"", 18)
	text_line("Neri says:", 17)
	varnak_banner(" ".join(said), 24)
	var fb = text_line("Tap the word Neri got wrong.", 17)
	var grid = HFlowContainer.new()
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)
	var bad_idx: Array = []
	if m.get("swap", false): bad_idx = [said.size() - 2, said.size() - 1]
	else: bad_idx = [m["slot"]]
	for k in range(said.size()):
		var b = button(said[k], func():
			if bad_idx.has(k):
				log_event("answer", {"activity": "Teach Neri: spot", "item": " ".join(said), "chose": said[k], "correct": said[bad_idx[0]]}, true)
				teach_fix(i, said, m, back)
			else:
				log_event("answer", {"activity": "Teach Neri: spot", "item": " ".join(said), "chose": said[k], "correct": said[bad_idx[0]]}, false)
				fb.text = "That one is fine. Look at the endings, or where the verb is."
				fb.add_theme_color_override("font_color", Color("8a2f1f")), grid)
		b.custom_minimum_size.x = 90
	button("Skip", teach_neri.bind(back), content)
	button("Back", back, content)

func teach_fix(i: int, said: Array, m: Dictionary, back: Callable):
	var tp: Dictionary = Data.TILES[i]
	var good = " ".join(tp["tiles"])
	clear_panel("Teach Neri")
	var first = not mastered.has("tn:" + str(i))
	var done = func():
		if first:
			gin += 1
			toast("Neri: K-ta-har-da, senar! (Thank you, teacher!) +1 gin")
			save_game()
		master("tn:" + str(i))
	if m.get("swap", false):
		text_line("Yes! Neri: “" + " ".join(said) + "”", 17)
		var opts: Array = [good, " ".join(said)]
		var alt: Array = tp["tiles"].duplicate()
		var f = alt.pop_front()
		alt.append(f)
		if not opts.has(" ".join(alt)): opts.append(" ".join(alt))
		ask("Which order is right?", opts, 0, done, "In Tujuju the verb comes last.", "Think about where the verb goes.", back, func():
			button("Another one", teach_neri.bind(back), content))
		return
	var wrong: String = m["wrong"]
	var right: String = tp["tiles"][m["slot"]]
	text_line("Yes! Neri said “" + wrong + "”. What should it be?", 17)
	var opts: Array = [right]
	for d in auto_decoys([right], 2):
		if d != wrong and not opts.has(d): opts.append(d)
	if opts.size() < 3:
		for d in tp["decoys"]:
			if d != wrong and not opts.has(d) and opts.size() < 3: opts.append(d)
	if opts.size() < 2: opts.append(wrong)
	ask("Fix it:", opts, 0, done, good + "  " + tp["tip"], "Not quite. " + tp["tip"], back, func():
		button("Another one", teach_neri.bind(back), content))


# ---- talk view: frame the villager's face above the menu ----

var talk_cam: Camera3D
var talk_view_id: String = ""
var talk_dir: Dictionary = {}
var portrait_frame: Control
var dnd_on: bool = false
const TALK_TOP = 0.47

func talk_view_target() -> String:
	if not panel.visible or dnd_on or riding: return ""
	var id = portrait_id if portrait_id != "" else talk_partner
	if id == "": return ""
	var e = entity_by_id(id)
	if e.is_empty() or e["kind"] != "npc" or not (e["node"] as Node3D).visible: return ""
	return id

func set_talk_layout(on: bool):
	if on:
		panel.anchor_top = TALK_TOP
		panel.offset_top = 0
		close_x.anchor_top = TALK_TOP
		close_x.anchor_bottom = TALK_TOP
		close_x.offset_top = 6
		close_x.offset_bottom = 58
		talk_cam.current = true
	else:
		panel.anchor_top = 0.0
		panel.offset_top = 226
		close_x.anchor_top = 0.0
		close_x.anchor_bottom = 0.0
		close_x.offset_top = 232
		close_x.offset_bottom = 284
		camera.current = true
	if is_instance_valid(portrait_frame): portrait_frame.visible = not on

func talk_cam_pose(id: String) -> Array:
	var e = entity_by_id(id)
	var node = e["node"] as Node3D
	var head = (node.get_meta("head") as Node3D).global_position
	var d = player.global_position - node.global_position
	d.y = 0.0
	if d.length() < 0.1: d = Vector3(sin(node.rotation.y), 0, cos(node.rotation.y))
	d = d.normalized()
	var hs = float(node.get_meta("h", 1.0)) if node.has_meta("h") else 1.0
	var dist = 3.3 * clampf(hs, 0.75, 1.2)
	if talk_dir.has(id): d = talk_dir[id]
	else:
		var space = get_world_3d().direct_space_state
		var best = d
		for ang in [0.0, 40.0, -40.0, 80.0, -80.0, 125.0, -125.0, 180.0]:
			var dd = d.rotated(Vector3.UP, deg_to_rad(ang))
			var q = PhysicsRayQueryParameters3D.create(head + dd * 0.45, head + dd * (dist + 0.4) + Vector3(0, 0.1, 0))
			q.exclude = [player.get_rid()]
			if space.intersect_ray(q).is_empty() and T.height(head.x + dd.x * dist, head.z + dd.z * dist) < head.y - 0.6:
				best = dd
				break
		d = best
		talk_dir[id] = d
	var side = d.cross(Vector3.UP).normalized()
	var pos = head + d * dist + side * 0.35 + Vector3(0, 0.1, 0)
	# the band between the top buttons and the menu is centered above the screen middle
	var vp = get_viewport().get_visible_rect().size
	var band_mid = (175.0 + vp.y * TALK_TOP) * 0.5
	var frac = (vp.y * 0.5 - band_mid) / (vp.y * 0.5)
	var k = dist * frac * tan(deg_to_rad(talk_cam.fov * 0.5))
	var look = head + Vector3(0, 0.12 - 0.25 * hs, 0) - Vector3(0, k, 0)
	return [pos, look]

func update_talk_view(delta: float):
	if talk_cam == null: return
	var id = talk_view_target()
	if id != talk_view_id:
		var was = talk_view_id
		talk_view_id = id
		if (was == "") != (id == ""): set_talk_layout(id != "")
		talk_dir.clear()
		if id != "":
			var pose = talk_cam_pose(id)
			talk_cam.global_position = pose[0]
			talk_cam.look_at(pose[1], Vector3.UP)
		return
	if id == "": return
	var p = talk_cam_pose(id)
	talk_cam.global_position = talk_cam.global_position.lerp(p[0], minf(delta * 4.0, 1.0))
	talk_cam.look_at(p[1], Vector3.UP)

# ------------------------------------------------------------ tenth expansion: asking and telling (new grammar)

func ask_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel("Ask " + id.capitalize())
	add_portrait(id)
	text_line("What do you want to ask or tell " + id.capitalize() + "?", 17)
	button("Can you...? (-kan)", can_menu.bind(id), content)
	button("What do you want? (-vai)", want_ask.bind(id), content)
	button("Where is...? (hama)", where_menu.bind(id), content)
	button("Ask them to do something (-o)", command_menu.bind(id), content)
	if npc_following(id): button("Go home (Ti-ni dom-ru ta-lum-o-ye)", send_home.bind(id), content)
	button("Back", chat_menu.bind(id), content)

func three_forms(right: String, wrongs: Array) -> Array:
	var out: Array = [right]
	for w in wrongs:
		if not out.has(w): out.append(w)
	return out

# ---- Can you...? ----

func can_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel("Ask " + id.capitalize() + ": Can you...?")
	add_portrait(id)
	learn("-kan")
	text_line("-kan means can. It goes right after the verb root: ta-sum-kan-ha? Can you swim?", 16)
	for v in Data.KAN.keys():
		var asked = mastered.has("kan:" + v + ":" + id)
		button(Data.KAN[v][0].capitalize() + ("  [asked]" if asked else ""), can_say.bind(id, v), content)
	button("My survey sheet", show_survey, content)
	button("Back", ask_menu.bind(id), content)

func can_say(id: String, v: String):
	learn(v)
	learn("-ha")
	clear_panel("Ask " + id.capitalize())
	add_portrait(id)
	talk_partner = id
	var en: String = Data.KAN[v][0]
	var right = "Ti ta-" + v + "-kan-ha?"
	var opts = three_forms(right, ["Ti na-" + v + "-kan-ha?", "Ti ta-" + v + "-kan-da.", "Ti ta-kan-" + v + "-ha?"])
	opts = opts.slice(0, 3 if level() < 3 else 4)
	ask("How do you ask: \"Can you " + en + "?\"", opts, 0, func(): can_answer.call_deferred(id, v),
		"", "Look at the person prefix (ta- you), where -kan goes (right after the root) and the ending (-ha asks).", can_menu.bind(id))

func can_answer(id: String, v: String):
	var yes: bool = Data.KAN[v][1].has(id)
	if v == "sul": yes = true
	var said = "Ti ta-" + v + "-kan-ha?"
	var said_en = "Can you " + Data.KAN[v][0] + "?"
	var line: Array
	if Data.KAN_LINES.has(id + ":" + v): line = Data.KAN_LINES[id + ":" + v]
	elif v == "fei":
		var f = Data.FEI_NO[randi() % Data.FEI_NO.size()]
		line = [f[0], f[1], "laugh"]
	elif yes: line = ["Ho! Na-" + v + "-kan-da!", "Yes! I can " + Data.KAN[v][0] + "!", "proud" if Data.PEOPLE[id]["trait"] == "proud" else "happy"]
	else: line = ["Maki. Ma-na-" + v + "-kan-ki-da.", "No. I can't " + Data.KAN[v][0] + ".", "sad" if Data.PEOPLE[id]["trait"] != "grumpy" else "angry"]
	var first = not mastered.has("kan:" + v + ":" + id)
	master("kan:" + v + ":" + id)
	if yes: master("kanyes:" + v + ":" + id)
	log_event("can_ask", {"npc": id, "verb": v, "yes": yes})
	react(id, said, said_en, line[0], line[1], line[2], 1 if first else 0)
	button("Ask something else", can_menu.bind(id), content)
	buttons_to_end(["Keep chatting", "Return"])
	check_survey()

func survey_found(v: String) -> Array:
	var who: Array = []
	for m in mastered:
		var ms = str(m)
		if ms.begins_with("kanyes:" + v + ":"): who.append(ms.split(":")[2])
	return who

func check_survey():
	if completed.has("survey"): return
	for v in Data.KAN.keys():
		if v == "fei": continue
		if survey_found(v).is_empty(): return
	complete("survey")
	gin += 3
	toast("Survey complete! You found someone for every row. +3 gin")

func show_survey():
	compact_buttons.call_deferred()
	clear_panel("Find someone who can...")
	text_line("Ask people “Ti ta-___-kan-ha?” (Can you ___?) and fill in the sheet. Chat, then Ask.", 16)
	for v in Data.KAN.keys():
		var who = survey_found(v)
		var asked: Array = []
		for m in mastered:
			var ms = str(m)
			if ms.begins_with("kan:" + v + ":"): asked.append(ms.split(":")[2])
		var row = Data.KAN[v][0] + " (ta-" + v + "-kan-ha?):  "
		if not who.is_empty(): row += ", ".join(who.map(func(x): return str(x).capitalize())) + "  [ok]"
		elif v == "fei" and asked.size() >= 3: row += "nobody yet... maybe ask someone with feathers?"
		else: row += "?" + ("  (asked " + str(asked.size()) + ")" if not asked.is_empty() else "")
		var l = text_line(row, 17)
		if not who.is_empty(): l.add_theme_color_override("font_color", Color("2f6b2f"))
	button("Back", show_notebook, content)

# ---- What do you want? ----

func want_ask(id: String):
	learn("-vai")
	clear_panel("Ask " + id.capitalize())
	add_portrait(id)
	talk_partner = id
	var right = "Ti han t-i-nuk-vai-ha?"
	ask("How do you ask: \"What do you want (to have)?\"", three_forms(right, ["Ti han k-i-nuk-vai-ha?", "Ti han t-i-nuk-vai-da.", "Ti hal t-i-nuk-vai-ha?"]).slice(0, 3 if level() < 3 else 4), 0,
		func(): want_answer.call_deferred(id), "", "t-i- means you (do it to) it. han is what; hal is who. -ha asks.", ask_menu.bind(id))

func want_answer(id: String):
	var pp: Dictionary = Data.PEOPLE[id]
	var tt: String = pp["trait"]
	var likes: Array = pp["likes"]
	var said = "Ti han t-i-nuk-vai-ha?"
	var said_en = "What do you want?"
	log_event("want_ask", id)
	if randf() < 0.3 or likes.is_empty():
		var odd = {"sleepy": ["Na-sul-vai-da... zzz", "I want to sleep... zzz", "sleepy"], "grumpy": ["Sela na-an-vai-da!", "I want to be alone!", "angry"],
			"giggly": ["Anke ti k-ta-hiri-vai-da! Ha!", "I want to prank you! Ha!", "laugh"], "dramatic": ["Na-fei-vai-da! ...Dan ma-na-fei-kan-ki-da.", "I want to fly! ...But I can't fly.", "sad"],
			"proud": ["Na-u-gao-vai-da!", "I want to be taller! (u- more, gao tall)", "proud"], "cheerful": ["Fiyesta! Na-kachaka-vai-da!", "A party! I want to dance!", "happy"]}
		var o: Array = odd.get(tt, odd["cheerful"])
		react(id, said, said_en, o[0], o[1], o[2], 1 if not mastered.has("want:" + id) else 0)
	else:
		var g: String = likes[randi() % likes.size()]
		learn(g)
		react(id, said, said_en, "Anke " + g + " k-i-nuk-vai-da!", "I want " + Data.GIFT_WORDS[g] + "!", "love", 1 if not mastered.has("want:" + id) else 0)
		var have = {"tari": fish_caught > 0, "panak": inventory.has("bread"), "cha": inventory.has("tea"), "gin": gin > 0, "bombom": inventory.has("candy"), "ret-gor": inventory.has("hotdog")}
		if have.get(g, false): button("Give it: Ki " + g + " ti-ru!", give_gift.bind(id, g), content)
		else: text_line("You don't have any " + g + " right now. Ketu sells most things at the market.", 16)
		buttons_to_end(["Keep chatting", "Return"])
	master("want:" + id)

# ---- Where is...? ----

func where_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel("Ask " + id.capitalize() + ": Where is...?")
	add_portrait(id)
	learn("hama")
	text_line("Ask about a person or a place. The answer uses bei north, nam south, dong east, sai west.", 16)
	for p in ["neri", "ketu", "suri", "pomo", "vira", "yalo", "desh", "oku", "gav", "tamu", "tor", "mira", "oren", "lira"]:
		if p != id: button(p.capitalize(), where_say.bind(id, p), content)
	for w in Data.WHERE_PLACES.keys():
		button(w + " (" + Data.WHERE_PLACES[w][0] + ")", where_say.bind(id, w), content)
	button("Back", ask_menu.bind(id), content)

func where_target_pos(t: String) -> Vector3:
	if Data.WHERE_PLACES.has(t): return Data.WHERE_PLACES[t][1]
	var e = entity_by_id(t)
	return (e["node"] as Node3D).position if not e.is_empty() else Vector3.ZERO

func where_say(id: String, t: String):
	clear_panel("Ask " + id.capitalize())
	add_portrait(id)
	talk_partner = id
	var nm = t if Data.WHERE_PLACES.has(t) else t.capitalize()
	var en = Data.WHERE_PLACES[t][0] if Data.WHERE_PLACES.has(t) else t.capitalize()
	var right = nm.capitalize() + " hama i-esh-ha?"
	ask("How do you ask: \"Where is " + en + "?\"", three_forms(right, [nm.capitalize() + "-ma hama i-esh-ha?", nm.capitalize() + " hama i-esh-da.", nm.capitalize() + " hal i-esh-ha?"]).slice(0, 3 if level() < 3 else 4), 0,
		func(): where_answer.call_deferred(id, t), "", "hama is where; the thing you ask about takes no ending; -ha asks.", where_menu.bind(id))

func where_answer(id: String, t: String):
	var me = (entity_by_id(id)["node"] as Node3D).position
	var tp = where_target_pos(t)
	var d = tp - me
	var nm = t if Data.WHERE_PLACES.has(t) else t.capitalize()
	var en = Data.WHERE_PLACES[t][0] if Data.WHERE_PLACES.has(t) else t.capitalize()
	var said = nm.capitalize() + " hama i-esh-ha?"
	var reply = ""
	var reply_en = ""
	var dir = ""
	var person = not Data.WHERE_PLACES.has(t)
	var ev = "da"
	if person and d.length() > 40.0: ev = "nu"
	if person and npc_following(t) :
		reply = nm + " ti-su i-esh-da! Ha!"
		reply_en = nm + " is with you! Ha!"
		dir = "with you"
	elif Vector2(d.x, d.z).length() < 12.0:
		reply = nm.capitalize() + " anni dalma i-esh-da!"
		reply_en = en.capitalize() + " is right next to me! (I can see it.)"
		dir = "next to them"
	else:
		dir = ("dong" if d.x > 0 else "sai") if absf(d.x) > absf(d.z) else ("bei" if d.z < 0 else "nam")
		learn(dir)
		reply = nm.capitalize() + " " + dir + "-ma i-esh-" + ev + "."
		reply_en = en.capitalize() + " is in the " + Data.DIRS[dir] + (". I can see it." if ev == "da" else ". That's what people say.")
	log_event("where_ask", {"npc": id, "target": t, "answer": dir})
	react(id, said, "Where is " + en + "?", reply, "(Tap Show meaning below if you need it.)", "happy", 1 if not mastered.has("hama:" + t) else 0)
	var opts: Array = ["north", "south", "east", "west", "next to them"]
	var correct = Data.DIRS.get(dir, dir)
	if dir == "with you": opts = ["with you", "north", "south"]
	var mean = text_line("", 16)
	button("Show meaning", func(): mean.text = reply_en, content)
	var ord: Array = [correct]
	for o in opts:
		if o != correct: ord.append(o)
	ask("So where is " + en + "?", ord, 0, func():
		master("hama:" + t)
		save_game(), reply_en, "Listen again: bei-ma north, nam-ma south, dong-ma east, sai-ma west, and dal-ma at the side.", where_menu.bind(id),
		func():
			button("Ask about somewhere else", where_menu.bind(id), content)
			buttons_to_end(["Keep chatting", "Return"]))
	buttons_to_end(["Keep chatting", "Return"])

# ---- Commands: ask them to do something ----

var acts: Dictionary = {}

func npc_following(id: String) -> bool:
	return acts.has(id) and acts[id].get("kind", "") == "follow"

func command_menu(id: String):
	compact_buttons.call_deferred()
	talk_partner = id
	clear_panel("Ask " + id.capitalize() + " to do something")
	add_portrait(id)
	text_line("Commands end in -o. Add -ye to be polite. Some people only listen when you're polite!", 16)
	for v in Data.COMMANDS.keys():
		button(Data.COMMANDS[v][0], command_say.bind(id, v), content)
	if level() >= 2: button("Jump and then sing! (-ka)", command_say.bind(id, "pul+ning"), content)
	button("Come with me!", command_say.bind(id, "kar"), content)
	button("Back", ask_menu.bind(id), content)

func command_forms(v: String) -> Dictionary:
	# meaning key -> Tujuju. The player picks one; the villager reacts to what was actually said.
	if v == "kar":
		return {"plain": "Ansu ta-kar-o!", "polite": "Ansu ta-kar-o-ye!", "statement": "Ansu ta-kar-da.", "me": "Ansu na-kar-o!", "dont": "Ansu ma-ta-kar-o-ki!"}
	if v == "pul+ning":
		return {"plain": "Ta-pul-o-ka ta-ning-o!", "polite": "Ta-pul-o-ka ta-ning-o-ye!", "statement": "Ta-pul-ka ta-ning-da.", "me": "Na-pul-o-ka na-ning-o!", "dont": "Ma-ta-pul-o-ki!"}
	return {"plain": "Ta-" + v + "-o!", "polite": "Ta-" + v + "-o-ye!", "statement": "Ta-" + v + "-da.", "me": "Na-" + v + "-o!", "dont": "Ma-ta-" + v + "-o-ki!"}

func command_say(id: String, v: String):
	compact_buttons.call_deferred()
	clear_panel("Tell " + id.capitalize())
	add_portrait(id)
	talk_partner = id
	var en = "Come with me!" if v == "kar" else ("Jump and then sing!" if v == "pul+ning" else Data.COMMANDS[v][0])
	text_line("You want to say: \"" + en + "\" Choose what you say. " + id.capitalize() + " will react to whatever you actually say!", 17)
	var f = command_forms(v)
	var keys: Array = ["plain", "polite", "statement", "me"]
	if level() >= 2: keys.append("dont")
	keys.shuffle()
	for k in keys:
		button(f[k], command_do.bind(id, v, k), content)
	button("Back", command_menu.bind(id), content)

func command_do(id: String, v: String, k: String):
	var f = command_forms(v)
	var said: String = f[k]
	var pp: Dictionary = Data.PEOPLE[id]
	var tt: String = pp["trait"]
	var fr: int = int(friend.get(id, 0))
	var md: int = int(mood.get(id, 0))
	var ok_meaning = k == "plain" or k == "polite"
	log_event("answer", {"activity": "Commands", "item": "Tell " + id + ": " + v, "chose": said, "correct": f["polite"]}, ok_meaning)
	var en = "Come with me!" if v == "kar" else ("Jump and then sing!" if v == "pul+ning" else Data.COMMANDS[v][0])
	match k:
		"statement":
			react(id, said, "(You told them they " + en.to_lower().trim_suffix("!") + ", like a fact.)", "Han? Maki, ma-na-" + v.split("+")[0] + "-im-ki-da.", "What? No, I'm not doing that. (-da describes; a command needs -o.)", "confused", 0)
		"me":
			react(id, said, "(na- means I: you just told yourself to do it!)", "Ha! Ho, ti! Ta-" + v.split("+")[0] + "-o!", "Ha! Yes, YOU! You do it! (na- is I; ta- is you.)", "laugh", 0)
			emote_player_hint()
		"dont":
			react(id, said, "(Don't!)", "...Ho. Ma-na-" + v.split("+")[0] + "-im-ki-da.", "...OK. I'm not doing it. (ma- ... -ki means don't.)", "confused", 0)
		_:
			var polite = k == "polite"
			var refuse = false
			if md < 0: refuse = true
			elif not polite and (tt == "grumpy" or tt == "proud") and fr < 6: refuse = true
			if v == "kar" and npc_following(id): refuse = false
			if refuse:
				add_friend(id, 0)
				react(id, said, en, "Maki!" + (" ...-ye?" if not polite else ""), ("No! (" + id.capitalize() + " wants you to be polite: add -ye.)" if not polite else "No! (" + id.capitalize() + " is still upset with you. Try a gift or a compliment.)"), "angry", 0)
				button("Try again politely", command_say.bind(id, v), content)
				buttons_to_end(["Keep chatting", "Return"])
				return
			var first = not mastered.has("cmd:" + v)
			master("cmd:" + v)
			if v == "kar":
				start_follow(id)
				react(id, said, en, "Ho! Ansu... ti-su na-kar-fu-da!", "OK! With you... I'll come with you! (" + id.capitalize() + " follows you around. Ask them to go home any time.)", "happy", 1 if polite else 0)
				return
			var parts: Array = v.split("+")
			var acts_list: Array = []
			for p in parts: acts_list.append(Data.COMMANDS[p][1])
			npc_act(id, acts_list)
			var reply = {"sing": "La la... Ning-ning!", "dance": "Kachaka! Kachaka!", "jump": "Hop! Hop!", "sit": "Uf.", "run": "Pav-pav-pav!", "sleep": "Kororo... zzz", "look": "Hama...? Han...?"}
			var r = ""
			for a in acts_list: r += reply.get(a, "Ho!") + " "
			var kind = {"sing": "happy", "dance": "laugh", "jump": "happy", "sit": "happy", "run": "laugh", "sleep": "sleepy", "look": "confused"}.get(acts_list[-1], "happy")
			if tt == "proud" and polite: kind = "proud"
			react(id, said, en, r.strip_edges(), id.capitalize() + " does it!" + (" Being polite (-ye) made " + id.capitalize() + " happy." if polite else ""), kind, (1 if polite else 0) + (1 if first else 0))
			button("Ask them to do something else", command_menu.bind(id), content)
			buttons_to_end(["Keep chatting", "Return"])

func emote_player_hint():
	toast("na- is I, ta- is you. Try again!")

func npc_act(id: String, list: Array):
	var e = entity_by_id(id)
	if e.is_empty(): return
	var node = e["node"] as Node3D
	acts[id] = {"kind": "seq", "list": list, "i": 0, "t0": clock, "base": node.position, "yaw": node.rotation.y}

func start_follow(id: String):
	acts[id] = {"kind": "follow", "t0": clock}
	toast(id.capitalize() + " is following you. Ansu! (with me)")

func send_home(id: String):
	acts[id] = {"kind": "home"}
	react(id, "Ti-ni dom-ru ta-lum-o-ye.", "Please go home.", "Ho! Chau!", "OK! Bye!", "happy", 0)

func update_acts(delta: float):
	for id in acts.keys():
		var a: Dictionary = acts[id]
		var e = entity_by_id(id)
		if e.is_empty():
			acts.erase(id)
			continue
		var node = e["node"] as Node3D
		var home: Vector3 = e["home"]
		match a["kind"]:
			"follow":
				var to = player.position - node.position
				to.y = 0.0
				if clock - float(a["t0"]) > 180.0 or to.length() > 70.0:
					a["kind"] = "home"
					continue
				if to.length() > 2.4:
					var step = to.normalized() * minf(5.5 * delta, to.length() - 2.4)
					node.position += step
					node.rotation.y = atan2(to.x, to.z)
				node.position.y = gy(node.position.x, node.position.z)
			"watch":
				var tp: Vector3 = a["pos"]
				var to = tp - node.position
				to.y = 0.0
				if clock > float(a["until"]):
					if a.get("tele", false):
						node.position = home
						acts.erase(id)
					else: a["kind"] = "home"
					continue
				if to.length() > 0.15:
					var step = to.normalized() * minf(6.0 * delta, to.length())
					node.position += step
					node.position.y = gy(node.position.x, node.position.z)
					node.rotation.y = atan2(to.x, to.z)
				else:
					var f: Vector3 = a["face"]
					node.rotation.y = lerp_angle(node.rotation.y, atan2(f.x - node.position.x, f.z - node.position.z), minf(delta * 5.0, 1.0))
			"home":
				var to = home - node.position
				to.y = 0.0
				if to.length() < 0.2 or to.length() > 120.0:
					node.position = home
					acts.erase(id)
					continue
				var step = to.normalized() * minf(4.0 * delta, to.length())
				node.position += step
				node.position.y = gy(node.position.x, node.position.z)
				node.rotation.y = atan2(to.x, to.z)
			"seq":
				var list: Array = a["list"]
				var t = clock - float(a["t0"])
				var dur = 3.2
				var i = int(t / dur)
				if i >= list.size():
					node.position = home if a.get("teleport", false) else a["base"]
					(node.get_meta("body") as Node3D).position = Vector3.ZERO
					for arm in node.get_meta("arms"): (arm as Node3D).rotation.z = 0.0
					(node.get_meta("head") as Node3D).rotation.y = 0.0
					acts.erase(id)
					continue
				var u = fmod(t, dur)
				var base: Vector3 = a["base"]
				var arms: Array = node.get_meta("arms")
				var body = node.get_meta("body") as Node3D
				body.position = Vector3.ZERO
				node.position = base
				for arm in arms: (arm as Node3D).rotation.z = 0.0
				(node.get_meta("head") as Node3D).rotation.y = 0.0
				match list[i]:
					"jump":
						node.position.y = base.y + absf(sin(u * 5.0)) * 0.6
						(arms[0] as Node3D).rotation.z = -2.4
						(arms[1] as Node3D).rotation.z = 2.4
					"dance":
						node.rotation.y += delta * 6.0
						(arms[0] as Node3D).rotation.z = -1.8 + sin(u * 9.0) * 0.6
						(arms[1] as Node3D).rotation.z = 1.8 + sin(u * 9.0 + 1.0) * 0.6
						node.position.y = base.y + absf(sin(u * 9.0)) * 0.12
					"sing":
						(arms[0] as Node3D).rotation.z = -1.1
						(arms[1] as Node3D).rotation.z = 1.1
						e["say"] = ["La la la... Ning!", clock + 0.5]
					"sit":
						body.position.y = -0.35
						(arms[0] as Node3D).rotation.x = -0.6
						(arms[1] as Node3D).rotation.x = -0.6
					"run":
						var ang = u / dur * TAU
						node.position = base + Vector3(sin(ang) * 1.4, 0, cos(ang) * 1.4 - 1.4)
						node.position.y = gy(node.position.x, node.position.z)
						node.rotation.y = ang + PI * 0.5
						(arms[0] as Node3D).rotation.x = sin(clock * 14.0) * 0.9
						(arms[1] as Node3D).rotation.x = -sin(clock * 14.0) * 0.9
					"swim":
						node.position.y = base.y + sin(clock * 3.0) * 0.06
						node.rotation.y += delta * 0.8
						(arms[0] as Node3D).rotation.x = sin(clock * 6.0) * 1.6
						(arms[1] as Node3D).rotation.x = -sin(clock * 6.0) * 1.6
					"sleep":
						(node.get_meta("head") as Node3D).rotation.z = 0.5
						e["say"] = ["Kororo... zzz", clock + 0.5]
					"look":
						(node.get_meta("head") as Node3D).rotation.y = sin(u * 3.0) * 1.0


func buttons_to_end(labels: Array):
	for c in content.get_children():
		if c is Button and labels.has((c as Button).text) and not c.is_queued_for_deletion(): content.move_child(c, -1)

# ------------------------------------------------------------ eleventh expansion: word wand, pass it on, guess who

# ---- the word wand: sentences come true ----

var wand: Dictionary = {"who": "Tor", "where": "kurma", "pre": "i", "neg": false, "verb": "kachaka", "tense": "im", "ev": "da"}
var wand_pending: Array = []
var sea_spot: Vector3 = Vector3.INF

func find_sea() -> Vector3:
	if sea_spot != Vector3.INF: return sea_spot
	for r in range(30, 80):
		var p = Vector3(2.0, 0, float(r))
		if T.height(p.x, p.z) < -0.6:
			sea_spot = Vector3(p.x, -0.25, p.z)
			return sea_spot
	sea_spot = Vector3(2, -0.25, 50)
	return sea_spot

func wand_place_pos(w: String) -> Vector3:
	if w == "haima": return find_sea()
	var p: Vector3 = Data.WAND_PLACES[w][1]
	return Vector3(p.x, gy(p.x, p.z), p.z)

func wand_sentence() -> String:
	var v = ("ma-" if wand["neg"] else "") + str(wand["pre"]) + "-" + str(wand["verb"]) + "-" + str(wand["tense"]) + ("-ki" if wand["neg"] else "") + "-" + str(wand["ev"])
	return str(wand["who"]) + " " + str(wand["where"]) + " " + v + "."

func wand_english() -> String:
	var who: String = Data.WAND_WHO[wand["who"]][0]
	var vb: Array = Data.WAND_VERBS[wand["verb"]]
	var pl: String = Data.WAND_PLACES[wand["where"]][0]
	var be = "am" if who == "I" else ("are" if who == "everyone" else "is")
	var t = ""
	match str(wand["tense"]):
		"im": t = (be + (" not " if wand["neg"] else " ") + vb[1])
		"fu": t = "will " + ("not " if wand["neg"] else "") + vb[0]
		"pa": t = ("did not " + vb[0]) if wand["neg"] else vb[2]
	var ev = {"da": " (I see it)", "shi": " (apparently)", "nu": " (people say)"}[wand["ev"]]
	return who.capitalize() + " " + t + " " + pl + ev

func wand_panel():
	compact_buttons.call_deferred()
	clear_panel("The word wand: gao-murak")
	talk_partner = ""
	learn("gao-murak")
	text_line("Build a sentence and wave the wand. Whatever you say comes true... exactly as you say it. Tap a piece to change it.", 16)
	varnak_banner(wand_sentence(), 22)
	var en = text_line("(" + wand_english() + ")", 15)
	en.add_theme_color_override("font_color", Color("6b4a2e"))
	var rows = [["Who", "who", Data.WAND_WHO.keys()], ["Where", "where", Data.WAND_PLACES.keys()], ["Person prefix", "pre", ["na", "ta", "i", "ri"]],
		["Action", "verb", Data.WAND_VERBS.keys()], ["When", "tense", Data.WAND_TENSE.keys()], ["How you know", "ev", Data.WAND_EV.keys()]]
	for r in rows:
		var key: String = r[1]
		var opts: Array = r[2]
		var cur = str(wand[key])
		var label = cur + "-" if key == "pre" else ("-" + cur if key in ["tense", "ev"] else cur)
		var extra = ""
		match key:
			"who": extra = Data.WAND_WHO[cur][0]
			"where": extra = Data.WAND_PLACES[cur][0]
			"verb": extra = Data.WAND_VERBS[cur][0]
			"tense": extra = Data.WAND_TENSE[cur]
			"ev": extra = Data.WAND_EV[cur]
			"pre": extra = {"na": "I", "ta": "you", "i": "he, she, it", "ri": "they"}[cur]
		button(r[0] + ":  " + label + "  (" + extra + ")", func():
			var i = opts.find(wand[key])
			wand[key] = opts[(i + 1) % opts.size()]
			wand_panel(), content)
	button(("Not: ma- ... -ki  (on)" if wand["neg"] else "Not: ma- ... -ki  (off)"), func():
		wand["neg"] = not wand["neg"]
		wand_panel(), content)
	button("Wave the wand!", wand_cast, content)
	button("Return", close_panel, content)

func wand_people(who: String) -> Array:
	if who == "Polu":
		var out: Array = []
		for e in entities:
			if e["kind"] == "npc" and Data.PEOPLE.has(e["id"]) and (e["node"] as Node3D).visible: out.append(e["id"])
		return out
	return [who.to_lower()]

func wand_cast():
	var s = wand_sentence()
	var who: String = wand["who"]
	var need: String = Data.WAND_WHO[who][1]
	var vb: String = wand["verb"]
	var ok_grammar = need == wand["pre"]
	log_event("wand", {"sentence": s, "meaning": wand_english()}, ok_grammar)
	clear_panel("Kabum!" if not ok_grammar else "The wand glows")
	varnak_banner(s, 22)
	if not ok_grammar:
		play_sfx("kabum", -2.0)
		var who_en = Data.WAND_WHO[who][0]
		text_line("The wand sputters and goes kabum! The person prefix does not match: " + who_en + " needs " + need + "-, not " + str(wand["pre"]) + "-. (na- I, ta- you, i- he or she, ri- they)", 17)
		button("Fix it", wand_panel, content)
		button("Return", close_panel, content)
		return
	learn(vb)
	play_sfx("sununu" if who == "Polu" and wand["tense"] != "pa" and wand["ev"] != "nu" else "whoosh", -2.0)
	var pos = wand_place_pos(wand["where"])
	var watcher = ""
	if wand["tense"] == "pa":
		var p = who.to_lower() if who != "An" and who != "Polu" else "tor"
		text_line("Past tense: it already happened, so nothing changes now.", 17)
		if who == "An": text_line("You suddenly remember " + Data.WAND_VERBS[vb][2] + " " + Data.WAND_PLACES[wand["where"]][0] + " last week. Did you? The wand says so.", 17)
		else:
			talk_partner = p
			text_line(p.capitalize() + " scratches their head: “Ho... " + ("ma-" if wand["neg"] else "") + "na-" + vb + "-pa" + ("-ki" if wand["neg"] else "") + "-da?” (I... did that?)", 17)
			emote(p, "confused", 3.0)
	elif wand["ev"] == "nu":
		text_line("-nu means people say. So the wand makes it a RUMOR, not a fact. Listen: everyone nearby is repeating it.", 17)
		for e in entities:
			if e["kind"] == "npc" and (e["node"] as Node3D).position.distance_to(player.position) < 40.0: e["say"] = [s.substr(s.find(" ") + 1), clock + 8.0]
		wand_success()
	elif who == "An":
		if wand["neg"]:
			text_line("You declare that you are NOT doing it there. The wand shrugs. Nothing happens.", 17)
		else:
			player.position = pos + Vector3(0, 0.6, 2.0) if wand["where"] != "haima" else Vector3(pos.x, 0.1, pos.z - 4.0)
			if T.deep(player.position.x, player.position.z): player.position = Vector3(0, 0.1, 36)
			text_line("Whoosh! The wand takes you " + Data.WAND_PLACES[wand["where"]][0] + ". (na- means I: you did it yourself!)", 17)
			wand_success()
	else:
		var ppl = wand_people(who)
		var delay = 6.0 if wand["tense"] == "fu" else 0.0
		var half = wand["ev"] == "shi"
		for i in range(ppl.size()):
			var off = Vector3.ZERO if ppl.size() == 1 else Vector3(cos(i * TAU / ppl.size()), 0, sin(i * TAU / ppl.size())) * 3.0
			wand_pending.append({"id": ppl[i], "at": clock + delay, "pos": pos + off, "verb": vb, "neg": wand["neg"], "half": half, "where": wand["where"]})
		watcher = ppl[0]
		if half: text_line("-shi means apparently. The wand only half believes you: it happens, but not where you said. Apparently.", 17)
		elif wand["tense"] == "fu": text_line("-fu is the future, so it will happen in a moment. Watch...", 17)
		else: text_line("-im and -da: it is happening right now, and you can see it!", 17)
		if wand["neg"]: text_line("And ma- ... -ki: they go there and very clearly do NOT do it.", 17)
		if who == "Polu": text_line("Polu: everyone!", 17)
		wand_success()
		talk_partner = watcher
		if delay == 0.0: wand_tick()
	var mean = text_line("", 16)
	button("Show meaning", func(): mean.text = wand_english(), content)
	button("Another sentence", wand_panel, content)
	button("Return", close_panel, content)

func wand_success():
	master("wand:" + str(wand["verb"]) + ":" + str(wand["tense"]) + ":" + str(wand["ev"]) + (":neg" if wand["neg"] else ""))
	if count_mastered("wand:") >= 5: complete("wand")

func wand_tick():
	var keep: Array = []
	for w in wand_pending:
		if clock < float(w["at"]):
			keep.append(w)
			continue
		var e = entity_by_id(w["id"])
		if e.is_empty(): continue
		var node = e["node"] as Node3D
		var vb: String = w["verb"]
		var act: String = Data.WAND_VERBS[vb][3]
		if w["half"]:
			npc_act(w["id"], [act, act, act])
			e["say"] = ["...shi?", clock + 4.0]
			emote(w["id"], "confused", 3.0)
			continue
		var p: Vector3 = w["pos"]
		node.position = p
		if w["where"] != "haima": node.position.y = gy(p.x, p.z)
		var list: Array = []
		if w["neg"]:
			list = ["sit"]
			e["say"] = ["Ma-na-" + vb + "-im-ki-da!", clock + 9.0]
			emote(w["id"], "angry", 4.0)
		elif vb == "sum" and w["where"] != "haima":
			list = ["sleep", "sleep"]
			e["say"] = ["Sum...? Ups. Dor i-len.", clock + 7.0]
			emote(w["id"], "embarrassed", 4.0)
		else:
			for k in range(8): list.append(act)
			emote(w["id"], "happy" if vb != "sul" else "sleepy", 3.0)
		acts[w["id"]] = {"kind": "seq", "list": list, "i": 0, "t0": clock, "base": node.position, "yaw": node.rotation.y, "teleport": true}
	wand_pending = keep

# ---- pass it on: a telephone game with reported speech ----

var relay: Dictionary = {}

func relay_for(src: String) -> int:
	for i in range(Data.RELAYS.size()):
		if Data.RELAYS[i]["src"] == src: return i
	return -1

func relay_start(i: int):
	var r: Dictionary = Data.RELAYS[i]
	relay = {"i": i, "done": [], "muts": []}
	talk_partner = r["src"]
	clear_panel(str(r["src"]).capitalize() + " has news")
	add_portrait(r["src"])
	emote(r["src"], "embarrassed", 3.0)
	text_line(str(r["src"]).capitalize() + " leans in and whispers:", 17)
	varnak_banner(r["v"], 22)
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = r["en"], content)
	var names = " and ".join(r["to"].map(func(x): return str(x).capitalize()))
	text_line("“" + str(r["to"][0]).capitalize() + "-ru e " + str(r["to"][1]).capitalize() + "-ru ta-gao-o-ye!” Please tell " + names + ".", 17)
	text_line("Careful: you did not see it yourself. You heard it from " + str(r["src"]).capitalize() + ".", 16)
	log_event("relay_start", r["src"])
	toast("Pass it on: find " + names + ".")
	buttons_to_end([])
	button("Return", close_panel, content)

func relay_tell(id: String):
	var r: Dictionary = Data.RELAYS[relay["i"]]
	talk_partner = id
	compact_buttons.call_deferred()
	clear_panel("Tell " + id.capitalize())
	add_portrait(id)
	text_line(str(r["src"]).capitalize() + " told you: “" + str(r["v"]) + "” How do you pass it on?", 17)
	var opts: Array = [["ok", r["ok"]]]
	for k in r["wrong"].keys(): opts.append([k, r["wrong"][k][0]])
	opts.shuffle()
	for o in opts:
		button(o[1], relay_said.bind(id, o[0]), content)
	button("Back", talk.bind(id), content)

func relay_said(id: String, k: String):
	var r: Dictionary = Data.RELAYS[relay["i"]]
	relay["done"].append(id)
	log_event("answer", {"activity": "Pass it on", "item": r["v"], "chose": r["ok"] if k == "ok" else r["wrong"][k][0], "correct": r["ok"]}, k == "ok")
	if k == "ok":
		react(id, r["ok"], r["ok_en"], "Ho?! I-zen-ha?! Ha!", "Really?! Is it true?! Ha! (You reported it with -nu: they say.)", "shocked", 1)
	else:
		relay["muts"].append(k)
		var reply = {"me": ["Ti?! Haku?!", "You?! Why?!", "shocked"], "da": ["Ti ta-pal-pa-ha? Hama?", "You saw it? Where?", "confused"], "noun": ["Han?! Ha! Ha!", "What?! Ha! Ha!", "laugh"]}[k]
		react(id, r["wrong"][k][0], "(what you actually said)", reply[0], reply[1], reply[2], 0)
	if relay["done"].size() >= 2:
		text_line("Both told! Go back to " + str(r["src"]).capitalize() + " and hear how the story came back.", 16)
	buttons_to_end(["Keep chatting", "Return"])

func relay_end():
	var r: Dictionary = Data.RELAYS[relay["i"]]
	var src: String = r["src"]
	talk_partner = src
	clear_panel("How the story came back")
	add_portrait(src)
	var muts: Array = relay["muts"]
	if muts.is_empty():
		varnak_banner(r["ok"], 20)
		text_line("The story came back exactly right. " + src.capitalize() + " is delighted: “Ho! Ti palar ho-ho!” You're a super good friend! (+3 gin)", 17)
		gin += 3
		emote(src, "love", 4.0)
		master("relay:" + src)
		complete_relays()
	else:
		text_line("The story went around the island and came back... different.", 17)
		for m in muts:
			varnak_banner(r["wrong"][m][0], 18)
			text_line(r["wrong"][m][1], 16)
		text_line(src.capitalize() + " stares at you: “Maki! Anke maki k-i-gao-pa-da!” I never said that!", 17)
		emote(src, "faint" if muts.size() > 1 else "shocked", 4.0)
		button("Try again", relay_start.bind(relay["i"]), content)
	log_event("relay_end", {"src": src, "mutations": muts}, muts.is_empty())
	relay = {}
	save_game()
	button("Return", close_panel, content)

func complete_relays():
	var n = 0
	for r in Data.RELAYS:
		if mastered.has("relay:" + r["src"]): n += 1
	if n >= Data.RELAYS.size(): complete("relay")

# ---- guess who: yes/no questions and crossing people out ----

var guess: Dictionary = {}

func guess_fact(id: String, q: String) -> bool:
	var ex: Dictionary = person_ex.get(id, {})
	var e = entity_by_id(id)
	var hx = float((e["home"] as Vector3).x) if not e.is_empty() else 0.0
	match q:
		"hat": return ex.has("hat") or int(looks[id][2]) == 3
		"glasses": return str(ex.get("face", "")) != ""
		"beard": return ex.has("beard")
		"small": return float(ex.get("h", 1.0)) < 0.85
		"tall": return float(ex.get("h", 1.0)) >= 1.08
		"east": return hx > 30.0
		"west": return hx < -30.0
		"swim": return Data.KAN["sum"][1].has(id)
		"read": return Data.KAN["rav"][1].has(id)
		"sing": return Data.KAN["ning"][1].has(id)
		"sleepy": return Data.PEOPLE[id]["trait"] == "sleepy"
		"happy": return Data.PEOPLE[id]["trait"] in ["cheerful", "giggly"]
	return false

func guess_start():
	var pool: Array = Data.GUESS_PEOPLE
	guess = {"secret": pool[randi() % pool.size()], "out": [], "asked": [], "mode": "cross", "wrong": 0}
	for w in ["dau-yir", "pal-sek", "barba", "sa"]: learn(w)
	log_event("guess_start", guess["secret"])
	guess_panel()

func guess_panel(last: String = ""):
	compact_buttons.call_deferred()
	clear_panel("Hal i-an-ha? Guess who!")
	talk_partner = ""
	text_line("Neri is thinking of someone on the island. Ask yes or no questions, cross people out, then guess." if last == "" else last, 16)
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	content.add_child(grid)
	for id in Data.GUESS_PEOPLE:
		var crossed = guess["out"].has(id)
		var b = Button.new()
		b.text = ("x " if crossed else "") + id.capitalize()
		b.custom_minimum_size = Vector2(0, 40)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.add_theme_font_size_override("font_size", 16)
		var sb = StyleBoxFlat.new()
		var col: Color = (person_ex.get(id, {}) as Dictionary).get("shirt", Color("c9a46d"))
		sb.bg_color = col.lerp(Color("e6dccb"), 0.75 if crossed else 0.35)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(3 if guess["mode"] == "guess" and not crossed else 1)
		sb.border_color = Color("7a1f3d") if guess["mode"] == "guess" else col.darkened(0.3)
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_color_override("font_color", Color("8a8070") if crossed else Color("2b1d14"))
		b.pressed.connect(guess_tap.bind(id))
		grid.add_child(b)
	if guess["mode"] == "guess":
		text_line("Tap the person you think it is.", 17)
		button("Not yet: keep asking", func():
			guess["mode"] = "cross"
			guess_panel(), content)
	else:
		button("Make a guess", func():
			guess["mode"] = "guess"
			guess_panel(), content)
		text_line("Ask Neri (questions asked: " + str(guess["asked"].size()) + "):", 17)
		for q in Data.GUESS_Q.keys():
			if guess["asked"].has(q): continue
			button(Data.GUESS_Q[q][0], guess_ask.bind(q), content)
	button("Return", close_panel, content)

func guess_ask(q: String):
	guess["asked"].append(q)
	var yes = guess_fact(guess["secret"], q)
	log_event("guess_ask", {"q": q, "yes": yes})
	var line = Data.GUESS_Q[q][0] + "  Neri: " + ("“Ho!” (yes)" if yes else "“Maki.” (no)")
	guess["log"] = guess.get("log", []) + [line + "   [" + Data.GUESS_Q[q][1] + "]"]
	guess_panel("\n".join(guess["log"]))

func guess_tap(id: String):
	if guess["mode"] == "guess":
		var ok = id == guess["secret"]
		log_event("answer", {"activity": "Guess who", "item": "questions " + str(guess["asked"].size()), "chose": id, "correct": guess["secret"]}, ok)
		if ok:
			var reward = maxi(1, 6 - guess["asked"].size() / 2 - guess["wrong"])
			gin += reward
			master("guess:" + id)
			if count_mastered("guess:") >= 3: complete("guesswho")
			talk_partner = "neri"
			clear_panel("Ho! " + id.capitalize() + "!")
			add_portrait("neri")
			emote("neri", "laugh", 3.0)
			varnak_banner("Ho! Sa " + id.capitalize() + " i-an-da!", 24)
			text_line("Yes! It's " + id.capitalize() + "! You asked " + str(guess["asked"].size()) + " questions. +" + str(reward) + " gin", 17)
			button("Play again", guess_start, content)
			button("Return", close_panel, content)
			save_game()
		else:
			guess["wrong"] += 1
			guess["out"].append(id)
			guess["mode"] = "cross"
			guess_panel("“Sa " + id.capitalize() + " i-an-ha?” Neri: “Maki!” Not " + id.capitalize() + ". Keep asking.")
		return
	if guess["out"].has(id): guess["out"].erase(id)
	else: guess["out"].append(id)
	guess_panel("\n".join(guess.get("log", [])))


func oku_wand():
	talk_partner = "oku"
	if not solved.has("wand"):
		solved.append("wand")
		learn("gao-murak")
		save_game()
		clear_panel("The old stick")
		add_portrait("oku")
		emote("oku", "proud", 3.0)
		varnak_banner("Ki gao-murak i-an-da. Ti ta-gao-fu... sa i-zen-fu!", 20)
		text_line("This is the telling stick. You will say it... and it will be true!", 16)
		text_line("Oku hands you a knobbly stick that hums. Say a sentence with it and the sentence happens. Exactly as you say it: the endings matter.", 17)
		button("Try the wand", wand_panel, content)
		button("Return", close_panel, content)
		return
	wand_panel()

# ------------------------------------------------------------ twelfth expansion: yesen (improv scenes with an audience)

var ys: Dictionary = {}
const YESEN_LEVEL = 2

func yesen_for(id: String) -> Array:
	var out: Array = []
	for i in range(Data.YESEN.size()):
		if Data.YESEN[i]["who"] == id: out.append(i)
	return out

func yesen_known_base(b: String) -> bool:
	var l = b.to_lower().trim_suffix("-").trim_suffix("-ir")
	if l == "": return false
	return words.has(l) or Data.PEOPLE.has(l) or l in ["an", "ti", "sa", "polu", "hirimara", "tekaru", "karaoke", "yue", "riya", "sipu", "pajama", "puts", "poltergais", "senar", "ravar", "palar", "choni-na", "dau-yir", "sena", "sek", "pai"]

func yesen_wrongs(tile: String) -> Array:
	# Plausible learner errors: wrong person prefix, wrong case ending, a missing or extra -ke.
	var out: Array = []
	var punct = ""
	var core = tile
	while core.length() > 0 and core[-1] in [".", "!", "?", ","]:
		punct = core[-1] + punct
		core = core.substr(0, core.length() - 1)
	if core.begins_with("“") or core == "": return out
	var words_in = core.split(" ")
	var last: String = words_in[-1]
	var head = " ".join(words_in.slice(0, words_in.size() - 1))
	var pre = head + " " if head != "" else ""
	var is_verb = last.contains("-") and (last.to_lower().begins_with("na-") or last.to_lower().begins_with("ta-") or last.to_lower().begins_with("i-") or last.to_lower().begins_with("ri-") or last.to_lower().begins_with("k-") or last.to_lower().begins_with("t-") or last.to_lower().begins_with("ma-"))
	if is_verb and words_in.size() == 1:
		var neg = last.begins_with("ma-")
		var body = last.substr(3) if neg else last
		var swaps = [["k-i-", "t-i-"], ["t-i-", "k-i-"], ["k-ta-", "t-na-"], ["t-na-", "k-ta-"], ["na-", "ta-"], ["ta-", "na-"], ["ri-", "i-"], ["i-", "ri-"]]
		for sw in swaps:
			if body.begins_with(sw[0]):
				out.append(("ma-" if neg else "") + sw[1] + body.substr(sw[0].length()) + punct)
				break
		# a wrong second choice: the question ending instead of a statement, or the wrong evidential
		for ev in ["-da", "-shi", "-nu"]:
			if body.ends_with(ev):
				out.append(("ma-" if neg else "") + body.substr(0, body.length() - ev.length()) + ("-ha" if ev == "-da" else "-da") + ("?" if ev == "-da" else punct))
				break
		return out
	var pron = {"An": ["Anke", "Anni"], "Anke": ["An", "Anni"], "Ti": ["Tike", "Ti-ni"], "Tike": ["Ti", "Ti-ni"]}
	if words_in.size() == 1 and pron.has(last):
		for p in pron[last]: out.append(p + punct)
		return out
	var cases = {"ke": "", "ma": "ru", "ru": "ma", "ta": "ma", "su": "ni", "li": "ma", "ni": "su"}
	for c in cases.keys():
		if last.to_lower().ends_with(c) and last.length() > c.length() + 1:
			var base = last.substr(0, last.length() - c.length())
			if yesen_known_base(base):
				var nb = base.trim_suffix("-") if cases[c] == "" else base
				out.append(pre + nb + cases[c] + punct)
				if c != "ke": out.append(pre + base.trim_suffix("-") + "ke" + punct)
				else: out.append(pre + base.trim_suffix("-") + "-ma" + punct)
				return out
	if last.ends_with("-ir") and yesen_known_base(last.trim_suffix("-ir")):
		out.append(pre + last.trim_suffix("-ir") + punct)
		out.append(pre + last + "ke" + punct)
		return out
	if words_in.size() == 1 and yesen_known_base(last):
		out.append(last + "ke" + punct)
		out.append(last + "-ma" + punct)
	elif words_in.size() == 2:
		out.append(last + " " + words_in[0] + punct)
	return out

func yesen_open(id: String):
	if level() < YESEN_LEVEL:
		message("Yesen! (improv)", "Yesen are quick improv scenes for advanced players. They unlock at level 2 (Speaker). Keep playing, or choose Harder in the menu.")
		return
	yesen_suggest(id)

func yesen_suggest(id: String = ""):
	# Improv shows start with a suggestion from the audience. Each word leads to its own scene.
	compact_buttons.call_deferred()
	var fresh: Array = []
	var done: Array = []
	for i in range(Data.YESEN.size()):
		if mastered.has("yesen:" + str(Data.YESEN[i]["id"])): done.append(i)
		else: fresh.append(i)
	fresh.shuffle()
	done.shuffle()
	var picks: Array = []
	for i in yesen_for(id):
		if not mastered.has("yesen:" + str(Data.YESEN[i]["id"])): picks.append(i)
	for i in fresh + done:
		if picks.size() >= 3: break
		if not picks.has(i): picks.append(i)
	picks.shuffle()
	var partner = id
	talk_partner = id
	clear_panel("Yesen! Get a suggestion")
	if id != "": add_portrait(id)
	for w in ["yesen", "ho, e"]: learn(w)
	text_line("Every yesen starts with a suggestion from the audience. Three people shout out words. Pick one, and " + (id.capitalize() if id != "" else "your partner") + " starts a scene inspired by it.", 16)
	for i in picks:
		var sg: Array = Data.YESEN[i]["sug"]
		learn(sg[0])
		var who = partner if partner != "" else str(Data.YESEN[i]["who"])
		button("“" + str(sg[0]).capitalize() + "!”  (" + str(sg[1]) + ")", yesen_start.bind(i, who), content)
	button("Other suggestions", yesen_suggest.bind(id), content)
	button("Not now", close_panel, content)

func yesen_start(i: int, partner: String = ""):
	var sc: Dictionary = Data.YESEN[i]
	if partner == "": partner = sc["who"]
	for w in ["yesen", "ho, e", "bravo", "kudos"]: learn(w)
	for e in entities:
		if acts.has(e["id"]) and acts[e["id"]].get("kind", "") == "watch": acts[e["id"]]["kind"] = "home"
	ys = {"i": i, "who": partner, "round": 0, "got": 0, "max": 0, "audience": [], "blocks": 0}
	talk_partner = partner
	acts.erase(partner)
	log_event("yesen_start", {"scene": sc["id"], "partner": partner, "suggestion": sc["sug"][0]})
	clear_panel("Yesen! " + str(sc["title"]))
	add_portrait(partner)
	var sg: Array = sc["sug"]
	text_line("Suggestion: “" + str(sg[0]).capitalize() + "!” (" + str(sg[1]) + ")", 18)
	text_line(partner.capitalize() + " takes the suggestion and starts a yesen, an improv scene. Yesen is borrowed from English \"yes, and\": always accept what your partner says, then add something.", 16)
	text_line("Answer each line with Ho, e... (yes, and...) and build your sentence. The better your Tujuju, the bigger the crowd.", 16)
	button("Start the scene", yesen_round, content)
	button("Not now", close_panel, content)

func yesen_round():
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var r: Array = sc["rounds"][ys["round"]]
	var who: String = ys["who"]
	compact_buttons.call_deferred()
	talk_partner = who
	clear_panel("Yesen: round " + str(ys["round"] + 1) + " of " + str(sc["rounds"].size()))
	add_portrait(who)
	emote(who, "happy" if ys["round"] == 0 else "proud", 2.0)
	varnak_banner(r[0], 22)
	var en = text_line("(Tap Show meaning if you need it.)", 15)
	button("Show meaning", func(): en.text = "(" + r[1] + ")", content)
	if not ys["audience"].is_empty(): text_line("Watching: " + ", ".join(ys["audience"].map(func(x): return str(x).capitalize())), 15)
	text_line("What do you add?", 17)
	for k in range(r[2].size()):
		button("Ho, e... " + str(r[2][k][0]), yesen_build.bind(k), content)
	button("Maki! (No! Block the idea)", yesen_block, content)

func yesen_block():
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var who: String = ys["who"]
	ys["blocks"] += 1
	ys["max"] += 3
	log_event("answer", {"activity": "Yesen", "item": sc["id"] + ":" + str(ys["round"]), "chose": "Maki!", "correct": "Ho, e..."}, false)
	clear_panel("Maki!")
	add_portrait(who)
	emote(who, "sad", 3.0)
	text_line("You said no. " + who.capitalize() + " freezes. The scene has nowhere to go. In improv, blocking your partner stops the fun: say yes, and add something.", 17)
	yesen_crowd(0.0)
	button("Keep going", yesen_next, content)

func yesen_build(k: int):
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var r: Array = sc["rounds"][ys["round"]]
	var idea: Array = r[2][k]
	var tiles: Array = idea[1]
	var nw = 1 if level() < 3 else 2
	compact_buttons.call_deferred()
	clear_panel("Say it in Tujuju")
	add_portrait(ys["who"])
	text_line("You want to say: \"Yes, and... " + str(idea[0]) + "\" Choose one piece from each row.", 16)
	var chosen: Array = []
	var preview = Label.new()
	preview.add_theme_font_size_override("font_size", 22)
	preview.add_theme_color_override("font_color", Color("7a1f3d"))
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(preview)
	var say: Button
	var refresh = func():
		var parts: Array = ["Ho, e..."]
		for c in chosen: parts.append(c if c != "" else "___")
		preview.text = " ".join(parts)
		if say: say.disabled = chosen.has("")
	for t in range(tiles.size()):
		var opts: Array = [tiles[t]]
		for w in yesen_wrongs(tiles[t]):
			if not opts.has(w) and opts.size() < nw + 1: opts.append(w)
		opts.shuffle()
		chosen.append(tiles[t] if opts.size() == 1 else "")
		if opts.size() == 1: continue
		var row = HFlowContainer.new()
		row.add_theme_constant_override("h_separation", 6)
		row.add_theme_constant_override("v_separation", 6)
		content.add_child(row)
		var group = ButtonGroup.new()
		for o in opts:
			var b = Button.new()
			b.text = o
			b.toggle_mode = true
			b.button_group = group
			b.custom_minimum_size = Vector2(0, 42)
			b.add_theme_font_size_override("font_size", 18)
			b.toggled.connect(func(on):
				if on:
					chosen[t] = o
					refresh.call())
			row.add_child(b)
	say = button("Say it!", func(): yesen_said(tiles, chosen.duplicate()), content)
	refresh.call()
	button("Back", yesen_round, content)

func yesen_said(tiles: Array, chosen: Array):
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var who: String = ys["who"]
	var right = 0
	var total = 0
	var opts_total = 0
	for t in range(tiles.size()):
		if yesen_wrongs(tiles[t]).is_empty(): continue
		opts_total += 1
		if chosen[t] == tiles[t]: right += 1
	total = maxi(opts_total, 1)
	var frac = float(right) / float(total)
	ys["got"] += right + 1
	ys["max"] += total + 1
	var said = "Ho, e... " + " ".join(chosen)
	var target = "Ho, e... " + " ".join(tiles)
	log_event("answer", {"activity": "Yesen", "item": sc["id"] + ":" + str(ys["round"]), "chose": said, "correct": target}, frac >= 0.999)
	clear_panel("Yesen: round " + str(ys["round"] + 1))
	add_portrait(who)
	varnak_banner(said, 20)
	if frac >= 0.999:
		emote(who, "laugh", 3.0)
		text_line("Perfect Tujuju! " + who.capitalize() + " cracks up and keeps going.", 17)
	elif frac >= 0.5:
		emote(who, "happy", 3.0)
		text_line("Almost! " + who.capitalize() + " understands and keeps going. The right way: " + target, 17)
	else:
		emote(who, "confused", 3.0)
		text_line("“Han...?” " + who.capitalize() + " is confused but keeps going. The right way: " + target, 17)
	yesen_crowd(frac)
	button("Next", yesen_next, content)

func yesen_next():
	var sc: Dictionary = Data.YESEN[ys["i"]]
	ys["round"] += 1
	if ys["round"] >= sc["rounds"].size(): yesen_end()
	else: yesen_round()

func yesen_spot(n: int) -> Vector3:
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var pn = entity_by_id(ys["who"])["node"] as Node3D
	var d = Vector3(talk_cam.global_position.x - pn.position.x, 0, talk_cam.global_position.z - pn.position.z)
	if d.length() < 0.1: d = Vector3(0, 0, 1)
	d = d.normalized()
	var side = d.cross(Vector3.UP).normalized()
	var row = n / 4
	var col = [-1.5, 1.5, -2.6, 2.6][n % 4]
	var p = pn.position - d * (1.2 + row * 1.5) + side * col * (1.0 + row * 0.35)
	p.y = gy(p.x, p.z)
	return p

func yesen_crowd(frac: float):
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var who: String = ys["who"]
	var aud: Array = ys["audience"]
	if frac >= 0.999: play_sfx("applause_small", -4.0 + minf(aud.size(), 6) * 0.8)
	elif frac < 0.34: play_sfx("cricket", -8.0)
	# the crowd reacts
	for a in aud:
		var kind = "laugh" if frac >= 0.999 else ("happy" if frac >= 0.5 else "confused")
		emote(a, kind, 2.6)
		var e = entity_by_id(a)
		e["say"] = [["Ha! Ha!", "Bravo!", "Ho! Ho!", "Kudos!"][randi() % 4] if frac >= 0.999 else (["Ho!", "Hm!"][randi() % 2] if frac >= 0.5 else "Han...?"), clock + 3.0]
	# good rounds draw a bigger crowd; a bad one sends someone home
	var add = 0
	if frac >= 0.999: add = 2
	elif frac >= 0.5: add = 1
	if frac < 0.34 and not aud.is_empty():
		var gone: String = aud.pop_back()
		acts[gone] = {"kind": "home"}
		toast(gone.capitalize() + " wanders off.")
	if add == 0: return
	var cands: Array = []
	var pn = (entity_by_id(who)["node"] as Node3D).position
	for e in entities:
		var id: String = e["id"]
		if e["kind"] != "npc" or not Data.PEOPLE.has(id) or id == who or aud.has(id) or not (e["node"] as Node3D).visible: continue
		if npc_following(id): continue
		cands.append([(e["node"] as Node3D).position.distance_to(pn), id])
	cands.sort_custom(func(x, y): return x[0] < y[0])
	for c in cands.slice(0, add):
		var id: String = c[1]
		aud.append(id)
		var p = yesen_spot(aud.size() - 1)
		var far = float(c[0]) > 45.0
		acts[id] = {"kind": "watch", "pos": p, "face": pn, "until": clock + 240.0, "tele": far}
		if far: (entity_by_id(id)["node"] as Node3D).position = p + Vector3(0, 0, 0)
		toast(id.capitalize() + " comes over to watch!")
	ys["audience"] = aud

func yesen_end():
	var sc: Dictionary = Data.YESEN[ys["i"]]
	var who: String = ys["who"]
	var frac = float(ys["got"]) / float(maxi(ys["max"], 1))
	clear_panel("Applause!")
	add_portrait(who)
	varnak_banner(sc["end"][0], 20)
	var en = text_line("(Tap Show meaning if you need it.)", 15)
	button("Show meaning", func(): en.text = "(" + str(sc["end"][1]) + ")", content)
	var n = ys["audience"].size()
	var level_text = ""
	var reward = 0
	var kind = "happy"
	if frac >= 0.9 and ys["blocks"] == 0:
		play_sfx("applause_huge", 0.0)
		level_text = "A standing ovation! Everyone shouts “Bravo! Kudos! Yesen!” and throws imaginary chonies onto the stage."
		reward = 5
		kind = "love"
	elif frac >= 0.7:
		play_sfx("applause_big", -2.0)
		level_text = "Big applause! Cheers and whistles. Somebody yells “Bravo!”"
		reward = 3
		kind = "laugh"
	elif frac >= 0.45:
		play_sfx("applause_small", -8.0)
		level_text = "Polite clapping. Clap. Clap. Clap."
		reward = 1
		kind = "happy"
	else:
		play_sfx("slowclap", -4.0)
		play_sfx("cricket", -6.0)
		level_text = "Silence. Somewhere, a cricket goes chiriri. Then one person claps, very slowly."
		reward = 0
		kind = "confused"
	text_line(level_text + " (" + str(n) + " watching. Tujuju accuracy: " + str(int(round(frac * 100.0))) + "%.)", 17)
	emote(who, kind, 4.0)
	for a in ys["audience"]:
		emote(a, kind, 4.0)
		entity_by_id(a)["say"] = ["Bravo!" if reward >= 3 else ("Ho." if reward >= 1 else "...chiriri"), clock + 5.0]
		if acts.has(a) and acts[a].get("kind", "") == "watch": acts[a]["until"] = clock + 12.0
	gin += reward
	if reward > 0: toast("+" + str(reward) + " gin")
	if frac >= 0.7:
		master("yesen:" + str(sc["id"]))
		if count_mastered("yesen:") >= 5: complete("yesen")
	log_event("yesen_end", {"scene": sc["id"], "accuracy": frac, "audience": n, "blocks": ys["blocks"]}, frac >= 0.7)
	save_game()
	var si: int = ys["i"]
	var swho: String = ys["who"]
	var others: Array = []
	for i in range(Data.YESEN.size()):
		if i != ys["i"] and not mastered.has("yesen:" + str(Data.YESEN[i]["id"])): others.append(Data.YESEN[i]["sug"][0])
	ys = {}
	button("Another suggestion!", yesen_suggest.bind(swho), content)
	if not others.is_empty(): text_line("Suggestions you haven't played yet: " + ", ".join(others.slice(0, 6)) + ". Anyone can do a yesen: Chat, then Yesen.", 15)
	button("Return", close_panel, content)

func show_yesen_list():
	compact_buttons.call_deferred()
	clear_panel("Yesen: improv scenes")
	talk_partner = ""
	if level() < YESEN_LEVEL:
		text_line("Yesen unlock at level 2 (Speaker). Keep playing, or choose Harder in the menu.", 17)
		button("Back", show_games, content)
		return
	text_line("Any villager will do a yesen with you (Chat, then Yesen). Or pick a suggestion here and play it with its usual partner. A crowd gathers if your Tujuju is good.", 16)
	button("Get three suggestions", yesen_suggest.bind(""), content)
	for i in range(Data.YESEN.size()):
		var sc: Dictionary = Data.YESEN[i]
		button("“" + str(sc["sug"][0]).capitalize() + "”: " + str(sc["title"]) + " (" + str(sc["who"]).capitalize() + ")" + ("  [ok]" if mastered.has("yesen:" + str(sc["id"])) else ""), yesen_start.bind(i, str(sc["who"])), content)
	button("Back", show_games, content)

# ------------------------------------------------------------ sound: effects, ambience, Desh's music, spoken Tujuju

const AMB_NAMES = ["ocean", "forest", "rain", "stream", "falls", "night", "wind", "cave", "underwater"]
var amb_w: Dictionary = {}
var uw_fx: int = -1
const SFX_NAMES = ["correct", "wrong", "coin", "fanfare", "newword", "pop", "whoosh", "kabum", "page", "splash", "step0", "step1",
	"applause_small", "applause_big", "applause_huge", "slowclap", "cricket", "pororo", "piriri", "chiriri", "guarara", "kororo",
	"tarara", "pururu", "siri", "vava", "sununu", "kachaka", "bird0", "bird1", "bird2", "hum"]
var sfx: Dictionary = {}
var sfx_pool: Array = []
var amb: Dictionary = {}
var desh_music: AudioStreamPlayer3D
var sound_on: bool = true
var sfx_last: Dictionary = {}
var amb_cd: float = 0.0
var step_t: float = 0.0
var bird_cd: float = 5.0
var last_spoken: String = ""

func setup_audio():
	for n in SFX_NAMES:
		var s = load("res://sfx/" + n + ".ogg")
		if s: sfx[n] = s
	for i in range(8):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)
	for n in AMB_NAMES:
		var s = load("res://sfx/amb_" + n + ".ogg") as AudioStreamOggVorbis
		if s == null: continue
		s.loop = true
		var p = AudioStreamPlayer.new()
		p.stream = s
		p.volume_db = -60.0
		add_child(p)
		p.play(randf() * 8.0)
		p.stream_paused = true
		amb[n] = p
	AudioServer.add_bus_effect(0, AudioEffectLowPassFilter.new())
	uw_fx = AudioServer.get_bus_effect_count(0) - 1
	(AudioServer.get_bus_effect(0, uw_fx) as AudioEffectLowPassFilter).cutoff_hz = 650.0
	AudioServer.set_bus_effect_enabled(0, uw_fx, false)
	var song = load("res://sfx/desh_song.ogg") as AudioStreamOggVorbis
	var de = entity_by_id("desh")
	if song and not de.is_empty():
		song.loop = true
		desh_music = AudioStreamPlayer3D.new()
		desh_music.stream = song
		desh_music.unit_size = 6.0
		desh_music.max_distance = 30.0
		desh_music.volume_db = -6.0
		desh_music.position = Vector3(0, 1.2, 0)
		(de["node"] as Node3D).add_child(desh_music)
		desh_music.play()
	apply_sound_setting()

func apply_sound_setting():
	AudioServer.set_bus_mute(0, not sound_on)

func play_sfx(n: String, db: float = 0.0, pitch: float = 1.0):
	if not sound_on or not sfx.has(n): return
	if clock - float(sfx_last.get(n, -9.0)) < 0.12: return
	sfx_last[n] = clock
	for p in sfx_pool:
		if not p.playing:
			p.stream = sfx[n]
			p.volume_db = db
			p.pitch_scale = pitch
			p.play()
			return
	var p0 = sfx_pool[0] as AudioStreamPlayer
	p0.stream = sfx[n]
	p0.volume_db = db
	p0.play()

func near_player(id: String, r: float = 22.0) -> bool:
	var e = entity_by_id(id)
	if e.is_empty(): return false
	return (e["node"] as Node3D).position.distance_to(player.position) < r or talk_view_id == id

func update_audio(delta: float):
	if sfx_pool.is_empty(): return
	# footsteps while walking
	var moving = Vector2(player.velocity.x, player.velocity.z).length() > 1.0 and player.is_on_floor() and not riding
	if moving:
		step_t -= delta
		if step_t <= 0.0:
			step_t = 0.42
			play_sfx("step" + str(randi() % 2), -14.0, randf_range(0.9, 1.1))
	amb_cd -= delta
	if amb_cd <= 0.0:
		amb_cd = 0.5
		amb_w = ambient_weights()
	for n in amb_w.keys():
		set_amb(n, float(amb_w[n]), delta)
	# Desh plays louder when he is performing
	if desh_music:
		var perf = acts.has("desh") or (panel.visible and talk_partner == "desh")
		desh_music.volume_db = lerpf(desh_music.volume_db, 2.0 if perf else -6.0, 0.5)

func set_amb(n: String, w: float, delta: float):
	if not amb.has(n): return
	var p = amb[n] as AudioStreamPlayer
	var cur = db_to_linear(p.volume_db)
	var nw = lerpf(cur, clampf(w, 0.0, 1.5), minf(delta * 1.2, 1.0))
	if p.stream_paused: nw = 0.0005
	p.volume_db = linear_to_db(maxf(nw, 0.0005))
	# silent zones stop decoding, which keeps phones cool
	if w < 0.01 and nw < 0.003 and not p.stream_paused: p.stream_paused = true
	elif w >= 0.01 and p.stream_paused: p.stream_paused = false

func ambient_weights() -> Dictionary:
	# Each sound zone fades in and out with where you are, the weather and the time of day.
	var p = player.position
	var w = {}
	var wet = 0
	for k in range(8):
		var a = k * TAU / 8.0
		for r in [7.0, 16.0, 26.0]:
			if T.height(p.x + cos(a) * r, p.z + sin(a) * r) < -0.25: wet += 1
	var trees = 0
	for q in tree_pts:
		if (q as Vector2).distance_squared_to(Vector2(p.x, p.z)) < 256.0: trees += 1
	var cen_d = Vector2(p.x, p.z).distance_to(T.CENOTE)
	var under = camera.global_position.y < cen_y_w and cen_d < 20.0
	var in_cave = cen_d < 18.0 and p.y < cen_top - 1.0
	var day = 1.0 - night
	var land = 1.0 - clampf(wet / 18.0, 0.0, 1.0)
	w["ocean"] = clampf(wet / 10.0, 0.0, 1.0) * 0.9
	w["forest"] = day * (0.18 + 0.82 * clampf(trees / 9.0, 0.0, 1.0)) * land
	w["night"] = night * (0.35 + 0.65 * land)
	w["rain"] = clampf(raining, 0.0, 1.0) * 1.1
	w["stream"] = clampf(1.0 - T.river_dist(p.x, p.z) / 14.0, 0.0, 1.0) * 0.8 + clampf(1.0 - Vector2(p.x, p.z).distance_to(T.POND) / 10.0, 0.0, 1.0) * 0.4
	w["falls"] = clampf(1.0 - Vector2(p.x, p.z).distance_to(T.FALLS_POOL) / 32.0, 0.0, 1.0) * 0.9
	w["wind"] = clampf((p.y - 4.0) / 4.0, 0.0, 1.0) * 0.7 + (0.25 if p.x < -95.0 else 0.0)
	w["cave"] = clampf(1.0 - cen_d / 24.0, 0.0, 1.0) * 0.8 + (0.6 if in_cave else 0.0)
	w["underwater"] = 1.2 if under else 0.0
	if in_cave or under:
		for k in ["ocean", "forest", "night", "rain", "wind", "stream", "falls"]: w[k] = float(w[k]) * (0.15 if under else 0.4)
	return w

# ---- the phone's voice reads Tujuju aloud ----

func speak(text: String):
	var t = text.replace("“", "").replace("”", "").replace("\"", "").replace("-", "").replace("\n", " ")
	t = t.replace("...", ", ").strip_edges()
	last_spoken = t
	log_event("speak", t)
	if OS.has_feature("web"):
		var js = "(function(t){try{var s=window.speechSynthesis;if(!s)return 'none';s.cancel();var u=new SpeechSynthesisUtterance(t);var vs=s.getVoices()||[];" + \
			"function f(p){for(var i=0;i<vs.length;i++){if((vs[i].lang||'').toLowerCase().indexOf(p)==0)return vs[i];}return null;}" + \
			"var v=f('es-mx')||f('es-us')||f('es')||f('it');if(v){u.voice=v;u.lang=v.lang;}else{u.lang='es-MX';}u.rate=0.85;s.speak(u);return v?v.lang:'default';}catch(e){return 'err';}})(" + JSON.stringify(t) + ")"
		var res = JavaScriptBridge.eval(js, true)
		if str(res) == "none": toast("This browser can't read aloud.")
		return
	var voices = DisplayServer.tts_get_voices_for_language("es")
	if voices.is_empty(): voices = DisplayServer.tts_get_voices_for_language("it")
	if voices.is_empty():
		toast("No voice is available on this device.")
		return
	DisplayServer.tts_stop()
	DisplayServer.tts_speak(t, voices[0], 50, 1.0, 0.85)

func speaker_button() -> Button:
	var b = Button.new()
	b.name = "Speaker"
	b.tooltip_text = "Listen"
	b.custom_minimum_size = Vector2(40, 40)
	b.focus_mode = Control.FOCUS_NONE
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("e9c46a")
	sb.set_corner_radius_all(20)
	b.add_theme_stylebox_override("normal", sb)
	b.add_theme_stylebox_override("hover", sb)
	var sb2 = sb.duplicate()
	sb2.bg_color = Color("f4a261")
	b.add_theme_stylebox_override("pressed", sb2)
	var icon = Control.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.draw.connect(func():
		var c = Color("24495a")
		var o = Vector2(9, 20)
		icon.draw_colored_polygon(PackedVector2Array([o + Vector2(0, -5), o + Vector2(6, -5), o + Vector2(13, -11), o + Vector2(13, 11), o + Vector2(6, 5), o + Vector2(0, 5)]), c)
		icon.draw_arc(o + Vector2(13, 0), 7.0, -0.9, 0.9, 10, c, 2.4)
		icon.draw_arc(o + Vector2(13, 0), 12.0, -0.9, 0.9, 12, c, 2.4))
	b.add_child(icon)
	return b

# ------------------------------------------------------------ the cenote (sonot)

const CEN_CAVE_R = 15.0
const CEN_CAVE_RY = 14.5
var cen_y_w: float = T.CENOTE_WATER
var cen_top: float
var cen_cave_cy: float
var cen_bottom: float
var cen_rays: Array = []
var cen_fish: Array = []
var cen_seen: bool = false

func cave_noise(a: float, y: float) -> float:
	return sin(a * 3.0 + y * 0.31) * 0.5 + sin(a * 7.0 - y * 0.57 + 1.7) * 0.3 + sin(a * 13.0 + y * 1.1) * 0.2

func cave_color(y: float, a: float) -> Color:
	var depth = clampf((cen_y_w - y) / 40.0, 0.0, 1.0)
	var c = Color("cfc7a8").lerp(Color("8fb7a8"), clampf((cen_y_w + 1.0 - y) / 6.0, 0.0, 1.0)).lerp(Color("2f6f74"), depth)
	if y > cen_y_w + 0.4: c = Color("b8b09a").lerp(Color("5f8a4a"), clampf((y - cen_y_w) / 2.5, 0.0, 1.0) * (0.5 + 0.5 * sin(a * 5.0)))
	return c.lerp(Color("e6dcc0"), 0.12 * (0.5 + 0.5 * sin(a * 11.0 + y)))

func cenote_mesh() -> ArrayMesh:
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var seg = 40
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rings: Array = []   # each ring: [y, radius_fn scale array]
	# shaft: from just above the rim down to the cavern ceiling
	var phi0 = asin(T.CENOTE_R / CEN_CAVE_R)
	cen_cave_cy = cen_y_w - 18.0
	var ceiling = cen_cave_cy + CEN_CAVE_RY * cos(phi0)
	cen_top = T.height(cx + T.CENOTE_R + 0.5, cz) + 0.6
	var ys: Array = []
	var y = cen_top
	while y > ceiling:
		ys.append([y, T.CENOTE_R])
		y -= 0.7
	# cavern: an uneven ellipsoid
	var phi_end = PI - asin(4.0 / CEN_CAVE_R)
	for k in range(1, 25):
		var phi = lerpf(phi0, phi_end, float(k) / 24.0)
		ys.append([cen_cave_cy + CEN_CAVE_RY * cos(phi), CEN_CAVE_R * sin(phi)])
	# the deep pit below
	var pit_top = cen_cave_cy + CEN_CAVE_RY * cos(phi_end)
	y = pit_top - 1.2
	cen_bottom = cen_y_w - 62.0
	while y > cen_bottom:
		ys.append([y, 4.0])
		y -= 1.5
	ys.append([cen_bottom, 4.0])
	for r in ys:
		var ring: Array = []
		for i in range(seg + 1):
			var a = TAU * float(i % seg) / seg
			var rr: float = r[1] * (1.0 + 0.1 * cave_noise(a, r[0])) if r[1] > T.CENOTE_R + 0.1 else r[1] + 0.25 * cave_noise(a, r[0])
			ring.append(Vector3(cx + cos(a) * rr, r[0], cz + sin(a) * rr))
		rings.append(ring)
	for j in range(rings.size() - 1):
		var r0: Array = rings[j]
		var r1: Array = rings[j + 1]
		for i in range(seg):
			var quad = [r0[i], r1[i], r1[i + 1], r0[i], r1[i + 1], r0[i + 1]]
			for v in quad:
				var vv: Vector3 = v
				var nrm = Vector3(cx - vv.x, 0.0, cz - vv.z).normalized()
				st.set_normal(nrm)
				st.set_color(cave_color(vv.y, atan2(vv.z - cz, vv.x - cx)))
				st.add_vertex(vv)
	# floor of the pit
	var last: Array = rings[-1]
	for i in range(seg):
		for v in [Vector3(cx, cen_bottom - 0.4, cz), last[i + 1], last[i]]:
			st.set_normal(Vector3.UP)
			st.set_color(Color("2a6a6a"))
			st.add_vertex(v)
	return st.commit()

func build_cenote():
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var mesh = cenote_mesh()
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.85
	mat.emission_enabled = true
	mat.emission = Color("1d5a5e")
	mat.emission_energy_multiplier = 0.35
	var mi = MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var body = StaticBody3D.new()
	var cs = CollisionShape3D.new()
	var shape = mesh.create_trimesh_shape() as ConcavePolygonShape3D
	shape.backface_collision = true
	cs.shape = shape
	body.add_child(cs)
	add_child(body)
	# a mossy rim that covers the edge of the hole in the ground
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var seg = 40
	var radii = [T.CENOTE_R - 0.05, T.CENOTE_R + 0.6, T.CENOTE_R + 1.8, T.CENOTE_R + 3.5, T.CENOTE_R + 4.8]
	var ring_pts: Array = []
	for ri in range(radii.size()):
		var ring: Array = []
		for i in range(seg + 1):
			var a = TAU * float(i % seg) / seg
			var rr: float = radii[ri] + (0.25 * cave_noise(a, 0.0) if ri == 0 else 0.0)
			var x = cx + cos(a) * rr
			var z = cz + sin(a) * rr
			var yy = cen_top - 0.55 + (0.12 * sin(a * 7.0) if ri < 2 else 0.0)
			if ri >= 3: yy = maxf(T.height(x, z) + 0.06, yy - (ri - 2) * 0.35)
			ring.append(Vector3(x, yy, z))
		ring_pts.append(ring)
	for j in range(ring_pts.size() - 1):
		for i in range(seg):
			var a: Array = ring_pts[j]
			var b: Array = ring_pts[j + 1]
			for v in [a[i], b[i + 1], b[i], a[i], a[i + 1], b[i + 1]]:
				st.set_normal(Vector3.UP)
				st.set_color(Color("6f8f4a").lerp(Color("9a9580"), 0.5 + 0.5 * sin(float(i) * 1.3 + j)) if j < 2 else Color("4f7a3a").lerp(Color("6f9a4a"), 0.5 + 0.5 * sin(float(i) * 0.7)))
				st.add_vertex(v)
	var rim = st.commit()
	var rmat = StandardMaterial3D.new()
	rmat.vertex_color_use_as_albedo = true
	rmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	rmat.roughness = 0.95
	var rmi = MeshInstance3D.new()
	rmi.mesh = rim
	rmi.material_override = rmat
	add_child(rmi)
	var rb = StaticBody3D.new()
	var rcs = CollisionShape3D.new()
	var rshape = rim.create_trimesh_shape() as ConcavePolygonShape3D
	rshape.backface_collision = true
	rcs.shape = rshape
	rb.add_child(rcs)
	add_child(rb)
	# the water: only the small round surface shows, the whole cavern below is flooded
	var wm = MeshInstance3D.new()
	var disc = CylinderMesh.new()
	disc.top_radius = T.CENOTE_R + 0.6
	disc.bottom_radius = T.CENOTE_R + 0.6
	disc.height = 0.02
	disc.radial_segments = 40
	wm.mesh = disc
	var wmat = Art.water_material(Color("1f8f8a"), Color("7fe3d0"), 0.72)
	wmat.set_shader_parameter("speed", 0.35)
	wm.material_override = wmat
	wm.position = Vector3(cx, cen_y_w, cz)
	wm.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(wm)
	var under = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2((T.CENOTE_R + 0.6) * 2.0, (T.CENOTE_R + 0.6) * 2.0)
	plane.flip_faces = true
	under.mesh = plane
	var umat = StandardMaterial3D.new()
	umat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	umat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	umat.albedo_color = Color(0.75, 1.0, 0.95, 0.55)
	under.material_override = umat
	under.position = Vector3(cx, cen_y_w - 0.02, cz)
	add_child(under)
	# light falling through the opening
	var rays_mat = StandardMaterial3D.new()
	rays_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rays_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rays_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	rays_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	rays_mat.albedo_color = Color(0.55, 0.95, 0.9, 0.07)
	rays_mat.disable_fog = true
	var rr = RandomNumberGenerator.new()
	rr.seed = 5150
	for k in range(6):
		var ray = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = rr.randf_range(0.25, 0.7)
		cyl.bottom_radius = rr.randf_range(1.6, 3.2)
		cyl.height = rr.randf_range(18.0, 28.0)
		cyl.radial_segments = 10
		cyl.cap_top = false
		cyl.cap_bottom = false
		ray.mesh = cyl
		ray.material_override = rays_mat
		ray.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var pivot = Node3D.new()
		pivot.position = Vector3(cx + rr.randf_range(-1.6, 1.6), cen_y_w - 0.1, cz + rr.randf_range(-1.6, 1.6))
		pivot.rotation = Vector3(rr.randf_range(-0.25, 0.25), 0, rr.randf_range(-0.25, 0.25))
		ray.position = Vector3(0, -cyl.height * 0.5, 0)
		pivot.add_child(ray)
		add_child(pivot)
		cen_rays.append([pivot, pivot.rotation, rr.randf() * TAU])
	# soft glowing algae on the walls, brighter deeper down
	var glow_t: Array = []
	var glow_c: Array = []
	for k in range(260):
		var a = rr.randf() * TAU
		var gy2 = rr.randf_range(cen_bottom + 2.0, cen_y_w - 4.0)
		var rad: float
		if gy2 < cen_cave_cy - CEN_CAVE_RY + 1.0: rad = 3.75
		else:
			var dy = (gy2 - cen_cave_cy) / CEN_CAVE_RY
			rad = CEN_CAVE_R * sqrt(maxf(0.02, 1.0 - dy * dy)) * (1.0 + 0.1 * cave_noise(a, gy2)) - 0.25
		var s = rr.randf_range(0.08, 0.3)
		glow_t.append(Transform3D(Basis.from_scale(Vector3(s, s * 0.6, s)), Vector3(cx + cos(a) * rad, gy2, cz + sin(a) * rad)))
		glow_c.append(Color("4ff0d0").lerp(Color("a0ff7a"), rr.randf()).lerp(Color("6fa0ff"), clampf((cen_cave_cy - gy2) / 30.0, 0.0, 1.0)))
	var glow = Art.scatter(self, Art.sphere_mesh(1.0, 6), glow_t, glow_c, false)
	var gmat = StandardMaterial3D.new()
	gmat.vertex_color_use_as_albedo = true
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gmat.disable_fog = true
	glow.material_override = gmat
	# stalactites hanging from the ceiling
	var stal_t: Array = []
	var stal_c: Array = []
	for k in range(40):
		var a = rr.randf() * TAU
		var d = rr.randf_range(4.5, 12.0)
		var dy = sqrt(maxf(0.0, 1.0 - pow(d / CEN_CAVE_R, 2.0)))
		var top = cen_cave_cy + CEN_CAVE_RY * dy - 0.3
		var h = rr.randf_range(1.0, 4.0)
		stal_t.append(Transform3D(Basis.from_scale(Vector3(0.35, h, 0.35)).rotated(Vector3.RIGHT, PI), Vector3(cx + cos(a) * d, top - h * 0.5, cz + sin(a) * d)))
		stal_c.append(Color("9fb8aa").lerp(Color("5f8f88"), rr.randf()))
	Art.scatter(self, Art.cone_mesh(1.0, 1.0, 6), stal_t, stal_c, false)
	# little glowing fish that circle slowly
	var fmat = StandardMaterial3D.new()
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.albedo_color = Color("b8fff0")
	fmat.disable_fog = true
	for school in range(3):
		var center_y = cen_cave_cy + rr.randf_range(-8.0, 6.0)
		var radius = rr.randf_range(5.0, 10.0)
		for f in range(9):
			var fish = MeshInstance3D.new()
			var sm = SphereMesh.new()
			sm.radius = 0.09
			sm.height = 0.18
			sm.radial_segments = 6
			sm.rings = 3
			fish.mesh = sm
			fish.scale = Vector3(1, 0.8, 2.6)
			fish.material_override = fmat
			add_child(fish)
			cen_fish.append([fish, center_y + rr.randf_range(-0.8, 0.8), radius + rr.randf_range(-0.8, 0.8), rr.randf() * TAU, rr.randf_range(0.18, 0.3) * (1 if school % 2 == 0 else -1)])
	# something old and carved rests on the cavern floor
	var stone = Node3D.new()
	stone.position = Vector3(cx + 3.5, cen_cave_cy - CEN_CAVE_RY + 1.4, cz - 2.0)
	add_child(stone)
	Art.cyl(stone, Vector3(0, 0.3, 0), 0.9, 1.0, 0.6, Color("6f8f88"), Vector3.ZERO, 14)
	for k in range(3):
		var tor = Art.torus(stone, Vector3(0, 0.61, 0), 0.3 + k * 0.2, 0.35 + k * 0.2, Color("7dffe0"), Vector3.ZERO)
		tor.material_override = gmat
	# floating motes in the water
	var motes = CPUParticles3D.new()
	motes.amount = 160
	motes.lifetime = 14.0
	motes.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents = Vector3(11, 11, 11)
	motes.position = Vector3(cx, cen_cave_cy, cz)
	motes.direction = Vector3(0, 1, 0)
	motes.spread = 40.0
	motes.gravity = Vector3.ZERO
	motes.initial_velocity_min = 0.05
	motes.initial_velocity_max = 0.2
	var mm = SphereMesh.new()
	mm.radius = 0.025
	mm.height = 0.05
	mm.radial_segments = 4
	mm.rings = 2
	motes.mesh = mm
	var mmat = StandardMaterial3D.new()
	mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mmat.albedo_color = Color(0.8, 1.0, 0.95, 0.6)
	mmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mmat.disable_fog = true
	motes.material_override = mmat
	add_child(motes)
	build_cenote_jungle()
	build_carvings()
	build_guardian()

func build_cenote_jungle():
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var vary = RandomNumberGenerator.new()
	vary.seed = 8484
	var trunks: Array = []
	var trunk_colors: Array = []
	var pines: Array = []
	var pine_colors: Array = []
	var oaks: Array = []
	var oak_colors: Array = []
	var placed: Array = []
	var tries = 0
	while placed.size() < 120 and tries < 3000:
		tries += 1
		var a = vary.randf() * TAU
		var d = vary.randf_range(8.0, 28.0)
		var x = cx + cos(a) * d
		var z = cz + sin(a) * d
		if T.coast(x, z) < 3.0 or x > 94.0: continue
		var crowded = false
		for q in placed:
			if q.distance_squared_to(Vector2(x, z)) < 7.0:
				crowded = true
				break
		if crowded: continue
		var y = T.height(x, z)
		solid(Vector3(x, y + 1.2, z), Vector3(0.5, 2.4, 0.5))
		add_tree(Vector3(x, y, z), vary, trunks, trunk_colors, pines, pine_colors, oaks, oak_colors)
		placed.append(Vector2(x, z))
	Art.scatter(self, Art.cyl_mesh(0.28, 1.0, 7), trunks, trunk_colors)
	Art.scatter(self, Art.cone_mesh(1.0, 1.0, 8), pines, pine_colors)
	Art.scatter(self, Art.sphere_mesh(1.0, 9), oaks, oak_colors)
	# ferns and big leaves around the rim, and vines hanging into the opening
	var leaf_t: Array = []
	var leaf_c: Array = []
	for k in range(260):
		var a = vary.randf() * TAU
		var d = vary.randf_range(T.CENOTE_R + 1.6, 16.0)
		var x = cx + cos(a) * d
		var z = cz + sin(a) * d
		if T.coast(x, z) < 2.0: continue
		var y = T.height(x, z) if d > T.CENOTE_R + 4.6 else cen_top - 0.5
		var s = vary.randf_range(0.35, 0.9) * (0.55 if d < T.CENOTE_R + 4.0 else 1.0)
		var b = Basis.from_euler(Vector3(vary.randf_range(-0.6, 0.6), vary.randf() * TAU, vary.randf_range(-0.6, 0.6))).scaled(Vector3(s * 1.6, s * 0.25, s * 0.7))
		leaf_t.append(Transform3D(b, Vector3(x, y + s * 0.3, z)))
		leaf_c.append(Color("2f6a2a").lerp(Color("6fb84a"), vary.randf()))
	Art.scatter(self, Art.sphere_mesh(1.0, 7), leaf_t, leaf_c, false)
	var vine_t: Array = []
	var vine_c: Array = []
	for k in range(34):
		var a = vary.randf() * TAU
		var r = T.CENOTE_R + vary.randf_range(-0.1, 0.25)
		var h = vary.randf_range(1.5, 3.4)
		vine_t.append(Transform3D(Basis.from_scale(Vector3(1, h, 1)), Vector3(cx + cos(a) * r, cen_top - 0.5 - h * 0.5, cz + sin(a) * r)))
		vine_c.append(Color("3d7a32").lerp(Color("7fb05a"), vary.randf()))
	Art.scatter(self, Art.cyl_mesh(0.035, 1.0, 4), vine_t, vine_c, false)
	# a few flowers
	for k in range(30):
		var a = vary.randf() * TAU
		var d = vary.randf_range(5.0, 14.0)
		var x = cx + cos(a) * d
		var z = cz + sin(a) * d
		if T.coast(x, z) < 2.0: continue
		Art.sph(self, Vector3(x, T.height(x, z) + 0.35, z), 0.12, [Color("ff7aa8"), Color("ffd34d"), Color("ffffff"), Color("c58aff")][k % 4], Vector3.ONE, 6)

func update_cenote(delta: float):
	if cen_rays.is_empty(): return
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var near = Vector2(player.position.x, player.position.z).distance_to(T.CENOTE) < 60.0
	if not near: return
	for r in cen_rays:
		var base: Vector3 = r[1]
		(r[0] as Node3D).rotation = base + Vector3(sin(clock * 0.21 + r[2]) * 0.04, 0, cos(clock * 0.17 + r[2]) * 0.04)
	for f in cen_fish:
		f[3] += delta * float(f[4])
		var a: float = f[3]
		var n = f[0] as Node3D
		n.position = Vector3(cx + cos(a) * f[2], f[1] + sin(clock * 0.6 + a * 3.0) * 0.3, cz + sin(a) * f[2])
		n.rotation.y = -a + (0.0 if f[4] > 0 else PI)

# ---- swimming and diving ----

var swimming: bool = false
var swim_up_held: bool = false
var swim_down_held: bool = false
var swim_ui: Array = []
var climb_button: Button
var uw_overlay: ColorRect
var bubbles: CPUParticles3D
var underwater: bool = false

func build_swim_ui():
	uw_overlay = ColorRect.new()
	uw_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	uw_overlay.color = Color(0.1, 0.55, 0.55, 0.0)
	uw_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	uw_overlay.hide()
	ui.add_child(uw_overlay)
	ui.move_child(uw_overlay, 0)
	var defs = [["Up", -400.0, func(on): swim_up_held = on], ["Dive", -326.0, func(on): swim_down_held = on]]
	for d in defs:
		var b = Button.new()
		b.name = "Swim" + d[0]
		b.text = d[0]
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 20)
		b.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		b.offset_left = -126
		b.offset_right = -20
		b.offset_top = d[1]
		b.offset_bottom = d[1] + 64
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.45, 0.48, 0.75)
		sb.set_corner_radius_all(32)
		sb.set_border_width_all(2)
		sb.border_color = Color("bff7ea")
		for st in ["normal", "hover", "pressed"]: b.add_theme_stylebox_override(st, sb)
		b.add_theme_color_override("font_color", Color.WHITE)
		var cb: Callable = d[2]
		b.button_down.connect(func(): cb.call(true))
		b.button_up.connect(func(): cb.call(false))
		b.hide()
		ui.add_child(b)
		swim_ui.append(b)
	climb_button = button("Climb out", climb_out, ui)
	climb_button.name = "ClimbOut"
	climb_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	climb_button.offset_left = -176
	climb_button.offset_right = -20
	climb_button.offset_top = -474
	climb_button.offset_bottom = -414
	climb_button.hide()
	bubbles = CPUParticles3D.new()
	bubbles.amount = 10
	bubbles.lifetime = 1.6
	bubbles.emitting = false
	bubbles.position = Vector3(0, -0.45, -1.3)
	bubbles.direction = Vector3(0, 1, 0)
	bubbles.spread = 18.0
	bubbles.gravity = Vector3(0, 0.6, 0)
	bubbles.initial_velocity_min = 0.3
	bubbles.initial_velocity_max = 0.7
	bubbles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	bubbles.emission_sphere_radius = 0.15
	var bm = SphereMesh.new()
	bm.radius = 0.012
	bm.height = 0.024
	bm.radial_segments = 6
	bm.rings = 3
	bubbles.mesh = bm
	var bmat = StandardMaterial3D.new()
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bmat.albedo_color = Color(0.9, 1.0, 1.0, 0.7)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.disable_fog = true
	bubbles.material_override = bmat
	camera.add_child(bubbles)

func in_cenote_water(p: Vector3) -> bool:
	var d = Vector2(p.x, p.z).distance_to(T.CENOTE)
	if d > CEN_CAVE_R + 2.0 or p.y < cen_bottom - 2.0: return false
	if d < T.CENOTE_R + 0.8: return p.y < cen_y_w - 0.35
	return p.y < cen_y_w - 3.0

func float_y() -> float:
	return cen_y_w - 1.45

func swim_physics(delta: float, axis: Vector2):
	var was = swimming
	swimming = true
	walk_to = {}
	walk_via.clear()
	if not was:
		player.velocity *= 0.3
		play_sfx("splash", 0.0)
		if not cen_seen and not discovered.has("sonot"):
			cen_seen = true
			for w in ["sonot", "lup", "sum"]: learn(w)
			toast("Sonot: a cenote! Swim, and dive as deep as you like.")
			log_event("cenote", "first swim")
	var cb = camera.global_basis
	var fwd3 = -cb.z
	var under = camera.global_position.y < cen_y_w
	var fwd = fwd3 if under else Vector3(fwd3.x, 0.0, fwd3.z).normalized()
	if not under and fwd3.y < -0.45 and axis.y < -0.3: fwd = fwd3
	var right = Vector3(cb.x.x, 0.0, cb.x.z).normalized()
	var want = (fwd * -axis.y + right * axis.x) * 3.2
	var up = swim_up_held or Input.is_physical_key_pressed(KEY_SPACE)
	var down = swim_down_held or Input.is_physical_key_pressed(KEY_C) or Input.is_physical_key_pressed(KEY_CTRL)
	if up: want.y += 2.8
	if down: want.y -= 2.8
	if not up and not down and axis == Vector2.ZERO: want.y += 1.0 if player.position.y > float_y() - 4.0 else 0.3
	player.velocity = player.velocity.lerp(want, minf(delta * 2.5, 1.0))
	player.move_and_slide()
	var fy = float_y()
	if player.position.y > fy:
		player.position.y = lerpf(player.position.y, fy + sin(clock * 1.4) * 0.05, minf(delta * 4.0, 1.0))
		if player.velocity.y > 0.0: player.velocity.y = 0.0
	var depth = maxf(0.0, cen_y_w - camera.global_position.y)
	chip_action = Callable()
	var nc = nearest_carving() if under else -1
	if guardian_near():
		chip_action = guardian_listen
		prompt.text = "Var Tari  ·  tap to listen"
		fit_prompt()
		prompt.visible = not panel.visible
		prompt.modulate.a = 1.0
		return
	if nc >= 0:
		chip_action = read_carving.bind(nc)
		prompt.text = "Carving  ·  tap to read"
		fit_prompt()
		prompt.visible = not panel.visible
		prompt.modulate.a = 1.0
		return
	prompt.text = ("Depth " + str(int(round(depth))) + " m" + ("  ·  Up to rise" if depth > 2.0 else "  ·  Dive to go down")) if depth > 0.3 else "Swimming  ·  Dive, or Climb out"
	fit_prompt()
	prompt.visible = not panel.visible
	prompt.modulate.a = 0.8
	interact_button.disabled = true

func climb_out():
	var d = Vector2(player.position.x - T.CENOTE.x, player.position.z - T.CENOTE.y)
	if d.length() < 0.1: d = Vector2(0, 1)
	d = d.normalized()
	var r = T.CENOTE_R + 2.6
	player.position = Vector3(T.CENOTE.x + d.x * r, cen_top + 0.4, T.CENOTE.y + d.y * r)
	player.velocity = Vector3.ZERO
	swimming = false
	swim_up_held = false
	swim_down_held = false
	play_sfx("splash", -8.0, 1.3)

func update_underwater(delta: float):
	if uw_overlay == null: return
	var at_surface = swimming and player.position.y > float_y() - 0.25
	var show_swim = swimming and not panel.visible
	for b in swim_ui: b.visible = show_swim
	climb_button.visible = show_swim and at_surface
	var cen_d = Vector2(camera.global_position.x, camera.global_position.z).distance_to(T.CENOTE)
	var under = camera.global_position.y < cen_y_w and cen_d < CEN_CAVE_R + 3.0
	if under != underwater:
		underwater = under
		uw_overlay.visible = under
		bubbles.emitting = under
		if uw_fx >= 0: AudioServer.set_bus_effect_enabled(0, uw_fx, under)
		if not under: env.fog_density = 0.003
		play_sfx("splash", -10.0, 0.7)
	if under:
		var depth = clampf((cen_y_w - camera.global_position.y) / 50.0, 0.0, 1.0)
		uw_overlay.color = Color(0.08, 0.5, 0.52, 0.16).lerp(Color(0.02, 0.18, 0.3, 0.42), depth)
		env.fog_light_color = Color("3fc4b4").lerp(Color("0b3a52"), depth)
		env.fog_density = lerpf(0.016, 0.045, depth)

# ------------------------------------------------------------ kirmel: the lost writing, the carvings and Var Tari

const K = preload("res://kirmel.gd")
var carvings: Array = []   # [node, index]  index -1 is the picture stone
var guardian: Node3D
var guardian_tail: Node3D
var guardian_t: float = 0.0
var guardian_line: int = -1
var chip_action: Callable = Callable()
var kir_show: bool = true

func kir_knows(c: String, v: String) -> bool:
	return mastered.has("ky:" + c + "|" + v)

func kir_knows_final(c: String) -> bool:
	return mastered.has("kf:" + c) or kir_shape_known(c)

func kir_shape_known(c: String) -> bool:
	for v in K.VOWELS:
		if kir_knows(c, v): return true
	return false

func kir_vowel_known(v: String) -> bool:
	for m in mastered:
		var ms = str(m)
		if ms.begins_with("ky:") and ms.ends_with("|" + v): return true
	return false

func kir_learn_syl(syl: Dictionary):
	if syl.has("p") or syl.has("sp"): return
	if syl["v"] != "": master("ky:" + str(syl["c"]) + "|" + str(syl["v"]))
	elif syl["c"] != "": master("kf:" + str(syl["c"]))
	for f in syl["f"]: master("kf:" + str(f))

func kir_readable(syl: Dictionary) -> bool:
	if syl.has("p") or syl.has("sp"): return true
	if syl["v"] == "":
		if not kir_knows_final(syl["c"]): return false
	elif not kir_knows(syl["c"], syl["v"]): return false
	for f in syl["f"]:
		if not kir_knows_final(f): return false
	return true

func kir_known_count() -> int:
	return count_mastered("ky:")

func glyph_cell(syl: Dictionary, label_text: String, hl: bool = false, cell: float = 34.0) -> Control:
	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 0)
	var g = Control.new()
	var fw = cell * (1.0 if syl["v"] != "" else 0.5) + cell * 0.4 * syl["f"].size()
	g.custom_minimum_size = Vector2(fw + 8, cell * 1.35)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	g.draw.connect(func():
		var ink = Color("7a1f3d") if hl else Color("1d3557")
		if hl: g.draw_rect(Rect2(Vector2.ZERO, g.size), Color(0.95, 0.85, 0.6, 0.6))
		var o = Vector2(cell * 0.5 + 4, cell * 0.62)
		var vv = syl["v"] if syl["v"] != "" else "a"
		var sc = 0.42 if syl["v"] != "" else 0.2
		var oo = o if syl["v"] != "" else o + Vector2(-cell * 0.15, -cell * 0.3)
		for st in K.glyph_strokes(syl["c"], vv):
			var pts = PackedVector2Array()
			for p in st: pts.append(oo + (p as Vector2) * cell * sc)
			g.draw_polyline(pts, ink, 2.2, true)
		var x = cell + 4 if syl["v"] != "" else cell * 0.5
		for f in syl["f"]:
			for st in K.glyph_strokes(f, "a"):
				var pts2 = PackedVector2Array()
				for p in st: pts2.append(Vector2(x, cell * 0.3) + (p as Vector2) * cell * 0.18)
				g.draw_polyline(pts2, ink, 1.8, true)
			x += cell * 0.4)
	vb.add_child(g)
	if label_text != "-":
		var l = Label.new()
		l.text = label_text
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color("7a1f3d") if label_text == "?" else Color("5a4632"))
		vb.add_child(l)
	return vb

func kir_line_view(text: String, show_labels: bool = true, highlight: int = -1, cell: float = 34.0) -> Control:
	var flow = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 2)
	flow.add_theme_constant_override("v_separation", 6)
	var sylls = K.syllables(text)
	for i in range(sylls.size()):
		var s: Dictionary = sylls[i]
		if s.has("sp"):
			var sp = Control.new()
			sp.custom_minimum_size = Vector2(cell * 0.45, 4)
			flow.add_child(sp)
			continue
		if s.has("p"):
			var pl = Label.new()
			pl.text = "◦"
			pl.add_theme_font_size_override("font_size", 16)
			pl.add_theme_color_override("font_color", Color("1d3557"))
			flow.add_child(pl)
			continue
		var lab = "-"
		if show_labels: lab = K.label(s) if kir_readable(s) else "?"
		flow.add_child(glyph_cell(s, lab, i == highlight, cell))
	content.add_child(flow)
	return flow

# ---- the carved stones ----

func carving_spot(depth: float, ang: float) -> Array:
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var y = cen_y_w - depth
	var rad: float
	if y > cen_cave_cy + CEN_CAVE_RY * cos(asin(T.CENOTE_R / CEN_CAVE_R)): rad = T.CENOTE_R - 0.25
	elif y < cen_cave_cy - CEN_CAVE_RY * cos(asin(4.0 / CEN_CAVE_R)) - 0.5: rad = 3.75
	else:
		var dy = (y - cen_cave_cy) / CEN_CAVE_RY
		rad = CEN_CAVE_R * sqrt(maxf(0.02, 1.0 - dy * dy)) * (1.0 + 0.1 * cave_noise(ang, y)) - 0.45
	return [Vector3(cx + cos(ang) * rad, y, cz + sin(ang) * rad), Vector3(cx, y, cz)]

func carving_texture(i: int) -> ImageTexture:
	var ink = Color(0.78, 1.0, 0.94, 1.0)
	var img: Image
	if i < 0:
		img = Image.create(640, 300, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var pics = Data.KIR_PICTURES
		for k in range(pics.size()):
			var cx0 = 64.0 + k * 128.0
			for st in kir_picture(pics[k][1]):
				var pts: Array = []
				for p in st: pts.append(Vector2(cx0, 80.0) + (p as Vector2) * 46.0)
				paint_poly(img, pts, ink, 4)
			var sub = K.image(pics[k][0], 128, 120, 34.0, ink, Color(0, 0, 0, 0), 4)
			img.blend_rect(sub, Rect2i(0, 0, 128, 120), Vector2i(int(cx0) - 64, 160))
	else:
		img = K.image(Data.KIR_STORY[i]["v"], 640, 340, 34.0, ink, Color(0, 0, 0, 0), 4)
	return ImageTexture.create_from_image(img)

func paint_poly(img: Image, pts: Array, ink: Color, thick: int):
	for k in range(pts.size() - 1):
		var a: Vector2 = pts[k]
		var b: Vector2 = pts[k + 1]
		var steps = int(maxf(a.distance_to(b), 1.0))
		for s in range(steps + 1):
			var p = a.lerp(b, float(s) / steps)
			img.fill_rect(Rect2i(int(p.x) - thick / 2, int(p.y) - thick / 2, thick, thick), ink)

func kir_picture(what: String) -> Array:
	match what:
		"fish":
			return [K.arc(Vector2(-0.1, 0.0), 0.55, 200.0, 520.0, 16), [Vector2(0.45, 0.0), Vector2(0.95, -0.4), Vector2(0.95, 0.4), Vector2(0.45, 0.0)], K.arc(Vector2(-0.4, -0.1), 0.06, 0, 360, 6)]
		"sun":
			var out = [K.arc(Vector2.ZERO, 0.4, 0, 360, 16)]
			for k in range(8):
				var a = k * TAU / 8.0
				out.append([Vector2(cos(a), sin(a)) * 0.55, Vector2(cos(a), sin(a)) * 0.85])
			return out
		"star":
			var pts: Array = []
			for k in range(11):
				var a = -PI * 0.5 + k * PI / 5.0
				pts.append(Vector2(cos(a), sin(a)) * (0.85 if k % 2 == 0 else 0.35))
			return [pts]
		"bird":
			return [[Vector2(-0.9, -0.2), Vector2(-0.4, -0.45), Vector2(0.0, 0.0), Vector2(0.4, -0.45), Vector2(0.9, -0.2)], K.arc(Vector2(0.0, 0.15), 0.15, 0, 360, 8)]
		"water":
			var w1: Array = []
			var w2: Array = []
			for k in range(17):
				var x = -0.9 + k * 0.1125
				w1.append(Vector2(x, -0.2 + sin(k * 0.8) * 0.15))
				w2.append(Vector2(x, 0.3 + sin(k * 0.8 + 1.0) * 0.15))
			return [w1, w2]
	return []

func build_carvings():
	var spots = [[3.2, 0.6]]
	for i in range(Data.KIR_STORY.size()):
		spots.append([float(Data.KIR_STORY[i]["depth"]), 1.2 + i * 0.95])
	for k in range(spots.size()):
		var idx = k - 1
		var sp = carving_spot(spots[k][0], spots[k][1])
		var node = Node3D.new()
		add_child(node)
		node.position = sp[0]
		node.look_at(sp[1], Vector3.UP)
		var w = 2.6 if idx >= 0 else 2.5
		var h = 1.4 if idx >= 0 else 1.2
		Art.box(node, Vector3(0, 0, 0.05), Vector3(w + 0.2, h + 0.2, 0.3), Color("6f8a84"))
		var q = MeshInstance3D.new()
		var qm = QuadMesh.new()
		qm.size = Vector2(w, h * (340.0 / 340.0) if idx >= 0 else h)
		q.mesh = qm
		var mat = StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_texture = carving_texture(idx)
		mat.albedo_color = Color(0.85, 1.0, 0.95, 0.9)
		mat.disable_fog = true
		q.material_override = mat
		q.position = Vector3(0, 0, -0.12)
		q.rotation.y = PI
		node.add_child(q)
		carvings.append([node, idx])

func nearest_carving() -> int:
	var best = -1
	var bd = 4.8
	for k in range(carvings.size()):
		var d = (carvings[k][0] as Node3D).global_position.distance_to(camera.global_position)
		if d < bd:
			bd = d
			best = k
	return best

func chip_pressed():
	if chip_action.is_valid():
		var c = chip_action
		c.call()
		return
	if not target.is_empty(): interact()

# ---- reading a stone ----

func read_carving(k: int):
	var idx: int = carvings[k][1]
	talk_partner = ""
	if idx < 0:
		picture_stone(0)
		return
	if kir_known_count() == 0:
		message("Strange marks", "Rows of glowing marks are carved into the stone. You can't read them yet. Maybe the stone with pictures, near the surface, can help.")
		return
	decipher(idx)

func picture_stone(step: int):
	var pics = Data.KIR_PICTURES
	if step >= pics.size():
		master("kc:pictures")
		log_event("kirmel", "picture stone read")
		clear_panel("The picture stone")
		text_line("You can read " + str(kir_known_count()) + " syllables now. Each mark is one syllable: a sound like ta or ri.", 17)
		text_line("Look closely: the shape seems to tell the first sound, and the way it is turned seems to change the vowel. Deeper stones tell a story. Dive down and try to read them.", 17)
		kir_line_view("tari riya sao par wak")
		button("Return", close_panel, content)
		return
	var p: Array = pics[step]
	learn(p[0])
	clear_panel("The picture stone (" + str(step + 1) + " of " + str(pics.size()) + ")")
	text_line("Under a carving of a " + str(p[1]) + ", there are these marks:", 17)
	kir_line_view(p[0], false, -1, 46.0)
	var opts: Array = [p[0]]
	for q in pics:
		if q[0] != p[0] and opts.size() < 3: opts.append(q[0])
	ask("What do the marks say?", opts, 0, func():
		for syl in K.syllables(p[0]): kir_learn_syl(syl)
		picture_stone.call_deferred(step + 1), "", "Think of the Tujuju word for " + str(p[1]) + ".", close_panel)

func kir_first_unknown(sylls: Array) -> int:
	for i in range(sylls.size()):
		if not kir_readable(sylls[i]): return i
	return -1

func decipher(idx: int):
	var ch: Dictionary = Data.KIR_STORY[idx]
	var sylls = K.syllables(ch["v"])
	# once you have worked out the pattern a few times, marks you can deduce read themselves
	if count_mastered("kd:") >= 3:
		var auto = 0
		for s2 in sylls:
			if kir_readable(s2) or s2["v"] == "": continue
			if kir_shape_known(s2["c"]) and kir_vowel_known(s2["v"]):
				var finals_ok = true
				for f in s2["f"]:
					if not kir_knows_final(f): finals_ok = false
				if finals_ok:
					kir_learn_syl(s2)
					auto += 1
		if auto > 0: toast("You know the pattern now: you work out " + str(auto) + " more mark" + ("s" if auto > 1 else "") + " yourself.")
	var u = kir_first_unknown(sylls)
	compact_buttons.call_deferred()
	clear_panel("Carving " + str(idx + 1) + " of " + str(Data.KIR_STORY.size()))
	if u < 0:
		master("kc:" + str(idx))
		log_event("kirmel", "chapter " + str(idx + 1))
		text_line("You can read the whole stone:", 17)
		kir_line_view(ch["v"])
		varnak_banner(ch["v"], 20)
		var en = text_line("(Tap Show meaning if you need it.)", 16)
		button("Show meaning", func(): en.text = ch["en"], content)
		text_line("The story is told with -nu: this is what people say, not what the carver saw.", 15)
		if idx == Data.KIR_STORY.size() - 1 and not mastered.has("kir:taught"): text_line("Something large moves slowly in the dark below.", 16)
		button("Story so far", show_kir_story, content)
		button("Return", close_panel, content)
		return
	var target_syl: Dictionary = sylls[u]
	text_line("Glowing marks. You can read some of them. Work out the highlighted one from the words around it.", 16)
	kir_line_view(ch["v"], true, u)
	var right = K.label(target_syl)
	var hint = ""
	var c: String = target_syl["c"]
	var v: String = target_syl["v"]
	if v != "" and kir_shape_known(c) and kir_vowel_known(v):
		hint = "You know this shape, and you know this turn. Shape = first sound, turn = vowel."
	elif v != "" and kir_shape_known(c):
		hint = "You know this shape, but not this turn. A new vowel?"
	elif v != "" and kir_vowel_known(v):
		hint = "A new shape, turned like a vowel you know."
	else:
		hint = "A new mark. Use the words around it."
	var hl = text_line(hint, 15)
	hl.add_theme_color_override("font_color", Color("6b4a2e"))
	var opts: Array = [right]
	var alts: Array = []
	for vv in K.VOWELS:
		if vv != v and v != "": alts.append(c + vv + "".join(target_syl["f"]))
	for cc in ["p", "t", "k", "m", "n", "l", "r", "s", "y", "h"]:
		if cc != c and v != "": alts.append(cc + v + "".join(target_syl["f"]))
	if v == "": alts = ["ng", "sh", "k", "t", "r", "n"]
	alts.shuffle()
	for a in alts:
		if not opts.has(a) and opts.size() < 3: opts.append(a)
	var deducible = v != "" and kir_shape_known(c) and kir_vowel_known(v)
	ask("Which syllable is it?", opts, 0, func():
		if deducible: master("kd:" + c + "|" + v)
		kir_learn_syl(target_syl)
		decipher.call_deferred(idx), "", "Read the words around it. Which Tujuju word would fit?", close_panel)

func kir_chapters_read() -> int:
	var n = 0
	for i in range(Data.KIR_STORY.size()):
		if mastered.has("kc:" + str(i)): n += 1
	return n

func show_kir_story():
	compact_buttons.call_deferred()
	clear_panel("The story on the stones")
	talk_partner = ""
	if kir_chapters_read() == 0: text_line("You haven't read any of the story yet. The carved stones are deep in the cenote.", 17)
	for i in range(Data.KIR_STORY.size()):
		if not mastered.has("kc:" + str(i)): continue
		var ch: Dictionary = Data.KIR_STORY[i]
		kir_line_view(ch["v"], false, -1, 26.0)
		varnak_banner(ch["v"], 18)
		var e = text_line("(" + str(ch["en"]) + ")", 15)
		e.add_theme_color_override("font_color", Color("6b4a2e"))
	button("Kirmel chart", show_kir_chart, content)
	button("Back", show_notebook, content)

func show_kir_chart():
	compact_buttons.call_deferred()
	clear_panel("Kirmel: the old writing")
	talk_partner = ""
	text_line("Every mark is a syllable. The shape is the first sound; the turn is the vowel (a right, e down, i left, o up, u with a line). A dot makes a sound voiced: p to b, t to d, k to g. You know " + str(kir_known_count()) + " of " + str(kir_all_keys().size()) + ".", 15)
	var grid = GridContainer.new()
	grid.columns = 6
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 2)
	content.add_child(grid)
	var head = Label.new()
	grid.add_child(head)
	for v in K.VOWELS:
		var l = Label.new()
		l.text = v
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(l)
	for c in ["", "p", "b", "t", "d", "ch", "k", "g", "m", "n", "ng", "l", "r", "s", "z", "sh", "y", "w", "h", "f", "v"]:
		var rl = Label.new()
		rl.text = c if c != "" else "(vowel)"
		rl.add_theme_font_size_override("font_size", 14)
		grid.add_child(rl)
		for v in K.VOWELS:
			if kir_knows(c, v): grid.add_child(glyph_cell({"c": c, "v": v, "f": []}, c + v, false, 28.0))
			else:
				var e = Label.new()
				e.text = "·"
				e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				grid.add_child(e)
	button("The story", show_kir_story, content)
	button("Back", show_notebook, content)

func kir_all_keys() -> Array:
	var out: Array = []
	for c in ["", "p", "b", "t", "d", "ch", "k", "g", "m", "n", "ng", "l", "r", "s", "z", "sh", "y", "w", "h", "f", "v"]:
		for v in K.VOWELS: out.append(c + "|" + v)
	return out

# ---- Var Tari ----

func build_guardian():
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	guardian = Node3D.new()
	guardian.position = Vector3(cx, cen_y_w - 47.0, cz)
	add_child(guardian)
	var body_c = Color("2f6f7a")
	var belly = Color("9fd9cf")
	var b = Art.sph(guardian, Vector3.ZERO, 0.75, body_c, Vector3(0.9, 0.85, 2.3), 16)
	b.material_override = Art.mat(body_c, 0.6, 0.25)
	var bl = Art.sph(guardian, Vector3(0, -0.28, 0.1), 0.6, belly, Vector3(0.8, 0.5, 2.0), 12)
	bl.material_override = Art.mat(belly, 0.7, 0.3)
	guardian_tail = Node3D.new()
	guardian_tail.position = Vector3(0, 0, -1.6)
	guardian.add_child(guardian_tail)
	var tail = Art.prism(guardian_tail, Vector3(0, 0, -0.45), Vector3(0.08, 1.3, 0.9), Color("3f8f96"))
	tail.material_override = Art.mat(Color("3f8f96"), 0.6, 0.35)
	var dorsal = Art.prism(guardian, Vector3(0, 0.7, -0.2), Vector3(0.06, 0.6, 1.2), Color("3f8f96"))
	dorsal.material_override = Art.mat(Color("3f8f96"), 0.6, 0.35)
	for sd in [-1.0, 1.0]:
		var fin = Art.box(guardian, Vector3(sd * 0.7, -0.15, 0.5), Vector3(0.6, 0.04, 0.35), Color("3f8f96"), Vector3(0, 0, sd * 25.0))
		fin.material_override = Art.mat(Color("3f8f96"), 0.6, 0.35)
		var eye = Art.sph(guardian, Vector3(sd * 0.42, 0.15, 1.35), 0.12, Color("fff7c8"), Vector3.ONE, 8, 2.0)
		eye.material_override = Art.mat(Color("fff7c8"), 0.3, 2.0)
		var pupil = Art.sph(guardian, Vector3(sd * 0.48, 0.15, 1.42), 0.06, Color("10202a"), Vector3.ONE, 6)
		var barbel = Art.cyl(guardian, Vector3(sd * 0.3, -0.3, 1.65), 0.015, 0.03, 0.8, Color("9fd9cf"), Vector3(70, 0, sd * 30.0), 4)
	# stars on its head, like the story says
	var rr = RandomNumberGenerator.new()
	rr.seed = 77
	for k in range(14):
		var a = rr.randf_range(-1.2, 1.2)
		var z = rr.randf_range(0.4, 1.4)
		var st = Art.sph(guardian, Vector3(sin(a) * 0.55, 0.45 + cos(a) * 0.15, z), rr.randf_range(0.03, 0.07), Color("fffbe0"), Vector3.ONE, 6, 3.0)
		st.material_override = Art.mat(Color("fffbe0"), 0.3, 3.0)
	for c in guardian.get_children():
		if c is GeometryInstance3D: c.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func update_guardian(delta: float):
	if guardian == null: return
	guardian_t += delta
	var cx = T.CENOTE.x
	var cz = T.CENOTE.y
	var home = Vector3(cx, cen_y_w - 47.0, cz)
	var p = camera.global_position
	var near = underwater and p.distance_to(guardian.position) < 14.0
	var want: Vector3
	var face: Vector3
	if near:
		var d = (p - guardian.position)
		var hd = Vector3(d.x, 0, d.z)
		want = p - d.normalized() * 3.6
		want.x = clampf(want.x, cx - 2.4, cx + 2.4)
		want.z = clampf(want.z, cz - 2.4, cz + 2.4)
		want.y = clampf(want.y, cen_bottom + 2.0, cen_y_w - 28.0)
		face = p
	else:
		var a = guardian_t * 0.12
		want = home + Vector3(cos(a) * 1.6, sin(guardian_t * 0.3) * 1.2, sin(a) * 1.6)
		face = home + Vector3(cos(a + 0.4) * 1.6, 0, sin(a + 0.4) * 1.6) + Vector3(0, want.y - home.y, 0)
	guardian.position = guardian.position.lerp(want, minf(delta * 0.35, 1.0))
	var dir = face - guardian.position
	if dir.length() > 0.1:
		var tgt = guardian.global_transform.looking_at(guardian.position - dir, Vector3.UP)
		guardian.global_transform = guardian.global_transform.interpolate_with(tgt, minf(delta * 0.8, 1.0))
	guardian_tail.rotation.y = sin(guardian_t * 1.3) * 0.35

func guardian_near() -> bool:
	return guardian != null and underwater and camera.global_position.distance_to(guardian.global_position) < 9.0

func guardian_lines() -> Array:
	var out: Array = []
	for i in range(Data.GUARDIAN_LINES.size()):
		var l: Array = Data.GUARDIAN_LINES[i]
		var ok = false
		match str(l[3]):
			"always": ok = true
			"read": ok = kir_chapters_read() > 0
			"night": ok = night > 0.5
			"fish": ok = fish_caught > 0 or completed.has("market")
			"yesen": ok = count_mastered("yesen:") > 0
			_: ok = completed.has(str(l[3]))
		if ok: out.append(i)
	return out

func guardian_listen():
	talk_partner = ""
	if not mastered.has("kg:met"):
		master("kg:met")
		learn("var tari")
		log_event("guardian", "met")
	var lines = guardian_lines()
	var pick = lines[0]
	for i in lines:
		if not mastered.has("kg:" + str(i)):
			pick = i
			break
	if mastered.has("kg:" + str(pick)) and lines.size() > 1:
		guardian_line = (guardian_line + 1) % lines.size()
		pick = lines[guardian_line]
	var l: Array = Data.GUARDIAN_LINES[pick]
	play_sfx("hum", -4.0)
	compact_buttons.call_deferred()
	clear_panel("Var Tari, the great fish")
	text_line("The great fish turns one huge, gentle eye toward you. The water hums.", 16)
	varnak_banner(l[0], 22)
	var en = text_line("(Tap Show meaning if you need it.)", 16)
	button("Show meaning", func(): en.text = "(" + str(l[1]) + ")", content)
	var opts = ["It saw it with its own eyes (-da)", "Someone told it (-nu)", "It worked it out (-shi)"]
	var right = {"da": 0, "nu": 1, "shi": 2}[str(l[2])]
	var ordered: Array = [opts[right]]
	for k in range(3):
		if k != right: ordered.append(opts[k])
	ask("Var Tari only says what it knows. How does it know this?", ordered, 0, func(): master("kg:" + str(pick)), "", "Listen to the ending of the verb: -da, -nu or -shi.", close_panel, func():
		button("Listen again", guardian_listen, content)
		if kir_chapters_read() >= Data.KIR_STORY.size() and not mastered.has("kir:taught"):
			button("Ask about the writing", guardian_teach, content))

func guardian_teach():
	for k in kir_all_keys():
		master("ky:" + str(k))
	for c in ["p", "b", "t", "d", "ch", "k", "g", "m", "n", "ng", "l", "r", "s", "z", "sh", "y", "w", "h", "f", "v"]: master("kf:" + c)
	master("kir:taught")
	log_event("kirmel", "taught by Var Tari")
	play_sfx("hum", 0.0)
	clear_panel("Var Tari remembers")
	varnak_banner("Anke kirmel k-i-zen-da. Ti-ru kirmel k-i-ven-fu-da.", 20)
	text_line("(I know the writing. I will give the writing to you.)", 15)
	text_line("The great fish breathes out slowly. Every glowing mark in the cenote brightens at once, and suddenly you can read all of them: every shape, every turn.", 17)
	text_line("Bring kirmel back to the village. Suri, the teacher at the school, will know what to do.", 17)
	toast("You can read all of kirmel now!")
	button("Kirmel chart", show_kir_chart, content)
	button("Return", close_panel, content)

# ---- bringing the writing home ----

func kir_options(name_text: String) -> Array:
	var sylls = K.syllables(name_text)
	var wrong1 = sylls.duplicate(true)
	var wrong2 = sylls.duplicate(true)
	for s in wrong1:
		if s.has("v") and s["v"] != "":
			s["v"] = {"a": "i", "e": "o", "i": "a", "o": "e", "u": "a"}[s["v"]]
			break
	for s in wrong2:
		if s.has("c") and s["c"] != "":
			s["c"] = {"t": "p", "p": "t", "k": "m", "m": "k", "s": "r", "r": "s", "n": "l", "l": "n", "v": "f", "y": "w", "w": "y", "g": "k", "d": "t", "sh": "s"}.get(s["c"], "h")
			break
	return [sylls, wrong1, wrong2]

func suri_kirmel(step: int):
	var names = ["Suri", "Ketu", "Tujuju"]
	talk_partner = "suri"
	if step >= names.size():
		complete("kirmel")
		log_event("kirmel", "brought home")
		apply_kirmel_signs()
		clear_panel("Kirmel comes home")
		add_portrait("suri")
		emote("suri", "love", 4.0)
		varnak_banner("Kirmel i-ho-ho! Senakma polu kirmel ri-rav-fu-da!", 20)
		text_line("(The writing is wonderful! At the school, everyone will read the writing!)", 15)
		text_line("Suri copies your chart onto the big board. By evening the village signs have kirmel on them, and the old writing shows above Tujuju sentences everywhere.", 17)
		button("Return", close_panel, content)
		return
	clear_panel("Teach Suri kirmel (" + str(step + 1) + " of " + str(names.size()) + ")")
	add_portrait("suri")
	text_line("Suri asks: how do you write “" + names[step] + "”?", 17)
	var opts = kir_options(names[step])
	var order = [0, 1, 2]
	order.shuffle()
	var fb = text_line("", 16)
	for k in order:
		var b = Button.new()
		b.custom_minimum_size = Vector2(0, 66)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var syl: Array = opts[k]
		var drawc = Control.new()
		drawc.set_anchors_preset(Control.PRESET_FULL_RECT)
		drawc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		drawc.draw.connect(func(): K.draw_on(drawc, syl, Vector2(16, 6), 38.0, 400.0, Color("1d3557"), 2.6))
		b.add_child(drawc)
		var kk = k
		b.pressed.connect(func():
			log_event("answer", {"activity": "Teach Suri kirmel", "item": names[step], "chose": str(kk), "correct": "0"}, kk == 0)
			if kk == 0:
				play_sfx("correct", -4.0)
				suri_kirmel.call_deferred(step + 1)
			else:
				play_sfx("wrong", -4.0)
				fb.text = "Suri tilts her head. Look at the turn of each mark (the vowel) and its shape (the first sound)."
				fb.add_theme_color_override("font_color", Color("8a2f1f")))
		content.add_child(b)
	button("Back", talk.bind("suri"), content)

func apply_kirmel_signs():
	for s in Art.signs:
		var node = s as Node3D
		if not is_instance_valid(node) or node.has_meta("kir_done"): continue
		node.set_meta("kir_done", true)
		var text = str(node.get_meta("text")).replace("\n", " ")
		var img = K.image(text, 256, 80, 24.0, Color("2b1d14"), Color(0, 0, 0, 0), 3)
		var tex = ImageTexture.create_from_image(img)
		Art.box(node, Vector3(0, 1.08, 0.06), Vector3(1.05, 0.34, 0.06), Color("e8d8b0"))
		for back in [false, true]:
			var sp = Sprite3D.new()
			sp.texture = tex
			sp.pixel_size = 0.004
			sp.position = Vector3(0, 1.08, 0.095 if not back else 0.025)
			if back: sp.rotation_degrees.y = 180
			sp.double_sided = false
			sp.visibility_range_end = 30.0
			node.add_child(sp)

func _exit_tree():
	Art.signs.clear()
