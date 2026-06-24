extends Node2D

var character_scenes = {
	"Strawberry": {
		"scene":  preload("res://scenes/characters/strawberry.tscn"),
		"bullet": preload("res://scenes/bullets/strawberry_bullet.tscn")
	},
	"Grape": {
		"scene":  preload("res://scenes/characters/grape.tscn"),
		"bullet": preload("res://scenes/bullets/grape_bullet.tscn")
	},
	"Orange": {
		"scene":  preload("res://scenes/characters/orange.tscn"),
		"bullet": preload("res://scenes/bullets/orange_bullet.tscn")
	},
	"Pineapple": {
		"scene":  preload("res://scenes/characters/pineapple.tscn"),
		"bullet": preload("res://scenes/bullets/pineapple_bullet.tscn")
	},
	"Lemon": {
		"scene":  preload("res://scenes/characters/lemon.tscn"),
		"bullet": preload("res://scenes/bullets/lemon_bullet.tscn")
	},
	"Watermelon": {
		"scene":  preload("res://scenes/characters/watermelon.tscn"),
		"bullet": preload("res://scenes/bullets/watermelon_bullet.tscn")
	},
	"Banana": {
		"scene":  preload("res://scenes/characters/banana.tscn"),
		"bullet": preload("res://scenes/bullets/banana_bullet.tscn")
	},
	"Cherry": {
		"scene":  preload("res://scenes/characters/cherry.tscn"),
		"bullet": preload("res://scenes/bullets/cherry_bullet.tscn")
	},
	"Coconut": {
		"scene":  preload("res://scenes/characters/coconut.tscn"),
		"bullet": preload("res://scenes/bullets/coconut_bullet.tscn")
	}
}

var bullet_scenes:     Dictionary = {}
var player_characters: Dictionary = {}
var kill_feed_script   = preload("res://scripts/ui/kill_feed.gd")
var bot_controller_scn = preload("res://scripts/ai/bot_controller.gd")
var melee_hit_scene    = preload("res://scenes/effects/melee_hit.tscn")
var _ending_round: bool = false
var _pause_layer: CanvasLayer = null

var juice_y:       float = 180.0
var _juice_time:   float = 0.0
var _juice_warned: bool  = false
var _juice_damage_timer: float = 0.0

var map_scenes: Array = [
	preload("res://scenes/maps/fruit_bowl.tscn"),
	preload("res://scenes/maps/juice_factory.tscn"),
	preload("res://scenes/maps/canopy.tscn"),
	preload("res://scenes/maps/blender.tscn"),
	preload("res://scenes/maps/watermelon_caves.tscn"),
	preload("res://scenes/maps/cherry_orchard.tscn"),
	preload("res://scenes/maps/banana_jungle.tscn"),
]
var current_map: Node2D = null


func _ready() -> void:
	Global.reset_all()
	_setup_kill_feed()
	Global.game_started = true
	Global.main_game = self
	_ending_round = false

	print("=== RUNDA " + str(Global.round_number) + " ===")
	for character in Global.modifiers:
		if Global.modifiers[character].size() > 0:
			print(character + " mody: " + str(Global.modifiers[character]))

	# Losowa mapa
	_load_random_map()

	# Spawn z pozycji mapy
	var spawns = _get_spawn_points()
	_spawn_player(Global.player1_character, spawns[0], "p1")
	_spawn_player(Global.player2_character, spawns[1], "p2")
	_spawn_player(Global.player3_character, spawns[2], "p3")
	_spawn_player(Global.player4_character, spawns[3], "p4")

	AudioManager.play_bgm()

	# HUD
	var hud_scene = preload("res://scenes/ui/hud.tscn")
	var hud_instance = hud_scene.instantiate()
	add_child(hud_instance)


func _draw() -> void:
	if juice_y >= 180.0:
		return
	var t = Time.get_ticks_msec() * 0.002

	# Tło soku
	draw_rect(Rect2(-270, juice_y + 6.0, 540, 220), Color(0.80, 0.10, 0.16, 0.72))

	# Falująca powierzchnia
	var steps = 40
	var w = 540.0 / steps
	for i in range(steps):
		var x0 = -270.0 + i * w
		var x1 = x0 + w + 1.0
		var y0 = juice_y + sin(t + i * 0.55) * 4.0
		var y1 = juice_y + sin(t + (i + 1) * 0.55) * 4.0
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(x0, y0), Vector2(x1, y1),
				Vector2(x1, juice_y + 12.0), Vector2(x0, juice_y + 12.0)
			]),
			Color(0.95, 0.25, 0.32, 0.92))

	# Bąbelki na powierzchni
	for i in range(10):
		var bx = -220.0 + i * 48.0 + sin(t * 0.8 + i * 1.4) * 14.0
		var by = juice_y + sin(t * 1.3 + i * 1.0) * 2.5 - 3.0
		var br = 2.5 + sin(t * 0.6 + i * 0.7) * 1.0
		draw_circle(Vector2(bx, by), br, Color(1.0, 0.55, 0.60, 0.65))


func _spawn_player(character_name: String, spawn_pos: Vector2, player_prefix: String) -> void:
	if character_name == "":
		return
	var data   = character_scenes[character_name]
	var player = data["scene"].instantiate()
	# Nadaj spójną nazwę węzła — wymagana przez RPC przez sieć
	player.name         = player_prefix
	player.action_left  = player_prefix + "_left"
	player.action_right = player_prefix + "_right"
	player.action_jump  = player_prefix + "_jump"
	player.action_shoot = player_prefix + "_shoot"
	player.position     = spawn_pos
	bullet_scenes[player_prefix]     = data["bullet"]
	player_characters[player_prefix] = character_name
	player.shoot.connect(func(pos, dir): _on_shoot(pos, dir, player_prefix))
	$Players.add_child(player)

	# Bot AI — jeśli slot to bot, dodaj kontroler i wyłącz input gracza
	var slot = int(player_prefix.substr(1))  # "p1" → 1
	if Global.slot_types.get(slot, "player") == "bot":
		var bot = Node.new()
		bot.set_script(bot_controller_scn)
		bot.name = "BotController"
		player.add_child(bot)
		bot.setup(player, character_name)
		# Wyłącz input gracza — bot steruje ruchem
		player.action_left  = ""
		player.action_right = ""
		player.action_jump  = ""
		player.action_shoot = ""

	# W trybie sieciowym przypisz właściciela węzła
	if Global.is_network_game:
		var owner_id = MultiplayerManager.get_peer_for_slot(slot)
		if owner_id > 0:
			player.network_owner_id = owner_id
			player.is_remote = (owner_id != multiplayer.get_unique_id())


func _setup_kill_feed() -> void:
	var canvas        = CanvasLayer.new()
	canvas.layer      = 10
	add_child(canvas)
	var feed          = VBoxContainer.new()
	feed.script       = kill_feed_script
	feed.anchor_right = 1.0
	feed.offset_left  = 4
	feed.offset_top   = 4
	feed.offset_right = -4
	canvas.add_child(feed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _ending_round:
			return
		if _pause_layer:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()


func _pause_game() -> void:
	get_tree().paused = true
	AudioManager.play_ui_click()

	_pause_layer = CanvasLayer.new()
	_pause_layer.layer = 30
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_layer)

	var bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.set_offset(SIDE_LEFT,   -110)
	vbox.set_offset(SIDE_TOP,     -80)
	vbox.set_offset(SIDE_RIGHT,   110)
	vbox.set_offset(SIDE_BOTTOM,   80)
	vbox.add_theme_constant_override("separation", 16)
	vbox.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.add_child(vbox)

	var title = Label.new()
	title.text = "Pauza"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var resume_btn = Button.new()
	resume_btn.text = "Wznów"
	resume_btn.custom_minimum_size = Vector2(220, 44)
	resume_btn.add_theme_font_size_override("font_size", 18)
	resume_btn.pressed.connect(_resume_game)
	vbox.add_child(resume_btn)

	var quit_btn = Button.new()
	quit_btn.text = "Wyjdź do menu"
	quit_btn.custom_minimum_size = Vector2(220, 44)
	quit_btn.add_theme_font_size_override("font_size", 18)
	quit_btn.pressed.connect(_quit_to_menu)
	vbox.add_child(quit_btn)


func _resume_game() -> void:
	AudioManager.play_ui_click()
	if _pause_layer:
		_pause_layer.queue_free()
		_pause_layer = null
	get_tree().paused = false


func _quit_to_menu() -> void:
	AudioManager.play_ui_click()
	get_tree().paused = false
	_pause_layer = null
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_shoot(pos: Vector2, dir: Vector2, player_prefix: String) -> void:
	if _ending_round:
		return
	AudioManager.notify_combat()
	var char_name = player_characters.get(player_prefix, "")

	# Ananas = MELEE — cios obszarowy zamiast pocisku
	if char_name == "Pineapple":
		_do_melee_attack(pos, dir, char_name)
		return

	if Global.is_network_game:
		_rpc_spawn_bullet.rpc(pos, dir, player_prefix)
	else:
		_do_spawn_bullet(pos, dir, player_prefix)


@rpc("any_peer", "call_local", "reliable")
func _rpc_spawn_bullet(pos: Vector2, dir: Vector2, player_prefix: String) -> void:
	# Walidacja: nadawca może strzelać tylko swoją postacią
	if Global.is_network_game and multiplayer.is_server():
		var sender = multiplayer.get_remote_sender_id()
		if sender > 0:
			var expected_slot = int(player_prefix.substr(1))
			var actual_slot = MultiplayerManager.player_slots.get(sender, -1)
			if expected_slot != actual_slot:
				return  # cheat attempt — ignoruj
	_do_spawn_bullet(pos, dir, player_prefix)


func _do_spawn_bullet(pos: Vector2, dir: Vector2, player_prefix: String) -> void:
	if not bullet_scenes.has(player_prefix):
		return
	var char_name: String = player_characters.get(player_prefix, "")
	if char_name == "":
		return

	AudioManager.play_sound("shoot")

	var bullet = bullet_scenes[player_prefix].instantiate() as Area2D
	$Bullets.add_child(bullet)
	bullet.setup(pos, dir, char_name)

	var extra_dirs: Array = ModifierSystem.get_extra_bullet_dirs(char_name, dir)
	for extra_dir in extra_dirs:
		var extra = bullet_scenes[player_prefix].instantiate() as Area2D
		$Bullets.add_child(extra)
		extra.setup(pos, extra_dir, char_name)


var shake_amount: float = 0.0

func add_shake(amount: float) -> void:
	shake_amount = max(shake_amount, amount)

func _physics_process(delta: float) -> void:
	if shake_amount > 0:
		shake_amount = move_toward(shake_amount, 0, delta * 50.0)
		if has_node("Camera2D"):
			$Camera2D.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_amount
	else:
		if has_node("Camera2D"):
			$Camera2D.offset = Vector2.ZERO

	# ── Wznoszący się sok ─────────────────────────────────────────────────────
	_juice_time += delta
	juice_y -= (0.8 + _juice_time * 0.015) * delta
	queue_redraw()

	if not _juice_warned and juice_y < 105.0:
		_juice_warned = true
		Global.kill_feed_message.emit("🍹 Sok owocowy się wznosi!")

	if not _ending_round and juice_y < 200.0:
		_juice_damage_timer += delta
		var should_apply_juice = _juice_damage_timer >= 0.25
		
		for player in $Players.get_children():
			var char_name = player_characters.get(player.name, "")
			if char_name == "" or not Global.alive.get(char_name, false):
				continue
			if player.position.y + 8.0 > juice_y:
				if should_apply_juice:
					player.apply_damage(10.0, "🍹 Sok owocowy")
					AudioManager.play_sound("hit", 0.5, -5.0) # Podwodny/tłumiony hit
		
		if should_apply_juice:
			_juice_damage_timer = 0.0

	if _ending_round:
		return
	# W trybie sieciowym koniec rundy wykrywa tylko serwer
	if Global.is_network_game and not multiplayer.is_server():
		return
	var alive_count = Global.alive.values().count(true)
	if alive_count <= 1:
		var winner = ""
		for ch in Global.alive:
			if Global.alive[ch]:
				winner = ch
				break
		_end_round(winner)


func _end_round(winning_character: String) -> void:
	if _ending_round:
		return
	_ending_round     = true
	Global.round_over = true
	Global.winner     = winning_character

	Global.build_ranking()
	Global.assign_points()

	if winning_character == "":
		Global.modifier_pickers = []

	if Global.is_network_game:
		# Serwer zmienia scenę dla wszystkich
		_rpc_end_round.rpc(winning_character)
	else:
		_do_scene_change()


@rpc("authority", "call_local", "reliable")
func _rpc_end_round(winner: String) -> void:
	Global.winner     = winner
	Global.round_over = true
	_do_scene_change()


func _do_scene_change() -> void:
	if Global.is_set_complete():
		if Global.is_network_game:
			MultiplayerManager.server_change_scene("res://scenes/ui/set_over.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/set_over.tscn")
	else:
		if Global.is_network_game:
			MultiplayerManager.server_change_scene("res://scenes/ui/round_ended.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/round_ended.tscn")


# ─── SPECTATOR OVERLAY ────────────────────────────────────────────────────────

## Serwer wywołuje tę funkcję na kliencie-obserwatorze, aby pokazał nakładkę.
@rpc("authority", "call_remote", "reliable")
func _rpc_notify_spectating() -> void:
	_show_spectator_overlay()

func _show_spectator_overlay() -> void:
	var canvas        = CanvasLayer.new()
	canvas.layer      = 20
	add_child(canvas)
	var lbl           = Label.new()
	lbl.text          = "OBSERWATOR"
	lbl.add_theme_font_size_override("font_size", 32)
	lbl.anchor_right  = 1.0
	lbl.anchor_bottom = 1.0
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	canvas.add_child(lbl)


# ─── MELEE ATTACK (Pineapple) ────────────────────────────────────────────────
func _do_melee_attack(pos: Vector2, dir: Vector2, char_name: String) -> void:
	AudioManager.play_sound("melee")
	var hit = melee_hit_scene.instantiate() as Area2D
	hit.position      = pos + dir * 25.0  # offset w kierunku ataku
	hit.shooter_name  = char_name
	hit.hit_direction = dir
	$Bullets.add_child(hit)  # reuse Bullets node jako kontener


# ─── MAP LOADING ─────────────────────────────────────────────────────────────
func _load_random_map() -> void:
	# Usuń stary teren z main_game.tscn (jeśli jest)
	if has_node("Terrain"):
		$Terrain.queue_free()

	var scene = map_scenes.pick_random()
	current_map = scene.instantiate()
	current_map.name = "MapInstance"
	add_child(current_map)
	move_child(current_map, 0)  # tło pod wszystkim

	print("Mapa: " + current_map.name)

func _get_spawn_points() -> Array:
	# Szukaj SpawnPoint1-4 w załadowanej mapie
	var points: Array = []
	for i in range(1, 5):
		var sp = current_map.get_node_or_null("SpawnPoint" + str(i))
		if sp:
			points.append(sp.position)
		else:
			# Fallback — domyślne pozycje
			points.append(Vector2(-100 + i * 50, 50))
	return points
