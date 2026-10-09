extends RefCounted
# Kirmel, the lost Varnak syllabary (kir carve + mel speak).
# One glyph per syllable. The shape is the consonant; the way it is turned is the vowel:
# a points right, e is turned a quarter (down), i is turned around (left), o three quarters (up),
# and u points right with a short line under it. A dot inside means a voiced sound (b d g z v j),
# a short crossing bar turns s into sh and t into ch. A consonant with no vowel after it
# (the end of a syllable) is a small raised glyph. A lone vowel uses the open triangle.

const VOWELS = ["a", "e", "i", "o", "u"]
const TURN = {"a": 0.0, "e": 90.0, "i": 180.0, "o": 270.0, "u": 0.0}
const BASES = ["", "p", "t", "k", "m", "n", "ng", "l", "r", "s", "y", "w", "h", "f"]
# voiced and barred letters share a base shape with a mark
const MARKS = {"b": ["p", "dot"], "d": ["t", "dot"], "g": ["k", "dot"], "z": ["s", "dot"], "v": ["f", "dot"], "j": ["t", "dotbar"], "sh": ["s", "bar"], "ch": ["t", "bar"]}

# strokes for each base shape, pointing right (the a form), in a box from -1 to 1 (y down)
static func strokes(base: String) -> Array:
	match base:
		"": return [[Vector2(-0.7, -0.85), Vector2(0.8, 0.0), Vector2(-0.7, 0.85), Vector2(-0.7, -0.85)]]
		"p": return [[Vector2(-0.6, -0.85), Vector2(-0.6, 0.85), Vector2(0.75, 0.85)]]
		"t": return [[Vector2(-0.7, 0.85), Vector2(-0.7, -0.85), Vector2(0.7, -0.85), Vector2(0.7, -0.25)]]
		"k": return [arc(Vector2(0.15, 0.0), 0.8, 90.0, 270.0, 12)]
		"m": return [[Vector2(-0.85, 0.7), Vector2(-0.45, -0.7), Vector2(0.0, 0.3), Vector2(0.45, -0.7), Vector2(0.85, 0.7)]]
		"n": return [[Vector2(-0.7, 0.85), Vector2(-0.7, -0.85), Vector2(0.7, 0.85), Vector2(0.7, 0.15)]]
		"ng": return [arc(Vector2(-0.25, 0.0), 0.55, 0.0, 360.0, 16), [Vector2(0.3, 0.0), Vector2(0.9, 0.0)]]
		"l": return [[Vector2(-0.7, -0.85), Vector2(-0.7, 0.85)], [Vector2(-0.7, 0.0), Vector2(0.85, 0.0)]]
		"r": return [[Vector2(-0.8, 0.7), Vector2(-0.8, -0.7), Vector2(0.6, -0.7), Vector2(0.6, 0.35), Vector2(-0.2, 0.35)]]
		"s": return [[Vector2(-0.75, -0.9), Vector2(-0.2, -0.9), Vector2(0.55, 0.05), Vector2(-0.45, -0.05), Vector2(0.25, 0.9)]]
		"y": return [[Vector2(-0.8, -0.7), Vector2(0.0, 0.0), Vector2(-0.8, 0.7)], [Vector2(0.0, 0.0), Vector2(0.9, 0.0)]]
		"w": return [[Vector2(0.75, -0.85), Vector2(-0.6, 0.0), Vector2(0.75, 0.85)], [Vector2(0.75, -0.85), Vector2(0.75, -0.3)]]
		"h": return [[Vector2(-0.7, -0.85), Vector2(-0.7, 0.85)], [Vector2(-0.7, 0.0), Vector2(0.7, 0.0), Vector2(0.7, 0.85)]]
		"f": return [[Vector2(-0.8, 0.8), Vector2(0.75, -0.75)], [Vector2(0.75, -0.75), Vector2(0.0, -0.75)], [Vector2(0.75, -0.75), Vector2(0.75, 0.0)]]
	return [[Vector2(-0.5, -0.5), Vector2(0.5, 0.5)], [Vector2(-0.5, 0.5), Vector2(0.5, -0.5)]]

static func arc(c: Vector2, r: float, a0: float, a1: float, n: int) -> Array:
	var out: Array = []
	for i in range(n + 1):
		var a = deg_to_rad(lerpf(a0, a1, float(i) / n))
		out.append(c + Vector2(cos(a), sin(a)) * r)
	return out

static func normalize_text(t: String) -> String:
	var s = t.to_lower().replace("“", "").replace("”", "").replace("\"", "").replace("'", "")
	s = s.replace("c", "k").replace("kh", "ch").replace("q", "k").replace("x", "ks")
	s = s.replace("kh", "ch")
	return s

static func split_segments(w: String) -> Array:
	var out: Array = []
	var i = 0
	while i < w.length():
		var two = w.substr(i, 2)
		if two in ["ng", "sh", "ch"]:
			out.append(two)
			i += 2
		else:
			out.append(w[i])
			i += 1
	return out

# Break text into syllables: [{"c": onset, "v": vowel, "f": [final consonants]} or {"p": punctuation} or {"sp": true}]
static func syllables(text: String) -> Array:
	var out: Array = []
	var s = normalize_text(text)
	# "ch" was produced from "kh" above; restore real ch spellings
	s = s.replace("kh", "ch")
	var words = s.split(" ", false)
	for wi in range(words.size()):
		var raw: String = words[wi]
		var punct = ""
		var clean = ""
		for ch in raw:
			if ch in [".", "!", "?", ",", ":", ";"]: punct = ch
			elif ch == "-": continue
			elif (ch >= "a" and ch <= "z"): clean += ch
		var segs = split_segments(clean)
		var i = 0
		while i < segs.size():
			var seg: String = segs[i]
			if seg in VOWELS:
				var syl = {"c": "", "v": seg, "f": []}
				i += 1
				i = take_finals(segs, i, syl)
				out.append(syl)
			elif i + 1 < segs.size() and segs[i + 1] in VOWELS:
				var syl2 = {"c": seg, "v": segs[i + 1], "f": []}
				i += 2
				i = take_finals(segs, i, syl2)
				out.append(syl2)
			else:
				out.append({"c": seg, "v": "", "f": []})
				i += 1
		if punct != "": out.append({"p": punct})
		if wi < words.size() - 1: out.append({"sp": true})
	return out

static func take_finals(segs: Array, i: int, syl: Dictionary) -> int:
	while i < segs.size() and not (segs[i] in VOWELS):
		if i + 1 < segs.size() and segs[i + 1] in VOWELS: break
		syl["f"].append(segs[i])
		i += 1
	return i

static func key(syl: Dictionary) -> String:
	return str(syl.get("c", "")) + "|" + str(syl.get("v", ""))

static func label(syl: Dictionary) -> String:
	if syl.has("p") or syl.has("sp"): return ""
	return str(syl["c"]) + str(syl["v"]) + "".join(syl["f"])

static func base_of(c: String) -> Array:
	if MARKS.has(c): return MARKS[c]
	return [c, ""]

# Strokes for one glyph in local units, already turned for its vowel.
static func glyph_strokes(c: String, v: String) -> Array:
	var bm = base_of(c)
	var base: String = bm[0]
	var mark: String = bm[1]
	var raw: Array = strokes(base).duplicate(true)
	if mark in ["dot", "dotbar"]:
		var dp = {"p": Vector2(0.1, 0.15), "t": Vector2(0.0, 0.2), "k": Vector2(0.2, 0.0), "s": Vector2(-0.45, 0.45), "f": Vector2(0.3, 0.3)}.get(base, Vector2(0.3, 0.3))
		raw.append(arc(dp, 0.16, 0.0, 360.0, 8))
		raw.append(arc(dp, 0.07, 0.0, 360.0, 6))
	if mark in ["bar", "dotbar"]: raw.append([Vector2(-0.35, 0.45), Vector2(0.35, 0.45)])
	var ang = deg_to_rad(TURN.get(v, 0.0))
	var out: Array = []
	for line in raw:
		var l2: Array = []
		for p in line: l2.append((p as Vector2).rotated(ang))
		out.append(l2)
	if v == "u": out.append([Vector2(-0.8, 1.3), Vector2(0.8, 1.3)])
	return out

# Lay out syllables: returns [[strokes in pixels, color index]] and the size used.
static func layout(sylls: Array, cell: float, width: float) -> Dictionary:
	var lines: Array = []
	var x = cell * 0.6
	var y = cell * 0.9
	var gap = cell * 0.35
	var maxx = 0.0
	# measure words to wrap whole words
	var i = 0
	while i < sylls.size():
		var s: Dictionary = sylls[i]
		if s.has("sp"):
			x += cell * 0.6
			i += 1
			continue
		if s.has("p"):
			lines.append([arc(Vector2(x, y + cell * 0.35), cell * 0.1, 0.0, 360.0, 8), 1])
			x += cell * 0.45
			i += 1
			continue
		var wlen = 0.0
		var j = i
		while j < sylls.size() and not sylls[j].has("sp") and not sylls[j].has("p"):
			wlen += cell * (1.0 if sylls[j]["v"] != "" else 0.55) + gap + cell * 0.45 * sylls[j]["f"].size()
			j += 1
		if x + wlen > width and x > cell:
			x = cell * 0.6
			y += cell * 2.2
		if s["v"] != "":
			for st in glyph_strokes(s["c"], s["v"]):
				var pts: Array = []
				for p in st: pts.append(Vector2(x, y) + (p as Vector2) * cell * 0.5)
				lines.append([pts, 0])
			x += cell + gap
		else:
			for st in glyph_strokes(s["c"], "a"):
				var pts2: Array = []
				for p in st: pts2.append(Vector2(x - cell * 0.15, y - cell * 0.35) + (p as Vector2) * cell * 0.22)
				lines.append([pts2, 0])
			x += cell * 0.55 + gap * 0.5
		for f in s["f"]:
			for st in glyph_strokes(f, "a"):
				var pts3: Array = []
				for p in st: pts3.append(Vector2(x - cell * 0.15, y - cell * 0.35) + (p as Vector2) * cell * 0.22)
				lines.append([pts3, 0])
			x += cell * 0.45
		maxx = maxf(maxx, x)
		i += 1
	return {"lines": lines, "size": Vector2(maxf(maxx, cell * 2.0), y + cell * 1.4)}

static func draw_on(ci: CanvasItem, text_or_sylls, origin: Vector2, cell: float, width: float, color: Color, thick: float = 2.5) -> Vector2:
	var sylls: Array = syllables(text_or_sylls) if text_or_sylls is String else text_or_sylls
	var lay = layout(sylls, cell, width)
	for ln in lay["lines"]:
		var pts = PackedVector2Array()
		for p in ln[0]: pts.append(origin + p)
		ci.draw_polyline(pts, color, thick, true)
	return lay["size"]

# Paint text into an image (for carvings and signs).
static func image(text: String, w: int, h: int, cell: float, ink: Color, bg: Color, thick: int = 4) -> Image:
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(bg)
	var lay = layout(syllables(text), cell, w - cell)
	var off = Vector2((w - lay["size"].x) * 0.5, maxf(4.0, (h - lay["size"].y) * 0.5))
	for ln in lay["lines"]:
		var pts: Array = ln[0]
		for k in range(pts.size() - 1):
			var a: Vector2 = pts[k] + off
			var b: Vector2 = pts[k + 1] + off
			var steps = int(maxf(a.distance_to(b), 1.0))
			for s in range(steps + 1):
				var p = a.lerp(b, float(s) / steps)
				img.fill_rect(Rect2i(int(p.x) - thick / 2, int(p.y) - thick / 2, thick, thick), ink)
	return img
