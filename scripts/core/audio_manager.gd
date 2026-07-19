extends Node
## Audio manager: placeholder playback and settings-aware muting.
## Real assets can replace the generated WAVs without code changes.

const UI_CLICK_PATH := "res://assets/audio/ui_click.wav"
const MUSIC_PATH := "res://assets/audio/music_menu.wav"

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var _music: AudioStreamPlayer = null
var _sfx: AudioStreamPlayer = null

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = BUS_MUSIC
	_music.name = "MusicPlayer"
	add_child(_music)

	_sfx = AudioStreamPlayer.new()
	_sfx.bus = BUS_SFX
	_sfx.name = "SfxPlayer"
	add_child(_sfx)

	apply_settings()
	EventBus.state_changed.connect(_on_state_changed)

func _on_state_changed(key: String, _value: Variant) -> void:
	if key == "settings":
		apply_settings()

func apply_settings() -> void:
	var music_enabled: bool = bool(GameState.settings.get("music_enabled", true))
	var sfx_enabled: bool = bool(GameState.settings.get("sfx_enabled", true))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_MUSIC), not music_enabled)
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS_SFX), not sfx_enabled)
	if music_enabled and _music and _music.stream == null:
		_play_stream(_music, MUSIC_PATH, true)

func play_ui_click() -> void:
	if _sfx:
		_play_stream(_sfx, UI_CLICK_PATH, false)

func _play_stream(player: AudioStreamPlayer, path: String, loop: bool) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	player.stream = stream
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	player.play()
