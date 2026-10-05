extends Node3D

const SAVE = "user://varnak_island.json"
var player: CharacterBody3D
var camera: Camera3D
var ui: Control
var status: Label
var prompt: Label
var panel: PanelContainer
var content: VBoxContainer
var interact_button: Button
var joy: Vector2 = Vector2.ZERO
var move_finger: int = -1
var look_finger: int = -1
var joy_origin: Vector2
var mouse_look: bool = false
var left_down: bool = false
var left_drag: float = 0.0
var hint_time: float = 0.0
var entities: Array = []
var inventory: Array = []
var discovered: Array = []
var completed: Array = []
var target: Dictionary = {}
var clock: float = 0.0
var save_clock: float = 0.0
var lesson: String = ""
var guesses: Dictionary = {}
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

func _ready():
	build_world()
	build_ui()
	load_game()
	show_intro()

func material(color: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m

func box(pos: Vector3, size: Vector3, color: Color, solid: bool = true) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var shape = BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	mesh.position = pos
	add_child(mesh)
	if solid:
		var body = StaticBody3D.new()
		var collider = CollisionShape3D.new()
		var collision = BoxShape3D.new()
		collision.size = size
		collider.shape = collision
		body.add_child(collider)
		mesh.add_child(body)
	return mesh

func sphere(parent: Node3D, pos: Vector3, radius: float, color: Color):
	var mesh = MeshInstance3D.new()
	var shape = SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	shape.radial_segments = 12
	shape.rings = 6
	mesh.mesh = shape
	mesh.material_override = material(color)
	mesh.position = pos
	parent.add_child(mesh)

func label3(parent: Node3D, text: String, pos: Vector3):
	var label = Label3D.new()
	label.text = text
	label.position = pos
	label.font_size = 36
	label.pixel_size = 0.008
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)

func entity(id: String, kind: String, word: String, pos: Vector3, color: Color):
	var node = Node3D.new()
	node.position = pos
	add_child(node)
	if kind == "npc":
		sphere(node, Vector3(0,1.65,0),0.25,Color("d6ac83"))
		var mesh = MeshInstance3D.new()
		var shape = CylinderMesh.new()
		shape.top_radius = 0.22
		shape.bottom_radius = 0.38
		shape.height = 1.1
		mesh.mesh = shape
		mesh.position.y = 0.85
		mesh.material_override = material(color)
		node.add_child(mesh)
		label3(node,word,Vector3(0,2.2,0))
	else:
		sphere(node,Vector3(0,0.6,0),0.24,color)
		label3(node,word,Vector3(0,1.05,0))
	entities.append({"id":id,"kind":kind,"word":word,"node":node,"home":pos})

func build_world():
	var environment = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("a9d9e3")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("c2d8e5")
	env.ambient_light_energy = 0.65
	env.fog_enabled = true
	env.fog_light_color = Color("a9d9e3")
	env.fog_density = 0.006
	environment.environment = env
	add_child(environment)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45,-25,0)
	sun.light_energy = 1.1
	add_child(sun)
	box(Vector3(0,-0.8,0),Vector3(250,0.2,250),Color("317e9a"),false)
	box(Vector3(0,-0.3,0),Vector3(76,0.6,94),Color("d5c393"))
	box(Vector3(0,0.015,-7),Vector3(58,0.03,65),Color("769f67"),false)
	# The bright path leads north, toward negative Z.
	box(Vector3(0,0.04,-4),Vector3(4,0.08,82),Color("bbaa85"),false)
	box(Vector3(0,0.08,36),Vector3(8,0.16,12),Color("99744c"))
	box(Vector3(-8,0.5,39),Vector3(3,1,6),Color("624839"))
	for p in [Vector3(-9,1.5,12),Vector3(10,1.5,7),Vector3(-11,1.5,1),Vector3(12,1.5,-4)]:
		box(p,Vector3(5,3,5),Color("d9b88f"))
		box(p+Vector3(0,1.9,0),Vector3(6,0.8,6),Color("b5654a"))
		box(p+Vector3(0,-0.5,2.53),Vector3(1.2,2,0.1),Color("5c4b3e"),false)
	var rng = RandomNumberGenerator.new()
	rng.seed = 70426
	for i in range(48):
		var x = rng.randf_range(-30,30)
		if abs(x) < 5: x += 7
		var z = rng.randf_range(-32,-5)
		box(Vector3(x,1.2,z),Vector3(0.5,2.4,0.5),Color("755b40"))
		sphere(self,Vector3(x,3,z),1.6,Color("477b59"))
	box(Vector3(0,0.06,-23),Vector3(70,0.08,5),Color("428ea3"),false)
	box(Vector3(0,0.14,-23),Vector3(3,0.2,7),Color("8e7252"))
	for z in [28,15,-8,-19,-32]:
		box(Vector3(3,0.7,z),Vector3(0.2,1.4,0.2),Color("735b42"))
		var sign = Node3D.new()
		sign.position = Vector3(3,1.7,z)
		add_child(sign)
		label3(sign,"bei\n↑",Vector3.ZERO)
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
	entity("bird","observe","par",Vector3(-6,0,-5),Color("ead8a4"))
	entity("fish","observe","tari",Vector3(6,0,-22),Color("7bb9c7"))
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
	camera.current = true
	player.add_child(camera)

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
	var theme = Theme.new()
	theme.default_font_size = 19
	ui.theme = theme
	status = Label.new()
	status.position = Vector2(20,38)
	status.size = Vector2(440,68)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(status)
	var top = HBoxContainer.new()
	top.position = Vector2(20,110)
	ui.add_child(top)
	button("Notebook",show_notebook,top)
	button("Bag",show_inventory,top)
	button("Map",show_map,top)
	prompt = Label.new()
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	prompt.position = Vector2(-130,-40)
	prompt.size = Vector2(260,80)
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ui.add_child(prompt)
	var cross = Label.new()
	cross.text = "+"
	cross.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	cross.position = Vector2(-7,30)
	ui.add_child(cross)
	var move = Label.new()
	move.text = "MOVE\nDrag here"
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

func clear_panel(title: String):
	joy = Vector2.ZERO
	move_finger = -1
	look_finger = -1
	mouse_look = false
	for c in content.get_children():
		content.remove_child(c)
		c.queue_free()
	panel.show()
	text_line(title,26)

func text_line(text: String, font_size: int = 20):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size",font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(label)

func close_panel():
	panel.hide()
	lesson = ""

func show_intro():
	clear_panel("TuJuJu Studios\nVarnak Island")
	text_line("Your friend Neri is somewhere on this island. Learn Varnak through objects, requests and clues to find them.")
	text_line("Portrait controls: drag the lower left to walk; swipe the right side to look. Approach an object or person and tap Interact.\n\nDesktop: W/S walk, A/D sidestep, left/right arrows turn, drag with the mouse to look around. Walk up to an object or person, then click it or press E.\n\nNorth is along the main path. Notebook meanings are optional hints. Progress saves automatically.")
	button("Explore",close_panel,content)

func learn(word: String):
	if words.has(word) and not discovered.has(word): discovered.append(word)

func complete(id: String):
	if not completed.has(id): completed.append(id)
	save_game()

func objective() -> String:
	for q in quests:
		if not completed.has(q[0]): return q[1]
	return "Neri found. Keep exploring and practicing Varnak."

func _physics_process(delta):
	clock += delta
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
	target = {}
	var best = 3.4
	for e in entities:
		var node = e["node"] as Node3D
		if not node.visible: continue
		var distance = player.position.distance_to(node.position)
		if distance < best:
			best = distance
			target = e
		if e["kind"] == "npc":
			node.rotation.y = sin(clock * 0.35 + float(entities.find(e))) * 0.12
	hint_time -= delta
	if hint_time > 0.0: pass
	elif target.is_empty(): prompt.text = ""
	else: prompt.text = str(target.get("word", "")) + "\n(click it, press E, or tap Interact)"
	interact_button.disabled = target.is_empty()

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
		hint_time = 2.5

func look(amount: Vector2):
	player.rotation.y -= amount.x * 0.004
	camera.rotation.x = clampf(camera.rotation.x - amount.y * 0.004,-1.05,1.05)

func interact():
	if target.is_empty(): return
	var e = target.duplicate()
	if e["kind"] == "npc":
		talk(e["id"])
	else:
		learn(e["word"])
		clear_panel(e["word"])
		text_line("You examine the object. Its name is now in your notebook.")
		if e["kind"] == "item":
			button("Pick up",func():
				inventory.append(e["id"])
				e["node"].hide()
				save_game()
				close_panel(),content)
		button("Return",close_panel,content)

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

func show_notebook():
	clear_panel("Field notebook")
	text_line("Collected forms. Tap a word to reveal its meaning and parts.")
	if discovered.is_empty(): text_line("Examine objects and talk to residents to collect words.")
	for word in discovered:
		button(word,reveal_word.bind(word),content)
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

func show_inventory():
	clear_panel("Your bag")
	if inventory.is_empty(): text_line("Your bag is empty.")
	for id in inventory:
		for e in entities:
			if e["id"] == id: text_line(e["word"])
	button("Return",close_panel,content)

func show_map():
	clear_panel("Island guide")
	text_line("NORTH\n\nNorthern cove: Neri\nFar bank: Oren\nRiver crossing: Tor\nForest path: Sanu\nVillage: Mira and Lira\nHarbor: Ena\n\nSOUTH\n\nThe light path connects all areas. North is marked bei on the signs.")
	text_line("Current objective:\n" + objective())
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
		for e in entities: e["node"].show()
		player.position = Vector3(0,0.1,36)
		player.rotation = Vector3.ZERO
		camera.rotation = Vector3.ZERO
		save_game()
		show_intro(),content)

func save_game():
	var file = FileAccess.open(SAVE,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"guesses":guesses,"inventory":inventory,"discovered":discovered,"completed":completed,"position":[player.position.x,player.position.y,player.position.z],"yaw":player.rotation.y,"pitch":camera.rotation.x}))

func load_game():
	if not FileAccess.file_exists(SAVE): return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE))
	if not data is Dictionary: return
	guesses = data.get("guesses",{})
	inventory = data.get("inventory",[])
	discovered = data.get("discovered",[])
	completed = data.get("completed",[])
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

func _notification(what):
	if what == NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(player): save_game()
