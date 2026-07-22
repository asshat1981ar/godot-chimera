extends Control
## Settings screen: mirrors Android app settings (music, sfx, reduced motion, text speed).
## Hidden build label: tap it 5 times to open the DevPanel.

@onready var _music: CheckBox = $VBox/MusicCheck
@onready var _sfx: CheckBox = $VBox/SfxCheck
@onready var _motion: CheckBox = $VBox/MotionCheck
@onready var _haptics: CheckBox = $VBox/HapticsCheck
@onready var _ai: CheckBox = $VBox/AiCheck
@onready var _speed: HSlider = $VBox/SpeedSlider
@onready var _speed_label: Label = $VBox/SpeedLabel
@onready var _build_label: Label = $VBox/BuildLabel
@onready var _dev_panel: Control = $DevPanel

const DEV_TAP_THRESHOLD := 5
const VERSION := "0.3.0"

var _build_taps := 0

func _ready() -> void:
	_music.button_pressed = GameState.settings.get("music_enabled", true)
	_sfx.button_pressed = GameState.settings.get("sfx_enabled", true)
	_motion.button_pressed = GameState.settings.get("reduced_motion", false)
	_haptics.button_pressed = GameState.settings.get("haptics_enabled", true)
	_ai.button_pressed = GameState.settings.get("ai_enabled", false)
	_speed.value = 1.0 / float(GameState.settings.get("text_speed", 0.04))
	_update_speed_label()
	_build_label.text = "Build %s" % VERSION
	_build_label.gui_input.connect(_on_build_label_input)
	_dev_panel.hide()
	_sync_dev_panel()
	_setup_focus()

func _setup_focus() -> void:
	var controls: Array = [_music, _sfx, _motion, _haptics, _ai, _speed, $VBox/BackButton]
	for i in range(controls.size()):
		var c: Control = controls[i]
		c.focus_mode = Control.FOCUS_ALL
		if i > 0:
			c.focus_neighbor_top = controls[i - 1].get_path()
		if i < controls.size() - 1:
			c.focus_neighbor_bottom = controls[i + 1].get_path()
	controls[0].grab_focus()

func _update_speed_label() -> void:
	_speed_label.text = "Text speed: %.0f%%" % (_speed.value / 25.0 * 100.0)

func _on_music_toggled(on: bool) -> void:
	GameState.settings["music_enabled"] = on

func _on_sfx_toggled(on: bool) -> void:
	GameState.settings["sfx_enabled"] = on

func _on_motion_toggled(on: bool) -> void:
	GameState.settings["reduced_motion"] = on

func _on_haptics_toggled(on: bool) -> void:
	GameState.settings["haptics_enabled"] = on

func _on_ai_toggled(on: bool) -> void:
	GameState.settings["ai_enabled"] = on

func _on_speed_changed(value: float) -> void:
	GameState.settings["text_speed"] = clampf(1.0 / value, 0.01, 0.5)
	_update_speed_label()

func _on_back_pressed() -> void:
	GameState.save_game("auto")
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		GameState.save_game("auto")
		SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")

func _on_build_label_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_build_taps += 1
		if _build_taps >= DEV_TAP_THRESHOLD:
			_dev_panel.show()
			_sync_dev_panel()

func _sync_dev_panel() -> void:
	if not _dev_panel:
		return
	var god_mode: CheckBox = _dev_panel.get_node_or_null("Panel/Margin/VBox/GodModeCheck")
	if god_mode:
		god_mode.button_pressed = GameState.has_dev_flag("god_mode")

func _on_jump_act_pressed() -> void:
	var next_act: int = mini(GameState.current_act + 1, 3)
	GameState.advance_act(next_act)
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_unlock_nodes_pressed() -> void:
	for node in Content.map_nodes(GameState.current_act):
		var id: String = node.get("id", "")
		if not id.is_empty() and not GameState.unlocked_nodes.has(id):
			GameState.unlocked_nodes.append(id)
	EventBus.emit_state_changed("unlocked_nodes", GameState.unlocked_nodes.duplicate())

func _on_grant_items_pressed() -> void:
	Simulation.grant_item("memory_dust", 10)
	Simulation.grant_item("purified_coral", 5)
	Simulation.grant_item("hollow_iron", 5)

func _on_god_mode_toggled(on: bool) -> void:
	GameState.set_dev_flag("god_mode", on)

func _on_reset_onboarding_pressed() -> void:
	GameState.settings["has_seen_onboarding"] = false
	GameState.save_game("auto")

func _on_force_save_pressed() -> void:
	GameState.save_game("auto")

func _on_close_dev_panel_pressed() -> void:
	_dev_panel.hide()
	_setup_focus()

func is_dev_panel_visible() -> bool:
	return _dev_panel and _dev_panel.visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		if _dev_panel.visible:
			_dev_panel.hide()
			_setup_focus()
		else:
			GameState.save_game("auto")
			SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")
