extends Node
## NetSync — synchronizacja pozycji/prędkości w trybie sieciowym (~30 Hz).
## Tworzony programatycznie przez character.gd w _ready().
## Właściciel postaci wysyła pakiety; strony zdalne interpolują pozycję lerp.

const NET_LERP_SPEED: float = 20.0
const SYNC_INTERVAL:  float = 0.033  # ~30 Hz

var owner_id:        int     = 0
var _net_target_pos: Vector2 = Vector2.ZERO
var _sync_timer:     float   = 0.0
var _is_remote:      bool    = false

var is_remote: bool:
	get: return _is_remote
	set(value):
		_is_remote = value
		if value:
			_net_target_pos = get_parent().global_position


func setup(p_owner_id: int) -> void:
	owner_id = p_owner_id


# Interpolacja pozycji dla zdalnych postaci
func _process(delta: float) -> void:
	if not _is_remote:
		return
	var parent = get_parent()
	if is_instance_valid(parent):
		parent.global_position = parent.global_position.lerp(
			_net_target_pos, clampf(delta * NET_LERP_SPEED, 0.0, 1.0))


# Właściciel wysyła pakiet co SYNC_INTERVAL sekund
func _physics_process(delta: float) -> void:
	if owner_id == 0 or not Global.is_network_game or _is_remote:
		return
	_sync_timer += delta
	if _sync_timer >= SYNC_INTERVAL:
		_sync_timer = 0.0
		var parent = get_parent()
		_rpc_sync_pos.rpc(parent.position, parent.velocity)


@rpc("any_peer", "call_remote", "unreliable")
func _rpc_sync_pos(pos: Vector2, vel: Vector2) -> void:
	_net_target_pos    = pos
	get_parent().velocity = vel
