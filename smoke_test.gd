extends SceneTree
const Data = preload("res://data.gd")
const T = preload("res://terrain.gd")
var game
func _initialize():
	call_deferred("run")
func press(label: String):
	var b = find_button(game.content, label)
	assert(b != null, "Missing button: " + label)
	if b: b.pressed.emit()
func find_button(node: Node, label: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == label and not child.disabled: return child
		var deeper = find_button(child, label)
		if deeper: return deeper
	return null
func run():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.inventory.clear()
	game.completed.clear()
	game.discovered.clear()
	game.inventory = ["own_bag"]
	game.talk("ena")
	press("Anni kel")
	assert(game.completed.has("belongings"))
	game.inventory.append_array(["water","fruit","container"])
	game.talk("mira")
	press("Offer supplies")
	assert(game.completed.has("meal"))
	assert(not game.inventory.has("water"))
	game.inventory.append("forest_bag")
	game.talk("sanu")
	press("Offer the forest bag")
	assert(game.completed.has("bag"))
	game.inventory.append_array(["wood","stone","rope"])
	game.talk("tor")
	press("Offer repair materials")
	assert(game.completed.has("bridge"))
	game.account("tor","italpada","Witnessed")
	game.talk("lira")
	game.talk("oren")
	game.check_evidence("Lira: italpanu")
	assert(not game.completed.has("evidence"))
	game.check_evidence("Tor: italpada")
	assert(game.completed.has("evidence"))
	game.talk("neri")
	assert(game.completed.has("cove"))
	game.player.position = Vector3(2,0.1,6)
	game.save_game()
	game.completed.clear()
	game.load_game()
	assert(game.completed.has("cove"))
	assert(game.player.position.x == 2)
	game.show_notebook()
	game.show_inventory()
	game.show_map()
	# ---- expansion: data integrity ----
	for sid in Data.SENTENCES.keys():
		var s = Data.SENTENCES[sid]
		assert(s["wrong"].size() == 2, "two wrong options for " + sid)
		for w in s["words"]: assert(game.words.has(w), "no gloss for " + w + " in " + sid)
	for id in Data.DOORS.keys():
		for w in Data.DOORS[id]["words"]: assert(game.words.has(w), "no gloss for " + w)
		assert(Data.DOORS[id]["options"].size() == 3)
	for id in Data.COUNTS.keys():
		assert(game.words.has(Data.COUNTS[id]["noun"]) and game.words.has(Data.COUNTS[id]["numword"]))
	for r in Data.NOUNS.keys(): assert(game.words.has(r), "noun gloss " + r)
	for s in Data.SUFFIXES.keys(): assert(game.words.has("-" + s), "suffix gloss " + s)
	# ---- expansion: sentence cards ----
	game.discovered.clear()
	game.phrases.clear()
	game.mastered.clear()
	game.solved.clear()
	for sid in Data.SENTENCES.keys():
		game.sentence_card(sid)
		assert(game.phrases.has(sid))
		press(Data.SENTENCES[sid]["en"])
		assert(game.mastered.has("s:" + sid))
	game.show_phrasebook()
	# ---- expansion: doors ----
	for id in Data.DOORS.keys():
		game.door_puzzle(id)
		var d = Data.DOORS[id]
		var wrong = d["options"][(d["correct"] + 1) % 3]
		press(wrong)
		assert(not game.solved.has(id))
		press(d["options"][d["correct"]])
		assert(game.solved.has(id))
		press("Return")
	# ---- expansion: counting, fishing, where, story ----
	game.count_puzzle("cairn")
	press("mur")
	assert(game.discovered.has("sek") and game.discovered.has("mur"))
	game.count_puzzle("flowers")
	press("kes")
	game.count_puzzle("basket")
	press("pan")
	game.fish_caught = 0
	game.mastered.erase("w:nuk")
	game.fishing()
	press("Na-tari-nuk-im.")
	press("Now catch one")
	press("Anke tari k-i-nuk-ak-pa-da.")
	assert(game.fish_caught == 1)
	game.where_puzzle("lira")
	press(Data.WHERE["lira"]["options"][0])
	game.where_puzzle("tor")
	press(Data.WHERE["tor"]["options"][1])
	game.neri_story()
	press("Kelarke tari i-nuk-ak-pa-da.")
	# ---- expansion: workshop and practice ----
	for w in ["tari", "teka", "mora", "dom", "wak", "guro"]: game.learn(w)
	game.show_workshop()
	game.workshop_noun("tari")
	press("-ma")
	game.workshop_noun("teka")
	press("-ir")
	assert(game.discovered.has("-ma") and game.discovered.has("-ir"))
	for i in range(6): game.workshop_challenge()
	for i in range(12): game.show_practice()
	game.show_notebook()
	game.show_map()
	# ---- expansion: every entity can be used ----
	game.close_panel()
	for e in game.entities:
		if e["kind"] == "star": continue
		game.target = e
		game.interact()
		assert(game.panel.visible, "panel for " + e["id"])
		game.close_panel()
	for e in game.entities:
		if e["kind"] == "item":
			game.target = e
			game.interact()
			press("Pick up")
	# ---- expansion: world state reacts to quests ----
	game.completed.clear()
	game.refresh_world()
	assert(not game.bridge_info["planks"][4].visible)
	game.complete("bridge")
	assert(game.bridge_info["planks"][4].visible)
	game.complete("meal")
	assert(game.table_node.get_meta("feast").visible)
	assert(game.houses["house1"].get_meta("door").rotation_degrees.y != 0.0)
	# ---- expansion: save and load round trip ----
	game.save_game()
	var kept_phrases = game.phrases.size()
	var kept_fish = game.fish_caught
	game.phrases.clear()
	game.solved.clear()
	game.mastered.clear()
	game.fish_caught = 0
	game.load_game()
	assert(game.phrases.size() == kept_phrases and game.fish_caught == kept_fish and game.solved.size() == 4)
	# ---- second expansion: side quests ----
	game.close_panel()
	game.completed.clear()
	game.inventory.clear()
	game.fish_caught = 1
	game.talk("ketu")
	press("Give mur tari (3 fish)")
	assert(not game.completed.has("market"))
	game.mastered.append("w:nuk")
	game.fishing()
	game.fishing()
	assert(game.fish_caught == 3)
	game.talk("ketu")
	press("Give mur tari (3 fish)")
	assert(game.completed.has("market") and game.inventory.has("tea") and game.fish_caught == 0)
	for i in range(4):
		game.school_quiz(i)
		var q = Data.SCHOOL[i]
		press(q["options"][(q["correct"] + 1) % 3])
		assert(i < 3 or not game.completed.has("school"))
		press(q["options"][q["correct"]])
	assert(game.completed.has("school"))
	for i in range(3):
		game.lookout_quiz(i)
		press(Data.LOOKOUT[i]["options"][Data.LOOKOUT[i]["correct"]])
	assert(game.completed.has("lookout"))
	game.talk("vira")
	press("Listen to Ila")
	press(Data.PAIN["options"][Data.PAIN["correct"]])
	assert(game.solved.has("pain"))
	game.talk("vira")
	press("Offer yok and cha")
	assert(not game.completed.has("healer"))
	game.inventory.append("herb")
	game.talk("vira")
	press("Offer yok and cha")
	assert(game.completed.has("healer") and not game.inventory.has("tea"))
	game.talk("yalo")
	press("Offer far (fire)")
	assert(not game.completed.has("lighthouse"))
	game.inventory.append("torch")
	game.talk("yalo")
	press("Offer far (fire)")
	press("Make the lighthouse dark!")
	assert(not game.completed.has("lighthouse") and game.inventory.has("torch"))
	press("Make the lighthouse bright!")
	assert(game.completed.has("lighthouse") and not game.inventory.has("torch"))
	assert(game.lighthouse_node.get_meta("beam").visible)
	for i in range(4):
		game.desh_round(i, Data.DESH)
		press(Data.DESH[i]["act"])
	assert(game.completed.has("lagoon"))
	game.identity_puzzle()
	press("An kelar na-an-da.")
	assert(game.mastered.has("q:ola"))
	for id in ["ketu","suri","rin","ola","pomo","vira","ila","yalo","desh","neri"]:
		game.talk(id)
		assert(game.panel.visible)
	for id in Data.COUNTS.keys():
		game.count_puzzle(id)
		press(Data.COUNTS[id]["numword"])
		assert(game.mastered.has("w:" + Data.COUNTS[id]["numword"]))
	# ---- quest marks follow progress ----
	game.completed.clear()
	game.update_marks()
	var marks = {}
	for e in game.entities:
		if e.has("mark"): marks[e["id"]] = e["mark"].visible
	assert(marks["ena"] and not marks["mira"] and marks["ketu"] and marks["desh"] and not marks["sair1"])
	game.complete("market")
	for e in game.entities:
		if e["id"] == "ketu": assert(not e["mark"].visible)
	# ---- picking: aim at a person, an item and a far object ----
	game.close_panel()
	game.player.position = Vector3(0, 0.1, 28)
	game.player.rotation = Vector3.ZERO
	game.camera.rotation = Vector3.ZERO
	game.player.rotation.y = 0.0
	await physics_frame
	await process_frame
	for want in ["ena", "own_bag", "water"]:
		var ent = null
		for e in game.entities:
			if e["id"] == want: ent = e
		ent["node"].show()
		game.player.look_at(Vector3(ent["node"].global_position.x, game.player.position.y, ent["node"].global_position.z) * Vector3(1, 1, 1), Vector3.UP)
		game.player.rotation.x = 0.0
		game.camera.rotation.x = -0.25
		await process_frame
		var c = ent["node"].global_position + Vector3(0, float(ent["ph"]) * 0.5, 0)
		var sp = game.camera.unproject_position(c)
		var got = game.pick_at(sp)
		assert(not got.is_empty() and got["id"] == want, "picked " + str(got.get("id", "nothing")) + " for " + want)
		game.pick_at(sp + Vector2(14, 10))
	var far_e = null
	for e in game.entities:
		if e["id"] == "mira": far_e = e
	game.player.position = Vector3(0, 0.1, 24)
	game.player.look_at(Vector3(far_e["node"].global_position.x, game.player.position.y, far_e["node"].global_position.z), Vector3.UP)
	game.camera.rotation.x = 0.0
	await process_frame
	game.tap(game.camera.unproject_position(far_e["node"].global_position + Vector3(0, 1.0, 0)))
	assert(not game.walk_to.is_empty() and game.walk_to["id"] == "mira")
	for i in range(240):
		await physics_frame
		if game.panel.visible: break
	assert(game.panel.visible, "auto-walk reached Mira")
	game.close_panel()
	# ---- terrain: everything stands on reachable land ----
	var walk = {}
	var q2 = [Vector2i(0, 34), Vector2i(48, 72)]
	walk[q2[0]] = true
	walk[q2[1]] = true
	var head = 0
	while head < q2.size():
		var c2 = q2[head]
		head += 1
		for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var n = c2 + d
			if walk.has(n) or abs(n.x) > 95 or n.y < -80 or n.y > 99: continue
			var crossing = (abs(n.x) <= 1 and n.y > -27 and n.y < -19) or (n.x == -30 and n.y > -27 and n.y < -19) or (n.x == 52 and n.y > -33 and n.y < -20) or (abs(n.x) <= 3 and n.y >= 30 and n.y <= 42) or (n.x == 48 and n.y >= 66 and n.y <= 74)
			if T.deep(n.x, n.y) and not crossing: continue
			if game.is_blocked(n.x, n.y, -0.6): continue
			walk[n] = true
			q2.append(n)
	for e in game.entities:
		var h: Vector3 = e["home"]
		if e["word"] == "tari" and e["kind"] == "observe": continue
		if e["id"] == "ferry": continue
		var near_ok = false
		for dx in range(-3, 4):
			for dz in range(-3, 4):
				if walk.has(Vector2i(roundi(h.x) + dx, roundi(h.z) + dz)): near_ok = true
		assert(near_ok, "cannot reach " + e["id"])
		if e["kind"] != "observe" and e["id"] != "boat" and not game.near_dock(h): assert(T.height(h.x, h.z) > -0.3, e["id"] + " is in the water")
	# ---- travel and map ----
	game.visited = ["market", "lagoon", "village"]
	game.show_map()
	game.travel("lagoon")
	assert(game.player.position.distance_to(Vector3(63, game.player.position.y, 20)) < 1.0)
	game.show_map()
	assert(game.map_tex != null)
	# ---- third expansion ----
	game.close_panel()
	game.completed.clear()
	game.inventory.clear()
	game.solved.clear()
	game.gin = 0
	game.refresh_world()
	# quest box folds
	game.hud_small = false
	game._on_status_input(_click())
	assert(game.hud_small and game.status_small.visible and not game.status.visible)
	game._on_status_input(_click())
	assert(not game.hud_small)
	# market economy and the dog
	game.complete("market")
	game.fish_caught = 2
	game.talk("ketu")
	press("Sell a fish: tari yan, gin yan")
	press("Sell a fish: tari yan, gin yan")
	assert(game.gin == 2 and game.fish_caught == 0)
	game.buy_bread()
	press("Yan panak t-na-ven-o-ye.")
	press("Pay vel gin (2 coins)")
	assert(game.inventory.has("bread") and game.gin == 0)
	game.target = game.entity_by_id("dog")
	game.interact()
	press("Share the panak")
	assert(game.completed.has("dog"))
	var follows = false
	for a in game.animals:
		if a["e"]["id"] == "dog": follows = a.get("follow", false)
	assert(follows)
	# mail
	game.talk("gav")
	press("Take the parcels")
	assert(game.inventory.has("parcel_yalo"))
	game.give_parcel("ketu")
	press("kel: Yalo-ru")
	assert(game.inventory.has("parcel_yalo"))
	for who in ["ketu", "yalo", "oku"]:
		game.give_parcel(who)
		press("kel: " + who.capitalize() + "-ru")
	assert(not game.has_any_parcel())
	game.talk("gav")
	assert(game.completed.has("mail") and game.gin == 5)
	# hide and seek
	game.talk("ola")
	press("Play hide and seek")
	assert(game.hiding["rin"] and game.hiding["ola"])
	game.talk("rin")
	press("T-na-pal-da!")
	assert(game.hiding["rin"])
	press("K-ta-pal-da!")
	game.talk("ola")
	press("K-ta-pal-da!")
	assert(game.completed.has("hide"))
	# riddles
	for i in range(5):
		game.riddle_quiz(i)
		press(Data.RIDDLES[i]["options"][Data.RIDDLES[i]["correct"]])
	assert(game.completed.has("riddles") and game.phrases.has("room_behind"))
	# cave, map, mounds, treasure
	game.cave_panel()
	press("Search behind the crystals")
	assert(game.inventory.has("map"))
	assert(game.entity_by_id("mound_behind")["node"].visible)
	game.mound_panel("mound_front")
	press("Dig here")
	assert(not game.completed.has("treasure"))
	game.mound_panel("mound_behind")
	press("Dig here")
	assert(game.completed.has("treasure") and game.gin == 15 and game.chest_node.visible)
	assert(not game.entity_by_id("mound_behind")["node"].visible)
	# sea stars
	for i in range(8):
		var st = game.entity_by_id("star" + str(i + 1))
		var sp: Vector3 = st["home"]
		assert(T.coast(sp.x, sp.z) > 3.0 and T.height(sp.x, sp.z) > -0.1, "star on a beach " + str(sp))
		game.collect_star(st)
	assert(game.completed.has("seastars"))
	# ferry ride
	game.close_panel()
	game.ride_puzzle(true)
	press("Sendor-ta t-na-tar-o-ye.")
	press("Sendor-ru t-na-tar-o-ye.")
	press("Set off!")
	assert(game.riding)
	for i in range(40):
		game.update_ride(0.5)
		if not game.riding: break
	assert(not game.riding and game.player.position.distance_to(Vector3(48, 0.15, 70.5)) < 0.5, "arrived on Sendor")
	game.ride_puzzle(false)
	press("Teka-ru t-na-tar-o-ye.")
	press("Set off!")
	for i in range(40):
		game.update_ride(0.5)
		if not game.riding: break
	assert(game.player.position.z < 43.0, "back at the harbor")
	# production practice
	for i in range(Data.TILES.size()):
		game.tile_puzzle(i)
		for w in Data.TILES[i]["tiles"]: press(w)
		press("Check")
		assert(game.mastered.has("t:" + str(i)), "tiles " + str(i))
	game.tile_puzzle(1)
	press("Kelarke")
	press("Check")
	assert(game.content.get_children().any(func(c): return c is Label and c.text.begins_with("Not quite")))
	for i in range(Data.VERBS.size()):
		var target: String = Data.VERBS[i][1]
		var parts = target.split("-")
		var ch = {0: "", 1: "", 2: "", 3: "", 4: "", 5: ""}
		var k = 0
		if parts[0] == "ma":
			ch[0] = "ma-"
			k = 1
		ch[1] = parts[k] + "-"
		ch[2] = parts[k + 1]
		for p in parts.slice(k + 2):
			if p in ["im", "ak", "ur"]: ch[3] = "-" + p
			elif p in ["pa", "fu"]: ch[4] = "-" + p
			elif p in ["da", "shi", "nu"]: ch[5] = "-" + p
		assert(game.verb_form(ch) == target, "verb " + target + " got " + game.verb_form(ch))
	game.show_verb_builder(3)
	game.show_notebook()
	# time, weather, whale
	for t in [0.0, 0.2, 0.4, 0.62, 0.8, 0.95]:
		game.day_t = t
		game.update_sky(0.0)
	assert(game.time_word == "salma")
	game.day_t = 0.8
	game.update_sky(0.0)
	assert(game.night > 0.9 and game.moon.visible)
	game.start_rain()
	assert(game.raining > 0.0 and game.phrases.has("rain_starts"))
	game.player.position = Vector3(0, 0.1, 41)
	assert(game.try_whale(true))
	game.day_t = 0.3
	game.update_sky(0.0)
	game.show_map()
	game.show_inventory()
	print("PASS: third expansion: quest box, shop, dog, mail, hide and seek, riddles, treasure, sea stars, ferry, builders, sky")
	print("PASS: second expansion quests, marks, picking, auto-walk, reachability, travel, map")
	print("PASS: expansion data, sentence cards, doors, counting, fishing, workshop, practice, entities, world state, persistence")
	game.inventory.clear()
	game.discovered.clear()
	game.completed.clear()
	game.phrases.clear()
	game.solved.clear()
	game.mastered.clear()
	game.fish_caught = 0
	game.player.position = Vector3(0,0.1,36)
	game.refresh_world()
	game.save_game()
	print("PASS: six quests, wrong/correct evidence, inventory, persistence, panels")
	quit()

func _click() -> InputEventMouseButton:
	var ev = InputEventMouseButton.new()
	ev.pressed = true
	ev.button_index = MOUSE_BUTTON_LEFT
	return ev
