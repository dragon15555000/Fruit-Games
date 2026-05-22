extends "res://scripts/map/map_base.gd"
## Mapa 1: Fruit Bowl — letnia otwarta arena z owocowym ogrodem.

func _get_sky_top() -> Color:    return Color(0.32, 0.62, 0.98)
func _get_sky_bottom() -> Color: return Color(0.72, 0.88, 1.0)

func _draw_decorations() -> void:
	# ── Słońce ──────────────────────────────────────────────────────────────
	var sun = Vector2(168, -102)
	draw_circle(sun, 22, Color(1.0, 0.90, 0.25, 0.35))   # blask
	draw_circle(sun, 16, Color(1.0, 0.93, 0.35, 0.55))   # poświata
	draw_circle(sun, 11, Color(1.0, 0.97, 0.55, 1.0))    # tarcza
	for i in range(10):
		var a = i * TAU / 10.0
		var d = Vector2(cos(a), sin(a))
		draw_line(sun + d * 14, sun + d * 22, Color(1.0, 0.92, 0.4, 0.55), 1.2)

	# ── Chmury ──────────────────────────────────────────────────────────────
	_draw_puffy_cloud(Vector2(-145, -95), 1.0)
	_draw_puffy_cloud(Vector2(55,  -105), 1.2)
	_draw_puffy_cloud(Vector2(-25,  -78), 0.65)

	# ── Drzewa owocowe w tle ────────────────────────────────────────────────
	_draw_fruit_tree(Vector2(-182, 84), Color(0.40, 0.25, 0.10))
	_draw_fruit_tree(Vector2( 178, 84), Color(0.42, 0.27, 0.11))
	_draw_fruit_tree(Vector2(  -5, 84), Color(0.38, 0.24, 0.10))

	# ── Micha (Fruit Bowl) w tle ────────────────────────────────────────────
	_draw_bowl(Vector2(0, 68))

	# ── Trawa z kępkami ─────────────────────────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 8), Color(0.26, 0.65, 0.17))
	for i in range(48):
		var bx = -190.0 + i * 8.2
		var h = 4.0 + fmod(float(i) * 3.7, 3.0)
		draw_line(Vector2(bx, 84), Vector2(bx - 1.5, 84 - h), Color(0.20, 0.55, 0.12, 0.85), 1.1)
		draw_line(Vector2(bx + 2, 84), Vector2(bx + 3, 84 - h + 1), Color(0.25, 0.60, 0.15, 0.75), 1.0)

	# ── Kwiaty ──────────────────────────────────────────────────────────────
	var flower_xs = [-170.0, -110.0, -45.0, 25.0, 85.0, 148.0]
	var flower_cols = [Color(1,0.4,0.7), Color(1,0.85,0.2), Color(0.5,0.4,1), Color(1,0.5,0.3), Color(0.4,0.9,0.5), Color(1,0.4,0.6)]
	for i in range(flower_xs.size()):
		_draw_flower(Vector2(flower_xs[i], 82), flower_cols[i])

	# ── Platformy drewniane ─────────────────────────────────────────────────
	_draw_wooden_platform(Rect2(-171, 28, 92, 17))
	_draw_wooden_platform(Rect2(52, 46, 92, 17))


func _draw_puffy_cloud(pos: Vector2, s: float) -> void:
	var c = Color(1, 1, 1, 0.82)
	draw_circle(pos, 10 * s, c)
	draw_circle(pos + Vector2(-9, 3) * s,  7 * s, c)
	draw_circle(pos + Vector2( 9, 3) * s,  7 * s, c)
	draw_circle(pos + Vector2(-4, 6) * s,  5 * s, c)
	draw_circle(pos + Vector2( 4, 6) * s,  5 * s, c)
	draw_circle(pos + Vector2( 0, 7) * s,  6 * s, c)
	# Cień na spodzie
	draw_circle(pos + Vector2(0, 8) * s,   7 * s, Color(0.82, 0.87, 0.95, 0.25))


func _draw_fruit_tree(base: Vector2, trunk: Color) -> void:
	# Pień z teksturą
	draw_rect(Rect2(base.x - 4, base.y - 42, 8, 42), trunk)
	draw_line(Vector2(base.x - 1, base.y - 40), Vector2(base.x - 1, base.y - 5), trunk.darkened(0.25), 1.0)
	draw_line(Vector2(base.x + 2, base.y - 35), Vector2(base.x + 2, base.y - 8), trunk.lightened(0.1), 0.8)
	# Gałąź lewa
	draw_line(Vector2(base.x, base.y - 30), Vector2(base.x - 14, base.y - 45), trunk, 2.0)
	# Gałąź prawa
	draw_line(Vector2(base.x, base.y - 28), Vector2(base.x + 12, base.y - 42), trunk, 2.0)
	# Korona — 4 warstwy ciemno→jasno
	draw_circle(base + Vector2(0,   -52), 22, Color(0.10, 0.38, 0.08, 0.60))
	draw_circle(base + Vector2(-10, -60), 16, Color(0.14, 0.44, 0.10, 0.70))
	draw_circle(base + Vector2( 11, -58), 17, Color(0.14, 0.44, 0.10, 0.70))
	draw_circle(base + Vector2(  0, -65), 14, Color(0.18, 0.52, 0.12, 0.78))
	draw_circle(base + Vector2( -6, -68), 10, Color(0.22, 0.58, 0.14, 0.65))
	# Owoce
	for off in [Vector2(-8,-50), Vector2(7,-54), Vector2(-2,-66), Vector2(11,-47), Vector2(-14,-60)]:
		draw_circle(base + off, 3.8, Color(0.92, 0.14, 0.14, 0.9))
		draw_circle(base + off + Vector2(-1, -1), 1.2, Color(1.0, 0.5, 0.5, 0.6))


func _draw_flower(pos: Vector2, col: Color) -> void:
	for i in range(6):
		var a = i * TAU / 6.0
		draw_circle(pos + Vector2(cos(a), sin(a)) * 3.2, 2.6, Color(col.r, col.g, col.b, 0.82))
	draw_circle(pos, 2.2, Color(1.0, 0.95, 0.20, 0.95))


func _draw_bowl(center: Vector2) -> void:
	var col = Color(0.75, 0.62, 0.45, 0.13)
	var rim = Color(0.85, 0.72, 0.52, 0.18)
	# Elipsa miski (dolna połowa)
	var steps = 32
	for i in range(steps):
		var a0 = i * PI / steps
		var a1 = (i + 1) * PI / steps
		draw_line(
			center + Vector2(cos(a0) * 85, sin(a0) * 22),
			center + Vector2(cos(a1) * 85, sin(a1) * 22),
			col, 2.5)
	# Krawędź (obwódka góry)
	for i in range(steps):
		var a0 = i * PI / steps
		var a1 = (i + 1) * PI / steps
		draw_line(
			center + Vector2(cos(a0) * 85, -3),
			center + Vector2(cos(a1) * 85, -3),
			rim, 3.0)
	# Nóżka miski
	draw_rect(Rect2(center.x - 6, center.y + 18, 12, 8), col)
	draw_rect(Rect2(center.x - 14, center.y + 26, 28, 4), rim)


func _draw_wooden_platform(rect: Rect2) -> void:
	var wood   = Color(0.52, 0.36, 0.16)
	var light  = Color(0.68, 0.50, 0.25)
	var dark   = Color(0.35, 0.22, 0.08)
	draw_rect(rect, wood)
	# Słoje drewna (pionowe linie)
	var step = 10
	for i in range(int(rect.size.x / step)):
		var x = rect.position.x + i * step + step * 0.5
		draw_line(Vector2(x, rect.position.y + 1), Vector2(x, rect.end.y - 1), Color(0.40, 0.26, 0.10, 0.30), 0.8)
	# Górna jasna krawędź (trawa/mech)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2), Color(0.35, 0.62, 0.18))
	# Boki ciemniejsze
	draw_line(rect.position, Vector2(rect.position.x, rect.end.y), dark, 1.5)
	draw_line(Vector2(rect.end.x, rect.position.y), rect.end, dark, 1.5)
	# Dolna linia cień
	draw_line(Vector2(rect.position.x + 1, rect.end.y), rect.end, dark, 1.5)
	# Górna jasna linia
	draw_line(Vector2(rect.position.x, rect.position.y + 2), Vector2(rect.end.x, rect.position.y + 2), light, 1.0)
