extends Control

@onready var _continue_button: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	GameState.current_phase = GameState.Phase.MENU
	# Only enable continue if an existing save is present.
	_continue_button.disabled = not FileAccess.file_exists(GameState.SAVE_PATH)
	_continue_button.modulate.a = 0.5 if _continue_button.disabled else 1.0

func _on_new_game_pressed() -> void:
	GameState.new_game()
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_continue_pressed() -> void:
	if GameState.load_game():
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_settings_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/settings_screen.tscn")

func _on_quit_pressed() -> void:
	GameState.save_game()
	get_tree().quit()
