extends "res://scripts/map/map_base.gd"
## Mapa 2: Juice Factory — mroczna fabryka soku, industrialne rury i platformy.

func _get_sky_top() -> Color:    return Color(0.10, 0.08, 0.16)
func _get_sky_bottom() -> Color: return Color(0.22, 0.14, 0.10)

func _draw_decorations() -> void:
	# ── Tło — ściana cegieł ─────────────────────────────────────────────────
	_draw_brick_wall()

	# ── Główne rury pionowe ──────────────────────────────────────────────────
	for x in [-160, -80, 0, 80, 160]:
		_draw_vertical_pipe(x, -120, 90)

	# ── Rury poziome ────────────────────────────────────────────────────────
	_draw_horizontal_pipe(-192, 192, -70, Color(0.38, 0.38, 0.44))
	_draw_horizontal_pipe(-192,  -60, 15, Color(0.38, 0.38, 0.44))
	_draw_horizontal_pipe(  60,  192, 15, Color(0.38, 0.38, 0.44))

	# ── Złącza rur ──────────────────────────────────────────────────────────
	for x in [-160, -80, 0, 80, 160]:
		draw_circle(Vector2(x, -70), 5, Color(0.50, 0.50, 0.56))
		draw_circle(Vector2(x, -70), 3, Color(0.32, 0.32, 0.38))
	draw_circle(Vector2(-60, 15), 5, Color(0.50, 0.50, 0.56))
	draw_circle(Vector2( 60, 15), 5, Color(0.50, 0.50, 0.56))

	# ── Barrels (beczki soku) ────────────────────────────────────────────────
	_draw_barrel(Vector2(-185, 72), Color(0.60, 0.28, 0.08))
	_draw_barrel(Vector2(-172, 72), Color(0.55, 0.25, 0.07))
	_draw_barrel(Vector2( 172, 72), Color(0.60, 0.28, 0.08))
	_draw_barrel(Vector2( 185, 72), Color(0.55, 0.25, 0.07))

	# ── Podłoga — metalowe płyty ─────────────────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 6), Color(0.28, 0.28, 0.34))
	for i in range(8):
		var x = -192 + i * 48 + 24
		draw_line(Vector2(x, 84), Vector2(x, 90), Color(0.18, 0.18, 0.22, 0.7), 1.0)

	# ── Żółte lampy ostrzegawcze ─────────────────────────────────────────────
	for pos in [Vector2(-180, -112), Vector2(-90, -112), Vector2(0, -112), Vector2(90, -112), Vector2(180, -112)]:
		_draw_warning_lamp(pos)

	# ── Sok spływający z rur ─────────────────────────────────────────────────
	_draw_juice_drip(Vector2(-160, -70), Color(1.0, 0.45, 0.1,  0.65))
	_draw_juice_drip(Vector2(   0, -70), Color(0.85, 0.15, 0.2, 0.55))
	_draw_juice_drip(Vector2( 160, -70), Color(0.3,  0.75, 0.2, 0.60))

	# ── Platformy metalowe ───────────────────────────────────────────────────
	_draw_metal_platform(Rect2(-170, 50,  80, 12))
	_draw_metal_platform(Rect2(  90, 50,  80, 12))
	_draw_metal_platform(Rect2( -60, 20, 120, 12))
	_draw_metal_platform(Rect2(-150, -10, 70, 12))
	_draw_metal_platform(Rect2(  80, -10, 70, 12))

	# ── Pary / opary ─────────────────────────────────────────────────────────
	for i in range(6):
		var sx = -150.0 + i * 60.0
		draw_circle(Vector2(sx, -100 - i * 3), 6 + i, Color(0.9, 0.9, 0.9, 0.04))


func _draw_brick_wall() -> void:
	var brick  = Color(0.22, 0.14, 0.10)
	var mortar = Color(0.16, 0.11, 0.09)
	var row_h  = 10
	var brick_w = 30
	for row in range(-120, 100, row_h):
		var offset = (row / row_h % 2) * (brick_w / 2)
		for col in range(-200, 220, brick_w):
			var bx = col + offset
			draw_rect(Rect2(bx, row, brick_w - 1, row_h - 1), brick)
	# Ciemna mgła na tle (zaciemnienie)
	for y in range(-120, 100, 4):
		var t = inverse_lerp(-120, 100, float(y))
		draw_line(Vector2(-220, y), Vector2(220, y), Color(0, 0, 0, 0.45 - t * 0.2), 4.0)


func _draw_vertical_pipe(x: float, y_top: float, y_bot: float) -> void:
	var dark   = Color(0.22, 0.22, 0.28)
	var mid    = Color(0.36, 0.36, 0.42)
	var light  = Color(0.50, 0.50, 0.56)
	draw_line(Vector2(x - 4, y_top), Vector2(x - 4, y_bot), dark,  7)
	draw_line(Vector2(x,     y_top), Vector2(x,     y_bot), mid,   7)
	draw_line(Vector2(x + 4, y_top), Vector2(x + 4, y_bot), dark,  7)
	draw_line(Vector2(x - 2, y_top), Vector2(x - 2, y_bot), light, 1)


func _draw_horizontal_pipe(x0: float, x1: float, y: float, col: Color) -> void:
	draw_line(Vector2(x0, y - 3), Vector2(x1, y - 3), col.darkened(0.3),  6)
	draw_line(Vector2(x0, y),     Vector2(x1, y),     col,                6)
	draw_line(Vector2(x0, y + 3), Vector2(x1, y + 3), col.darkened(0.3),  6)
	draw_line(Vector2(x0, y - 2), Vector2(x1, y - 2), col.lightened(0.2), 1)


func _draw_barrel(center: Vector2, col: Color) -> void:
	draw_rect(Rect2(center.x - 7, center.y - 12, 14, 12), col)
	# Obręcze
	for ry in [center.y - 10, center.y - 5, center.y - 1]:
		draw_line(Vector2(center.x - 7, ry), Vector2(center.x + 7, ry), col.darkened(0.4), 1.5)
	# Wieczko
	draw_rect(Rect2(center.x - 8, center.y - 13, 16, 3), col.lightened(0.15))
	# Poświata soku
	draw_circle(center + Vector2(0, -3), 4, Color(1.0, 0.5, 0.1, 0.08))


func _draw_warning_lamp(pos: Vector2) -> void:
	# Obudowa
	draw_rect(Rect2(pos.x - 5, pos.y - 4, 10, 8), Color(0.3, 0.3, 0.35))
	# Blask
	draw_circle(pos, 8, Color(1.0, 0.75, 0.1, 0.10))
	draw_circle(pos, 4, Color(1.0, 0.82, 0.2, 0.70))
	draw_circle(pos, 2, Color(1.0, 0.95, 0.5, 1.00))


func _draw_juice_drip(top: Vector2, col: Color) -> void:
	# Strumień soku
	var length = 18.0
	for i in range(int(length)):
		var alpha = 0.6 * (1.0 - float(i) / length)
		draw_circle(top + Vector2(0, float(i)), 1.5, Color(col.r, col.g, col.b, alpha))
	# Kapla
	draw_circle(top + Vector2(0, length), 3, Color(col.r, col.g, col.b, 0.5))


func _draw_metal_platform(rect: Rect2) -> void:
	var base   = Color(0.34, 0.34, 0.40)
	var light  = Color(0.52, 0.52, 0.58)
	var dark   = Color(0.20, 0.20, 0.26)
	var stripe = Color(1.0, 0.75, 0.0, 0.55)
	draw_rect(rect, base)
	# Żółto-czarne paski bezpieczeństwa na krawędziach
	var sw = 6.0
	var i = 0
	while rect.position.x + i * sw < rect.end.x:
		if int(i) % 2 == 0:
			var x0 = rect.position.x + i * sw
			var x1 = minf(x0 + sw, rect.end.x)
			draw_rect(Rect2(x0, rect.position.y, x1 - x0, 3), stripe)
		i += 1
	# Siatka (nity)
	for nx in range(int(rect.size.x / 16)):
		var rx = rect.position.x + nx * 16 + 8
		draw_circle(Vector2(rx, rect.position.y + 7), 1.5, dark)
	# Krawędzie
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), light, 1.0)
	draw_line(Vector2(rect.position.x, rect.end.y), rect.end, dark, 1.5)
