extends CharacterBody2D
## character.gd — uniwersalny skrypt postaci
## Ustaw character_name w Inspektorze Godota dla każdej sceny postaci.
## Logika modyfikatorów → ModifierSystem.gd

@export var character_name: String = "Strawberry"

@onready var CoyoteTimer:      Timer       = $Coyote
@onready var JumpBufferTimer:  Timer       = $JumpBufferTimer
@onready var Reloading:        Timer       = $ReloadTime
@onready var health_bar:       ProgressBar = $HealthBar
@onready var fruit_sprite:     Node2D      = $FruitSprite

var _visuals: Node = null

signal shoot(pos: Vector2, dir: Vector2)

# Input — ustawiane przez main_game.gd po spawnie
var action_left:  String = ""
var action_right: String = ""
var action_jump:  String = ""
var action_shoot: String = ""

# Sieć — delegowane do NetSync (tworzony w _ready)
var _net_sync: Node = null

var network_owner_id: int:
	get: return _net_sync.owner_id if _net_sync else 0
	set(v): if _net_sync: _net_sync.owner_id = v
var is_remote: bool:
	get: return _net_sync.is_remote if _net_sync else false
	set(v): if _net_sync: _net_sync.is_remote = v

var max_speed:  float = 0.0
var base_speed: float = 0.0

# ── KLUCZOWA FLAGA — zapobiega wielokrotnemu wywołaniu die() ─────────────────
# Problem: queue_free() nie usuwa węzła natychmiast. _physics_process może być
# wywołany jeszcze raz po die() zanim węzeł faktycznie zniknie. Bez tej flagi
# die() wywołuje się wielokrotnie → death_order ma duplikaty → crash w ranking.
var _is_dying: bool = false

# ── Stan modów — delegowany do ModifierState (tworzony w _ready) ─────────────
var _modifier_state: Node = null

# Proxy do pól ModifierState — ModifierSystem i inne zewnętrzne skrypty
# korzystają z tych właściwości bez wiedzy o wewnętrznej strukturze.
var wax_active: bool:
	get: return _modifier_state.wax_active if _modifier_state else false
	set(v): if _modifier_state: _modifier_state.wax_active = v
var second_fruit_used: bool:
	get: return _modifier_state.second_fruit_used if _modifier_state else false
	set(v): if _modifier_state: _modifier_state.second_fruit_used = v
var rot_explosion_triggered: bool:
	get: return _modifier_state.rot_explosion_triggered if _modifier_state else false
	set(v): if _modifier_state: _modifier_state.rot_explosion_triggered = v
var streak_bonus_ready: bool:
	get: return _modifier_state.streak_bonus_ready if _modifier_state else false
	set(v): if _modifier_state: _modifier_state.streak_bonus_ready = v
var preservative_timer: float:
	get: return _modifier_state.preservative_timer if _modifier_state else 0.0
	set(v): if _modifier_state: _modifier_state.preservative_timer = v
var regen_timer: float:
	get: return _modifier_state.regen_timer if _modifier_state else 2.0
	set(v): if _modifier_state: _modifier_state.regen_timer = v
var armor_flat: float:
	get: return _modifier_state.armor_flat if _modifier_state else 0.0
	set(v): if _modifier_state: _modifier_state.armor_flat = v
var seed_collector_bonus: float:
	get: return _modifier_state.seed_collector_bonus if _modifier_state else 0.0
	set(v): if _modifier_state: _modifier_state.seed_collector_bonus = v
var streak_count: int:
	get: return _modifier_state.streak_count if _modifier_state else 0
	set(v): if _modifier_state: _modifier_state.streak_count = v
var is_slowed: bool:
	get: return _modifier_state.is_slowed if _modifier_state else false
var poison_zone_scene: Resource:
	get: return _modifier_state.poison_zone_scene if _modifier_state else null
var poison_spawn_timer: float:
	get: return _modifier_state.poison_spawn_timer if _modifier_state else 0.0
	set(v): if _modifier_state: _modifier_state.poison_spawn_timer = v

# ── Gnicie — delegowane do RotComponent (tworzony w _ready) ──────────────────
var _rot_component: Node = null

var rot_time_remaining: float:
	get: return _rot_component.rot_time_remaining if _rot_component else 0.0
	set(v):
		if _rot_component: _rot_component.rot_time_remaining = v

# ── Fizyka ────────────────────────────────────────────────────────────────────
var coyote_time_activated: bool  = false
const JUMP_HEIGHT:  float = -270.0
var   gravity:      float = 15.0
const MAX_GRAVITY:  float = 20.0
const ACCELERATION: float = 16.0
const FRICTION:     float = 18.0


# ─────────────────────────────────────────────
# READY
# ─────────────────────────────────────────────
func _ready() -> void:
	if Global.characters.is_empty():
		Global.reset_all()

	base_speed = float(Global.characters[character_name]["speed"])
	max_speed  = base_speed

	# Aplikuj mody startowe (on_apply) — prędkość, HP, flagi
	ModifierSystem.apply_on_ready(character_name, self)

	# ModifierState — przed RotComponent żeby preservative_timer był gotowy
	_modifier_state = preload("res://scripts/characters/modifier_state.gd").new()
	_modifier_state.name = "ModifierState"
	add_child(_modifier_state)
	_modifier_state.setup(character_name)

	# RotComponent — po apply_on_ready żeby antirot zdążył zapisać bonus
	_rot_component = preload("res://scripts/characters/rot_component.gd").new()
	_rot_component.name = "RotComponent"
	add_child(_rot_component)
	_rot_component.setup(character_name)

	# CharacterVisuals — etykieta nazwy + animacja sprite'a
	_visuals = preload("res://scripts/characters/character_visuals.gd").new()
	_visuals.name = "CharacterVisuals"
	add_child(_visuals)
	_visuals.setup(character_name, fruit_sprite)

	# NetSync — synchronizacja sieciowa pozycji/prędkości
	_net_sync = preload("res://scripts/characters/net_sync.gd").new()
	_net_sync.name = "NetSync"
	add_child(_net_sync)
	_net_sync.setup(0)  # owner_id ustawia main_game.gd po spawnie

	Reloading.wait_time  = Global.characters[character_name]["fire_rate"]
	health_bar.max_value = Global.base_characters[character_name]["hp"]
	health_bar.value     = Global.characters[character_name]["hp"]

	add_to_group("Players")  # wymagane przez ModifierSystem._find_character()


# ─────────────────────────────────────────────
# INPUT
# ─────────────────────────────────────────────
func get_input() -> void:
	if action_shoot == "":  # bot — sterowany przez BotController
		return
	if not Input.is_action_just_pressed(action_shoot):
		return
	if not Reloading.is_stopped():
		return
	shoot.emit(position, get_local_mouse_position().normalized())
	Reloading.start()
	if _visuals: _visuals.trigger_recoil()


# ─────────────────────────────────────────────
# PUBLICZNE API
# ─────────────────────────────────────────────

func apply_slow()   -> void: if _modifier_state: _modifier_state.apply_slow()
func apply_poison() -> void: if _modifier_state: _modifier_state.apply_poison()

## Główna brama obrażeń — wywoływana z bullet.gd.
## Zwraca faktyczne obrażenia po modyfikacjach (0.0 = zablokowane).
func receive_damage(raw_dmg: float, attacker_name: String = "") -> float:
	# Jeśli już umieramy, ignoruj dalsze obrażenia
	if _is_dying:
		return 0.0

	var dmg = ModifierSystem.apply_on_receive(character_name, raw_dmg, attacker_name)
	if dmg <= 0.0:
		return 0.0

	AudioManager.play_sound("hit")
	Global.spawn_particles(global_position, Color(1, 0, 0), 5)

	# Sprawdź czy cios byłby śmiertelny
	var cur_hp = float(Global.characters[character_name]["hp"])
	if cur_hp - dmg <= 0.0:
		if ModifierSystem.apply_on_lethal(character_name):
			return 0.0  # przeżył dzięki second_fruit

	return dmg

## Śmierć — wywołaj tylko przez tę funkcję, nigdy queue_free() bezpośrednio.
func die() -> void:
	if _is_dying:
		return
	_is_dying = true

	AudioManager.play_sound("death")
	if Global.main_game:
		Global.main_game.add_shake(15.0)
	Global.spawn_particles(global_position, Color(0.5, 0, 0), 20)

	Global.alive[character_name] = false
	Global.death_order.append(character_name)

	queue_free()


# ─────────────────────────────────────────────
# PHYSICS PROCESS
# ─────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	# W trybie sieciowym: jeśli to nie nasza postać, tylko aktualizuj HP bar
	if Global.is_network_game and network_owner_id != 0:
		if multiplayer.get_unique_id() != network_owner_id:
			health_bar.value = Global.characters[character_name]["hp"]
			return

	# Sprawdź HP — jeśli <= 0 to śmierć
	if Global.characters[character_name]["hp"] <= 0:
		die()
		return

	health_bar.value = Global.characters[character_name]["hp"]

	# Mody pasywne
	ModifierSystem.apply_passive(character_name, delta, self)

	get_input()

	# Ruch poziomy (pomijany dla botów — BotController steruje velocity)
	var cur_max = max_speed * 0.4 if is_slowed else max_speed
	if action_left != "":
		var x_input    = Input.get_action_strength(action_right) - Input.get_action_strength(action_left)
		var vel_weight = delta * (ACCELERATION if x_input else FRICTION)
		velocity.x     = lerp(velocity.x, x_input * cur_max, vel_weight)

	# Grawitacja i coyote time
	if is_on_floor():
		coyote_time_activated = false
		gravity = lerp(gravity, 12.0, 12.0 * delta)
	else:
		if CoyoteTimer.is_stopped() and not coyote_time_activated:
			CoyoteTimer.start()
			coyote_time_activated = true
		if action_jump != "" and Input.is_action_just_released(action_jump) or is_on_ceiling():
			velocity.y *= 0.5
		gravity = lerp(gravity, MAX_GRAVITY, 12.0 * delta)

	# Jump buffer (tylko gracze)
	if action_jump != "" and Input.is_action_just_pressed(action_jump) and JumpBufferTimer.is_stopped():
		JumpBufferTimer.start()

	if not JumpBufferTimer.is_stopped() and (not CoyoteTimer.is_stopped() or is_on_floor()):
		velocity.y = JUMP_HEIGHT
		JumpBufferTimer.stop()
		CoyoteTimer.stop()
		coyote_time_activated = true
		AudioManager.play_sound("jump")

	# Head nudge — pozwala wejść pod niskie platformy
	if velocity.y < JUMP_HEIGHT / 2.0:
		var hc = [
			$Left_HeadNudge.is_colliding(),
			$Left_Head_Nudge2.is_colliding(),
			$Right_Head_Nudge3.is_colliding(),
			$Right_Head_Nudge4.is_colliding()
		]
		if hc.count(true) == 1:
				if hc[0] or hc[1]: global_position.x += 1.75
				if hc[2] or hc[3]: global_position.x -= 1.75

	# Wall climb nudge
	if velocity.y > -30 and velocity.y < -5 and abs(velocity.x) > 3:
		if $RayCast2D3.is_colliding() and not $RayCast2D4.is_colliding() and velocity.x < 0:
			velocity.y += JUMP_HEIGHT / 3.25
		if $RayCast2D.is_colliding()  and not $RayCast2D2.is_colliding() and velocity.x > 0:
			velocity.y += JUMP_HEIGHT / 3.25

	velocity.y += gravity
	move_and_slide()
