extends SceneTree
# The three quiet features: sitting, the singing stones and the drifting raft.
# None of them is on a quest path, so nothing else would notice if they broke.
const T = preload("res://terrain.gd")
const Data = preload("res://data.gd")
var game
var fails: Array = []

func _initialize():
	call_deferred("run")

func frames(n: int = 2):
	for i in range(n):
		await process_frame
		await physics_frame

func run():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await frames(4)

	# ---- sitting ----
	game.player.position = Vector3(0, 0.4, 20)
	await frames(6)
	var stand_h = game.camera.position.y
	game.toggle_sit()
	await frames(2)
	if not game.sitting: fails.append("could not sit down on open ground")
	for i in range(90): await frames(1)
	if game.camera.position.y > stand_h - 0.5:
		fails.append("sitting did not lower the view (" + str(snappedf(game.camera.position.y, 0.01)) + " vs " + str(stand_h) + ")")
	if game.status.modulate.a > 0.5: fails.append("sitting did not quiet the interface")
	# walking gets you up again
	game.joy = Vector2(0, -1)
	await frames(3)
	game.joy = Vector2.ZERO
	if game.sitting: fails.append("walking did not stand the player up")
	for i in range(80): await frames(1)
	if absf(game.camera.position.y - stand_h) > 0.05:
		fails.append("the view did not come back up after standing (" + str(snappedf(game.camera.position.y, 0.01)) + ")")
	# you cannot sit while swimming
	game.player.position = Vector3(T.CENOTE.x, game.cen_y_w - 1.0, T.CENOTE.y)
	await frames(8)
	game.toggle_sit()
	await frames(2)
	if game.sitting: fails.append("sat down while swimming")
	game.sitting = false

	# ---- the singing stones ----
	if game.ning_stones.size() != 5: fails.append("expected five singing stones, found " + str(game.ning_stones.size()))
	for i in range(5):
		if not game.sfx.has("stone" + str(i)): fails.append("the tone stone" + str(i) + " did not load")
		var e = game.entity_by_id("ningsek" + str(i))
		if e.is_empty():
			fails.append("singing stone " + str(i) + " is not something you can touch")
			continue
		var d = Vector2((e["node"] as Node3D).position.x, (e["node"] as Node3D).position.z).distance_to(game.NING_SEK)
		if d > 6.0: fails.append("singing stone " + str(i) + " is " + str(snappedf(d, 0.1)) + " m from the hilltop")
	if not game.words.has("ning-sek"): fails.append("ning-sek has no notebook entry")
	game.solved.erase("ningsek")
	game.discovered.erase("ning-sek")
	game.player.position = Vector3(game.NING_SEK.x, 9.0, game.NING_SEK.y)
	await frames(4)
	game.examine(game.entity_by_id("ningsek2"))
	await frames(2)
	if not game.discovered.has("ning-sek"): fails.append("striking a stone taught nothing")
	if game.panel.visible: fails.append("striking a stone opened a panel; it should just sound")
	# the wind sounds them on its own
	game.ning_cd = 0.01
	var before = game.sfx_last.duplicate()
	for i in range(140): await frames(1)
	var played = false
	for i in range(5):
		if game.sfx_last.get("stone" + str(i), -9.0) != before.get("stone" + str(i), -9.0): played = true
	if not played: fails.append("the wind never sounded the stones")

	# ---- the raft ----
	if game.raft_node == null:
		fails.append("there is no raft")
	else:
		if game.raft_path.size() < 4: fails.append("the raft has no river to follow")
		var a = game.raft_point(0.0)
		var b = game.raft_point(1.0)
		if a.x > -39.0: fails.append("the raft does not start at the hot spring end")
		if b.x < 80.0: fails.append("the raft does not reach the sea (" + str(snappedf(b.x, 1)) + ")")
		# even speed the whole way: no stretch should be more than twice another
		var steps: Array = []
		for i in range(10):
			steps.append(game.raft_point(float(i + 1) / 10.0).distance_to(game.raft_point(float(i) / 10.0)))
		var lo = steps.min()
		var hi = steps.max()
		if hi > lo * 1.6: fails.append("the raft speeds up and slows down (" + str(snappedf(lo, 0.1)) + " to " + str(snappedf(hi, 0.1)) + " per tenth)")
		# the whole drift, and it must put the player on dry land at the end
		game.player.position = Vector3(-40.0, 0.4, -20.0)
		await frames(2)
		game.raft_board()
		await frames(2)
		if not game.rafting: fails.append("could not board the raft")
		var start_x = game.player.position.x
		for i in range(40): await frames(1)
		var moved_early = game.player.position.x - start_x
		if moved_early < 0.4: fails.append("the raft is not drifting (" + str(snappedf(moved_early, 0.1)) + " m)")
		# skip to the end rather than sit through the whole minute
		game.raft_t = 0.97
		for i in range(260):
			await frames(1)
			if not game.rafting: break
		var moved = game.player.position.x - start_x
		if game.rafting:
			game.raft_land(false)
			await frames(2)
		if moved < 20.0: fails.append("the raft barely moved (" + str(snappedf(moved, 1)) + " m)")
		await frames(4)
		var pz = game.player.position
		if T.height(pz.x, pz.z) < 0.0: fails.append("stepping off the raft left the player in the water")
		if game.rafting: fails.append("still rafting after landing")

	print("quiet-feature failures: ", fails.size())
	for f in fails: print("  - ", f)
	quit(1 if fails.size() > 0 else 0)
