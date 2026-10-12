extends SceneTree
# The cenote has to be reachable on foot. Everything at the bottom (the carvings,
# Var Tari, the whole Ayvu discovery) sits behind getting into the water, and the
# capybara trail leads players to the rim, so a wall there strands the content.
# Checks both routes: walking off the edge, and tapping the dive prompt.
const T = preload("res://terrain.gd")
var game
var fails: Array = []

func _initialize():
	call_deferred("run")

func frames(n: int = 2):
	for i in range(n):
		await process_frame
		await physics_frame

func stand_at(a: float, r: float):
	var p = Vector3(T.CENOTE.x + cos(a) * r, 0, T.CENOTE.y + sin(a) * r)
	p.y = T.height(p.x, p.z) + 1.0
	game.player.position = p
	game.player.velocity = Vector3.ZERO
	game.swimming = false
	await frames(2)
	game.player.rotation.y = atan2(-(T.CENOTE.x - p.x), -(T.CENOTE.y - p.z))

func run():
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await frames(4)

	# 1. walk off the edge, from every direction around the rim
	var walked_in = 0
	var dirs = 16
	for k in range(dirs):
		await stand_at(k * TAU / dirs, T.CENOTE_R + 5.0)
		for i in range(170):
			game.joy = Vector2(0, -1)
			await physics_frame
			if game.swimming: break
		game.joy = Vector2.ZERO
		if game.swimming: walked_in += 1
	print("walked in from ", walked_in, "/", dirs, " directions")
	if walked_in < dirs: fails.append("could not walk into the cenote from every direction (" + str(walked_in) + "/" + str(dirs) + ")")

	# 2. the dive prompt appears on the rim and puts the player in the water
	var dived = 0
	var prompted = 0
	for k in range(8):
		await stand_at(k * TAU / 8.0, T.CENOTE_R + 1.6)
		if game.at_cenote_rim(): prompted += 1
		game.dive_in()
		for i in range(200):
			await physics_frame
			if game.swimming: break
		if game.swimming: dived += 1
	print("dive prompt offered at ", prompted, "/8 spots, dive put the player in the water ", dived, "/8 times")
	if prompted < 8: fails.append("the dive prompt did not appear all around the rim")
	if dived < 8: fails.append("the dive did not put the player in the water every time")

	# 3. the prompt must NOT appear away from the cenote, or in the water
	game.player.position = Vector3(0, 1.0, 20)
	await frames(2)
	if game.at_cenote_rim(): fails.append("the dive prompt appears in the village")
	game.player.position = Vector3(T.CENOTE.x, game.cen_y_w - 1.0, T.CENOTE.y)
	await frames(6)
	if game.at_cenote_rim(): fails.append("the dive prompt appears while already swimming")

	# 4. once in, you can still dive deep and climb back out
	game.player.position = Vector3(T.CENOTE.x, game.cen_y_w - 1.0, T.CENOTE.y)
	await frames(4)
	game.swim_down_held = true
	var deepest = 0.0
	for i in range(260):
		await physics_frame
		deepest = maxf(deepest, game.cen_y_w - game.player.position.y)
	game.swim_down_held = false
	print("dove ", snappedf(deepest, 0.1), " m down")
	if deepest < 6.0: fails.append("could not dive away from the surface")
	game.climb_out()
	await frames(6)
	if game.swimming or game.player.position.y < game.cen_y_w + 0.5:
		fails.append("could not climb back out onto the rim")

	# 5. the open mouth must not let a swimmer out through the wall
	game.player.position = Vector3(T.CENOTE.x, game.cen_y_w - 1.0, T.CENOTE.y)
	await frames(4)
	for k in range(6):
		var a = k * TAU / 6.0
		game.player.rotation.y = a
		for i in range(60):
			game.joy = Vector2(0, -1)
			await physics_frame
		game.joy = Vector2.ZERO
		var d = Vector2(game.player.position.x, game.player.position.z).distance_to(T.CENOTE)
		if not game.in_cenote_water(game.player.position) or d > T.CENOTE_R + 1.5:
			fails.append("swam out through the shaft wall heading " + str(k) + " (dist " + str(snappedf(d, 0.1)) + ")")
		game.player.position = Vector3(T.CENOTE.x, game.cen_y_w - 1.0, T.CENOTE.y)
		await frames(3)

	print("cenote failures: ", fails.size())
	for f in fails: print("  - ", f)
	quit(1 if fails.size() > 0 else 0)
