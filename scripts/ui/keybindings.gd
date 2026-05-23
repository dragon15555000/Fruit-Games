extends Control

const ACTIONS: Array = [
	["Lewo",    "_left"],
	["Prawo",   "_right"],
	["Skok",    "_jump"],
	["Strzał",  "_shoot"],
]

var _recording_button: Button = null
var _recording_action: String = ""
var _buttons: Dictionary = {}


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center = VBoxContainer.new()
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.set_offset(SIDE_LEFT,   -270)
	center.set_offset(SIDE_TOP,    -200)
	center.set_offset(SIDE_RIGHT,   270)
	center.set_offset(SIDE_BOTTOM,  200)
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	var title = Label.new()
	title.text = "Sterowanie"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	var hint = Label.new()
	hint.text = "Kliknij przycisk, potem naciśnij klawisz lub przycisk myszy. ESC anuluje."
	hint.add_theme_font_size_override("font_size", 9)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	center.add_child(hint)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(540, 230)
	center.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	scroll.add_child(grid)

	for h in ["Akcja", "Gracz 1", "Gracz 2", "Gracz 3", "Gracz 4"]:
		var lbl = Label.new()
		lbl.text = h
		lbl.custom_minimum_size = Vector2(105, 0)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", Color(0.75, 0.9, 1.0))
		grid.add_child(lbl)

	for action_def in ACTIONS:
		var action_label:  String = action_def[0]
		var action_suffix: String = action_def[1]

		var lbl = Label.new()
		lbl.text = action_label
		lbl.custom_minimum_size = Vector2(105, 34)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 11)
		grid.add_child(lbl)

		for p in range(1, 5):
			var action = "p%d%s" % [p, action_suffix]
			var btn    = Button.new()
			btn.custom_minimum_size = Vector2(105, 34)
			btn.text = _get_current_label(action)
			btn.add_theme_font_size_override("font_size", 10)
			btn.pressed.connect(_on_bind_pressed.bind(action, btn))
			grid.add_child(btn)
			_buttons[action] = btn

	var sep = HSeparator.new()
	center.add_child(sep)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	center.add_child(hbox)

	var reset_btn = Button.new()
	reset_btn.text = "Przywróć domyślne"
	reset_btn.custom_minimum_size = Vector2(160, 36)
	reset_btn.pressed.connect(_on_reset_pressed)
	hbox.add_child(reset_btn)

	var back_btn = Button.new()
	back_btn.text = "Wróć"
	back_btn.custom_minimum_size = Vector2(100, 36)
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)


func _on_bind_pressed(action: String, btn: Button) -> void:
	AudioManager.play_ui_click()
	if _recording_button:
		_recording_button.text = _get_current_label(_recording_action)
	_recording_button = btn
	_recording_action = action
	btn.text = "[ naciśnij ]"


func _input(event: InputEvent) -> void:
	if _recording_action == "":
		return
	if not (event is InputEventKey or event is InputEventMouseButton):
		return
	if event is InputEventKey:
		if not event.pressed:
			return
		if event.keycode == KEY_ESCAPE:
			_recording_button.text = _get_current_label(_recording_action)
			_recording_button = null
			_recording_action = ""
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and not event.pressed:
		return

	_clear_kb_mouse(_recording_action)
	InputMap.action_add_event(_recording_action, event)
	SettingsManager.save_keybinding(_recording_action, event)

	_recording_button.text = _get_event_label(event)
	_recording_button = null
	_recording_action = ""
	get_viewport().set_input_as_handled()


func _on_reset_pressed() -> void:
	AudioManager.play_ui_click()
	SettingsManager.reset_keybindings()
	for action in _buttons:
		_buttons[action].text = _get_current_label(action)


func _on_back_pressed() -> void:
	AudioManager.play_ui_click()
	if _recording_button:
		_recording_button.text = _get_current_label(_recording_action)
		_recording_button = null
		_recording_action = ""
	get_tree().change_scene_to_file("res://scenes/ui/options_menu.tscn")


func _clear_kb_mouse(action: String) -> void:
	for ev in InputMap.action_get_events(action).duplicate():
		if ev is InputEventKey or ev is InputEventMouseButton:
			InputMap.action_erase_event(action, ev)


func _get_current_label(action: String) -> String:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey or ev is InputEventMouseButton:
			return _get_event_label(ev)
	return "—"


func _get_event_label(event: InputEvent) -> String:
	if event is InputEventKey:
		var s = OS.get_keycode_string(event.keycode)
		if s == "":
			s = OS.get_keycode_string(event.physical_keycode)
		return s if s != "" else "?"
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:   return "LPM"
			MOUSE_BUTTON_RIGHT:  return "PPM"
			MOUSE_BUTTON_MIDDLE: return "ŚPM"
			_: return "Mysz%d" % event.button_index
	return "?"
