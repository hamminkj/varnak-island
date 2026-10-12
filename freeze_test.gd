extends SceneTree
# Hunts dead-end panels: a panel left open with no button the player can press
# is a freeze, because _physics_process returns early while panel.visible.
# Opens a panel, then presses each of its buttons in turn from a fresh open.
const Data = preload("res://data.gd")
var game
var fails: Array = []
var seen := 0
var steps := 0

func _initialize():
	call_deferred("run")

func buttons(node: Node) -> Array:
	var out: Array = []
	for child in node.get_children():
		if child.is_queued_for_deletion(): continue
		if child is CanvasItem and not child.visible: continue
		if child is Button and not child.disabled: out.append(child)
		out.append_array(buttons(child))
	return out

func check(label: String) -> bool:
	if not game.panel.visible: return false
	seen += 1
	if buttons(game.content).is_empty():
		fails.append(label + "   [title: " + str(game.cur_title) + "]")
		print("DEAD END: ", label, "   title=", game.cur_title)
		return false
	return true

func breathe():
	steps += 1
	if steps % 20 == 0: await process_frame

func press_all(label: String, open: Callable):
	game.close_panel()
	open.call()
	await breathe()
	if not check(label): return
	var n = buttons(game.content).size()
	for i in range(n):
		game.close_panel()
		open.call()
		await breathe()
		var bs = buttons(game.content)
		if i >= bs.size(): break
		var b: Button = bs[i]
		var t = b.text
		if t.begins_with("Set off") or t.contains("Return to island"): continue
		if b.toggle_mode: b.button_pressed = not b.button_pressed
		else: b.pressed.emit()
		await breathe()
		check(label + " > " + t)

func profile(kind: String):
	game.completed.clear()
	game.inventory = ["own_bag"]
	if kind != "fresh":
		for q in ["belongings", "meal", "bag", "bridge", "heard_dofo", "heard_sital", "heard_rofi", "evidence"]:
			game.completed.append(q)
	if kind == "all":
		for q in game.quests: game.completed.append(q[0])
		for s in game.side_quests: game.completed.append(s[0])

func run():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for kind in ["fresh", "evidence", "all"]:
		profile(kind)
		for p in Data.PEOPLE.keys():
			seed(p.hash())
			await press_all("talk(" + p + ") [" + kind + "]", game.talk.bind(p))
			await press_all("chat(" + p + ") [" + kind + "]", game.chat_menu.bind(p))
	profile("evidence")
	for i in range(12):
		seed(i * 104729)
		await press_all("teach_neri", game.teach_neri.bind(game.talk.bind("neri")))
		await press_all("neri_story", game.neri_story)
		await press_all("tile_puzzle", game.tile_puzzle.bind(-1, game.talk.bind("neri")))
		await press_all("gap_fill", game.gap_fill.bind(game.talk.bind("neri")))
		await press_all("word_forge", game.word_forge.bind(game.talk.bind("neri")))
		await press_all("guess_start", game.guess_start)
		await press_all("show_practice", game.show_practice)
	print("panels checked: ", seen, "  dead ends: ", fails.size())
	for f in fails: print("  - ", f)
	quit(1 if fails.size() > 0 else 0)
