extends Node
## Global scene transition manager with a parchment fade and toast layer.

const FADE_DURATION := 0.35

@onready var _tree := get_tree()
var _loading := false
var pending_payload: Dictionary = {}
var _overlay: ColorRect

func _ready() -> void:
	# Full-screen fade overlay survives scene changes because it lives on root.
	# Defer add_child so we don't collide with root's own child setup during autoload init.
	_overlay = ColorRect.new()
	_overlay.color = Color(0.06, 0.05, 0.04, 0.0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tree.root.call_deferred("add_child", _overlay)
	_tree.root.size_changed.connect(_on_root_size_changed)

func switch_to(path: String, payload: Dictionary = {}) -> void:
	if _loading:
		return
	_loading = true
	pending_payload = payload.duplicate()
	EventBus.emit_ui_request(path, pending_payload)
	await _fade_in()
	_tree.change_scene_to_file(path)
	await _tree.create_timer(0.05).timeout
	await _fade_out()
	_loading = false

func switch_to_packed(scene: PackedScene, payload: Dictionary = {}) -> void:
	if _loading:
		return
	_loading = true
	pending_payload = payload.duplicate()
	await _fade_in()
	_tree.change_scene_to_packed(scene)
	await _tree.create_timer(0.05).timeout
	await _fade_out()
	_loading = false

func quit_to_menu() -> void:
	GameState.save_game()
	switch_to("res://scenes/screens/main_menu.tscn")

func toast(text: String, duration := 2.0) -> void:
	ToastLayer.show_toast(text, duration)

func _fade_in() -> void:
	if UIAdapt.is_reduced_motion():
		_overlay.color.a = 1.0
		return
	var tw := create_tween()
	tw.tween_property(_overlay, "color:a", 1.0, FADE_DURATION)
	await tw.finished

func _fade_out() -> void:
	if UIAdapt.is_reduced_motion():
		_overlay.color.a = 0.0
		return
	var tw := create_tween()
	tw.tween_property(_overlay, "color:a", 0.0, FADE_DURATION)
	await tw.finished

func _on_root_size_changed() -> void:
	# Keep the overlay covering the full window on orientation/resize changes.
	if _overlay:
		_overlay.size = _tree.root.size
