extends Area2D
## bullet.gd — uniwersalny skrypt pocisku
## shooter_name ustawiany przez setup() z main_game.gd.

var velocity:     Vector2 = Vector2.ZERO
var shooter_name: String  = ""

const GRAVITY: float = 75.0

# ── Smuga ─────────────────────────────────────────────────────────────────────
const TRAIL_LEN: int = 16
var _trail: Array[Vector2] = []

# ── Spinning ──────────────────────────────────────────────────────────────────
var spin_timer:     float = 0.0
var spin_direction: float = 1.0

# ── Bouncing ──────────────────────────────────────────────────────────────────
var bounces_left: int  = 1
var has_bounced:  bool = false

# ── Damage modifiers (zmieniane przez on_bounce) ──────────────────────────────
var bonus_dmg:       float = 0.0   # destroying_bounce: +5 DMG co odbicie
var bounce_dmg_mult: float = 1.0   # rage_bounce: x1.3 DMG

# ── Magnetyczny ───────────────────────────────────────────────────────────────
var is_magnetic:           bool  = false
var magnetic_after_bounce: bool  = false
var magnetic_timer:        float = 0.0
const MAGNETIC_RANGE:      float = 200.0
var bullet_speed:          float = 180.0
var _magnetic_target:      Node2D = null

# ── Dojrzały strzał — TYLKO jeśli gracz wybrał mod "ripe_shot" ───────────────
var ripe_shot_bonus: bool = false

# ── Owocowa passa ─────────────────────────────────────────────────────────────
var streak_bonus: bool = false


# ─────────────────────────────────────────────
# SETUP — wywoływane z main_game.gd po instantiate()
# ─────────────────────────────────────────────
func setup(pos: Vector2, dir: Vector2, p_shooter_name: String) -> void:
	shooter_name   = p_shooter_name
	spin_direction = 1.0 if randf() > 0.5 else -1.0

	var mods = Global.modifiers.get(shooter_name, [])

	# Prędkość — sniper_seed zwiększa o 25%. Dodajemy +/- 5% losowości dla naturalności.
	bullet_speed = 130.0 * (1.0 + randf_range(-0.05, 0.05))
	if mods.has("sniper_seed"):
		bullet_speed *= 1.25

	velocity = dir * bullet_speed
	position = pos + dir * 20.0

	# Liczba odbić bazowa + mody
	bounces_left = 1
	if mods.has("extra_bounce"): bounces_left += 1
	if mods.has("bouncy"):       bounces_left  = 4   # stary mod

	# Magnetyczna pestka — pocisk sam skręca w stronę wroga
	is_magnetic = mods.has("magnetic_seed")

	# Dojrzały strzał — licznik rośnie TYLKO jeśli gracz wybrał ten mod.
	# BEZ tego warunku licznik chodził dla wszystkich graczy zawsze —
	# każdy co 3. pocisk zadawał bonus niezależnie od wyboru modu.
	if mods.has("ripe_shot"):
		Global.shot_counter[shooter_name] = Global.shot_counter.get(shooter_name, 0) + 1
		if Global.shot_counter[shooter_name] >= 3:
			Global.shot_counter[shooter_name] = 0
			ripe_shot_bonus = true

	# Owocowa passa — flaga ustawiona przez ModifierSystem po 3 trafieniach z rzędu
	var char_node = _find_shooter()
	if char_node and char_node.streak_bonus_ready:
		streak_bonus                 = true
		char_node.streak_bonus_ready = false
		char_node.streak_count       = 0


# ─────────────────────────────────────────────
# PHYSICS
# ─────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	var mods = Global.modifiers.get(shooter_name, [])

	# Wirujący pocisk — sinusoidalny ruch boczny
	if mods.has("spinning"):
		spin_timer += delta
		var perp     = Vector2(-velocity.normalized().y, velocity.normalized().x)
		var spin_off = sin(spin_timer * 8.0) * 60.0 * spin_direction
		position    += perp * spin_off * delta

	# Magnetyczna pestka — ciągłe skręcanie w stronę najbliższego wroga
	if is_magnetic:
		# Optymalizacja: szukaj celu tylko raz na 5 klatek
		if Engine.get_physics_frames() % 5 == 0:
			_apply_homing(delta)
		else:
			_apply_homing_continuous(delta)

	# Magnetyczne odbicie — homing aktywny przez 2 sekundy po odbiciu
	if magnetic_after_bounce and has_bounced:
		magnetic_timer += delta
		if magnetic_timer < 2.0:
			if Engine.get_physics_frames() % 5 == 0:
				_apply_homing(delta)
			else:
				_apply_homing_continuous(delta)

	velocity.y += GRAVITY * delta
	position   += velocity * delta

	# ── Smuga — historia pozycji ──────────────────────────────────────────
	_trail.push_back(global_position)
	if _trail.size() > TRAIL_LEN:
		_trail.pop_front()
	queue_redraw()

	# ── Kolizja pocisk–pocisk ─────────────────────────────────────────────
	for other in get_tree().get_nodes_in_group("Bullet"):
		if other == self or not is_instance_valid(other): continue
		if other.get("shooter_name") == shooter_name:    continue
		var hit_radius = 7.0 + velocity.length() * delta * 0.35
		if global_position.distance_to(other.global_position) < hit_radius:
			_spawn_shatter(global_position, Color(1.0, 0.85, 0.1), 14)
			_spawn_shatter(other.global_position, Color(1.0, 0.7, 0.1), 10)
			if Global.main_game:
				Global.main_game.add_shake(4.0)
			other.call_deferred("queue_free")
			call_deferred("queue_free")
			return


# ─────────────────────────────────────────────
# SMUGA
# ─────────────────────────────────────────────
func _draw() -> void:
	var n = _trail.size()
	if n < 2:
		return
	for i in range(n):
		var t     = float(i) / float(TRAIL_LEN)
		var alpha = t * t * 0.7          # kwadratowy zanik — ogon znika szybciej
		var r     = lerp(0.4, 2.2, t)    # rozmiar rośnie ku przodowi
		draw_circle(to_local(_trail[i]), r, Color(1.0, 0.9, 0.4, alpha))


# ─────────────────────────────────────────────
# KOLIZJE
# ─────────────────────────────────────────────
func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(self): return

	# ── Teren ──────────────────────────────────────────────────────────────

	if body.is_in_group("Terrain"):

		bounces_left -= 1

		if bounces_left >= 0:

			velocity.y  = -velocity.y * 0.8

			has_bounced = true

			ModifierSystem.apply_on_bounce(shooter_name, self)

			return

		call_deferred("queue_free")

		return

	if body.is_in_group("Bullet"):
		if body == self or not is_instance_valid(body):
			return
		if body.get("shooter_name") == shooter_name:
			return
		_spawn_shatter(global_position, Color(1.0, 0.85, 0.1), 14)
		if Global.main_game:
			Global.main_game.add_shake(3.0)
		body.call_deferred("queue_free")
		call_deferred("queue_free")
		return

	if not is_instance_valid(body): return
	if not body.has_method("receive_damage"): return

	var target_name: String = body.get("character_name")
	if target_name == null or target_name == shooter_name: return
	if not Global.characters.has(target_name): return
	if not Global.alive.get(target_name, false): return
	if not Global.characters.has(shooter_name): return
	if not Global.alive.get(shooter_name, false): return

	# W trybie sieciowym obrażenia zadaje tylko serwer (uniknięcie duplikatów)
	if Global.is_network_game and not multiplayer.is_server():
		call_deferred("queue_free")
		return



	# ── Oblicz DMG ─────────────────────────────────────────────────────────
	var base_dmg: float = float(Global.characters[shooter_name]["dmg"])
	var dmg:      float = (base_dmg + bonus_dmg) * bounce_dmg_mult

	if ripe_shot_bonus: dmg *= 1.3   # co 3. strzał (mod: ripe_shot)
	if streak_bonus:    dmg *= 1.3   # po 3 trafieniach z rzędu (mod: fruit_streak)

	# Przekaż przez receive_damage() postaci.
	# receive_damage() zwraca faktyczne obrażenia po modyfikacjach (0 = zablokowane).
	var actual: float = body.receive_damage(dmg, shooter_name)

	if actual > 0.0:
		Global.take_damage(target_name, actual, "pocisk od " + shooter_name)
		# Sprawdź jeszcze raz po zadaniu obrażeń — body mogło właśnie umrzeć
		if is_instance_valid(body) and Global.alive.get(target_name, false):
			ModifierSystem.apply_on_hit(shooter_name, body, global_position, actual)

	call_deferred("queue_free")


# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────

func _apply_homing(delta: float) -> void:
	var nearest:      Node2D = null
	var nearest_dist: float  = MAGNETIC_RANGE

	for node in get_tree().get_nodes_in_group("Players"):
		if not is_instance_valid(node): continue
		if node.get("character_name") == shooter_name: continue
		if not Global.alive.get(node.get("character_name"), false): continue
		
		var d = global_position.distance_to(node.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest      = node

	_magnetic_target = nearest
	_apply_homing_continuous(delta)

func _apply_homing_continuous(delta: float) -> void:
	if is_instance_valid(_magnetic_target) and Global.alive.get(_magnetic_target.get("character_name"), false):
		var d = global_position.distance_to(_magnetic_target.global_position)
		if d <= MAGNETIC_RANGE * 1.5: # Zwiększony zasięg śledzenia gdy już złapie cel
			var desired = (_magnetic_target.global_position - global_position).normalized() * bullet_speed
			velocity    = velocity.lerp(desired, delta * 4.0)
		else:
			_magnetic_target = null
	else:
		_magnetic_target = null

func _find_shooter() -> Node:
	for node in get_tree().get_nodes_in_group("Players"):
		if not is_instance_valid(node): continue
		if node.get("character_name") == shooter_name:
			return node
	return null


func _spawn_shatter(pos: Vector2, color: Color, amount: int) -> void:
	Global.spawn_particles(pos, color, amount)
	if not Global.main_game:
		return
	var burst = CPUParticles2D.new()
	burst.position = pos
	burst.one_shot = true
	burst.emitting = true
	burst.amount = 8
	burst.lifetime = 0.22
	burst.spread = 180.0
	burst.gravity = Vector2.ZERO
	burst.initial_velocity_min = 60
	burst.initial_velocity_max = 120
	burst.scale_amount_min = 0.8
	burst.scale_amount_max = 1.8
	burst.color = color.lightened(0.15)
	Global.main_game.add_child(burst)
