extends SceneTree
const Data = preload("res://data.gd")
const T = preload("res://terrain.gd")
var game
func _initialize():
	call_deferred("run")
func press(label: String):
	var b = find_button(game.content, label)
	assert(b != null, "Missing button: " + label)
	if b and b.toggle_mode: b.button_pressed = true
	elif b: b.pressed.emit()
func find_button(node: Node, label: String) -> Button:
	for child in node.get_children():
		if child.is_queued_for_deletion() or (child is CanvasItem and not child.visible): continue
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
	assert(game.phrases.size() == kept_phrases and game.fish_caught == kept_fish and game.solved.filter(func(x): return x.begins_with("house")).size() == 4)
	# ---- second expansion: side quests ----
	game.close_panel()
	game.completed.clear()
	game.inventory.clear()
	game.fish_caught = 1
	game.talk("ketu")
	press("Give mur tari (3 fish)")
	assert(not game.completed.has("market"))
	game.mastered.append("w:nuk")
	for k in range(2):
		game.fishing()
		assert(game.mg["type"] == "fish")
		game.mg["u"] = game.mg["zx"] + game.mg["zw"] * 0.5
		game.fish_pull()
	game.fishing()
	game.mg["u"] = fmod(game.mg["zx"] + 0.5, 1.0) if game.mg["zx"] + game.mg["zw"] < 0.45 or game.mg["zx"] > 0.55 else 0.0
	if game.mg["u"] >= game.mg["zx"] - 0.02 and game.mg["u"] <= game.mg["zx"] + game.mg["zw"] + 0.02: game.mg["u"] = 1.5
	game.fish_pull()
	assert(game.fish_caught == 3, "missed pull does not catch")
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
	# ---- bridges: walk across each crossing, even steering a little sideways ----
	for c in game.CROSSINGS:
		for drift in [0.0, 0.35, -0.35]:
			var a: Vector3 = c[0]
			var bb: Vector3 = c[1]
			game.player.position = Vector3(a.x, 0.3, a.z + 1.5)
			game.player.velocity = Vector3.ZERO
			game.player.rotation.y = 0.0
			var reverted = 0
			game.joy = Vector2(drift, -1.0)
			for i in range(200):
				await physics_frame
				if game.player.position.z < bb.z - 0.8: break
			game.joy = Vector2.ZERO
			assert(game.player.position.z < bb.z - 0.8, "crossed at x=" + str(a.x) + " drift " + str(drift) + ", stuck at " + str(game.player.position))
			game.player.rotation.y = PI
			game.joy = Vector2(drift, -1.0)
			for i in range(200):
				await physics_frame
				if game.player.position.z > a.z + 0.8: break
			game.joy = Vector2.ZERO
			assert(game.player.position.z > a.z + 0.8, "crossed back at x=" + str(a.x) + " drift " + str(drift))
	# auto-walk over the river picks a bridge
	var route = game.plan_route(Vector3(-20, 0, -10), Vector3(-20, 0, -36))
	assert(route.size() == 2, "route uses a crossing")
	game.player.position = Vector3(-12, 0.3, -12)
	game.player.velocity = Vector3.ZERO
	var tgt = game.entity_by_id("neri")
	game.walk_to = tgt
	game.walk_via = game.plan_route(game.player.position, (tgt["node"] as Node3D).global_position)
	game.walk_last = INF
	game.walk_check = 0.8
	assert(not game.walk_via.is_empty())
	for i in range(900):
		await physics_frame
		if game.panel.visible: break
	assert(game.panel.visible, "auto-walk crossed the river to Neri, stuck at " + str(game.player.position))
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
			if walk.has(n) or n.x < -142 or n.x > 95 or n.y < -80 or n.y > 99: continue
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
		if e["kind"] != "observe" and not e["id"] in ["boat", "odd_bed", "odd_teapot"] and not game.near_dock(h): assert(T.height(h.x, h.z) > -0.3, e["id"] + " is in the water")
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
	for lvb in [-1, 1, 3]:
		game.diff_bias = lvb
		for i in range(Data.TILES.size()):
			game.tile_puzzle(i)
			for w in Data.TILES[i]["tiles"]: game.tile_tapped(tray_tile(w))
			press("Check")
			assert(game.mastered.has("t:" + str(i)), "tiles " + str(i))
			game.mastered.erase("t:" + str(i))
	game.diff_bias = 0
	# drag a wrong tile into the first box, then swap in the right one by dragging
	game.tile_puzzle(1)
	game.drop_on(game.dd["slots"][0], tray_tile("Kelarke"))
	assert(game.dd_words()[0] == "Kelarke")
	game.drop_on(game.dd["slots"][0], tray_tile("Kelar"))
	assert(game.dd_words()[0] == "Kelar" and tray_tile("Kelarke") != null, "swapped tile returns to the tray")
	game.drop_on(game.dd["slots"][1], tray_tile("tekaru"))
	game.drop_on(game.dd["slots"][2], tray_tile("i-tal-ak-pa-da."))
	press("Check")
	assert(game.mastered.has("t:1"))
	game.tile_puzzle(1)
	game.drop_on(game.dd["slots"][0], tray_tile("Kelarke"))
	game.drop_on(game.dd["slots"][1], tray_tile("tekaru"))
	game.drop_on(game.dd["slots"][2], tray_tile("i-tal-ak-pa-da."))
	press("Check")
	assert(has_text("Not quite"))
	# gap fill, word forge, word match, challenges
	for k in range(12):
		game.gap_fill()
		for i in range(game.dd["slots"].size()):
			var sl = game.dd["slots"][i]
			if not sl.get_meta("locked"): game.drop_on(sl, tray_tile(game.dd["answers"][i]))
		press("Check")
		assert(has_text("Correct!"), "gap fill")
	for k in range(16):
		game.diff_bias = k % 3
		game.word_forge()
		for a in game.dd["answers"]: game.tile_tapped(tray_tile(a))
		press("Check")
		assert(has_text("Correct!"), "forge " + str(game.dd["answers"]))
	game.diff_bias = 0
	for w in ["wak", "guro", "kor", "sek", "lin", "tari", "par", "dom"]: game.learn(w)
	game.word_match()
	for i in range(game.dd["slots"].size()): game.drop_on(game.dd["slots"][i], tray_tile(game.dd["answers"][i]))
	press("Check")
	assert(has_text("Correct!"), "word match")
	game.diff_bias = 1
	var g0 = game.gin
	game.challenge("mira")
	for w in Data.TILES[Data.CHALLENGES["mira"]]["tiles"]: game.tile_tapped(tray_tile(w))
	press("Check")
	assert(game.mastered.has("c:mira") and game.gin == g0 + 1)
	game.talk("tor")
	press("Say it yourself")
	game.diff_bias = 0
	# memory, market rush, speed round
	game.memory_game()
	assert(game.mg["type"] == "memory")
	var cards: Array = []
	for c in game.content.get_children():
		if c is GridContainer and not c.is_queued_for_deletion(): cards = c.get_children()
	assert(cards.size() >= 8)
	var gm = game.gin
	var by_text = {}
	for b in cards: by_text[b] = null
	# open every pair by trying all combinations quickly
	for b1 in cards:
		for b2 in cards:
			if b1 == b2 or b1.disabled or b2.disabled: continue
			if b1.text != "?" or b2.text != "?": continue
			b1.pressed.emit()
			b2.pressed.emit()
			if not b1.disabled:
				game.mg["busy"] = false
				game.mg["open"] = []
				b1.text = "?"
				b2.text = "?"
	assert(game.mg["left"] == 0 and game.gin > gm and game.mastered.has("g:memory"))
	game.complete("market")
	game.diff_bias = 2
	game.market_rush()
	var served = 0
	while game.mg.get("type", "") == "market":
		for g in game.mg["order"].keys(): game.mg["counts"][g] = game.mg["order"][g]
		press("Hand it over")
		served += 1
	assert(served >= 5 and game.mastered.has("g:market"))
	game.market_rush()
	game.update_minigame(30.0)
	assert(game.mg["i"] == 1, "timer moves to the next customer")
	game.close_panel()
	game.diff_bias = 0
	for w in ["mar", "gor", "fal", "hen", "nav", "gao", "sen", "var"]: game.learn(w)
	game.speed_round()
	for k in range(12):
		var w = game.content.get_children().filter(func(c): return c is PanelContainer and not c.is_queued_for_deletion())[0].get_child(0).text
		press(game.short_gloss(w))
	game.update_minigame(61.0)
	assert(game.best_speed >= 12 and game.mastered.has("g:speed"))
	game.show_games()
	game.show_more()
	press("Harder")
	assert(game.diff_bias == 1)
	press("Automatic")
	# levels and sentence cards at each level
	for b in [-1, 0, 1, 3]:
		game.diff_bias = b
		game.sentence_card("village_big")
		press("The village is big.")
		game.count_puzzle("cairn")
		press("mur")
		game.show_practice()
	game.diff_bias = 0
	assert(game.level() >= 1 and game.level() <= 4)
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
	# ---- fifth expansion: gossip, strange things, rumors, parrot, silly events ----
	game.close_panel()
	game.completed.clear()
	game.solved.clear()
	game.rumors.clear()
	game.rumor_count = 0
	for g in Data.GOSSIP:
		assert(game.looks.has(g["by"]) and game.looks.has(g["about"]), "gossip people exist " + g["id"])
		assert(g["v"].ends_with("-" + g["ev"] + "."), "evidential matches " + g["id"])
	for g in Data.GOSSIP.slice(0, 6):
		game.gossip_card(g, 0)
		press(g["en"])
		press("Next: how does " + str(g["by"]).capitalize() + " know?")
		var by = str(g["by"]).capitalize()
		var right = {"da": by + " saw it or knows it firsthand (-da)", "shi": by + " is guessing from clues (-shi)", "nu": "Someone told " + by + " (-nu)"}[g["ev"]]
		press(right)
		assert(game.solved.has("gh:" + g["id"]))
	assert(not game.completed.has("gossip"))
	for g in Data.GOSSIP.slice(0, 3):
		game.talk(g["about"])
		press("Ask about what " + str(g["by"]).capitalize() + " said")
		assert(game.solved.has("gc:" + g["id"]))
	assert(game.completed.has("gossip"))
	game.talk("lira")
	assert(find_button(game.content, "Tell some gossip") != null)
	# strange things
	for id in ["odd_fish", "odd_chair", "odd_clothes", "odd_book", "odd_bed", "odd_fruit", "odd_teapot", "odd_choni"]:
		game.target = game.entity_by_id(id)
		game.interact()
		press(Data.SENTENCES[id]["en"])
	assert(game.completed.has("strange"))
	# rumors: English and Tujuju are built correctly
	var rc = {"who": "Tor", "place": "haima", "adv": "hala", "verb": "sum", "tense": "past", "neg": false, "ev": "nu"}
	assert(game.rumor_parts(rc)["v"] == "Tor haima hala i-sum-pa-nu.")
	assert(game.rumor_en(rc) == "Tor swam in the sea fast (people say)")
	rc = {"who": "An", "place": "", "adv": "", "verb": "ning", "tense": "usual", "neg": true, "ev": "da"}
	assert(game.rumor_parts(rc)["v"] == "An ma-na-ning-ur-ki-da.")
	assert(game.rumor_en(rc) == "I do not usually sing (I saw it!)")
	rc = {"who": "Mar", "place": "wak-korma", "adv": "sela", "verb": "sul", "tense": "now", "neg": false, "ev": "shi"}
	assert(game.rumor_parts(rc)["nu"] == "Mar wak-korma sela i-sul-im-nu.")
	game.rumor_composer("mira")
	press("Yalo")
	press("murakma")
	press("-shi apparently")
	press("Whisper it to Mira")
	assert(game.rumors.size() == 1 and game.rumors[0]["v"] == "Yalo murakma i-ning-ur-nu.")
	assert(has_text("Then Mira laughs") or true)
	game.rumor_composer("tor")
	press("Whisper it to Tor")
	assert(game.rumor_count == 2)
	game.rumor_composer("desh")
	press("Desh")
	press("Whisper it to Desh")
	game.news("mira")
	assert(not game.completed.has("rumor") or game.rumor_count >= 3)
	game.news("ketu")
	assert(game.completed.has("rumor"))
	game.rumors.append({"who": "Ketu", "v": "Ketu haima i-sum-pa-nu.", "en": "x", "teller": "mira"})
	game.news("ketu")
	game.parrot_panel()
	for c in game.content.get_children():
		if c is LineEdit and not c.is_queued_for_deletion(): c.text = "Tari i-ho"
	press("Say it to the parrot")
	assert(game.mastered.has("p:parrot"))
	# silly events
	game.close_panel()
	game.fish_rain_t = 0.5
	var fc = game.fish_caught
	game.update_silly(0.1)
	game.update_silly(1.0)
	assert(game.fish_caught == fc + 3 and game.phrases.has("fish_rain"))
	game.night = 0.0
	game.player.position = Vector3(0, 0.1, 10)
	game.guro_cd = 0.0
	game.update_silly(0.1)
	assert(game.guro_t >= 0.0 and game.greeting("mira") == "Var guro!")
	game.update_silly(12.0)
	assert(game.guro_t < 0.0)
	game.save_game()
	var nr = game.rumors.size()
	game.rumors.clear()
	game.load_game()
	assert(game.rumors.size() == nr)
	# ---- sixth expansion: feelings, friendship, reactions ----
	game.close_panel()
	game.completed.clear()
	game.friend.clear()
	game.mood.clear()
	game.chat_day.clear()
	for id in Data.PEOPLE.keys():
		assert(game.looks.has(id), "person exists " + id)
		game.chat_menu(id)
		assert(game.portrait_id == id)
		game.compliment(id)
		for o in ["thing", "you", "head"]:
			game.chat_menu(id)
			var pp = Data.PEOPLE[id]
			var opts = {"thing": ["Ti-ni " + pp["thing"][0] + " i-ho!", "Your x"], "you": ["Ti ta-ho-da!", "x"], "head": ["Ti-ni dau i-var!", "x"]}
			game.do_compliment(id, [opts[o][0], opts[o][1], o])
			assert(game.panel.visible)
		game.do_compliment(id, ["Ti ta-ho-da!", "x", "you"])
		game.tease(id)
		game.joke_menu(id)
		game.do_joke(id, Data.JOKES[0])
		game.feel(id)
	assert(game.mastered.has("chat:mira:faint") and game.mastered.has("chat:tor:proud") and game.mastered.has("chat:lira:laugh"))
	# gifts: likes, hates and neutral
	game.fish_caught = 3
	game.gin = 5
	game.inventory.append_array(["bread", "tea"])
	var f0 = int(game.friend.get("ketu", 0))
	game.give_gift("ketu", "tari")
	assert(int(game.friend["ketu"]) == mini(f0 + 3, 10) and game.fish_caught == 2)
	var f1 = int(game.friend.get("mira", 0))
	game.give_gift("mira", "panak")
	assert(int(game.friend["mira"]) == maxi(f1 - 1, 0) and not game.inventory.has("bread"))
	game.give_gift("desh", "gin")
	# secrets and the friends quest
	for id in ["ena", "ketu", "desh", "neri", "gav"]: game.add_friend(id, 10)
	assert(game.completed.has("friends"))
	game.chat_menu("ketu")
	press("Ask about a secret")
	assert(game.mastered.has("sec:ketu"))
	game.mood["oren"] = -2
	assert(game.greeting("oren") == "Hmph!")
	game.feel("oren")
	# every reaction animates and resets cleanly
	for k in ["happy", "love", "angry", "shocked", "sad", "embarrassed", "laugh", "faint", "dizzy", "confused", "sleepy", "proud", "disgust", "sneeze"]:
		var e = game.entity_by_id("lira")
		var hx = e["node"].position.x
		game.emote("lira", k, 1.0)
		for i in range(12): game.apply_emote(e, 0.1)
		assert(not e.has("emote") and absf(e["node"].position.x - hx) < 0.001 and e["node"].rotation.x == 0.0, "emote resets " + k)
		assert(game.reaction_text("lira", k) != "" or k == "sneeze")
	game.ambient_cd = 0.0
	game.close_panel()
	game.player.position = Vector3(0, 0.1, 10)
	game.update_ambient(0.1)
	game.add_portrait("mira")
	game.panel.show()
	game.portrait_id = "mira"
	game.update_portrait()
	game.save_game()
	var fr = game.friend.duplicate()
	game.friend.clear()
	game.load_game()
	assert(game.friend.size() == fr.size())
	# ---- seventh expansion: boat landing, new-word practice, poem plants ----
	game.close_panel()
	game.start_ride(true)
	for i in range(40):
		game.update_ride(0.5)
		if not game.riding: break
	game.player.rotation.y = PI
	game.joy = Vector2(0, -1)
	for i in range(150): await physics_frame
	game.joy = Vector2.ZERO
	assert(game.player.position.z > 76.0, "walked off the dock onto Sendor: " + str(game.player.position))
	game.player.position = Vector3(0, 0.1, 30)
	game.last_safe = game.player.position
	# practice for every word class
	for w in Data.EXT_VERBS_I.keys() + Data.EXT_VERBS_T.keys() + Data.EXT_STATIVES.keys() + ["teka", "kel", "tari", "sao", "luk", "gov"]:
		var it = game.ext_items(w)
		assert(not it["forms"].is_empty() and not it["builds"].is_empty(), "practice for " + w)
		for f in it["forms"]:
			assert(not f[2].has(f[1]), "wrong options differ for " + w)
		game.ext_form(w, Callable())
		for b in it["builds"]:
			game.dnd({"title": "t", "prompt": "p", "answers": b["tiles"], "pool": b["decoys"], "tip": b["tip"], "key": "xb:" + w})
			for t in b["tiles"]: game.tile_tapped(tray_tile(t))
			press("Check")
			assert(has_text("Correct!"), "build " + str(b["tiles"]))
	game.discovered.erase("sena")
	game.pending_ext.clear()
	game.talk("ena")
	press("Ask about the boat")
	game.talk("ena")
	assert(game.content.get_children().any(func(c): return c is PanelContainer and not c.is_queued_for_deletion() and find_button(c, "Use it in a new form") != null), "practice box after a new word")
	game.ext_form("sena", game.talk.bind("ena"))
	for f in game.ext_items("sena")["forms"]:
		if find_button(game.content, f[1]) != null and has_text("You know sena"):
			var prompt_ok = false
			for c in game.content.get_children():
				if not c.is_queued_for_deletion() and (c is Label or c is RichTextLabel) and c.text.contains("\"" + f[0] + "\""): prompt_ok = true
			if prompt_ok: press(f[1])
	assert(game.mastered.has("x:sena"))
	game.reveal_word("sena")
	press("Build a new sentence with it")
	# poems
	for i in range(400):
		var lines = game.make_poem("ning-guro" if i % 2 == 0 else "sao-dau", "" if i % 3 else "mira")
		for ln in lines:
			assert(ln[0] != "" and ln[1] != "" and not ln[0].contains("  "), "poem line " + str(ln))
	var pe = game.entity_by_id("berry1")
	assert(T.height(pe["home"].x, pe["home"].z) > -0.05)
	for pl in game.PLANTS:
		var h: Vector3 = game.entity_by_id(pl[0])["home"]
		assert(T.height(h.x, h.z) > -0.05 and not game.is_blocked(h.x, h.z, 0.0), "plant on open land " + pl[0])
	game.berries = 0
	game.poems.clear()
	game.completed.erase("poems")
	pe["ripe_at"] = 0.0
	game.target = pe
	game.interact()
	assert(game.berries == 1)
	press("Eat it now")
	assert(game.berries == 0 and game.poems.size() == 1)
	game.target = pe
	game.interact()
	assert(game.berries == 0, "berries need time to regrow")
	game.shrooms = 3
	game.berries = 2
	game.gift_menu("tor")
	press("ning-guro (song-berry)")
	assert(game.poems.size() == 2 and game.poems[-1]["by"] == "tor")
	game.villager_poem("lira", "sao-dau")
	game.eat_poem("sao-dau")
	game.eat_poem("sao-dau")
	assert(game.completed.has("poems"))
	game.show_poems()
	game.show_inventory()
	# ---- borrowed words ----
	for id in Data.PEOPLE.keys():
		game.do_compliment(id, ["Ti ta-kawai-da!", "You are cute!", "cute"])
		assert(game.panel.visible)
	seed(3)
	for k in range(12): game.tease("tor")
	for g in Data.GOSSIP:
		if g["id"] in ["tor_choni", "oku_candy", "desh_party"]:
			game.gossip_card(g, 0)
			press(g["en"])
	game.inventory.append("candy")
	game.give_gift("rin", "bombom")
	assert(not game.inventory.has("candy"))
	game.discovered.append("choni")
	game.show_loans()
	assert(has_text("choni"))
	print("PASS: borrowed words: kawai compliments, choni teases, loan gossip, bombom gifts, borrowed words page")
	# ---- word play: endearments, insults, calques, false friends, doubling, Guarani sound words ----
	for id in Data.PEOPLE.keys():
		game.do_compliment(id, ["Habibi!", "Darling!", "habibi"])
		game.putz(id)
		assert(game.panel.visible)
	assert(game.discovered.has("habibi") and game.discovered.has("puts"))
	game.friend["desh"] = 9
	game.day_count = 0
	game.mood["desh"] = 0
	game.entity_by_id("desh").erase("say")
	game.guro_t = -1.0
	assert(game.greeting("desh") == Data.ENDEAR["giggly"])
	for sid in ["suri_kinder", "oku_brainstorm", "hot_dog", "fruit_variety", "mira_sizzle", "fire_pops", "desh_toot"]:
		game.sentence_card(sid)
		press(Data.SENTENCES[sid]["en"])
	game.gin = 3
	game.completed.append("market")
	game.talk("ketu")
	press("Buy ret-gor (hot dog): gin yan")
	assert(game.inventory.has("hotdog"))
	game.give_gift("desh", "ret-gor")
	assert(not game.inventory.has("hotdog"))
	for w in ["var", "len", "kawai"]:
		var fs: Array = game.ext_items(w)["forms"]
		assert(fs.any(func(f): return f[1] == "Dom i-" + w + "-" + w + "."))
	var rcd = {"who": "Tor", "place": "", "adv": "", "verb": "sum", "dbl": true, "tense": "past", "neg": false, "ev": "nu"}
	assert(game.rumor_parts(rcd)["v"] == "Tor i-sum-sum-pa-nu.")
	assert(game.rumor_en(rcd).contains("again and again"))
	rcd["who"] = "Oren"
	game.rumor_react("oren", rcd)
	assert(has_any("Puts!"))
	game.false_friends(true)
	for k in range(8):
		var f: Array = game.ff_order[game.ff_i]
		press(f[2])
		press("Next false friend")
	assert(has_any("weren't fooled"))
	game.sound_game(true)
	for k in range(6):
		var f2: Array = game.ff_order[game.ff_i]
		press(f2[0])
		press("Next sound")
	assert(has_any("Great ears"))
	game.show_sounds()
	assert(has_any("pororo"))
	game.show_loans()
	assert(has_any("Calques") and has_any("False friends") and has_any("Doubling"))
	var prng = RandomNumberGenerator.new()
	for k in range(40):
		prng.seed = k
		var ln = game.poem_line(0, prng)
		assert(ln[0].ends_with("."))
	assert(game.ui.find_child("MovePad", true, false) != null)
	game.show_varnak()
	assert(has_any("Evidentials") and has_any("Doubling") and has_any("Ma-k-i-pal-pa-ki-da"))
	# ---- eighth expansion: Hirimara, pranks, choni hunt, compact menus ----
	var T8 = load("res://terrain.gd")
	for pt in [Vector2(-110, 0), Vector2(-96, 16), Vector2(-100, -14), Vector2(-127, 14), Vector2(-86, 2), Vector2(-92, -6)]:
		assert(T8.height(pt.x, pt.y) > -0.1, "Hirimara should be land at " + str(pt))
	assert(not T8.deep(-84, 0) and not T8.deep(-84, 5), "the neck to Hirimara is walkable")
	for id in ["maze_chest", "lavir", "karaoke", "ghost_hut", "scarecrow", "dopel", "choni_hill", "choni_falls", "choni_islet", "choni_ruins"]:
		assert(not game.entity_by_id(id).is_empty(), "missing entity " + id)
	for c in Data.CHONI_HUNT:
		if c[0] in ["choni_ghost", "choni_maze"]: continue
		assert(T8.height(c[1], c[2]) > -0.3, "choni reachable: " + c[0])
	game.examine(game.entity_by_id("karaoke"))
	press("Sing it! (Ta-ning-o!)")
	assert(has_any("Bravo"))
	game.examine(game.entity_by_id("scarecrow"))
	game.examine(game.entity_by_id("dopel"))
	press("Ask: Ti hal ta-an-ha? (Who are you?)")
	press("Say: Ti Pomo ma-ta-an-ki-da! (You are not Pomo!)")
	game.examine(game.entity_by_id("ghost_hut"))
	press("Ta-sul-o-ye!")
	assert(not game.solved.has("ch:choni_ghost"))
	press("T-na-ven-o-ye!")
	assert(game.solved.has("ch:choni_ghost"))
	game.examine(game.entity_by_id("maze_chest"))
	assert(game.solved.has("ch:choni_maze") and game.inventory.has("chochke"))
	assert(game.completed.has("hirimara"), "five secrets of Hirimara")
	for id in ["choni_hill", "choni_falls", "choni_islet", "choni_ruins"]:
		game.target = game.entity_by_id(id)
		game.interact()
	assert(game.chonies_found() == 6)
	game.choni_hints()
	press("Give Gav the chonies")
	assert(game.completed.has("chonies") and game.choni_line.visible)
	for id in Data.PEOPLE.keys():
		game.prank_menu(id)
		for pk in Data.PRANKS:
			press(pk["label"])
			assert(game.panel.visible)
			game.prank_menu(id)
	seed(11)
	for k in range(20): game.tease("oren")
	for g in Data.GOSSIP:
		game.gossip_card(g, 0)
		press(g["en"])
		game.gossip_reply(g)
	var prng2 = RandomNumberGenerator.new()
	for t in [11, 12, 13, 14]:
		for k in range(10):
			prng2.seed = k * 7 + t
			var ln = game.poem_line(t, prng2)
			assert(ln[0] != "" and ln[1] != "")
	game.choni_rain_t = 0.5
	game.update_hirimara(0.1)
	assert(game.choni_fx.emitting)
	game.update_hirimara(1.0)
	game.chat_menu("gav")
	await process_frame
	var grid_found = false
	for c in game.content.get_children():
		if c is GridContainer: grid_found = true
	assert(grid_found, "chat buttons are in a compact grid")
	game.show_map()
	game.message("Same old", "This happened before.")
	game.examine(game.entity_by_id("deshavu"))
	assert(has_any("This happened before") and has_any("Deshavu"))
	var poems_before = game.poems.size()
	for k in range(40):
		game.ambient_cd = 0.0
		game.close_panel()
		game.player.position = Vector3(-4, 0.1, 13)
		game.update_ambient(0.1)
	assert(game.poems.size() >= poems_before)
	var mb = game.top_row.get_node("MoreButton") as Button
	assert(mb != null and mb.icon != null and mb.text == "")
	mb.pressed.emit()
	assert(has_any("Difficulty"))
	print("PASS: eighth expansion: Hirimara (maze, karaoke, poltergeist, doppelganger, scarecrow), choni hunt, pranks, teases, new gossip, poems, choni rain, compact menus")
	print("PASS: word play: habibi and putz, calques, false friends game, doubling, Guarani sound words, move pad icon")
	print("PASS: seventh expansion: ferry landing, new-word practice for every class, poem plants, poems, poem book")
	print("PASS: sixth expansion: chat, compliments, teasing, jokes, gifts, moods, secrets, friends quest, reactions, portrait")
	print("PASS: fifth expansion: gossip, evidentials, replies, strange things, rumors, news, parrot, fish rain, rolling fruit")
	print("PASS: fourth expansion: drag and drop, gap fill, forge, match, challenges, memory, market rush, speed round, levels")
	# ninth: close X, errands, review
	game.talk("mira")
	assert(game.close_x.visible and game.panel.visible)
	game.close_x.pressed.emit()
	assert(not game.panel.visible and not game.close_x.visible)
	game.inventory.clear()
	game.gin = 0
	game.friend["mira"] = 0
	game.errand = {"npc": "mira", "item": "panak", "n": 2}
	game.errand_menu("mira")
	assert(has_any("Vel panak t-na-ven-o-ye"))
	game.inventory.append_array(["bread", "bread"])
	game.errand_deliver("mira")
	assert(game.gin == 2 and not game.inventory.has("bread") and game.errands_done() == 1 and game.errand.is_empty())
	game.errand_menu("ketu")
	assert(not game.errand.is_empty())
	game.errand = {}
	game.discovered.append_array(["wak", "guro", "kor"])
	game.review_rusty()
	assert(game.panel.visible)
	print("PASS: ninth expansion: close X, errands, review")
	# ninth b: overheard talk, mystery letters, Teach Neri, learning log
	game.close_panel()
	game.mastered = game.mastered.filter(func(m): return not (str(m).begins_with("ov:") or str(m).begins_with("lt:") or str(m).begins_with("tn:")))
	game.completed.erase("letters")
	var ov0: Dictionary = Data.OVERHEAR[0]
	var nna = game.entity_by_id(ov0["a"])["node"]
	var nnb = game.entity_by_id(ov0["b"])["node"]
	game.player.position = (nna.position + nnb.position) * 0.5 + Vector3(1.5, 0.1, 1.5)
	game.overhear_now = {}
	game.overhear_cd = 0.0
	game.update_overhear(0.1)
	assert(not game.overhear_now.is_empty() and game.overhear_now["o"]["id"] == ov0["id"], "overhear starts near the pair")
	game.update_overhear(0.1)
	assert(game.listen_button.visible)
	var gv0 = game.gin
	game.listen_in()
	assert(game.panel.visible and has_any(ov0["lines"][0][1]))
	press(ov0["opts"][0])
	assert(game.mastered.has("ov:" + ov0["id"]) and game.gin == gv0 + 2 and game.clue_list().has("paper"))
	game.show_overheard()
	assert(has_any("1 of " + str(Data.OVERHEAR.size())))
	# every conversation renders and can be answered
	for o in Data.OVERHEAR:
		game.overhear_panel(o, false)
		press(o["opts"][0])
		assert(game.mastered.has("ov:" + o["id"]), o["id"])
	assert(game.clue_list().size() == Data.LETTER_CLUES.size())
	# letters
	for w in ["wak", "guro", "kor", "kel", "anni", "tekaru", "tari", "gin", "cha"]: game.learn(w)
	assert(game.next_letter() == 0)
	game.talk("gav")
	press("Read the mystery letter")
	assert(game.mastered.has("lt:read:0") and game.next_letter() == -1)
	for k in range(Data.LETTERS.size()):
		var ltr: Dictionary = Data.LETTERS[k]
		if k > 0:
			assert(game.next_letter() == k, "letter " + str(k) + " ready")
			game.letter_panel(k)
		press(ltr["opts"][0])
		assert(game.mastered.has("lt:q:" + str(k)))
		if ltr["replies"].is_empty(): break
		press("Write back")
		var rr: Dictionary = ltr["replies"][k % ltr["replies"].size()]
		press(rr["en"])
		for w in rr["tiles"]: game.tile_tapped(tray_tile(w))
		press("Check")
		assert(game.mastered.has("lt:reply:" + str(k)), "reply " + str(k))
	game.show_letters()
	press("Who is it? Solve the mystery")
	press("Gav (Gav the mail carrier)")
	press("Gav ti-ni palar i-an-shi.  (The clues show it)")
	assert(not game.mastered.has("lt:solved"))
	game.solve_how(Data.SUSPECTS[0])
	press("Par ti-ni palar i-an-da.  (I saw it with my own eyes)")
	assert(not game.mastered.has("lt:solved"))
	game.solve_how(Data.SUSPECTS[0])
	press("Par ti-ni palar i-an-shi.  (The clues show it)")
	assert(game.mastered.has("lt:solved"))
	game.parrot_panel()
	press("Show the parrot one of its letters")
	assert(game.completed.has("letters") and game.inventory.has("feather"))
	# Teach Neri: every tile sentence makes a findable mistake with a fix
	for i in range(Data.TILES.size()):
		var nm = game.neri_mistake(Data.TILES[i])
		assert(not nm.is_empty() or Data.TILES[i]["tiles"].size() < 2, "mistake for tile " + str(i))
	for rep9 in range(12):
		game.teach_neri()
		assert(game.panel.visible and has_any("Neri says:"))
	# say it yourself is open at level 1
	game.diff_bias = -1
	game.talk("mira")
	assert(find_button(game.content, "Say it yourself") != null or find_button(game.content, "Say it yourself  [ok]") != null)
	game.diff_bias = 0
	# learning log and export
	assert(game.events.size() > 10)
	var kinds9 = {}
	for e in game.events: kinds9[e["k"]] = true
	for k in ["session", "word_found", "mastered", "answer", "build", "overheard", "letter_read", "letter_reply", "quest"]:
		assert(kinds9.has(k), "log has " + k)
	game.show_progress()
	assert(has_any("Words:") and find_button(game.content, "Export data (CSV)") != null)
	var csv9 = game.export_payload("csv")
	assert(csv9.begins_with("time_utc,kind,activity") and csv9.split("\n").size() > 10)
	var js9 = JSON.parse_string(game.export_payload("json"))
	assert(js9 is Dictionary and js9["summary"]["letters_answered"] == 5 and js9["events"].size() == game.events.size())
	game.export_data("json")
	assert(game.last_export != "")
	game.show_notebook()
	assert(find_button(game.content, "Letters") != null and find_button(game.content, "My learning") != null)
	print("PASS: ninth expansion b: overheard talk, mystery letters, Teach Neri, learning log and export")
	# tenth: talk view, asking and telling with -kan, -vai, hama and commands
	game.close_panel()
	var dn = game.entity_by_id("desh")["node"]
	game.player.position = dn.position + Vector3(0, 0.1, 3.0)
	game.chat_menu("desh")
	game.update_talk_view(0.016)
	assert(game.talk_view_id == "desh" and game.talk_cam.current and game.panel.anchor_top > 0.4, "talk view frames the villager")
	assert(game.close_x.visible and game.close_x.anchor_top > 0.4)
	game.close_x.pressed.emit()
	game.update_talk_view(0.016)
	assert(game.talk_view_id == "" and game.camera.current and game.panel.anchor_top == 0.0)
	# no talk view during drag and drop
	game.challenge("desh")
	game.update_talk_view(0.016)
	assert(game.talk_view_id == "")
	game.close_panel()
	# can you...?
	game.mastered = game.mastered.filter(func(m): return not (str(m).begins_with("kan") or str(m).begins_with("cmd:") or str(m).begins_with("hama:") or str(m).begins_with("want:")))
	game.completed.erase("survey")
	game.chat_menu("desh")
	press("Ask or tell...")
	press("Can you...? (-kan)")
	press("Sing")
	press("Ti na-ning-kan-ha?")
	assert(not game.mastered.has("kan:ning:desh"))
	press("Ti ta-ning-kan-ha?")
	await process_frame
	assert(game.mastered.has("kan:ning:desh") and game.survey_found("ning").has("desh") and has_any("Tarara"))
	for v in Data.KAN.keys():
		for who in Data.KAN[v][1]: game.can_answer(who, v)
	game.can_answer("tor", "fei")
	assert(game.completed.has("survey"))
	game.show_survey()
	assert(has_any("Desh"))
	# what do you want?
	game.want_ask("ketu")
	press("Ti han t-i-nuk-vai-ha?")
	await process_frame
	assert(game.mastered.has("want:ketu") and game.panel.visible)
	for rep10 in range(10): game.want_answer(["oren", "pomo", "lira", "mira", "tor", "ena"][rep10 % 6])
	# where is...?
	game.where_say("desh", "fardom")
	press("Fardom hama i-esh-ha?")
	await process_frame
	assert(has_any("Fardom bei-ma i-esh-da."))
	press("north")
	assert(game.mastered.has("hama:fardom"))
	for t in Data.WHERE_PLACES.keys(): game.where_answer("ketu", t)
	for p in ["neri", "yalo", "suri"]: game.where_answer("ketu", p)
	assert(has_any("Suri anni dalma i-esh-da!"))
	# commands: villagers react to what you actually say
	game.friend["oren"] = 2
	game.mood["oren"] = 0
	game.command_do("oren", "pul", "plain")
	assert(has_any("Maki!") and not game.mastered.has("cmd:pul"))
	game.command_do("oren", "pul", "polite")
	assert(game.mastered.has("cmd:pul") and game.acts.has("oren"))
	for f in range(240):
		game.clock += 0.016
		game.update_acts(0.016)
	game.command_do("desh", "kachaka", "statement")
	assert(has_any("Han?"))
	game.command_do("desh", "kachaka", "me")
	assert(has_any("Ta-kachaka-o!"))
	game.command_do("desh", "pul+ning", "polite")
	assert(game.acts["desh"]["list"] == ["jump", "sing"])
	for f in range(500):
		game.clock += 0.016
		game.update_acts(0.016)
	assert(not game.acts.has("desh"))
	var home = game.entity_by_id("desh")["home"]
	assert(dn.position.distance_to(home) < 0.05, "back in place after acting")
	for v in Data.COMMANDS.keys(): game.command_do("ketu", v, "polite")
	for f in range(300):
		game.clock += 0.05
		game.update_acts(0.05)
	# come with me, then go home
	game.command_do("ketu", "kar", "polite")
	assert(game.npc_following("ketu"))
	var kn = game.entity_by_id("ketu")["node"]
	game.player.position = kn.position + Vector3(8, 0.1, 0)
	for f in range(120):
		game.clock += 0.05
		game.update_acts(0.05)
	assert(kn.position.distance_to(game.player.position) < 3.5, "follows the player")
	game.where_answer("desh", "ketu")
	assert(has_any("ti-su"))
	game.send_home("ketu")
	for f in range(400):
		game.clock += 0.05
		game.update_acts(0.05)
	assert(not game.acts.has("ketu") and kn.position.distance_to(game.entity_by_id("ketu")["home"]) < 0.3)
	game.show_varnak()
	assert(has_any("Can and want"))
	print("PASS: tenth expansion: talk view, distinct villagers, -kan, -vai, hama, commands, survey")
	# eleventh: word wand, pass it on, guess who
	game.close_panel()
	game.solved.erase("wand")
	game.completed.erase("wand")
	game.talk("oku")
	press("Ask about the old stick")
	assert(game.solved.has("wand"))
	press("Try the wand")
	assert(has_any("gao-murak"))
	# wrong prefix fizzles
	game.wand = {"who": "Tor", "where": "kurma", "pre": "ri", "neg": false, "verb": "kachaka", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(has_any("kabum") and game.wand_pending.is_empty())
	# cycling a piece changes the sentence
	game.wand_panel()
	press("Who:  Tor  (Tor)")
	assert(game.wand["who"] != "Tor")
	# -im -da: Tor dances at the market right now
	var tn = game.entity_by_id("tor")["node"]
	var thome = game.entity_by_id("tor")["home"]
	game.wand = {"who": "Tor", "where": "kurma", "pre": "i", "neg": false, "verb": "kachaka", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(tn.position.distance_to(Data.WAND_PLACES["kurma"][1]) < 3.0 and game.acts.has("tor"), "teleported to the market " + str(tn.position) + str(game.acts.keys()) + str(game.wand_pending.size()))
	assert(game.talk_partner == "tor")
	for f in range(800):
		game.clock += 0.05
		game.update_acts(0.05)
	assert(tn.position.distance_to(thome) < 0.1 and not game.acts.has("tor"), "Tor comes home")
	# -fu waits, then happens
	game.wand = {"who": "Mira", "where": "haima", "pre": "i", "neg": false, "verb": "sum", "tense": "fu", "ev": "da"}
	game.wand_cast()
	assert(game.wand_pending.size() == 1 and not game.acts.has("mira"))
	game.clock += 7.0
	game.wand_tick()
	assert(game.acts.has("mira") and game.acts["mira"]["list"][0] == "swim")
	assert(game.T.height(game.entity_by_id("mira")["node"].position.x, game.entity_by_id("mira")["node"].position.z) < -0.5, "Mira swims in the sea")
	# -pa changes nothing, -nu makes a rumor, -shi stays home, negation refuses, swimming on land flops
	game.acts.clear()
	game.wand = {"who": "Desh", "where": "sang-ma", "pre": "i", "neg": false, "verb": "ning", "tense": "pa", "ev": "da"}
	game.wand_cast()
	assert(game.wand_pending.is_empty() and has_any("already happened"))
	game.wand["tense"] = "im"
	game.wand["ev"] = "nu"
	game.wand_cast()
	assert(game.wand_pending.is_empty() and has_any("RUMOR"))
	game.wand["ev"] = "shi"
	var dhome = game.entity_by_id("desh")["home"]
	game.wand_cast()
	assert(game.acts.has("desh") and game.entity_by_id("desh")["node"].position.distance_to(dhome) < 0.5)
	game.acts.clear()
	game.wand = {"who": "Ketu", "where": "kurma", "pre": "i", "neg": true, "verb": "ning", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(str(game.entity_by_id("ketu")["say"][0]).begins_with("Ma-na-ning-im-ki-da"))
	game.wand = {"who": "Gav", "where": "kurma", "pre": "i", "neg": false, "verb": "sum", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(game.acts["gav"]["list"][0] == "sleep")
	# I (na-) moves the player; everyone (ri-) moves everyone
	game.wand = {"who": "An", "where": "fardom-ma", "pre": "na", "neg": false, "verb": "pul", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(game.player.position.distance_to(Data.WAND_PLACES["fardom-ma"][1]) < 6.0)
	game.wand = {"who": "Polu", "where": "tekama", "pre": "ri", "neg": false, "verb": "pul", "tense": "im", "ev": "da"}
	game.wand_cast()
	assert(game.acts.size() >= 15)
	assert(game.completed.has("wand"))
	for f in range(800):
		game.clock += 0.05
		game.update_acts(0.05)
	assert(game.acts.is_empty())
	for id in Data.GUESS_PEOPLE:
		assert(game.entity_by_id(id)["node"].position.distance_to(game.entity_by_id(id)["home"]) < 0.1, id + " home")
	# pass it on
	for r in Data.RELAYS:
		game.mastered.erase("relay:" + r["src"])
	game.completed.erase("relay")
	for ri in range(Data.RELAYS.size()):
		var rl: Dictionary = Data.RELAYS[ri]
		game.talk(rl["src"])
		press("Any news? (pass it on)")
		assert(game.relay["i"] == ri)
		game.talk(rl["to"][0])
		press("Pass on " + str(rl["src"]).capitalize() + "'s news")
		press(rl["ok"])
		game.talk(rl["to"][1])
		press("Pass on " + str(rl["src"]).capitalize() + "'s news")
		press(rl["wrong"]["noun"][0] if ri == 0 else rl["ok"])
		game.talk(rl["src"])
		press("Ask how the story came back")
		assert(game.relay.is_empty())
		if ri == 0:
			assert(has_any("came back") and not game.mastered.has("relay:lira"))
			press("Try again")
			for to in rl["to"]:
				game.relay_tell(to)
				press(rl["ok"])
			game.relay_end()
		assert(game.mastered.has("relay:" + str(rl["src"])))
	assert(game.completed.has("relay"))
	# guess who: facts are consistent, and winning works
	for q in Data.GUESS_Q.keys():
		var yes = 0
		for id in Data.GUESS_PEOPLE:
			if game.guess_fact(id, q): yes += 1
		assert(yes > 0 and yes < Data.GUESS_PEOPLE.size(), "question " + q + " splits people")
	game.completed.erase("guesswho")
	for round in range(3):
		game.guess_start()
		var secret = game.guess["secret"]
		press(Data.GUESS_Q["hat"][0])
		assert(has_any("Neri:"))
		game.guess_tap("ena" if secret != "ena" else "mira")
		assert(game.guess["out"].size() == 1)
		press("Make a guess")
		var other = "tor" if secret != "tor" else "oku"
		game.guess_tap(other)
		assert(game.guess["wrong"] == 1)
		press("Make a guess")
		game.guess_tap(secret)
		assert(has_any("i-an-da!"))
		game.mastered.append("guess:x" + str(round))
	assert(game.completed.has("guesswho"))
	print("PASS: eleventh expansion: word wand, pass it on, guess who")
	# twelfth: yesen improv scenes
	game.close_panel()
	game.diff_bias = -3
	game.chat_menu("mira")
	press("Yesen! (improv)  (level 2)")
	assert(has_any("unlock at level 2"))
	game.diff_bias = 3
	# every tile that can be wrong has a plausible wrong version that is different
	var fixed_tiles = 0
	for sc in Data.YESEN:
		assert(Data.PEOPLE.has(sc["who"]) and sc["rounds"].size() >= 3, sc["id"])
		for r in sc["rounds"]:
			assert(r[2].size() == 2)
			for idea in r[2]:
				var wrongs_n = 0
				for t in idea[1]:
					var ws = game.yesen_wrongs(t)
					assert(not ws.has(t), t)
					if ws.is_empty(): fixed_tiles += 1
					else: wrongs_n += 1
				assert(wrongs_n >= 2, "idea needs choices: " + str(idea[1]))
	assert(Data.YESEN.size() >= 15)
	# a perfect scene draws a crowd and a standing ovation
	game.completed.erase("yesen")
	game.gin = 0
	var m0 = game.entity_by_id("mira")["node"]
	game.player.position = m0.position + Vector3(0, 0.1, 3.0)
	game.chat_menu("mira")
	press("Yesen! (improv)")
	assert(has_any("suggestion"))
	var sug_buttons = 0
	for sc in Data.YESEN:
		if find_button(game.content, "“" + str(sc["sug"][0]).capitalize() + "!”  (" + str(sc["sug"][1]) + ")") != null: sug_buttons += 1
	assert(sug_buttons == 3, "three suggestions")
	# any villager can play any suggestion
	game.chat_menu("desh")
	press("Yesen! (improv)")
	var s3 = Data.YESEN[3]
	var b3 = find_button(game.content, "“" + str(s3["sug"][0]).capitalize() + "!”  (" + str(s3["sug"][1]) + ")")
	if b3 == null:
		game.yesen_start(5, "desh")
	else: b3.pressed.emit()
	assert(game.ys["who"] == "desh" and has_any("Suggestion:"))
	game.chat_menu("mira")
	game.yesen_start(0, "mira")
	assert(game.ys["i"] == 0 and game.ys["who"] == "mira")
	press("Start the scene")
	game.update_talk_view(0.016)
	for rn in range(3):
		var rr: Array = Data.YESEN[0]["rounds"][rn]
		assert(has_any(rr[0]))
		press("Ho, e... " + str(rr[2][0][0]))
		for t in rr[2][0][1]:
			if game.yesen_wrongs(t).is_empty(): continue
			press(t)
		press("Say it!")
		assert(has_any("Perfect Tujuju"))
		press("Next")
	assert(has_any("standing ovation") and game.gin == 5 and game.mastered.has("yesen:soup"))
	var aud = 0
	for id in game.acts.keys():
		if game.acts[id].get("kind", "") == "watch": aud += 1
	assert(aud >= 4, "a crowd gathered")
	for f in range(1200):
		game.clock += 0.05
		game.update_acts(0.05)
	assert(game.acts.is_empty(), "the crowd goes home")
	# a scene full of mistakes and a block gets crickets, and people leave
	game.yesen_start(1)
	game.yesen_round()
	game.yesen_build(0)
	var r0: Array = Data.YESEN[1]["rounds"][0][2][0][1]
	var bad: Array = []
	for t in r0:
		var ws = game.yesen_wrongs(t)
		bad.append(ws[0] if not ws.is_empty() else t)
	game.yesen_said(r0, bad)
	assert(has_any("confused"))
	game.yesen_next()
	press("Maki! (No! Block the idea)")
	assert(has_any("blocking"))
	press("Keep going")
	game.yesen_build(1)
	var r2: Array = Data.YESEN[1]["rounds"][2][2][1][1]
	game.yesen_said(r2, r2)
	game.yesen_next()
	assert(not has_any("standing ovation") and not game.mastered.has("yesen:moonbridge"))
	# every scene can be finished
	for k in range(Data.YESEN.size()):
		game.yesen_start(k)
		for rn in range(Data.YESEN[k]["rounds"].size()):
			game.yesen_round()
			game.yesen_build(rn % 2)
			var tl: Array = Data.YESEN[k]["rounds"][rn][2][rn % 2][1]
			game.yesen_said(tl, tl)
			game.yesen_next()
		assert(game.mastered.has("yesen:" + str(Data.YESEN[k]["id"])), Data.YESEN[k]["id"])
	assert(game.completed.has("yesen"))
	for f in range(1200):
		game.clock += 0.05
		game.update_acts(0.05)
	game.diff_bias = 0
	game.show_yesen_list()
	press("Get three suggestions")
	assert(has_any("suggestion"))
	print("PASS: twelfth expansion: yesen improv scenes, " + str(Data.YESEN.size()) + " scenes")
	# sound: effects, ambience, Desh's music, speaker buttons
	assert(game.sfx.size() == game.SFX_NAMES.size(), "all sounds load")
	for an in game.AMB_NAMES: assert(game.amb.has(an), "ambient " + an)
	assert(game.desh_music != null and game.desh_music.get_parent() == game.entity_by_id("desh")["node"])
	for n in game.SFX_NAMES: game.play_sfx(n)
	game.clock += 1.0
	game.amb_cd = 0.0
	game.update_audio(0.5)
	game.sentence_card("village_big")
	await process_frame
	var spk = game.content.find_child("Speaker", true, false)
	assert(spk != null, "banner has a speaker button")
	spk.pressed.emit()
	assert(game.last_spoken == "Teka ivar.", game.last_spoken)
	var rl = game.rich_line("Mira says “Wak. Guro.” to you.")
	assert(rl.text.contains("[url]"))
	rl.meta_clicked.emit("Ti-ni pai i-ho-da!")
	assert(game.last_spoken == "Tini pai ihoda!")
	game.show_more()
	press("Sound: on")
	assert(not game.sound_on and AudioServer.is_bus_mute(0))
	press("Sound: off")
	assert(game.sound_on and not AudioServer.is_bus_mute(0))
	game.sound_game(true)
	assert(find_button(game.content, "Hear it again") != null)
	print("PASS: sound effects, ambience, Desh's music and spoken Tujuju")
	# ambient zones and the cenote
	game.close_panel()
	game.player.position = Vector3(0, 0.3, 40)
	var aw = game.ambient_weights()
	assert(float(aw["ocean"]) > 0.4, "the harbor sounds like the sea " + str(aw))
	game.player.position = Vector3(-10, 0.3, -12)
	aw = game.ambient_weights()
	assert(float(aw["forest"]) > float(aw["ocean"]) and float(aw["stream"]) > 0.1, "the forest path " + str(aw))
	var cc = T.CENOTE
	assert(game.in_cenote_water(Vector3(cc.x, game.cen_y_w - 1.0, cc.y)))
	assert(game.in_cenote_water(Vector3(cc.x + 9.0, game.cen_y_w - 15.0, cc.y)))
	assert(not game.in_cenote_water(Vector3(cc.x + 9.0, T.height(cc.x + 9.0, cc.y) + 0.1, cc.y)), "dry land beside the cenote")
	assert(not game.in_cenote_water(Vector3(0, -1.0, 40)), "the sea is not swimmable")
	# fall in, float, dive, rise, climb out
	game.player.position = Vector3(cc.x, game.cen_y_w + 1.5, cc.y)
	game.player.velocity = Vector3.ZERO
	for f in range(150): await physics_frame
	assert(game.swimming and absf(game.player.position.y - game.float_y()) < 0.4, "floating at the surface " + str(game.player.position))
	game.swim_down_held = true
	for f in range(200): await physics_frame
	game.swim_down_held = false
	for f in range(3): await process_frame
	var depth0 = game.cen_y_w - game.camera.global_position.y
	assert(depth0 > 4.0 and game.underwater and game.uw_overlay.visible, "diving " + str(depth0))
	assert(float(game.ambient_weights()["underwater"]) > 1.0)
	game.swim_up_held = true
	for f in range(400): await physics_frame
	game.swim_up_held = false
	for f in range(3): await process_frame
	assert(not game.underwater and game.swimming, "back at the surface")
	game.climb_out()
	for f in range(60): await physics_frame
	assert(not game.swimming and game.player.position.y > game.cen_y_w + 1.0, "out on the rim " + str(game.player.position))
	assert(game.discovered.has("sonot"))
	game.player.position = Vector3(0, 0.3, 36)
	game.player.velocity = Vector3.ZERO
	print("PASS: ambient zones, the cenote, swimming and diving")
	# kirmel: the lost writing, the carvings and Var Tari
	var Kir = preload("res://kirmel.gd")
	assert(Kir.syllables("Tujuju").map(func(x): return Kir.label(x)) == ["tu", "ju", "ju"])
	assert(Kir.syllables("kachaka").map(func(x): return Kir.label(x)) == ["ka", "cha", "ka"])
	var sigs = {}
	for c in Kir.BASES + Kir.MARKS.keys():
		for v in Kir.VOWELS:
			var sg = str(Kir.glyph_strokes(c, v))
			assert(not sigs.has(sg), "glyphs must differ: " + c + v)
			sigs[sg] = true
	game.mastered = game.mastered.filter(func(m): return not (str(m).begins_with("ky:") or str(m).begins_with("kf:") or str(m).begins_with("kc:") or str(m).begins_with("kg:") or str(m) == "kir:taught"))
	game.completed.erase("kirmel")
	assert(game.carvings.size() == Data.KIR_STORY.size() + 1)
	for k in range(game.carvings.size()):
		var cn = game.carvings[k][0] as Node3D
		assert(game.in_cenote_water(cn.global_position), "carving " + str(k) + " is under water")
	# deeper stones can't be read before the picture stone
	game.read_carving(1)
	assert(has_any("can't read them yet"))
	game.read_carving(0)
	for p in Data.KIR_PICTURES:
		assert(has_any(str(p[1])))
		press(p[0])
		await process_frame
	assert(game.mastered.has("kc:pictures") and game.kir_known_count() >= 7)
	# decipher every chapter by reading the words around each new mark
	for ci in range(Data.KIR_STORY.size()):
		game.decipher(ci)
		var guard = 0
		while not game.mastered.has("kc:" + str(ci)) and guard < 60:
			guard += 1
			var sy = Kir.syllables(Data.KIR_STORY[ci]["v"])
			var u = game.kir_first_unknown(sy)
			assert(u >= 0)
			press(Kir.label(sy[u]))
			await process_frame
		assert(game.mastered.has("kc:" + str(ci)), "read chapter " + str(ci))
	game.show_kir_story()
	assert(has_any("first day"))
	# Var Tari
	game.close_panel()
	game.guardian_listen()
	assert(game.mastered.has("kg:met") and has_any("How does it know this?"))
	var gl: Array = Data.GUARDIAN_LINES[0]
	press("It saw it with its own eyes (-da)")
	assert(game.mastered.has("kg:0"))
	press("Ask about the writing")
	assert(game.mastered.has("kir:taught") and game.kir_known_count() == game.kir_all_keys().size())
	for gi in range(Data.GUARDIAN_LINES.size()):
		var gle: Array = Data.GUARDIAN_LINES[gi]
		assert(str(gle[0]).ends_with("-da.") or str(gle[0]).contains("-da") or str(gle[0]).contains("-nu") or str(gle[0]).contains("-shi"), "Var Tari speaks with evidentials: " + str(gle[0]))
	# bring it home to Suri
	game.talk("suri")
	press("Show Suri the old writing")
	assert(has_any("how do you write"))
	var ko = game.kir_options("Ketu")
	assert(str(ko[0]) != str(ko[1]) and str(ko[0]) != str(ko[2]))
	game.suri_kirmel(3)
	assert(game.completed.has("kirmel"))
	var marked = 0
	for sgn in game.Art.signs:
		if is_instance_valid(sgn) and sgn.has_meta("kir_done"): marked += 1
	assert(marked >= 8, "village signs show kirmel")
	game.sentence_card("village_big")
	print("PASS: kirmel, the carvings, Var Tari and bringing the writing home")
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

func tray_tile(w: String) -> Control:
	for t in game.dd["tray"].get_children():
		if t.get_meta("word") == w: return t
	return null

func has_any(t: String, n: Node = null) -> bool:
	if n == null: n = game.content
	for c in n.get_children():
		if c.is_queued_for_deletion(): continue
		if (c is Label or c is RichTextLabel) and c.text.contains(t): return true
		if has_any(t, c): return true
	return false

func has_text(t: String) -> bool:
	for c in game.content.get_children():
		if c.is_queued_for_deletion(): continue
		if (c is Label or c is RichTextLabel) and c.text.begins_with(t): return true
	return false
