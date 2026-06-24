extends Node
## CharacterVisuals — animacja sprite'a i etykieta nazwy nad postacią.
## Tworzony programatycznie przez character.gd w _ready().
## Potrzebuje referencji do FruitSprite i dostępu do velocity/is_on_floor
## przez get_parent() — zawsze jest dzieckiem CharacterBody2D.

var _anim_time:   float  = 0.0
var _recoil_time: float  = 0.0
var _sprite:      Node2D = null
var _base_scale:  Vector2 = Vector2.ONE
var _hp_scale:     float  = 1.0
var _critical_pulse: bool = false
var _flash_time:     float = 0.0
var _rot_active:     bool = false


func setup(char_name: String, sprite: Node2D) -> void:
	_sprite = sprite
	if is_instance_valid(_sprite):
		_base_scale = _sprite.scale
	_create_name_label(char_name)


func trigger_recoil() -> void:
	_recoil_time = 0.1


func set_hp_scaling(scale_factor: float) -> void:
	if not is_instance_valid(_sprite):
		return
	_hp_scale = clampf(scale_factor, 0.72, 1.0)


func set_critical_ogryzek(active: bool) -> void:
	_critical_pulse = active


func trigger_hit_flash() -> void:
	_flash_time = 0.12


func set_rot_active(active: bool) -> void:
	_rot_active = active


func _create_name_label(char_name: String) -> void:
	var lbl: Label = Label.new()
	lbl.text = char_name
	lbl.add_theme_font_size_override("font_size", 4)
	lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.8))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-12, -22)
	lbl.size     = Vector2(24, 8)
	get_parent().add_child(lbl)


func _process(delta: float) -> void:
	var parent = get_parent()
	if not is_instance_valid(parent) or parent._is_dying:
		return

	_anim_time += delta
	if _flash_time > 0.0:
		_flash_time -= delta
	if _recoil_time > 0.0:
		_recoil_time -= delta

	if not is_instance_valid(_sprite):
		return

	var base_anim_scale := Vector2.ONE
	_sprite.rotation = 0.0

	if not parent.is_on_floor():
		var stretch: float = clamp(absf(float(parent.velocity.y)) / 500.0, 0.0, 0.3)
		base_anim_scale = Vector2(1.0 - stretch * 0.5, 1.0 + stretch)
	else:
		if abs(parent.velocity.x) > 5.0:
			_sprite.rotation = sin(_anim_time * 20.0) * 0.15
			if parent.velocity.x < 0:
				base_anim_scale.x = -1.0
		else:
			base_anim_scale.y = 1.0 + sin(_anim_time * 5.0) * 0.03
			base_anim_scale.x = 1.0 - sin(_anim_time * 5.0) * 0.02

	if _recoil_time > 0.0:
		base_anim_scale *= (1.0 + _recoil_time * 2.0)

	if _critical_pulse:
		base_anim_scale *= 1.0 + sin(_anim_time * 12.0) * 0.05

	_sprite.scale = _base_scale * _hp_scale * base_anim_scale

	# Feedback kolorystyczny
	if _flash_time > 0.0:
		_sprite.modulate = Color(2.5, 2.5, 2.5) # Flash
	elif _rot_active:
		var pulse = (sin(_anim_time * 8.0) + 1.0) * 0.5
		_sprite.modulate = Color(1.0, 1.0, 1.0).lerp(Color(0.8, 0.3, 1.0), pulse * 0.6)
	else:
		_sprite.modulate = Color(1, 1, 1)
