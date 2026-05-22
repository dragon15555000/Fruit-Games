extends "res://scripts/map/map_base.gd"
## Mapa 5: Watermelon Caves — wnętrze gigantycznego arbuza, jaskinia z miąższem.

func _get_sky_top() -> Color:    return Color(0.65, 0.08, 0.12)  # głęboki czerwony miąższ
func _get_sky_bottom() -> Color: return Color(0.82, 0.15, 0.20)  # jaśniejszy miąższ

func _draw_decorations() -> void:
	# ── Żyłki arbuza — biała siatka w tle ───────────────────────────────────
	_draw_watermelon_veins()

	# ── Sufit jaskini (stalaktyty z miąższu) ────────────────────────────────
	_draw_ceiling()

	# ── Pestki arbuza — bioluminescencyjne ───────────────────────────────────
	var seed_positions = [
		Vector2(-185, -85), Vector2(-155, -40), Vector2(-130, -95), Vector2(-100, -20),
		Vector2( -75, -70), Vector2( -50,-100), Vector2( -25, -55), Vector2(   5, -80),
		Vector2(  30, -30), Vector2(  55, -90), Vector2(  80, -15), Vector2( 105, -75),
		Vector2( 130, -50), Vector2( 158, -88), Vector2( 182, -35), Vector2(-170, 30),
		Vector2(-110,  55), Vector2( -65,  45), Vector2(  20,  60), Vector2(  90,  40),
		Vector2( 150,  55), Vector2( -40, -10), Vector2( 185, 70),
	]
	for sp in seed_positions:
		_draw_glowing_seed(sp)

	# ── Miąższ — tekstura (pasy) ─────────────────────────────────────────────
	_draw_flesh_texture()

	# ── Podłoga — skórka arbuza ──────────────────────────────────────────────
	draw_rect(Rect2(-210, 84, 420, 10), Color(0.18, 0.52, 0.12))  # zielona skórka
	draw_rect(Rect2(-210, 82, 420,  4), Color(0.72, 0.85, 0.62))  # biała warstwa pod skórką
	draw_rect(Rect2(-210, 80, 420,  3), Color(0.60, 0.78, 0.50))  # środkowa warstwa

	# ── Stalaktyty przy ziemi (nacieki) ─────────────────────────────────────
	for i in range(18):
		var sx = -185.0 + i * 22.0
		var sh = 6.0 + fmod(float(i) * 7.3, 10.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(sx - 4, 80), Vector2(sx + 4, 80), Vector2(sx, 80 - sh)
		]), Color(0.18, 0.52, 0.12, 0.70))

	# ── Duże jaskiniowe platformy (miąższ) ───────────────────────────────────
	_draw_flesh_platform(Rect2(-250, 100, 150, 20))
	_draw_flesh_platform(Rect2( 100, 100, 150, 20))
	_draw_flesh_platform(Rect2(-100,   0, 200, 20))
	_draw_flesh_platform(Rect2(-350,-100, 120, 20))
	_draw_flesh_platform(Rect2( 230,-100, 120, 20))
	_draw_flesh_platform(Rect2(-150,-200, 300, 20))

	# ── Sokowe jeziorka na podłodze ──────────────────────────────────────────
	_draw_juice_pool(Vector2(-110, 82), 35)
	_draw_juice_pool(Vector2(  70, 82), 28)
	_draw_juice_pool(Vector2( 170, 82), 22)

	# ── Ściany boczne (skórka) ───────────────────────────────────────────────
	draw_rect(Rect2(-210,-120, 18, 210), Color(0.16, 0.48, 0.10, 0.80))
	draw_rect(Rect2( 392,-120, 18, 210), Color(0.16, 0.48, 0.10, 0.80))
	draw_rect(Rect2(-192,-120, 10, 210), Color(0.60, 0.82, 0.50, 0.35))
	draw_rect(Rect2( 382,-120, 10, 210), Color(0.60, 0.82, 0.50, 0.35))


func _draw_watermelon_veins() -> void:
	var vein = Color(0.90, 0.35, 0.38, 0.12)
	# Główne żyłki promieniście
	for i in range(12):
		var a = i * TAU / 12.0
		var cx = 100.0  # środek trochę przesunięty
		var cy = -150.0
		draw_line(
			Vector2(cx, cy),
			Vector2(cx + cos(a) * 320, cy + sin(a) * 320),
			vein, 1.5)
	# Dodatkowe żyłki poziome
	for y in range(-100, 90, 25):
		draw_line(Vector2(-210, float(y)), Vector2(410, float(y)), Color(0.88, 0.30, 0.35, 0.06), 1.0)


func _draw_ceiling() -> void:
	# Sufit jaskini — ciemna warstwa na górze
	draw_rect(Rect2(-210, -120, 420, 18), Color(0.12, 0.04, 0.05))
	# Stalaktyty (trójkąty)
	for i in range(24):
		var sx = -200.0 + i * 17.5
		var sh = 12.0 + fmod(float(i) * 11.3, 18.0)
		var stalactite = PackedVector2Array([
			Vector2(sx - 5, -102),
			Vector2(sx + 5, -102),
			Vector2(sx,     -102 + sh)
		])
		draw_colored_polygon(stalactite, Color(0.55, 0.08, 0.10))
		# Kapla soku na końcu
		draw_circle(Vector2(sx, -102 + sh), 2.0, Color(0.90, 0.18, 0.22, 0.70))


func _draw_glowing_seed(pos: Vector2) -> void:
	# Poświata bioluminescencyjna
	draw_circle(pos, 7.0, Color(0.05, 0.05, 0.08, 0.25))
	draw_circle(pos, 4.5, Color(0.10, 0.10, 0.15, 0.40))
	# Pestka — czarna owalny kształt
	var seed = PackedVector2Array([
		Vector2(pos.x, pos.y - 4.0),
		Vector2(pos.x + 2.2, pos.y - 2.0),
		Vector2(pos.x + 2.5, pos.y),
		Vector2(pos.x + 2.2, pos.y + 2.0),
		Vector2(pos.x, pos.y + 4.0),
		Vector2(pos.x - 2.2, pos.y + 2.0),
		Vector2(pos.x - 2.5, pos.y),
		Vector2(pos.x - 2.2, pos.y - 2.0),
	])
	draw_colored_polygon(seed, Color(0.08, 0.06, 0.07))
	# Błękitny połysk — bioluminescencja
	draw_circle(pos + Vector2(-0.8, -1.2), 1.0, Color(0.40, 0.65, 1.00, 0.55))


func _draw_flesh_texture() -> void:
	# Subtelne pasy miąższu arbuza
	for y in range(-100, 80, 8):
		var alpha = 0.04 + 0.02 * sin(float(y) * 0.3)
		draw_line(Vector2(-210, float(y)), Vector2(410, float(y)), Color(1.0, 0.50, 0.52, alpha), 3.0)


func _draw_flesh_platform(rect: Rect2) -> void:
	var flesh  = Color(0.82, 0.20, 0.28)
	var light  = Color(0.92, 0.35, 0.40)
	var dark   = Color(0.55, 0.10, 0.15)
	var rind   = Color(0.25, 0.62, 0.18)
	draw_rect(rect, flesh)
	# Żyłki na miąższu
	for i in range(int(rect.size.x / 20)):
		var lx = rect.position.x + i * 20 + 10
		draw_line(Vector2(lx, rect.position.y + 2), Vector2(lx + 5, rect.end.y - 2), Color(1, 0.55, 0.58, 0.20), 1.0)
	# Zielona górna krawędź (skórka od wewnątrz)
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 3), rind)
	draw_rect(Rect2(rect.position.x, rect.position.y + 3, rect.size.x, 2), Color(0.70, 0.88, 0.60))
	# Dolny cień
	draw_rect(Rect2(rect.position.x, rect.end.y - 3, rect.size.x, 3), dark)
	# Boczne cienie
	draw_line(rect.position + Vector2(0, 4), Vector2(rect.position.x, rect.end.y), dark, 1.5)
	draw_line(Vector2(rect.end.x, rect.position.y + 4), rect.end, dark, 1.5)
	# Pestki na platformie
	for i in range(int(rect.size.x / 30)):
		var sx = rect.position.x + i * 30 + 15
		var sy = rect.position.y + rect.size.y * 0.5
		draw_circle(Vector2(sx, sy), 2.5, Color(0.08, 0.06, 0.07, 0.60))


func _draw_juice_pool(center: Vector2, radius: float) -> void:
	# Czerwone jeziorko soku
	var steps = 20
	for i in range(steps):
		var a0 = i * TAU / steps
		var a1 = (i + 1) * TAU / steps
		var r_a = radius * (0.85 + 0.15 * sin(float(i) * 2.1))
		var r_b = radius * (0.85 + 0.15 * sin(float(i + 1) * 2.1))
		draw_line(
			center + Vector2(cos(a0) * r_a, sin(a0) * r_a * 0.28),
			center + Vector2(cos(a1) * r_b, sin(a1) * r_b * 0.28),
			Color(0.75, 0.10, 0.15, 0.50), 2.0)
	draw_circle(center, radius * 0.5, Color(0.82, 0.14, 0.20, 0.18))
	# Odbicie
	draw_circle(center + Vector2(-radius * 0.25, 0), radius * 0.18, Color(1.0, 0.60, 0.65, 0.22))
