extends Control
## Settings screen: mirrors Android app settings (music, sfx, reduced motion, text speed).

@onready var _music: CheckBox = $VBox/MusicCheck
@onready var _sfx: CheckBox = $VBox/SfxCheck
@onready var _motion: CheckBox = $VBox/MotionCheck
@onready var _ai: CheckBox = $VBox/AiCheck
@onready var _speed: HSlider = $VBox/SpeedSlider
@onready var _speed_label: Label = $VBox/SpeedLabel

func _ready() -> void:
	_music.button_pressed = GameState.settings.get("music_enabled", true)
	_sfx.button_pressed = GameState.settings.get("sfx_enabled", true)
	_motion.button_pressed = GameState.settings.get("reduced_motion", false)
	_ai.button_pressed = GameState.settings.get("ai_enabled", false)
	_speed.value = 1.0 / float(GameState.settings.get("text_speed", 0.04))
	_update_speed_label()

func _update_speed_label() -> void:
	_speed_label.text = "Text speed: %.0f%%" % (_speed.value / 25.0 * 100.0)

func _on_music_toggled(on: bool) -> void:
	GameState.settings["music_enabled"] = on

func _on_sfx_toggled(on: bool) -> void:
	GameState.settings["sfx_enabled"] = on

func _on_motion_toggled(on: bool) -> void:
	GameState.settings["reduced_motion"] = on

func _on_ai_toggled(on: bool) -> void:
	GameState.settings["ai_enabled"] = on

func _on_speed_changed(value: float) -> void:
	GameState.settings["text_speed"] = clampf(1.0 / value, 0.01, 0.5)
	_update_speed_label()

func _on_back_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")
