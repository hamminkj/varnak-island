extends RefCounted
# Island shape. Height 0 is the flat ground the original village, harbor and forest sit on.
# Everything else (coast, river channel, west hill, hot spring, lagoon, harbor inlet) is
# carved or raised from that flat base, so older positions keep working.

const X0 = -100.0
const X1 = 100.0
const Z0 = -90.0
const Z1 = 100.0
const STEP = 2.0
const HILL = Vector3(-60.0, 9.0, -38.0)   # x, peak height, z
const HILL_R = 19.0
const POND = Vector2(-44.0, -22.0)
const LAGOON = Vector2(81.0, 22.0)
const LAGOON_R = 12.0
const RIDGE = Vector3(66.0, 8.0, -44.0)   # x, peak height, z (north-east ridge with the waterfall)
const RIDGE_R = 12.0
const FALLS_POOL = Vector2(64.0, -32.4)
const ISLET = Vector2(50.0, 82.0)
# Extra land beyond the main oval: south-west peninsula (ruins) and north-east headland (ridge).
const LOBES = [Vector3(-62.0, 40.0, 16.0), Vector3(66.0, -48.0, 14.0)]
# The river runs from the hot spring east to the sea.
const RIVER = [Vector2(-44, -22), Vector2(-30, -23), Vector2(0, -23), Vector2(30, -23), Vector2(55, -27), Vector2(75, -31), Vector2(98, -35)]

static func wobble(x: float, z: float) -> float:
	return sin(x * 0.11 + z * 0.05) * 0.5 + sin(z * 0.13 - x * 0.07 + 1.3) * 0.35 + sin((x + z) * 0.31) * 0.15

# Approximate metres inside the coastline (negative values are out at sea).
static func coast(x: float, z: float) -> float:
	var ax = 84.0
	var az = 50.0 if z < 0.0 else 47.0
	var d = pow(pow(absf(x) / ax, 4.0) + pow(absf(z) / az, 4.0), 0.25)
	var s = (1.0 - d) * 50.0 + wobble(x, z) * 2.5
	for l in LOBES:
		s = maxf(s, l.z - Vector2(x, z).distance_to(Vector2(l.x, l.y)) + wobble(z, x) * 1.5)
	s = maxf(s, 12.0 - Vector2(x, z).distance_to(ISLET) + wobble(x * 2.0, z) * 0.8)
	# harbor inlet: open water south of the dock head
	if absf(x) < 15.0 and z > 31.0:
		var e = minf(z - 33.0, 15.0 - absf(x))
		s = minf(s, 3.0 - e)
	# east lagoon
	var ld = Vector2(x, z).distance_to(LAGOON)
	if ld < LAGOON_R + 4.0:
		s = minf(s, 3.0 - (LAGOON_R - ld))
	return s

static func seg_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	return p.distance_to(a + ab * t)

static func river_dist(x: float, z: float) -> float:
	var p = Vector2(x, z)
	var best = 1e9
	for i in range(RIVER.size() - 1):
		best = minf(best, seg_dist(p, RIVER[i], RIVER[i + 1]))
	return best

# The river's centre line z at a given x (used to place reeds and crossings).
static func river_z(x: float) -> float:
	for i in range(RIVER.size() - 1):
		var a: Vector2 = RIVER[i]
		var b: Vector2 = RIVER[i + 1]
		if x >= a.x and x <= b.x:
			return lerpf(a.y, b.y, (x - a.x) / (b.x - a.x))
	return -23.0

static func height(x: float, z: float) -> float:
	var s = coast(x, z)
	var h = 0.0
	if s < 4.0: h = maxf((s - 4.0) * 0.12, -3.0)
	var hd = Vector2(x - HILL.x, z - HILL.z).length()
	if hd < HILL_R: h += HILL.y * 0.5 * (1.0 + cos(PI * hd / HILL_R))
	var rd = river_dist(x, z)
	if rd < 3.4: h = minf(h, lerpf(-1.1, 0.0, smoothstep(1.7, 3.4, rd)))
	var rgd = Vector2(x - RIDGE.x, z - RIDGE.z).length()
	if rgd < RIDGE_R: h += RIDGE.y * 0.5 * (1.0 + cos(PI * rgd / RIDGE_R))
	var id = Vector2(x, z).distance_to(ISLET)
	if id < 7.0 and h > -0.2: h += 0.6 * (1.0 - id / 7.0)
	var pd = Vector2(x, z).distance_to(POND)
	if pd < 5.5: h = minf(h, lerpf(-0.9, 0.0, smoothstep(3.0, 5.5, pd)))
	var fd = Vector2(x, z).distance_to(FALLS_POOL)
	if fd < 3.4: h = minf(h, lerpf(-1.0, 0.0, smoothstep(1.4, 3.4, fd)))
	return h

# Deep water the player cannot walk into.
static func deep(x: float, z: float) -> bool:
	return height(x, z) < -0.42

static func sand(x: float, z: float) -> float:
	return 1.0 - smoothstep(6.0, 10.0, coast(x, z))

# Ground mesh with vertex colours: r = sand, g = rock, b = unused.
static func build_mesh() -> ArrayMesh:
	var nx = int((X1 - X0) / STEP) + 1
	var nz = int((Z1 - Z0) / STEP) + 1
	var heights = PackedFloat32Array()
	heights.resize(nx * nz)
	for iz in range(nz):
		for ix in range(nx):
			heights[iz * nx + ix] = height(X0 + ix * STEP, Z0 + iz * STEP)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for iz in range(nz):
		for ix in range(nx):
			var x = X0 + ix * STEP
			var z = Z0 + iz * STEP
			var h = heights[iz * nx + ix]
			var hl = heights[iz * nx + maxi(ix - 1, 0)]
			var hr = heights[iz * nx + mini(ix + 1, nx - 1)]
			var hu = heights[maxi(iz - 1, 0) * nx + ix]
			var hdn = heights[mini(iz + 1, nz - 1) * nx + ix]
			var n = Vector3(hl - hr, 2.0 * STEP, hu - hdn).normalized()
			var rock = clampf((1.0 - n.y) * 4.0, 0.0, 1.0) * smoothstep(1.0, 3.0, h) + smoothstep(6.5, 8.8, h) * 0.5
			st.set_color(Color(sand(x, z) * (1.0 - smoothstep(0.6, 1.6, h)), clampf(rock, 0.0, 1.0), 0.0))
			st.set_normal(n)
			st.add_vertex(Vector3(x, h, z))
	for iz in range(nz - 1):
		for ix in range(nx - 1):
			var a = iz * nx + ix
			var b = a + 1
			var c = a + nx
			var d = c + 1
			st.add_index(a)
			st.add_index(b)
			st.add_index(c)
			st.add_index(b)
			st.add_index(d)
			st.add_index(c)
	return st.commit()
