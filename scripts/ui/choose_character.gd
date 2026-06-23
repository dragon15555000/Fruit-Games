extends Control

@onready var picking_label: Label = $PickingLabel
@onready var character_info: RichTextLabel = $CharacterInfo
@onready var buttons = {
	"Strawberry": $Strawberry2,
	"Orange":     $Orange2,
	"Pineapple":  $Pineapple2,
	"Grape":      $Grape2,
	"Lemon":      $Lemon2,
	"Watermelon": $Watermelon2,
}

const DEFAULT_INFO_TEXT := "[b]Wybierz owoc[/b]\nNajedź myszą na postać, aby zobaczyć jej styl gry."

const CHARACTER_PREVIEWS := {
	"Strawberry": {
		"title": "Strawberry",
		"style": "Mobilny duelist",
		"hp": 110,
		"speed": 92,
		"dmg": 23,
		"fire_rate": 0.62,
		"range": 140,
		"note": "double_shot: nacisk z dwóch pocisków"
	},
	"Orange": {
		"title": "Orange",
		"style": "Snajper / artyleria",
		"hp": 70,
		"speed": 88,
		"dmg": 66,
		"fire_rate": 2.2,
		"range": 470,
		"note": "explosive: mocny strzał i wybuch"
	},
	"Pineapple": {
		"title": "Pineapple",
		"style": "Melee brawler",
		"hp": 240,
		"speed": 58,
		"dmg": 38,
		"fire_rate": 0.55,
		"range": 72,
		"note": "sticky + melee: walka w zwarciu"
	},
	"Grape": {
		"title": "Grape",
		"style": "Szybkostrzelny spammer",
		"hp": 82,
		"speed": 118,
		"dmg": 11,
		"fire_rate": 0.12,
		"range": 200,
		"note": "shotgun: ciągła presja"
	},
	"Lemon": {
		"title": "Lemon",
		"style": "Kontrola przestrzeni",
		"hp": 88,
		"speed": 98,
		"dmg": 16,
		"fire_rate": 0.72,
		"range": 260,
		"note": "magnetic_seed + fermentation: prowadzenie i nacisk"
	},
	"Watermelon": {
		"title": "Watermelon",
		"style": "Ciężki tank",
		"hp": 310,
		"speed": 46,
		"dmg": 72,
		"fire_rate": 1.35,
		"range": 100,
		"note": "stone_seed + armor: wytrzymałość i kara za błąd"
	},
}

func _ready():
	if Global.is_network_game:
		if multiplayer.is_server():
			Global.reset_selection()
			MultiplayerManager._rpc_sync_character_state.rpc(
				Global.player1_character,
				Global.player2_character,
				Global.player3_character,
				Global.player4_character,
				Global.current_picking_player
			)
		MultiplayerManager.pick_synced.connect(_on_pick_synced)
	else:
		Global.reset_selection()
	_bind_preview_signals()
	_set_default_character_info()
	update_ui()
	# Jeśli bieżący slot to bot — auto-pick po krótkim opóźnieniu
	_try_bot_auto_pick()


func _on_pick_synced() -> void:
	update_ui()


func _bind_preview_signals() -> void:
	for character_name in buttons:
		var button = buttons[character_name]
		if not is_instance_valid(button):
			continue
		var preview_name := character_name
		button.mouse_entered.connect(func() -> void:
			_on_character_hover_start(preview_name)
		)
		button.mouse_exited.connect(_on_character_hover_end)


func _set_default_character_info() -> void:
	if is_instance_valid(character_info):
		character_info.text = DEFAULT_INFO_TEXT


func _on_character_hover_start(character_name: String) -> void:
	if not is_instance_valid(character_info):
		return
	if not CHARACTER_PREVIEWS.has(character_name):
		return
	character_info.text = _format_preview_text(character_name)


func _on_character_hover_end() -> void:
	if not is_instance_valid(character_info):
		return
	if Global.current_picking_player == 0:
		_set_default_character_info()
		return
	update_ui()


func update_ui():
	var slot = Global.current_picking_player

	# Przeskocz sloty "off" — każdy pusty pick przesuwa current_picking_player
	while slot <= 4 and Global.slot_types.get(slot, "off") == "off":
		Global.pick_character("")
		slot = Global.current_picking_player
		if Global.all_picked():
			_start_game()
			return

	# slot_type oblicz PO while loop — slot wskazuje aktualny aktywny slot
	var slot_type = Global.slot_types.get(slot, "player")

	if slot_type == "bot":
		picking_label.text = "Slot %d (Bot) wybiera..." % slot
		for character in buttons:
			buttons[character].disabled = true
	else:
		picking_label.text = "Gracz %d wybiera!" % slot
		_set_default_character_info()
		var my_turn = _is_my_turn()
		for character in buttons:
			buttons[character].disabled = not Global.available_characters.has(character) or not my_turn


func _is_my_turn() -> bool:
	if not Global.is_network_game:
		return true
	return Global.current_picking_player == Global.local_player_slot


func _try_bot_auto_pick() -> void:
	# Pomiń sloty "off"
	while Global.current_picking_player <= Global.total_players + _count_off_slots():
		var slot = Global.current_picking_player
		if slot > 4:
			break
		var slot_type = Global.slot_types.get(slot, "player")
		if slot_type == "off":
			Global.pick_character("")
			if Global.all_picked():
				_start_game()
				return
			continue
		elif slot_type == "bot":
			# Bot losuje z dostępnych postaci
			await get_tree().create_timer(0.3).timeout
			if Global.available_characters.size() > 0:
				var choices = Global.available_characters.duplicate()
				choices.shuffle()
				pick(choices[0])
			return
		else:
			# Gracz — czekaj na kliknięcie
			return

func _count_off_slots() -> int:
	var count = 0
	for i in range(1, 5):
		if Global.slot_types.get(i, "player") == "off":
			count += 1
	return count


func _format_preview_text(character_name: String) -> String:
	var s = CHARACTER_PREVIEWS[character_name]
	return "[b]%s[/b]\n%s\nHP %s | SPD %s | DMG %s | FR %ss | Range %s\n%s" % [
		s["title"],
		s["style"],
		str(s["hp"]),
		str(s["speed"]),
		str(s["dmg"]),
		str(s["fire_rate"]),
		str(s["range"]),
		s["note"]
	]


func _on_strawberry_2_pressed():
	AudioManager.play_ui_click()
	pick("Strawberry")

func _on_grape_2_pressed():
	AudioManager.play_ui_click()
	pick("Grape")

func _on_orange_2_pressed():
	AudioManager.play_ui_click()
	pick("Orange")

func _on_pineapple_2_pressed():
	AudioManager.play_ui_click()
	pick("Pineapple")

func _on_lemon_2_pressed():
	AudioManager.play_ui_click()
	pick("Lemon")

func _on_watermelon_2_pressed():
	AudioManager.play_ui_click()
	pick("Watermelon")

func pick(character_name: String):
	if Global.is_network_game:
		MultiplayerManager.request_pick.rpc_id(1, character_name)
	else:
		Global.pick_character(character_name)
		if Global.all_picked():
			_start_game()
		else:
			update_ui()
			_try_bot_auto_pick()


func _start_game() -> void:
	Global.reset_all()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
