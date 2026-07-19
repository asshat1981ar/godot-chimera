extends Node
## Global scene transition manager with a parchment fade.

@onready var _tree := get_tree()
var _loading := false
var pending_payload: Dictionary = {}

func switch_to(path: String, payload: Dictionary = {}) -> void:
	if _loading:
		return
	_loading = true
	pending_payload = payload.duplicate()
	EventBus.emit_ui_request(path, pending_payload)
	await _tree.create_timer(0.15).timeout
	_tree.change_scene_to_file(path)
	_loading = false

func switch_to_packed(scene: PackedScene, payload: Dictionary = {}) -> void:
	if _loading:
		return
	_loading = true
	pending_payload = payload.duplicate()
	await _tree.create_timer(0.15).timeout
	_tree.change_scene_to_packed(scene)
	_loading = false

func quit_to_menu() -> void:
	GameState.save_game()
	switch_to("res://scenes/screens/main_menu.tscn")
