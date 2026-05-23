extends Node
## ModifierState — stan modyfikatorów postaci.
## Tworzony programatycznie przez character.gd w _ready().
## ModifierSystem odczytuje i zapisuje pola przez proxy w character.gd.

var wax_active:              bool  = false
var second_fruit_used:       bool  = false
var rot_explosion_triggered: bool  = false
var streak_bonus_ready:      bool  = false
var preservative_timer:      float = 0.0
var regen_timer:             float = 2.0
var armor_flat:              float = 0.0
var seed_collector_bonus:    float = 0.0
var streak_count:            int   = 0

var is_slowed:  bool  = false
var slow_timer: float = 0.0

var poison_stack_timers: Array[float] = []
var poison_tick_timer:   float        = 0.0

var poison_zone_scene: Resource = null
var poison_spawn_timer: float   = 0.0

var _char_name: String = ""


func setup(char_name: String) -> void:
	_char_name = char_name
	if ResourceLoader.exists("res://scenes/effects/poison_zone.tscn"):
		poison_zone_scene = load("res://scenes/effects/poison_zone.tscn")


func apply_slow() -> void:
	if preservative_timer > 0.0:
		return
	is_slowed  = true
	slow_timer = 3.0


func apply_poison() -> void:
	if preservative_timer > 0.0:
		return
	poison_stack_timers.append(3.0)


func _physics_process(delta: float) -> void:
	var parent = get_parent()
	if not is_instance_valid(parent) or parent._is_dying:
		return

	if preservative_timer > 0.0:
		preservative_timer -= delta

	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0.0:
			is_slowed = false

	if poison_stack_timers.size() > 0:
		for i in range(poison_stack_timers.size() - 1, -1, -1):
			poison_stack_timers[i] -= delta
			if poison_stack_timers[i] <= 0.0:
				poison_stack_timers.remove_at(i)
		poison_tick_timer -= delta
		if poison_tick_timer <= 0.0:
			poison_tick_timer = 1.0
			var stacks = poison_stack_timers.size()
			if stacks > 0:
				Global.take_damage(_char_name, 5.0 * stacks, "🧪 Trucizna")
				Global.spawn_particles(parent.global_position, Color(0.5, 0.0, 0.8), 10)
