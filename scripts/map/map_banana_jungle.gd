extends "res://scripts/map/map_base.gd"
## Mapa 7: Banana Jungle — tropikalna dżungla bananowa.

func _get_sky_top() -> Color:    return Color(0.18, 0.42, 0.12)
func _get_sky_bottom() -> Color: return Color(0.32, 0.60, 0.18)

func _draw_decorations() -> void:
	# ── Liście palmowe w tle ─────────────────────────────────────────────────
	_draw_palm(Vector2(-175, 84))
	_draw_palm(Vector2(175, 84))
	_draw_palm(Vector2(-40, 84))
	_draw_palm(Vector2(80, 84))

	# ── Pęczki bananów wiszące ───────────────────────────────────────────────
	_draw_banana_bunch(Vector2(-130, -20))
	_draw_banana_bunch(Vector2(120, -35))
	_draw_banana_bunch(Vector2(10, -70))

	# ── Winoroślowe liny (dekoracja) ─────────────────────────────────────────
	for i in [-150, -80, 60, 140]:
		draw_line(Vector2(i, -120), Vector2(i + 10, 85), Color(0.25, 0.55, 0.12, 0.45), 1.5)
		for j in range(5):
			var y = -100 + j * 40
			draw_circle(Vector2(i + j * 2, y), 2.5, Color(0.20, 0.50, 0.10, 0.5))

	# ── Grunt — mokra ziemia ─────────────────────────────────────────────────
	draw_rect(Rect2(-192, 84, 384, 8), Color(0.32, 0.22, 0.08))
	for i in range(50):
		var bx = -190.0 + i * 7.8
		var h = 3.0 + fmod(float(i) * 2.3, 4.0)
		draw_line(Vector2(bx, 84), Vector2(bx, 84 - h), Color(0.22, 0.48, 0.10, 0.9), 1.2)

	# ── Platformy — grube bambusowe belki ───────────────────────────────────
	_draw_bamboo_platform(Rect2(-155, 30, 85, 14))
	_draw_bamboo_platform(Rect2(48, 46, 85, 14))
	_draw_bamboo_platform(Rect2(-25, 10, 70, 14))
	_draw_bamboo_platform(Rect2(-110, -28, 65, 14))
	_draw_bamboo_platform(Rect2(25, -55, 65, 14))


func _draw_palm(base: Vector2) -> void:
	var trunk = Color(0.45, 0.32, 0.15)
	# Pień lekko krzywy
	draw_line(base, base + Vector2(5, -50), trunk, 4.0)
	draw_line(base + Vector2(5, -50), base + Vector2(8, -80), trunk, 3.5)

	var top = base + Vector2(8, -80)
	var leaf_color = Color(0.22, 0.65, 0.15, 0.85)
	var dirs = [
		Vector2(-30, -15), Vector2(-20, -25), Vector2(0, -28),
		Vector2(20, -22), Vector2(30, -10), Vector2(25, 5), Vector2(-25, 5)
	]
	for d in dirs:
		draw_line(top, top + d, leaf_color, 3.0)
		draw_line(top + d * 0.5, top + d + Vector2(d.y * 0.2, -d.x * 0.2), leaf_color, 1.5)


func _draw_banana_bunch(pos: Vector2) -> void:
	draw_line(pos, pos + Vector2(0, -15), Color(0.38, 0.28, 0.12), 2.0)
	var offsets = [
		Vector2(-8, 0), Vector2(-4, -5), Vector2(0, -8),
		Vector2(4, -5), Vector2(8, 0)
	]
	for off in offsets:
		var bp = pos + off
		draw_colored_polygon(PackedVector2Array([
			bp + Vector2(-4, -2), bp + Vector2(4, -2),
			bp + Vector2(5, 3), bp + Vector2(-5, 3)
		]), Color(0.98, 0.92, 0.15))
		draw_line(bp + Vector2(-4, -2), bp + Vector2(-5, -4), Color(0.55, 0.40, 0.10), 1.0)


func _draw_bamboo_platform(rect: Rect2) -> void:
	var bamboo  = Color(0.60, 0.72, 0.22)
	var dark    = Color(0.40, 0.52, 0.14)
	var joint   = Color(0.38, 0.50, 0.12)
	draw_rect(rect, bamboo)
	# Poziome segmenty bambusu
	var seg = 18
	for i in range(int(rect.size.x / seg)):
		var x = rect.position.x + i * seg
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), joint, 2.0)
		draw_rect(Rect2(x - 1, rect.position.y, 2, rect.size.y), joint)
	draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.end.x, rect.position.y), dark, 1.5)
	draw_line(Vector2(rect.position.x, rect.end.y), rect.end, dark.darkened(0.2), 1.5)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 2), Color(0.70, 0.85, 0.28))
