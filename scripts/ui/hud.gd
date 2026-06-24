extends CanvasLayer

@onready var p1_label    = $Control/Margin/Grid/P1Label
@onready var p2_label    = $Control/Margin/Grid/P2Label
@onready var p3_label    = $Control/Margin/Grid/P3Label
@onready var p4_label    = $Control/Margin/Grid/P4Label
@onready var round_label = $Control/Margin/Grid/RoundLabel
var debug_label: RichTextLabel

var labels: Array
var bars: Array = []

func _ready() -> void:
	labels = [p1_label, p2_label, p3_label, p4_label]
	bars = [
		get_node_or_null("Control/Margin/Grid/P1Bar"),
		get_node_or_null("Control/Margin/Grid/P2Bar"),
		get_node_or_null("Control/Margin/Grid/P3Bar"),
		get_node_or_null("Control/Margin/Grid/P4Bar")
	]
	_setup_debug_overlay()
	update_hud()

func _process(_delta: float) -> void:
	# Częsta aktualizacja na wypadek zmian HP / modów
	update_hud()

func update_hud() -> void:
	var round_in_set = ((Global.round_number - 1) % Global.rounds_per_set) + 1
	round_label.text = "Runda %d/%d" % [round_in_set, Global.rounds_per_set]

	for i in range(4):
		var prefix = "p" + str(i + 1)
		var char_name = ""
		match i:
			0: char_name = Global.player1_character
			1: char_name = Global.player2_character
			2: char_name = Global.player3_character
			3: char_name = Global.player4_character
			
		var lbl = labels[i]
		var bar = bars[i] if i < bars.size() else null
		
		if char_name == "" or Global.slot_types.get(i+1, "off") == "off":
			lbl.text = ""
			if bar: bar.visible = false
			continue
			
		var hp = Global.characters.get(char_name, {}).get("hp", 0)
		var is_alive = Global.alive.get(char_name, false)
		
		# Ostrzeżenie gnicia - odczyt z postaci w grupie Players
		var is_rot_critical = false
		var char_node = null
		for p in get_tree().get_nodes_in_group("Players"):
			if p.get("character_name") == char_name:
				char_node = p
				break
		
		if char_node and is_alive:
			var rot_time = char_node.get("rot_time_remaining")
			if rot_time != null and rot_time < 30.0:
				is_rot_critical = true

		# Aktualizacja paska
		if bar:
			bar.visible = is_alive
			if is_alive:
				bar.max_value = 100 # Bazowe HP
				bar.value = hp
				if is_rot_critical:
					bar.modulate = Color(0.8, 0.4, 1.0) # Fioletowy
				else:
					bar.modulate = Color(1.0, 1.0, 1.0)

		# Budowa tekstu
		var txt = "[b]" + prefix.to_upper() + ": " + char_name + "[/b]\n"
		
		if is_alive:
			if is_rot_critical:
				txt += "[color=#cc33ff]HP: " + str(int(hp)) + " (GNICIE!)[/color]\n"
			else:
				txt += "HP: " + str(int(hp)) + "\n"
		else:
			txt += "[color=red]MARTWY[/color]\n"
			
		# Punkty (Kille)
		var pts = Global.points.get(char_name, 0)
		txt += "Punkty: " + str(pts) + "\n"
		
		# Modyfikatory
		var mods = Global.modifiers.get(char_name, [])
		if mods.size() > 0:
			txt += "Mody: "
			for m in mods:
				if Global.modifier_registry.has(m):
					txt += Global.modifier_registry[m]["emoji"]
		
		lbl.text = txt

	if is_instance_valid(debug_label):
		var debug_txt = "[b]Debug[/b]\n"
		for i in range(4):
			var char_name = ""
			match i:
				0: char_name = Global.player1_character
				1: char_name = Global.player2_character
				2: char_name = Global.player3_character
				3: char_name = Global.player4_character
			if char_name == "":
				continue
			var last_hit = Global.last_hit_by.get(char_name, "brak")
			debug_txt += char_name + ": " + last_hit + "\n"
		debug_label.text = debug_txt


func _setup_debug_overlay() -> void:
	var parent = $Control/Margin/Grid
	debug_label = RichTextLabel.new()
	debug_label.bbcode_enabled = true
	debug_label.fit_content = true
	debug_label.scroll_active = false
	debug_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	debug_label.anchor_right = 1.0
	debug_label.anchor_top = 1.0
	debug_label.anchor_bottom = 1.0
	debug_label.offset_left = 20.0
	debug_label.offset_top = 170.0
	debug_label.offset_right = 360.0
	debug_label.offset_bottom = 320.0
	debug_label.add_theme_font_size_override("normal_font_size", 16)
	parent.add_child(debug_label)
