extends SceneTree
# The talk view swaps in a second camera and the panel slides down the screen. If it
# ever fails to swap back, the player sees a still of somebody's face while their own
# input does nothing, which looks exactly like a freeze. This walks the player up to
# every villager in turn, opens the panel, lets the camera settle, closes it, and
# checks that control comes back each time.
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
	for p in Data.PEOPLE.keys():
		var e = game.entity_by_id(p)
		if e.is_empty():
			fails.append(p + ": no entity")
			continue
		var node = e["node"] as Node3D
		if not node.has_meta("head"):
			fails.append(p + ": the talk camera has no head to aim at")
			continue
		game.player.position = node.position + Vector3(2.0, 0, 2.0)
		await frames(2)
		game.talk(p)
		await frames(6)
		if game.talk_view_id != p:
			fails.append(p + ": the talk view never engaged (talk_view_id=" + str(game.talk_view_id) + ")")
		if not game.talk_cam.current:
			fails.append(p + ": the talk camera did not become current")
		var pose = game.talk_cam_pose(p)
		if pose.is_empty():
			fails.append(p + ": talk_cam_pose came back empty while in the talk view")
		game.close_panel()
		await frames(6)
		if game.talk_cam.current or not game.camera.current:
			fails.append(p + ": the island camera did not come back after closing")
		if game.talk_view_id != "":
			fails.append(p + ": talk_view_id stuck at " + str(game.talk_view_id))
	# and the same for a villager who gets hidden while the panel is open
	var who: String = Data.PEOPLE.keys()[0]
	var e2 = game.entity_by_id(who)
	game.player.position = (e2["node"] as Node3D).position + Vector3(2.0, 0, 2.0)
	await frames(2)
	game.talk(who)
	await frames(4)
	(e2["node"] as Node3D).visible = false
	await frames(6)
	if game.talk_cam.current:
		fails.append("hiding " + who + " mid-conversation left the talk camera on")
	game.close_panel()
	(e2["node"] as Node3D).visible = true
	await frames(4)
	if not game.camera.current:
		fails.append("the island camera never came back after " + who + " was hidden")
	print("talk camera failures: ", fails.size())
	for f in fails: print("  - ", f)
	quit(1 if fails.size() > 0 else 0)
