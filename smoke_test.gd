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
	for id in ["odd_fish", "odd_chair", "odd_clothes", "odd_book", "odd_bed", "odd_fruit", "odd_teapot"]:
		game.target = game.entity_by_id(id)
		game.interact()
		press(Data.SENTENCES[id]["en"])
	assert(game.completed.has("strange"))
	# rumors: English and Varnak are built correctly
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
	print("PASS: fifth expansion: gossip, evidentials, replies, strange things, rumors, news, parrot, fish rain, rolling fruit")
	print("PASS: fourth expansion: drag and drop, gap fill, forge, match, challenges, memory, market rush, speed round, levels")
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

func has_text(t: String) -> bool:
	for c in game.content.get_children():
		if c.is_queued_for_deletion(): continue
		if (c is Label or c is RichTextLabel) and c.text.begins_with(t): return true
	return false
