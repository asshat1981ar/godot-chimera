extends Control

@onready var _continue_button: Button = $VBoxContainer/ContinueButton
@onready var _no_save_label: Label = $VBoxContainer/NoSaveLabel
@onready var _confirm_popup: Control = $NewGameConfirm
@onready var _confirm_summary: RichTextLabel = $NewGameConfirm/Panel/Margin/VBox/SummaryLabel
@onready var _confirm_cancel: Button = $NewGameConfirm/Panel/Margin/VBox/ButtonRow/CancelButton
@onready var _confirm_ok: Button = $NewGameConfirm/Panel/Margin/VBox/ButtonRow/ConfirmButton

func _ready() -> void:
	GameState.current_phase = GameState.Phase.MENU
	# Enable continue if an auto save or legacy save exists.
	var has_save := FileAccess.file_exists(GameState.SAVE_PATH) or GameState.list_save_slots().size() > 0
	_continue_button.disabled = not has_save
	_continue_button.modulate.a = 0.5 if _continue_button.disabled else 1.0
	_no_save_label.visible = not has_save
	_confirm_popup.hide()
	_setup_focus()

func _setup_focus() -> void:
	# Controller / keyboard navigation: start focus on the first actionable button.
	var first: Button = $VBoxContainer/NewGameButton
	first.focus_mode = Control.FOCUS_ALL
	first.grab_focus()
	for btn in [$VBoxContainer/NewGameButton, $VBoxContainer/ContinueButton,
			$VBoxContainer/SettingsButton, $VBoxContainer/QuitButton]:
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_neighbor_top = NodePath("..")
		btn.focus_neighbor_bottom = NodePath("..")
		btn.focus_neighbor_left = NodePath("..")
		btn.focus_neighbor_right = NodePath("..")
	# Confirm popup focus ring.
	_confirm_cancel.focus_mode = Control.FOCUS_ALL
	_confirm_ok.focus_mode = Control.FOCUS_ALL
	_confirm_cancel.focus_neighbor_left = _confirm_ok.get_path()
	_confirm_ok.focus_neighbor_right = _confirm_cancel.get_path()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		if _confirm_popup.visible:
			_confirm_popup.hide()
			_setup_focus()
		else:
			GameState.save_game("auto")
			get_tree().quit()
	elif event.is_action_pressed("ui_accept") and _confirm_popup.visible:
		get_viewport().set_input_as_handled()
		_on_new_game_confirm_pressed()

func _on_new_game_pressed() -> void:
	if not _has_any_save():
		GameState.new_game()
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
		return
	_confirm_summary.text = _save_summary()
	_confirm_popup.show()

func _on_continue_pressed() -> void:
	if GameState.load_game("auto"):
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_settings_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/settings_screen.tscn")

func _on_quit_pressed() -> void:
	GameState.save_game("auto")
	get_tree().quit()

func _on_new_game_cancel_pressed() -> void:
	_confirm_popup.hide()
	_setup_focus()

func _on_new_game_confirm_pressed() -> void:
	_confirm_popup.hide()
	GameState.new_game()
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _has_any_save() -> bool:
	return FileAccess.file_exists(GameState.SAVE_PATH) or GameState.list_save_slots().size() > 0

func _save_summary() -> String:
	var slot := _find_first_slot()
	if slot.is_empty():
		return "An existing save was found."
	var file := FileAccess.open(slot, FileAccess.READ)
	if not file:
		return "An existing save was found."
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		var data: Dictionary = parsed
		var node: String = data.get("current_node_id", "unknown")
		var act: int = int(data.get("current_act", 1))
		var party_size: int = data.get("party", []).size()
		var ts: int = int(data.get("timestamp", 0))
		var when := Time.get_datetime_string_from_unix_time(ts) if ts > 0 else "unknown"
		return "Existing save found.\n[ul]\n• Act %d\n• Last node: %s\n• Party: %d\n• Saved: %s\n[/ul]\nStarting a new game will overwrite this save." % [act, node, party_size, when]
	return "Existing save found. Starting a new game will overwrite it."

func _find_first_slot() -> String:
	if FileAccess.file_exists(GameState.SAVE_PATH):
		return GameState.SAVE_PATH
	for s in GameState.list_save_slots():
		var p: String = "user://save_%s.json" % s
		if FileAccess.file_exists(p):
			return p
	return ""
