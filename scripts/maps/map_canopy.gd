extends "res://scripts/maps/map_base.gd"
## Mapa 3: Canopy — nocny las tropikalny, platformy na gałęziach drzew.

func _get_sky_top() -> Color:    return Color(0.04, 0.06, 0.18)
func _get_sky_bottom() -> Color: return Color(0.07, 0.18, 0.08)

func _draw_decorations() -> void:
	# ── Gwiazdy ─────────────────────────────────────────────────────────────
	var star_data = [
		Vector2(-185,-115), Vector2(-170,-108), Vector2(-152,-118), Vector2(-130,-105),
		Vector2(-108,-112), Vector2( -88,-100), Vector2( -65,-115), Vector2( -45,-107),
		Vector2( -20,-118), Vector2(   5,-103), Vector2(  28,-112), Vector2(  50,-118),
		Vector2(  72,-104), Vector2(  95,-115), Vector2( 118,-108), Vector2( 140,-117),
		Vector2( 162,-103), Vector2( 180,-112), Vector2( 195,-118), Vector2(-158,-95),
		Vector2( -75, -92), Vector2(  35, -95), Vector2( 148, -92), Vector2(  90,-108),
	]
	for s in star_data:
		var size = 0.8 + fmod(abs(s.x + s.y) * 0.03, 1.2)
		draw_circle(s, size, Color(1, 1, 0.9, 0.75 + fmod(abs(s.x) * 0.01, 0.25)))

	# ── Księżyc ──────────────────────────────────────────────────────────────
	var moon = Vector2(155, -105)
	draw_circle(moon, 14, Color(0.95, 0.92, 0.78, 0.90))
	draw_circle(moon + Vector2(5, -3), 11, Color(0.07, 0.18, 0.08, 1.0))  # faza

	# ── Mgła przyziemna ─────────────────────────────────────────────────────
	for y in range(70, 90, 2):
		var a = 0.06 * (1.0 - float(y - 70) / 20.0)
		draw_line(Vector2(-200, float(y)), Vector2(200, float(y)), Color(0.6, 0.9, 0.7, a), 2.5)

	# ── Drzewa — warstwy od tyłu do przodu ───────────────────────────────────
	# Daleki plan (małe, ciemne)
	for x in [-170, -50, 70, 175]:
		_draw_tree_bg(Vector2(float(x), 84))

	# Główne drzewa (duże) z korzeniami
	_draw_big_tree(Vector2(-155, 84))
	_draw_big_tree(Vector2( -40, 84))
	_draw_big_tree(Vector2(  55, 84))
	_draw_big_tree(Vector2( 155, 84))

	# ── Mech i korzenie na ziemi ─────────────────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 7), Color(0.12, 0.32, 0.08))
	for i in range(50):
		var mx = -190.0 + i * 7.8
		var mh = 3.0 + fmod(float(i) * 2.3, 4.0)
		draw_line(Vector2(mx, 84), Vector2(mx + 1, 84 - mh), Color(0.18, 0.45, 0.10, 0.7), 1.0)

	# ── Grzyby ───────────────────────────────────────────────────────────────
	for pos in [Vector2(-178, 84), Vector2(-100, 84), Vector2(20, 84), Vector2(120, 84), Vector2(182, 84)]:
		_draw_mushroom(pos)

	# ── Liany zwisające z góry ───────────────────────────────────────────────
	for lx in [-140.0, -60.0, 30.0, 110.0]:
		_draw_vine(lx)

	# ── Platformy — gałęzie drzew ────────────────────────────────────────────
	_draw_branch_platform(Rect2(-160, 55, 60, 10), Color(0.30, 0.18, 0.08))
	_draw_branch_platform(Rect2( -70, 35, 50, 10), Color(0.18, 0.42, 0.09))
	_draw_branch_platform(Rect2(  20, 15, 55, 10), Color(0.30, 0.18, 0.08))
	_draw_branch_platform(Rect2( 110, 40, 60, 10), Color(0.18, 0.42, 0.09))
	_draw_branch_platform(Rect2( -30,-15, 60, 10), Color(0.14, 0.30, 0.07))
	_draw_branch_platform(Rect2(-130, -5, 50, 10), Color(0.18, 0.42, 0.09))
	_draw_branch_platform(Rect2(  70,-20, 50, 10), Color(0.30, 0.18, 0.08))

	# ── Świetliki ────────────────────────────────────────────────────────────
	var firefly_positions = [
		Vector2(-160,-20), Vector2(-120, 10), Vector2(-80,-40), Vector2(-40, 25),
		Vector2(  10,-15), Vector2(  55, 35), Vector2( 85,-30), Vector2(125,  5),
		Vector2( 160,-45), Vector2(-175, 30), Vector2( 175, 20), Vector2(  0, 60),
		Vector2( -55,-10), Vector2( 100,-50), Vector2(-100, 50),
	]
	for fp in firefly_positions:
		var brightness = 0.55 + fmod(abs(fp.x * fp.y) * 0.001, 0.45)
		draw_circle(fp, 2.8, Color(0.6, 1.0, 0.4, brightness * 0.35))
		draw_circle(fp, 1.5, Color(0.8, 1.0, 0.5, brightness))
		draw_circle(fp, 0.7, Color(1.0, 1.0, 0.8, 1.0))


func _draw_tree_bg(base: Vector2) -> void:
	draw_rect(Rect2(base.x - 2, base.y - 55, 4, 55), Color(0.12, 0.08, 0.04, 0.5))
	draw_circle(base + Vector2(0, -60), 14, Color(0.06, 0.18, 0.04, 0.50))
	draw_circle(base + Vector2(-6,-68),  9, Color(0.07, 0.20, 0.05, 0.45))
	draw_circle(base + Vector2( 7,-65), 10, Color(0.07, 0.20, 0.05, 0.45))


func _draw_big_tree(base: Vector2) -> void:
	var trunk = Color(0.22, 0.13, 0.06)
	# Korzenie
	draw_line(Vector2(base.x - 6, base.y), Vector2(base.x - 14, base.y + 6), trunk, 2.5)
	draw_line(Vector2(base.x + 5, base.y), Vector2(base.x + 12, base.y + 5), trunk, 2.5)
	# Pień
	draw_rect(Rect2(base.x - 5, base.y - 80, 10, 80), trunk)
	draw_line(Vector2(base.x - 2, base.y - 78), Vector2(base.x - 2, base.y - 5), trunk.darkened(0.3), 1.5)
	draw_line(Vector2(base.x + 3, base.y - 72), Vector2(base.x + 3, base.y - 8), trunk.lightened(0.12), 1.0)
	# Konar główny
	draw_line(Vector2(base.x, base.y - 55), Vector2(base.x - 22, base.y - 72), trunk, 3.0)
	draw_line(Vector2(base.x, base.y - 50), Vector2(base.x + 20, base.y - 68), trunk, 3.0)
	# Liście (ciemno→jasno)
	draw_circle(base + Vector2( 0, -88), 24, Color(0.07, 0.26, 0.04, 0.72))
	draw_circle(base + Vector2(-14,-96), 17, Color(0.09, 0.30, 0.05, 0.78))
	draw_circle(base + Vector2( 15,-93), 18, Color(0.09, 0.30, 0.05, 0.75))
	draw_circle(base + Vector2(  0,-104), 14, Color(0.12, 0.36, 0.07, 0.80))
	draw_circle(base + Vector2( -7,-110),  9, Color(0.15, 0.42, 0.09, 0.70))
	draw_circle(base + Vector2(  8,-108), 10, Color(0.15, 0.42, 0.09, 0.68))


func _draw_mushroom(base: Vector2) -> void:
	# Trzon
	draw_rect(Rect2(base.x - 2, base.y - 8, 4, 8), Color(0.85, 0.80, 0.72))
	# Kapelusz
	var cap_col = Color(0.75, 0.18, 0.12, 0.90)
	draw_circle(base + Vector2(0, -9), 6, cap_col)
	draw_circle(base + Vector2(-3,-8), 4, cap_col)
	draw_circle(base + Vector2( 3,-8), 4, cap_col)
	# Białe kropki
	draw_circle(base + Vector2( 0,-10), 1.2, Color(1,1,1,0.85))
	draw_circle(base + Vector2(-2, -8), 0.8, Color(1,1,1,0.75))
	draw_circle(base + Vector2( 2, -7), 0.8, Color(1,1,1,0.75))


func _draw_vine(x: float) -> void:
	var points = 18
	for i in range(points - 1):
		var t0 = float(i) / float(points)
		var t1 = float(i + 1) / float(points)
		var swing0 = sin(t0 * PI * 1.5) * 4
		var swing1 = sin(t1 * PI * 1.5) * 4
		var y0 = -120 + t0 * 80
		var y1 = -120 + t1 * 80
		draw_line(Vector2(x + swing0, y0), Vector2(x + swing1, y1), Color(0.18, 0.50, 0.10, 0.70), 1.5)
		# Listki
		if i % 3 == 1:
			draw_circle(Vector2(x + swing0 + 4, y0), 2.5, Color(0.20, 0.52, 0.12, 0.55))


func _draw_branch_platform(rect: Rect2, col: Color) -> void:
	# Kora drzewa
	draw_rect(rect, col)
	# Tekstura kory — podłużne linie
	for i in range(int(rect.size.x / 8)):
		var lx = rect.position.x + i * 8 + 4
		draw_line(Vector2(lx, rect.position.y), Vector2(lx + 2, rect.end.y), col.darkened(0.25), 0.8)
	# Mech na wierzchu
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2.5), Color(0.20, 0.50, 0.10, 0.75))
	for i in range(int(rect.size.x / 5)):
		var mx = rect.position.x + i * 5 + 2
		draw_circle(Vector2(mx, rect.position.y + 1), 1.5, Color(0.18, 0.48, 0.09, 0.60))
	# Krawędź cień
	draw_line(Vector2(rect.position.x, rect.end.y), rect.end, col.darkened(0.35), 1.5)
