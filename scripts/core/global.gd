extends Node
signal kill_feed_message(text: String)

# ── Tryb sieciowy ─────────────────────────────────────────────────────────────
var is_network_game:   bool = false   # true gdy gram przez sieć
var main_game:         Node = null    # odniesienie do głównej instancji gry
var local_player_slot: int  = 0       # który slot kontroluję (1-4), 0 = lokalny

var player1_character: String = ""
var player2_character: String = ""
var player3_character: String = ""
var player4_character: String = ""

# Typ slotu: "player" lub "bot" — ustawiany w menu
var slot_types: Dictionary = { 1: "player", 2: "player", 3: "player", 4: "player" }

var round_over:   bool   = false
var game_started: bool   = false
var winner:       String = ""
var total_players: int   = 4
var current_picking_player: int = 1

var selected_characters:  Dictionary = {}
var available_characters: Array      = []
var alive:                Dictionary = {}

var round_number:   int = 1
var rounds_per_set: int = 5

var points:    Dictionary = {}
var modifiers: Dictionary = {}
var rot_bonus: Dictionary = {}

var death_order:      Array = []
var ranking:          Array = []
var modifier_pickers: Array = []

var shot_counter: Dictionary = {}
var last_hit_by: Dictionary = {}
var _damage_accumulator: Dictionary = {}

# Oryginalne staty — NIGDY nie modyfikuj tego słownika.
# Służy jako source-of-truth przy każdym reset_all().
const ORIGINAL_BASE_CHARACTERS: Dictionary = {
	"Strawberry": { "hp": 110, "speed": 92,  "dmg": 23, "range": 140, "fire_rate": 0.62 },
	"Orange":     { "hp": 70,  "speed": 88,  "dmg": 66, "range": 470, "fire_rate": 2.2 },
	"Pineapple":  { "hp": 240, "speed": 58,  "dmg": 38, "range": 72,  "fire_rate": 0.55 },
	"Grape":      { "hp": 82,  "speed": 118, "dmg": 11, "range": 200, "fire_rate": 0.12 },
	"Lemon":      { "hp": 88,  "speed": 98,  "dmg": 16, "range": 260, "fire_rate": 0.72 },
	"Watermelon": { "hp": 310, "speed": 46,  "dmg": 72, "range": 100, "fire_rate": 1.35 },
	"Banana":     { "hp": 100, "speed": 80,  "dmg": 22, "range": 250, "fire_rate": 0.6  },
	"Cherry":     { "hp": 70,  "speed": 105, "dmg": 20, "range": 200, "fire_rate": 0.5  },
	"Coconut":    { "hp": 160, "speed": 70,  "dmg": 30, "range": 150, "fire_rate": 1.0  },
}

# Kopia robocza — może być modyfikowana przez mody (thick_skin, seed_collector itp.)
# Resetowana z ORIGINAL_BASE_CHARACTERS na początku każdej rundy.
var base_characters: Dictionary = {}
var characters: Dictionary = {}

var modifier_registry: Dictionary = {
	"double_shot":        { "name": "Podwójny strzał",       "emoji": "✌️",  "category": "projectile", "trigger": "on_shoot",   "desc": "Wystrzelasz dodatkowy pocisk obok głównego." },
	"sniper_seed":        { "name": "Pestka snajpera",        "emoji": "🎯",  "category": "projectile", "trigger": "on_shoot",   "desc": "Pocisk leci o 25% szybciej." },
	"fermentation":       { "name": "Fermentacja",            "emoji": "🧪",  "category": "projectile", "trigger": "on_hit",     "desc": "Każdy pocisk zatruwa wroga na 3 sek." },
	"ripe_shot":          { "name": "Dojrzały strzał",        "emoji": "🍑",  "category": "projectile", "trigger": "on_shoot",   "desc": "Co 3. strzał zadaje +30% obrażeń." },
	"shotgun":            { "name": "Shotgun pestek",         "emoji": "💥",  "category": "projectile", "trigger": "on_shoot",   "desc": "Wystrzelasz 3 dodatkowe pociski w wachlarzu." },
	"radioactive_seed":   { "name": "Radioaktywna pestka",    "emoji": "☢️",  "category": "projectile", "trigger": "on_hit",     "desc": "Przy trafieniu zostaje toksyczna plama na 3 sek." },
	"rot_shot":           { "name": "Strzał zgnilizny",       "emoji": "🦠",  "category": "projectile", "trigger": "on_hit",     "desc": "Trafiony wróg gnije o 3 sek szybciej." },
	"magnetic_seed":      { "name": "Magnetyczna pestka",     "emoji": "🧲",  "category": "projectile", "trigger": "on_shoot",   "desc": "Pocisk skręca w kierunku wroga w zasięgu 2m." },
	"thick_skin":         { "name": "Gruba skórka",           "emoji": "🥊",  "category": "defense",    "trigger": "on_apply",   "desc": "Maksymalne HP +25." },
	"juicy_core":         { "name": "Soczyste wnętrze",       "emoji": "💧",  "category": "defense",    "trigger": "on_hit",     "desc": "Odzyskujesz 15% brakującego HP przy trafieniu wroga." },
	"wax_coat":           { "name": "Woskowa powłoka",        "emoji": "🕯️",  "category": "defense",    "trigger": "on_receive", "desc": "Blokujesz pierwsze trafienie w rundzie." },
	"thorn_shield":       { "name": "Kolczasta tarcza",       "emoji": "🌵",  "category": "defense",    "trigger": "on_receive", "desc": "Wrogowie trafiający cię dostają -3 HP." },
	"hard_fruit":         { "name": "Twardy owoc",            "emoji": "🪨",  "category": "defense",    "trigger": "on_receive", "desc": "Redukcja wszystkich obrażeń o 10%." },
	"antirot":            { "name": "Antyzgnilizna",          "emoji": "🧴",  "category": "defense",    "trigger": "passive",    "desc": "Gnijesz o 10 sek wolniej." },
	"preservative":       { "name": "Konserwant",             "emoji": "🛡️",  "category": "defense",    "trigger": "on_apply",   "desc": "Przez pierwsze 15 sek rundy jesteś odporny na efekty negatywne." },
	"second_fruit":       { "name": "Drugi owoc",             "emoji": "🍀",  "category": "defense",    "trigger": "on_lethal",  "desc": "Raz na rundę przeżywasz śmiertelny cios z 5 HP." },
	"still_green":        { "name": "Zielony jeszcze",        "emoji": "🌿",  "category": "defense",    "trigger": "passive",    "desc": "Gdy HP < 30%, regenerujesz 1 HP co 2 sek." },
	"stone_seed":         { "name": "Kamienna pestka",        "emoji": "🗿",  "category": "defense",    "trigger": "on_apply",   "desc": "+8 pancerza, ale -10% prędkości ruchu." },
	"extra_bounce":       { "name": "Dodatkowe odbicie",      "emoji": "↩️",  "category": "bounce",     "trigger": "on_shoot",   "desc": "Pocisk odbija się o +1 powierzchnię więcej." },
	"accelerating_bounce":{ "name": "Przyspieszające odbicie","emoji": "⚡",  "category": "bounce",     "trigger": "on_bounce",  "desc": "Każde odbicie zwiększa prędkość pocisku o 10%." },
	"destroying_bounce":  { "name": "Niszczące odbicie",      "emoji": "💢",  "category": "bounce",     "trigger": "on_bounce",  "desc": "Każde odbicie dodaje +5 DMG." },
	"magnetic_bounce":    { "name": "Magnetyczne odbicie",    "emoji": "🧲",  "category": "bounce",     "trigger": "on_bounce",  "desc": "Po odbiciu pocisk leci w stronę najbliższego wroga przez 2 sek." },
	"mirror_skin":        { "name": "Lustrzana skórka",       "emoji": "🪞",  "category": "defense",    "trigger": "on_receive", "desc": "10% szansa na odbicie ataku wroga." },
	"rage_bounce":        { "name": "Wściekłe odbicie",       "emoji": "😡",  "category": "bounce",     "trigger": "on_bounce",  "desc": "Odbity pocisk zadaje 40% więcej obrażeń." },
	"ripe_sprint":        { "name": "Dojrzały sprint",        "emoji": "👟",  "category": "passive",    "trigger": "on_apply",   "desc": "Prędkość ruchu +15%." },
	"rot_accelerator":    { "name": "Przyspieszacz gnicia",   "emoji": "💀",  "category": "area",       "trigger": "passive",    "desc": "Wrogowie w twoim zasięgu gniją 15% szybciej." },
	"rot_explosion":      { "name": "Gnilna eksplozja",       "emoji": "🌋",  "category": "defense",    "trigger": "passive",    "desc": "Gdy HP < 20%, odpychasz wrogów i leczysz 10 HP (jednorazowo)." },
	"seed_collector":     { "name": "Kolekcjoner pestek",     "emoji": "🌰",  "category": "projectile", "trigger": "on_hit",     "desc": "Każde trafienie bez otrzymania ciosu daje +1 DMG. Reset przy ciosie." },
	"fruit_streak":       { "name": "Owocowa passa",          "emoji": "🔥",  "category": "projectile", "trigger": "on_hit",     "desc": "3 trafienia z rzędu = następny pocisk +30% obrażeń." },
	"mod_duplicator":     { "name": "Duplikator modów",       "emoji": "🔄",  "category": "passive",    "trigger": "on_apply",   "desc": "Losowy posiadany modyfikator zostaje skopiowany." },
	"bouncy":   { "name": "Odbijające pociski", "emoji": "↩️", "category": "bounce",     "trigger": "on_shoot",   "desc": "Pociski odbijają się 4 razy." },
	"spinning": { "name": "Wirujące pociski",   "emoji": "🌪️", "category": "projectile", "trigger": "passive",    "desc": "Pociski poruszają się sinusoidalnie." },
	"poison":   { "name": "Ślad trucizny",      "emoji": "☠️", "category": "area",       "trigger": "passive",    "desc": "Gracz zostawia toksyczny ślad." },
	"lifesteal":{ "name": "Kradzież HP",        "emoji": "🔴", "category": "projectile", "trigger": "on_hit",     "desc": "Odzyskujesz 30% zadanych obrażeń jako HP." },
	"explosive":{ "name": "Eksplodujące",       "emoji": "💣", "category": "projectile", "trigger": "on_hit",     "desc": "Pociski eksplodują przy trafieniu." },
	"sticky":   { "name": "Lepkie pociski",     "emoji": "🐌", "category": "projectile", "trigger": "on_hit",     "desc": "Trafiony wróg jest spowolniony przez 3 sek." },
	"armor":    { "name": "Pancerz",            "emoji": "🛡️", "category": "defense",    "trigger": "on_receive", "desc": "Redukuje obrażenia o 30%." },
	"speed":    { "name": "+20% prędkość",      "emoji": "👟", "category": "passive",    "trigger": "on_apply",   "desc": "Prędkość ruchu +20%." },
}

var all_modifiers: Array = [
	# Projectile
	"double_shot", "sniper_seed", "fermentation", "ripe_shot", "shotgun",
	"radioactive_seed", "rot_shot", "magnetic_seed",
	"lifesteal", "explosive", "sticky", "spinning",
	# Defense
	"thick_skin", "juicy_core", "wax_coat", "thorn_shield", "hard_fruit",
	"antirot", "preservative", "second_fruit", "still_green", "stone_seed",
	"armor",
	# Bounce
	"extra_bounce", "accelerating_bounce", "destroying_bounce",
	"magnetic_bounce", "mirror_skin", "rage_bounce", "bouncy",
	# Passive / Area
	"ripe_sprint", "rot_accelerator", "rot_explosion",
	"seed_collector", "fruit_streak", "mod_duplicator",
	"poison", "speed",
]

func _ready() -> void:
	_setup_gamepads()
	base_characters = ORIGINAL_BASE_CHARACTERS.duplicate(true)
	round_number    = 1
	points          = {}
	modifiers       = {}
	reset_selection()
	reset_all()

func _setup_gamepads() -> void:
	for i in range(4):
		var prefix = "p" + str(i + 1)
		
		# Skok (A)
		var ev_jump = InputEventJoypadButton.new()
		ev_jump.device = i
		ev_jump.button_index = JOY_BUTTON_A
		InputMap.action_add_event(prefix + "_jump", ev_jump)
		
		# Strzał (X / Right Bumper / Right Trigger)
		var ev_shoot = InputEventJoypadButton.new()
		ev_shoot.device = i
		ev_shoot.button_index = JOY_BUTTON_X
		InputMap.action_add_event(prefix + "_shoot", ev_shoot)
		
		var ev_shoot2 = InputEventJoypadButton.new()
		ev_shoot2.device = i
		ev_shoot2.button_index = JOY_BUTTON_RIGHT_SHOULDER
		InputMap.action_add_event(prefix + "_shoot", ev_shoot2)
		
		var ev_shoot_trigger = InputEventJoypadMotion.new()
		ev_shoot_trigger.device = i
		ev_shoot_trigger.axis = JOY_AXIS_TRIGGER_RIGHT
		ev_shoot_trigger.axis_value = 1.0
		InputMap.action_add_event(prefix + "_shoot", ev_shoot_trigger)
		
		# Lewo (D-Pad Left)
		var ev_left = InputEventJoypadButton.new()
		ev_left.device = i
		ev_left.button_index = JOY_BUTTON_DPAD_LEFT
		InputMap.action_add_event(prefix + "_left", ev_left)
		
		# Lewo (Left Stick -X)
		var ev_stick_l = InputEventJoypadMotion.new()
		ev_stick_l.device = i
		ev_stick_l.axis = JOY_AXIS_LEFT_X
		ev_stick_l.axis_value = -1.0
		InputMap.action_add_event(prefix + "_left", ev_stick_l)
		
		# Prawo (D-Pad Right)
		var ev_right = InputEventJoypadButton.new()
		ev_right.device = i
		ev_right.button_index = JOY_BUTTON_DPAD_RIGHT
		InputMap.action_add_event(prefix + "_right", ev_right)
		
		# Prawo (Left Stick +X)
		var ev_stick_r = InputEventJoypadMotion.new()
		ev_stick_r.device = i
		ev_stick_r.axis = JOY_AXIS_LEFT_X
		ev_stick_r.axis_value = 1.0
		InputMap.action_add_event(prefix + "_right", ev_stick_r)

func reset_selection() -> void:
	available_characters   = base_characters.keys()
	selected_characters    = {}
	current_picking_player = 1
	player1_character = ""
	player2_character = ""
	player3_character = ""
	player4_character = ""

func reset_all() -> void:
	base_characters = ORIGINAL_BASE_CHARACTERS.duplicate(true)
	characters      = ORIGINAL_BASE_CHARACTERS.duplicate(true)
	shot_counter = {}
	last_hit_by.clear()
	_damage_accumulator.clear()
	rot_bonus.clear()
	alive        = {}
	var all_chars = [player1_character, player2_character, player3_character, player4_character]
	for ch in all_chars:
		if ch == "": continue
		alive[ch] = true
		if not points.has(ch):    points[ch]    = 0
		if not modifiers.has(ch): modifiers[ch] = []
		
		# Wbudowane modyfikatory postaci
		if ch == "Strawberry" and not "double_shot" in modifiers[ch]:
			modifiers[ch].append("double_shot")
		if ch == "Orange" and not "explosive" in modifiers[ch]:
			modifiers[ch].append("explosive")
		if ch == "Pineapple" and not "sticky" in modifiers[ch]:
			modifiers[ch].append("sticky")
		if ch == "Grape" and not "shotgun" in modifiers[ch]:
			modifiers[ch].append("shotgun")
		if ch == "Lemon" and not "magnetic_seed" in modifiers[ch]:
			modifiers[ch].append("magnetic_seed")
		if ch == "Watermelon" and not "stone_seed" in modifiers[ch]:
			modifiers[ch].append("stone_seed")
		if ch == "Lemon" and not "fermentation" in modifiers[ch]:
			modifiers[ch].append("fermentation")
		if ch == "Watermelon" and not "armor" in modifiers[ch]:
			modifiers[ch].append("armor")
		if ch == "Banana" and not "ripe_sprint" in modifiers[ch]:
			modifiers[ch].append("ripe_sprint")
		if ch == "Coconut" and not "hard_fruit" in modifiers[ch]:
			modifiers[ch].append("hard_fruit")
			
	round_over   = false
	game_started = false
	winner       = ""
	death_order  = []
	ranking      = []

func reset_full_game() -> void:
	round_number = 1
	points       = {}
	modifiers    = {}
	reset_selection()
	reset_all()

func pick_character(character_name: String) -> void:
	selected_characters[current_picking_player] = character_name
	match current_picking_player:
		1: player1_character = character_name
		2: player2_character = character_name
		3: player3_character = character_name
		4: player4_character = character_name
	if character_name != "":
		available_characters.erase(character_name)
	current_picking_player += 1

func all_picked() -> bool:
	# Przeskocz sloty "off" w liczniku
	var last_active_slot = 0
	for i in range(1, 5):
		if slot_types.get(i, "off") != "off":
			last_active_slot = i
	return current_picking_player > last_active_slot

func is_set_complete() -> bool:
	return round_number % rounds_per_set == 0

func assign_points() -> void:
	if winner == "":
		return

	var point_values = [3, 2, 1, 0]
	for i in range(ranking.size()):
		if i < point_values.size():
			var ch = ranking[i]
			if not points.has(ch): points[ch] = 0
			points[ch] += point_values[i]

func get_modifier_pickers() -> Array:
	@warning_ignore("integer_division")
	var half: int = ranking.size() / 2
	var pickers = []
	for i in range(ranking.size() - 1, ranking.size() - half - 1, -1):
		pickers.append(ranking[i])
	return pickers

func build_ranking() -> void:
	ranking = []
	for ch in alive:
		if alive[ch]: ranking.append(ch)
	var rev = death_order.duplicate()
	rev.reverse()
	for ch in rev: ranking.append(ch)

func take_damage(target: String, amount: float, reason: String = "") -> void:
	if amount <= 0.0 or not characters.has(target): return
	if not alive.get(target, false): return # Postać już martwa - ignoruj
	characters[target]["hp"] -= amount

	if reason != "":
		last_hit_by[target] = reason
	
	# Akumulacja małych obrażeń dla czytelności logów
	var key = reason + "->" + target
	var acc = _damage_accumulator.get(key, 0.0) + amount
	
	if int(acc) > 0 or characters[target]["hp"] <= 0:
		var display_dmg = int(acc) if int(acc) > 0 else 1
		var msg = reason + " → " + target + " [color=#ff4444]-" + str(display_dmg) + " HP[/color]"
		if characters[target]["hp"] <= 0:
			msg = "[b][color=red]" + reason + " → " + target + " (ELIMINACJA)[/color][/b]"
		
		print(msg.replace("[b]", "").replace("[/b]", "").replace("[color=red]", "").replace("[color=#ff4444]", "").replace("[/color]", ""))
		kill_feed_message.emit(msg)
		_damage_accumulator[key] = acc - int(acc)
	else:
		_damage_accumulator[key] = acc
	# W trybie sieciowym serwer synchronizuje HP do wszystkich klientów
	if is_network_game and multiplayer.is_server():
		_rpc_sync_hp.rpc(target, float(characters[target]["hp"]))

@rpc("authority", "call_remote", "reliable")
func _rpc_sync_hp(target: String, hp: float) -> void:
	if characters.has(target):
		characters[target]["hp"] = hp

@rpc("authority", "call_local", "reliable")
func rpc_reset_all() -> void:
	reset_all()

# _physics_process USUNIĘTY CAŁKOWICIE
# Koniec rundy wykrywa wyłącznie main_game.gd

const CHARACTER_COLORS: Dictionary = {
	"Strawberry": Color(0.90, 0.10, 0.15),
	"Orange":     Color(1.00, 0.55, 0.10),
	"Pineapple":  Color(0.85, 0.70, 0.15),
	"Grape":      Color(0.55, 0.10, 0.70),
	"Lemon":      Color(0.98, 0.95, 0.15),
	"Watermelon": Color(0.90, 0.20, 0.30),
	"Banana":     Color(0.98, 0.92, 0.15),
	"Cherry":     Color(0.85, 0.05, 0.12),
	"Coconut":    Color(0.50, 0.33, 0.15),
}

func get_char_color(char_name: String) -> Color:
	return CHARACTER_COLORS.get(char_name, Color(1, 0.8, 0.2))

func spawn_particles(pos: Vector2, color: Color, amount: int = 15) -> void:
	if main_game == null or not is_instance_valid(main_game): return
	var cp = CPUParticles2D.new()
	cp.position = pos
	cp.emitting = true
	cp.one_shot = true
	cp.explosiveness = 0.9
	cp.amount = amount
	cp.lifetime = 0.6
	cp.spread = 180.0
	cp.gravity = Vector2(0, 280)
	cp.initial_velocity_min = 80
	cp.initial_velocity_max = 220
	cp.scale_amount_min = 3.5
	cp.scale_amount_max = 7.0
	cp.color = color
	main_game.add_child(cp)
	cp.finished.connect(cp.queue_free)

func spawn_hit_particles(pos: Vector2, char_name: String) -> void:
	if main_game == null or not is_instance_valid(main_game): return
	var col = get_char_color(char_name)
	# Mała iskra trafienia
	var cp = CPUParticles2D.new()
	cp.position = pos
	cp.emitting = true
	cp.one_shot = true
	cp.explosiveness = 1.0
	cp.amount = 8
	cp.lifetime = 0.35
	cp.spread = 60.0
	cp.gravity = Vector2(0, 200)
	cp.initial_velocity_min = 60
	cp.initial_velocity_max = 140
	cp.scale_amount_min = 2.0
	cp.scale_amount_max = 4.0
	cp.color = col
	main_game.add_child(cp)
	cp.finished.connect(cp.queue_free)

func spawn_death_particles(pos: Vector2, char_name: String) -> void:
	if main_game == null or not is_instance_valid(main_game): return
	var col = get_char_color(char_name)
	# Duża eksplozja przy śmierci
	for i in range(3):
		var cp = CPUParticles2D.new()
		cp.position = pos
		cp.emitting = true
		cp.one_shot = true
		cp.explosiveness = 0.95
		cp.amount = 12 + i * 6
		cp.lifetime = 0.5 + i * 0.2
		cp.spread = 180.0
		cp.gravity = Vector2(0, 250 - i * 50)
		cp.initial_velocity_min = 80 + i * 40
		cp.initial_velocity_max = 180 + i * 60
		cp.scale_amount_min = 4.0 - i * 0.5
		cp.scale_amount_max = 8.0 - i * 0.5
		cp.color = col if i == 0 else Color(col.r * 0.7, col.g * 0.7, col.b * 0.7, 0.8)
		main_game.add_child(cp)
		cp.finished.connect(cp.queue_free)

func spawn_damage_text(pos: Vector2, text: String, color: Color = Color.WHITE) -> void:
	if main_game == null or not is_instance_valid(main_game): return
	var label = Label.new()
	label.text = text
	label.z_index = 5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.position = pos - Vector2(20, 20)
	main_game.add_child(label)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.chain().tween_callback(label.queue_free)
