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
	update_ui()
	# Jeśli bieżący slot to bot — auto-pick po krótkim opóźnieniu
	_try_bot_auto_pick()


func _on_pick_synced() -> void:
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
		if is_instance_valid(character_info):
			character_info.text = _build_character_info()
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


func _build_character_info() -> String:
	var lines = ["[b]Balans postaci[/b]"]
	var stats = {
		"Strawberry": {"style": "Mobilny duelist", "hp": 110, "speed": 92, "dmg": 23, "fire_rate": 0.62, "range": 140},
		"Orange": {"style": "Snajper / artyleria", "hp": 70, "speed": 88, "dmg": 66, "fire_rate": 2.2, "range": 470},
		"Pineapple": {"style": "Melee brawler", "hp": 240, "speed": 58, "dmg": 38, "fire_rate": 0.55, "range": 72},
		"Grape": {"style": "Szybkostrzelny spammer", "hp": 82, "speed": 118, "dmg": 11, "fire_rate": 0.12, "range": 200},
		"Lemon": {"style": "Kontrola przestrzeni", "hp": 88, "speed": 98, "dmg": 16, "fire_rate": 0.72, "range": 260},
		"Watermelon": {"style": "Ciężki tank", "hp": 310, "speed": 46, "dmg": 72, "fire_rate": 1.35, "range": 100},
	}
	for name in ["Strawberry", "Orange", "Pineapple", "Grape", "Lemon", "Watermelon"]:
		var s = stats[name]
		var note = ""
		match name:
			"Strawberry": note = "double_shot"
			"Orange": note = "explosive"
			"Pineapple": note = "sticky + melee"
			"Grape": note = "shotgun"
			"Lemon": note = "magnetic_seed + fermentation"
			"Watermelon": note = "stone_seed + armor"
		lines.append("%s: %s | HP %s | SPD %s | DMG %s | FR %ss | %s" % [name, s["style"], str(s["hp"]), str(s["speed"]), str(s["dmg"]), str(s["fire_rate"]), note])
	return "\n".join(lines)


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
