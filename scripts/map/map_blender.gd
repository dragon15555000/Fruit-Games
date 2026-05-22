extends "res://scripts/map/map_base.gd"
## Mapa 4: Blender — wirująca arena wewnątrz gigantycznego blendera.

func _get_sky_top() -> Color:    return Color(0.78, 0.82, 0.92)
func _get_sky_bottom() -> Color: return Color(0.60, 0.65, 0.75)

func _draw_decorations() -> void:
	# ── Zewnętrzny blender — plastikowa obudowa ──────────────────────────────
	draw_rect(Rect2(-200, -120, 400, 220), Color(0.85, 0.88, 0.94, 0.08))

	# ── Szklana czara blendera (boki) ─────────────────────────────────────────
	_draw_glass_wall(-192, -120, 210)
	_draw_glass_wall( 184, -120, 210)

	# ── Sok/mus wewnątrz (gradient warstwy) ──────────────────────────────────
	_draw_juice_layers()

	# ── Kawałki owoców pływające w środku ────────────────────────────────────
	_draw_fruit_chunk(Vector2(-120, -30), Color(0.90, 0.15, 0.20), 8.0)  # truskawka
	_draw_fruit_chunk(Vector2(  80, -55), Color(0.55, 0.12, 0.65), 6.0)  # winogrono
	_draw_fruit_chunk(Vector2(-50,  15), Color(1.00, 0.60, 0.10), 9.0)  # pomarańcza
	_draw_fruit_chunk(Vector2( 130,  10), Color(0.85, 0.70, 0.15), 7.0)  # ananas
	_draw_fruit_chunk(Vector2( -20, -80), Color(0.90, 0.15, 0.20), 5.0)
	_draw_fruit_chunk(Vector2( 160, -60), Color(0.30, 0.75, 0.20), 6.5)  # arbuz
	_draw_fruit_chunk(Vector2( -90,  50), Color(1.00, 0.60, 0.10), 7.5)
	_draw_fruit_chunk(Vector2(  40, -100), Color(0.95, 0.90, 0.15), 5.5) # cytryna
	_draw_fruit_chunk(Vector2(-160,  60), Color(0.55, 0.12, 0.65), 5.0)
	_draw_fruit_chunk(Vector2( 100,  65), Color(0.90, 0.15, 0.20), 6.0)

	# ── Bąbelki powietrza ─────────────────────────────────────────────────────
	var bubble_data = [
		[Vector2(-140,-90), 3.5], [Vector2(-100,-50), 2.5], [Vector2(-70,-70), 4.0],
		[Vector2( -30,-95), 2.0], [Vector2(  20,-45), 5.0], [Vector2(  60,-80), 3.0],
		[Vector2( 100,-95), 2.5], [Vector2( 140,-60), 4.0], [Vector2( 170,-85), 2.0],
		[Vector2(-160, 40), 3.5], [Vector2(-80,  55), 2.8], [Vector2( 50,  45), 3.2],
		[Vector2( 150, 55), 4.0], [Vector2(  10, 70), 2.5], [Vector2(-115,-15), 3.0],
	]
	for bd in bubble_data:
		var pos = bd[0] as Vector2
		var r   = bd[1] as float
		draw_circle(pos, r, Color(1, 1, 1, 0.08))
		draw_arc(pos, r, 0, TAU, 16, Color(1, 1, 1, 0.25), 0.8)
		draw_circle(pos + Vector2(-r * 0.3, -r * 0.3), r * 0.35, Color(1, 1, 1, 0.35))

	# ── Ostrza blendera — dekoracyjne ────────────────────────────────────────
	_draw_blades(Vector2(0, 37))

	# ── Podłoga — metalowa podstawa blendera ─────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 10), Color(0.30, 0.32, 0.38))
	draw_rect(Rect2(-192, 84, 384,  3), Color(0.50, 0.52, 0.58))
	for i in range(10):
		var bx = -192 + i * 38 + 19
		draw_circle(Vector2(bx, 87), 2, Color(0.22, 0.22, 0.28))

	# ── Platformy — metalowe tace ────────────────────────────────────────────
	_draw_blade_platform(Rect2(-50,  30, 100, 14))
	_draw_wall_platform(Rect2(-188,  10,  40, 10))
	_draw_wall_platform(Rect2( 148,  10,  40, 10))
	_draw_wall_platform(Rect2(-188, -40,  40, 10))
	_draw_wall_platform(Rect2( 148, -40,  40, 10))

	# ── Odbicia na szkle ─────────────────────────────────────────────────────
	for i in range(6):
		var ry = -100 + i * 30
		draw_line(Vector2(-190, ry), Vector2(-185, ry + 15), Color(1, 1, 1, 0.06), 2.0)
		draw_line(Vector2( 190, ry), Vector2( 185, ry + 15), Color(1, 1, 1, 0.06), 2.0)


func _draw_glass_wall(x: float, y_top: float, h: float) -> void:
	# Gruba szklana ściana
	draw_rect(Rect2(x, y_top, 8, h), Color(0.75, 0.82, 0.92, 0.22))
	# Połysk
	draw_line(Vector2(x + 2, y_top), Vector2(x + 2, y_top + h), Color(1, 1, 1, 0.18), 1.5)
	# Krawędź zewnętrzna
	draw_line(Vector2(x, y_top), Vector2(x, y_top + h), Color(0.5, 0.55, 0.65, 0.45), 1.0)
	if x < 0:
		draw_line(Vector2(x + 8, y_top), Vector2(x + 8, y_top + h), Color(0.5, 0.55, 0.65, 0.30), 1.0)
	else:
		draw_line(Vector2(x,     y_top), Vector2(x,     y_top + h), Color(0.5, 0.55, 0.65, 0.30), 1.0)


func _draw_juice_layers() -> void:
	# Warstwy soku w blenderze — gradient kolorów
	var layers = [
		[78, 84, Color(1.00, 0.45, 0.15, 0.22)],  # pomarańczowy na dnie
		[60, 78, Color(0.85, 0.20, 0.25, 0.12)],  # różowy w środku
		[40, 60, Color(1.00, 0.50, 0.15, 0.08)],  # jasnopomarańczowy
	]
	for layer in layers:
		for y in range(layer[0], layer[1], 2):
			draw_line(Vector2(-184, float(y)), Vector2(184, float(y)), layer[2] as Color, 2.5)


func _draw_fruit_chunk(pos: Vector2, col: Color, size: float) -> void:
	# Nieregularny kawałek owocu
	var pts = PackedVector2Array()
	var sides = 5 + int(fmod(abs(pos.x + pos.y), 3))
	for i in range(sides):
		var a = i * TAU / sides + fmod(abs(pos.x), 0.5)
		var r = size * (0.7 + fmod(abs(pos.x * float(i)) * 0.1, 0.35))
		pts.append(pos + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, Color(col.r, col.g, col.b, 0.55))
	# Krawędź
	for i in range(pts.size()):
		draw_line(pts[i], pts[(i + 1) % pts.size()], Color(col.r, col.g, col.b, 0.75), 0.8)
	# Połysk
	draw_circle(pos + Vector2(-size * 0.25, -size * 0.25), size * 0.2, Color(1, 1, 1, 0.30))


func _draw_blades(center: Vector2) -> void:
	var blade_col = Color(0.55, 0.58, 0.65, 0.40)
	var shine_col = Color(0.80, 0.85, 0.92, 0.25)
	# 4 ostrza pod kątem
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		var d0 = Vector2(cos(angle), sin(angle))
		var d1 = Vector2(cos(angle + 0.3), sin(angle + 0.3))
		var pts = PackedVector2Array([
			center,
			center + d0 * 55,
			center + (d0 + d1).normalized() * 58,
			center + d1 * 50,
		])
		draw_colored_polygon(pts, blade_col)
		draw_line(center + d0 * 10, center + d0 * 52, shine_col, 1.5)
	# Środkowe piasto
	draw_circle(center, 8, Color(0.40, 0.42, 0.48, 0.80))
	draw_circle(center, 5, Color(0.60, 0.62, 0.68, 0.90))
	draw_circle(center, 3, Color(0.80, 0.82, 0.88, 0.80))


func _draw_blade_platform(rect: Rect2) -> void:
	# Centralna platforma — błyszczący metal
	var base  = Color(0.52, 0.55, 0.62)
	var light = Color(0.78, 0.82, 0.90)
	var dark  = Color(0.35, 0.37, 0.43)
	draw_rect(rect, base)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 3), light)
	draw_rect(Rect2(rect.position.x, rect.end.y - 3, rect.size.x, 3), dark)
	# Śruby na końcach
	for nx in [rect.position.x + 5, rect.end.x - 5]:
		draw_circle(Vector2(nx, rect.position.y + rect.size.y * 0.5), 2, dark)
		draw_circle(Vector2(nx, rect.position.y + rect.size.y * 0.5), 1, light)


func _draw_wall_platform(rect: Rect2) -> void:
	var base = Color(0.38, 0.40, 0.46)
	var top  = Color(0.55, 0.58, 0.65)
	draw_rect(rect, base)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2), top)
	draw_line(Vector2(rect.position.x, rect.end.y), rect.end, Color(0.25, 0.26, 0.32), 1.5)
