extends Node
## RotComponent — zarządza czasem gnicia postaci.
## Tworzony programatycznie przez character.gd w _ready().
## character.gd wystawia proxy rot_time_remaining → wszystkie zewnętrzne
## odwołania (ModifierSystem) działają bez zmian.

const BASE_ROT_TIME: float = 210.0

var rot_time_remaining: float = BASE_ROT_TIME
var _char_name: String = ""
var _rot_bar: ProgressBar = null


func setup(char_name: String) -> void:
	_char_name = char_name
	rot_time_remaining = BASE_ROT_TIME + Global.rot_bonus.get(char_name, 0.0)

	_rot_bar = ProgressBar.new()
	_rot_bar.max_value = BASE_ROT_TIME
	_rot_bar.value = rot_time_remaining
	_rot_bar.show_percentage = false
	_rot_bar.size = Vector2(16, 2)
	_rot_bar.position = Vector2(-8, -17)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.2, 0.8, 0.2)
	_rot_bar.add_theme_stylebox_override("fill", sb)
	get_parent().add_child(_rot_bar)


func _physics_process(delta: float) -> void:
	var parent = get_parent()
	if not is_instance_valid(parent) or parent._is_dying:
		return

	rot_time_remaining -= delta

	if _rot_bar:
		_rot_bar.value = rot_time_remaining
		# Pasek zmienia kolor: zielony → żółty → czerwony
		var t = clampf(rot_time_remaining / BASE_ROT_TIME, 0.0, 1.0)
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(1.0 - t, t * 0.8, 0.1 * t)
		_rot_bar.add_theme_stylebox_override("fill", sb)

	if rot_time_remaining <= 0.0:
		Global.take_damage(_char_name, 9999.0, "🦠 Zgnilizna")
