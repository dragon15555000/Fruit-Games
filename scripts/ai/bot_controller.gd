extends Node
## Bot AI — kontroluje CharacterBody2D zamiast inputu gracza.
## Dodawany jako child postaci przez main_game.gd.

var character: CharacterBody2D
var char_name: String = ""

# Cel i zachowanie
var target: CharacterBody2D = null
var retarget_timer: float = 0.0
var shoot_timer: float = 0.0
var jump_timer: float = 0.0
var direction: float = 0.0  # -1, 0, 1
var stuck_timer: float = 0.0
var last_x: float = 0.0

# ── Nowe mechaniki decyzyjne ───────────────────────────────────────────────
var hazard_cooldown: float = 0.0     # co ile sprawdzamy zagrożenia (0.2s)
var decision_lock: float = 0.0      # blokada zmiany kierunku po uniku (0.3s)
const EVASION_DIST: float = 120.0
const EDGE_LOOK_AHEAD: float = 25.0


func setup(p_character: CharacterBody2D, p_char_name: String) -> void:
	character = p_character
	char_name = p_char_name
	# Losowy offset na timery — żeby boty nie strzelały synchronicznie
	shoot_timer = randf() * 0.5
	jump_timer  = randf() * 1.0
	last_x = character.global_position.x


func _physics_process(delta: float) -> void:
	if not is_instance_valid(character):
		return
	if character.get("_is_dying", false):
		return

	retarget_timer -= delta
	shoot_timer    -= delta
	jump_timer     -= delta
	stuck_timer    += delta
	decision_lock  -= delta
	hazard_cooldown -= delta

	# 1. Detekcja zagrożeń (Pociski i Krawędzie)
	if hazard_cooldown <= 0.0:
		hazard_cooldown = 0.18 + randf() * 0.05
		if randf() > 0.30: # 70% szansy na reakcję
			_check_hazards()
			_check_edges()

	# 2. Celowanie i ruch bazowy (tylko jeśli nie ma blokady decyzji po uniku)
	if decision_lock <= 0.0:
		_process_ai_logic(delta)

	# 3. Anti-stuck (ulepszony)
	if abs(character.global_position.x - last_x) < 1.0:
		if stuck_timer > 0.8:
			if character.is_on_wall():
				_do_jump()
				direction = -direction if direction != 0 else [ - 1.0, 1.0].pick_random()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0
	last_x = character.global_position.x

	# Aplikuj ruch
	_apply_movement(delta)


func _process_ai_logic(delta: float) -> void:
	# Co 0.5s szukaj najbliższego wroga
	if retarget_timer <= 0.0:
		retarget_timer = 0.4 + randf() * 0.2
		_find_target()

	if is_instance_valid(target) and not target.get("_is_dying", false):
		var dx = target.global_position.x - character.global_position.x
		var dy = target.global_position.y - character.global_position.y

		var hp = Global.characters.get(char_name, {}).get("hp", 100.0)
		var is_low_hp = hp < 35.0
		var is_high_hp = hp > 75.0

		if abs(dx) > (160.0 if is_low_hp else 50.0):
			direction = sign(dx)
			if is_low_hp: # Kiting: uciekaj jeśli cel jest zbyt blisko
				if abs(dx) < 140.0:
					direction = -sign(dx)
		else:
			direction = lerp(direction, float([ - 1.0, 0.0, 1.0].pick_random()), 0.2)

		if dy < -30.0 and jump_timer <= 0.0:
			jump_timer = (0.5 if is_low_hp else 0.7) + randf() * 0.4
			_do_jump()
		elif jump_timer <= 0.0 and randf() < (0.04 if is_low_hp else 0.015):
			jump_timer = 1.0
			_do_jump()

		# Strzelanie
		var fire_rate = float(Global.characters.get(char_name, {}).get("fire_rate", 0.6))
		if shoot_timer <= 0.0:
			var hp = Global.characters.get(char_name, {}).get("hp", 100.0)
			shoot_timer = fire_rate + randf() * 0.25
			var shoot_dir = (target.global_position - character.global_position).normalized()
			# Celność: bardziej precyzyjna gdy bot ma dużo HP
			var spread = 12.0 if hp < 40.0 else (6.0 if hp > 75.0 else 9.0)
			shoot_dir = shoot_dir.rotated(deg_to_rad(randf_range(-spread, spread)))
			character.shoot.emit(character.global_position, shoot_dir)
			if character.has_node("ReloadTime"):
				character.get_node("ReloadTime").start()
	else:
		# Brak celu
		if randf() < 0.01:
			direction = [ - 1.0, 0.0, 1.0].pick_random()
		if randf() < 0.005:
			_do_jump()


func _check_hazards() -> void:
	var bullets = get_tree().get_nodes_in_group("Bullet")
	for bullet in bullets:
		if not is_instance_valid(bullet): continue
		if bullet.get("shooter_name") == char_name: continue

		var dist = character.global_position.distance_to(bullet.global_position)
		if dist < EVASION_DIST:
			var rel_pos = bullet.global_position - character.global_position
			var b_vel = bullet.get("velocity", Vector2.ZERO)
			
			# Czy pocisk leci w moją stronę? (dot product)
			if b_vel.dot(-rel_pos.normalized()) > 0.4:
				decision_lock = 0.35 # Zablokuj AI na czas uniku
				if abs(rel_pos.y) < 25.0: # Pocisk na wysokości nóg/tułowia
					_do_jump()
				else:
					direction = -sign(rel_pos.x) # Odskocz w bok


func _check_edges() -> void:
	if not character.is_on_floor() or direction == 0.0:
		return

	var space_state = character.get_world_2d().direct_space_state
	var look_pos = character.global_position + Vector2(direction * EDGE_LOOK_AHEAD, 10.0)
	# Mask 1 = Terrain. Exclude self to avoid false positives.
	var query = PhysicsRayQueryParameters2D.create(look_pos, look_pos + Vector2(0, 50.0), 1, [character.get_rid()])
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		# Przepaść!
		if randf() < 0.6:
			direction = -direction
			decision_lock = 0.4
		else:
			_do_jump()


func _apply_movement(delta: float) -> void:
	var cur_max = character.max_speed * 0.4 if character.is_slowed else character.max_speed
	# Bezpośredni dostęp do stałych skryptu postaci lub bezpieczne fallbacki
	var acc = character.get("ACCELERATION") if character.get("ACCELERATION") != null else 16.0
	var fric = character.get("FRICTION") if character.get("FRICTION") != null else 18.0
	var vel_weight = delta * (acc if direction != 0.0 else fric)
	
	if character.is_on_wall() and direction != 0.0:
		vel_weight = delta * fric
		
	character.velocity.x = lerp(character.velocity.x, direction * cur_max, vel_weight)


func _do_jump() -> void:
	if character.is_on_floor():
		var j_height = character.get("JUMP_HEIGHT") if character.get("JUMP_HEIGHT") != null else -270.0
		character.velocity.y = j_height


func _find_target() -> void:
	var best: CharacterBody2D = null
	var best_dist: float = 9999.0
	for node in get_tree().get_nodes_in_group("Players"):
		if not is_instance_valid(node) or node == character:
			continue
		if node.get("_is_dying", false):
			continue
		var d = character.global_position.distance_to(node.global_position)
		if d < best_dist:
			best_dist = d
			best      = node
	target = best

