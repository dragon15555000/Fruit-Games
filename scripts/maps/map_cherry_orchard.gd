extends "res://scripts/maps/map_base.gd"
## Mapa 6: Cherry Orchard — wiosenny sad z kwitnącymi wiśniami.

func _get_sky_top() -> Color:    return Color(0.95, 0.72, 0.82)
func _get_sky_bottom() -> Color: return Color(1.00, 0.88, 0.93)

func _draw_decorations() -> void:
	# ── Wiosenny księżyc / słońce ────────────────────────────────────────────
	var sun = Vector2(-150, -90)
	draw_circle(sun, 18, Color(1.0, 0.85, 0.90, 0.4))
	draw_circle(sun, 12, Color(1.0, 0.90, 0.92, 0.7))
	draw_circle(sun, 8,  Color(1.0, 0.96, 0.98, 1.0))

	# ── Płatki sakury lecące w powietrzu ────────────────────────────────────
	var petal_positions = [
		Vector2(-160, -60), Vector2(-90, -80), Vector2(-20, -50),
		Vector2(50, -70), Vector2(120, -40), Vector2(170, -85),
		Vector2(80, -20), Vector2(-50, -30), Vector2(140, -100),
	]
	for p in petal_positions:
		_draw_petal(p)

	# ── Drzewa wiśniowe ──────────────────────────────────────────────────────
	_draw_cherry_tree(Vector2(-165, 84))
	_draw_cherry_tree(Vector2(165, 84))
	_draw_cherry_tree(Vector2(0, 84))

	# ── Trawa z kwiatkami ───────────────────────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 8), Color(0.55, 0.80, 0.35))
	for i in range(40):
		var bx = -188.0 + i * 9.8
		draw_line(Vector2(bx, 84), Vector2(bx - 1, 84 - 4), Color(0.42, 0.70, 0.25, 0.9), 1.0)

	# ── Platformy gałęziowe ──────────────────────────────────────────────────
	_draw_branch_platform(Rect2(-160, 26, 80, 12))
	_draw_branch_platform(Rect2(55, 42, 80, 12))
	_draw_branch_platform(Rect2(-30, 8, 70, 12))
	_draw_branch_platform(Rect2(-120, -30, 65, 12))
	_draw_branch_platform(Rect2(20, -58, 65, 12))


func _draw_petal(pos: Vector2) -> void:
	var col = Color(1.0, 0.75, 0.82, 0.75)
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -3), pos + Vector2(2, 0),
		pos + Vector2(0, 3), pos + Vector2(-2, 0)
	]), col)


func _draw_cherry_tree(base: Vector2) -> void:
	var trunk = Color(0.38, 0.22, 0.10)
	draw_rect(Rect2(base.x - 3, base.y - 44, 6, 44), trunk)
	draw_line(Vector2(base.x, base.y - 30), Vector2(base.x - 15, base.y - 48), trunk, 2.0)
	draw_line(Vector2(base.x, base.y - 28), Vector2(base.x + 13, base.y - 44), trunk, 2.0)

	# Korona — różowe kwiaty
	var layers = [
		[Vector2(0, -54), 20, Color(0.98, 0.72, 0.80, 0.65)],
		[Vector2(-10, -62), 15, Color(0.98, 0.65, 0.75, 0.75)],
		[Vector2(11, -60), 16, Color(0.98, 0.65, 0.75, 0.75)],
		[Vector2(0, -68), 13, Color(1.00, 0.78, 0.85, 0.80)],
		[Vector2(-5, -70), 10, Color(1.00, 0.82, 0.88, 0.70)],
	]
	for l in layers:
		draw_circle(base + l[0], l[1], l[2])

	# Wiśnie wiszące
	for off in [Vector2(-8, -52), Vector2(7, -55), Vector2(-2, -64), Vector2(10, -48)]:
		draw_circle(base + off, 3.5, Color(0.82, 0.06, 0.12, 0.9))
		draw_circle(base + off + Vector2(-1, -1), 1.2, Color(1.0, 0.45, 0.50, 0.6))


func _draw_branch_platform(rect: Rect2) -> void:
	var bark   = Color(0.40, 0.25, 0.12)
	var light  = Color(0.55, 0.38, 0.20)
	draw_rect(rect, bark)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2), Color(0.48, 0.68, 0.22))
	var step = 8
	for i in range(int(rect.size.x / step)):
		var x = rect.position.x + i * step + step * 0.5
		draw_line(Vector2(x, rect.position.y + 1), Vector2(x, rect.end.y - 1), Color(0.30, 0.18, 0.06, 0.25), 0.7)
	draw_line(rect.position, Vector2(rect.position.x, rect.end.y), bark.darkened(0.3), 1.2)
	draw_line(Vector2(rect.end.x, rect.position.y), rect.end, bark.darkened(0.3), 1.2)
	draw_line(Vector2(rect.position.x, rect.position.y + 2), Vector2(rect.end.x, rect.position.y + 2), light, 0.8)
