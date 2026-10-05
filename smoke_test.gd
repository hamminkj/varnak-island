extends SceneTree
const Data = preload("res://data.gd")
var game
func _initialize():
	call_deferred("run")
func press(label: String):
	for child in game.content.get_children():
		if child is Button and child.text == label:
			child.pressed.emit()
			return
	assert(false, "Missing button: " + label)
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
