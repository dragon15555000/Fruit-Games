extends Node
## RotComponent — odliczanie czasu gnicia i wizualny pasek.
## Tworzony programatycznie przez character.gd w _ready().

const BASE_ROT_TIME: float = 210.0

var rot_time_remaining: float = BASE_ROT_TIME
var _rot_bar: ProgressBar     = null
var _char_name: String        = ""
var _bar_fill: StyleBoxFlat   = null


func setup(char_name: String) -> void:
	_char_name         = char_name
	rot_time_remaining = BASE_ROT_TIME + Global.rot_bonus.get(char_name, 0.0)

	_rot_bar = ProgressBar.new()
	_rot_bar.max_value      = rot_time_remaining
	_rot_bar.value          = rot_time_remaining
	_rot_bar.show_percentage = false
	_rot_bar.size            = Vector2(16, 2)
	_rot_bar.position        = Vector2(-8, -17)

	_bar_fill = StyleBoxFlat.new()
	_bar_fill.bg_color = Color(0.2, 0.8, 0.2)
	_rot_bar.add_theme_stylebox_override("fill", _bar_fill)

	get_parent().add_child(_rot_bar)


func _physics_process(delta: float) -> void:
	var parent = get_parent()
	if not is_instance_valid(parent) or parent._is_dying:
		return

	rot_time_remaining -= delta

	if _rot_bar:
		_rot_bar.value = rot_time_remaining
		var t = clampf(rot_time_remaining / BASE_ROT_TIME, 0.0, 1.0)
		if t > 0.5:
			_bar_fill.bg_color = Color(1.0 - (1.0 - t) * 2.0, 0.8, 0.2)
		else:
			_bar_fill.bg_color = Color(1.0, t * 2.0 * 0.8, 0.2)

	if rot_time_remaining <= 0.0:
		if parent.has_method("apply_damage"):
			parent.apply_damage(9999.0, "🦠 Zgnilizna")
		else:
			Global.take_damage(_char_name, 9999.0, "🦠 Zgnilizna")

