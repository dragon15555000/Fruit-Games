extends Node

# ── Ścieżki dźwiękowe ─────────────────────────────────────────────────────────
const _SOUND_PATHS: Dictionary = {
	"shoot":    "res://assets/audio/shoot.wav",
	"hit":      "res://assets/audio/hit.wav",
	"jump":     "res://assets/audio/jump.wav",
	"death":    "res://assets/audio/death.wav",
	"ui_click": "res://assets/audio/ui_click.wav",
	"melee":    "res://assets/audio/melee.wav",
	"bgm":      "res://assets/audio/bgm.wav",
}

# bgm_combat jest opcjonalne — gdy brak pliku, combat player używa bgm jako fallback
const _BGM_COMBAT_PATH: String = "res://assets/audio/bgm_combat.wav"

# Dźwięki z losową zmianą tonacji — każde trafienie i skok brzmi unikalnie
const _PITCH_RANDOMIZED: Array = ["hit", "jump", "shoot"]
const _PITCH_VARIANCE:   float = 0.1  # ±10% tonacji

var _sounds: Dictionary = {}

# ── Odtwarzacze muzyki (równoległy crossfade) ─────────────────────────────────
var _ambient_player: AudioStreamPlayer
var _combat_player:  AudioStreamPlayer

var _target_ambient_db: float = -10.0
var _target_combat_db:  float = -80.0

# ── Licznik powrotu do trybu ambient ─────────────────────────────────────────
const COMBAT_REVERT_TIME: float = 5.0
var _combat_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_sounds()
	_setup_bgm_players()


func _load_sounds() -> void:
	for key in _SOUND_PATHS:
		var path: String = _SOUND_PATHS[key]
		if ResourceLoader.exists(path):
			_sounds[key] = load(path)
		else:
			push_warning("AudioManager: brak pliku '%s'" % path)


func _setup_bgm_players() -> void:
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Master"
	if _sounds.has("bgm"):
		_ambient_player.stream = _sounds["bgm"]
	_ambient_player.volume_db = _target_ambient_db
	add_child(_ambient_player)

	_combat_player = AudioStreamPlayer.new()
	_combat_player.bus = "Master"
	if ResourceLoader.exists(_BGM_COMBAT_PATH):
		_combat_player.stream = load(_BGM_COMBAT_PATH)
	elif _sounds.has("bgm"):
		_combat_player.stream = _sounds["bgm"]
	_combat_player.volume_db = _target_combat_db
	add_child(_combat_player)


func _process(delta: float) -> void:
	# Interpolacja głośności obu ścieżek
	if is_instance_valid(_ambient_player):
		_ambient_player.volume_db = lerp(_ambient_player.volume_db, _target_ambient_db, delta * 2.5)
	if is_instance_valid(_combat_player):
		_combat_player.volume_db  = lerp(_combat_player.volume_db,  _target_combat_db,  delta * 2.5)

	# Odliczanie powrotu do trybu ambient po ciszy
	if _combat_timer > 0.0:
		_combat_timer -= delta
		if _combat_timer <= 0.0:
			_set_ambient_mode()


# ── Publiczne API ─────────────────────────────────────────────────────────────

func play_sound(sound_name: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if not _sounds.has(sound_name):
		push_warning("AudioManager: nieznany dźwięk '%s'" % sound_name)
		return
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = _sounds[sound_name]
	# Losowa zmiana tonacji dla powtarzalnych dźwięków — eliminuje efekt monotonii
	if pitch_scale == 1.0 and sound_name in _PITCH_RANDOMIZED:
		player.pitch_scale = 1.0 + randf_range(-_PITCH_VARIANCE, _PITCH_VARIANCE)
	else:
		player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


func play_bgm() -> void:
	if is_instance_valid(_ambient_player) and not _ambient_player.playing and _ambient_player.stream:
		_ambient_player.play()
	if is_instance_valid(_combat_player) and not _combat_player.playing and _combat_player.stream:
		_combat_player.play()


func stop_bgm() -> void:
	if is_instance_valid(_ambient_player): _ambient_player.stop()
	if is_instance_valid(_combat_player):  _combat_player.stop()


## Wywołaj przy strzale/trafieniu — muzyka przechodzi w tryb walki.
## Po COMBAT_REVERT_TIME sekundach ciszy automatycznie wraca do ambient.
func notify_combat() -> void:
	_combat_timer = COMBAT_REVERT_TIME
	_set_combat_mode()


func play_ui_click() -> void:
	play_sound("ui_click")


# ── Prywatne przełączniki trybu ───────────────────────────────────────────────

func _set_combat_mode() -> void:
	_target_ambient_db = -25.0
	_target_combat_db  = -10.0


func _set_ambient_mode() -> void:
	_target_ambient_db = -10.0
	_target_combat_db  = -80.0
