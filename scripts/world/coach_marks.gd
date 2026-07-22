extends Control
## Sequential dimmed-overlay coach marks for first-time map users.
## Shows 4 steps: pan/zoom, tap node, Travel, quick-bar. Tap or press to advance.

signal dismissed

const STEP_COUNT := 4

var _step := 0
var _tween: Tween

@onready var _blocker: ColorRect = $Blocker
@onready var _panel: PanelContainer = $Panel
@onready var _title: Label = $Panel/Margin/VBox/Title
@onready var _body: RichTextLabel = $Panel/Margin/VBox/Body
@onready var _hint: Label = $Panel/Margin/VBox/Hint

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_blocker.set_anchors_preset(PRESET_FULL_RECT)
	_blocker.color = Color(0.0, 0.0, 0.0, 0.0)
	_panel.set_anchors_preset(PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(560, 200)
	_show_step()
	_animate_in()

func _show_step() -> void:
	match _step:
		0:
			_title.text = "Move the map"
			_body.text = "Drag with one finger to pan.\nPinch with two fingers to zoom in and out."
		1:
			_title.text = "Visit a location"
			_body.text = "Tap a glowing ruin on the map to travel there and enter its scene."
		2:
			_title.text = "Travel"
			_body.text = "Each node has a story. Completed nodes fade to green."
		3:
			_title.text = "Quick bar"
			_body.text = "Use the buttons on the right for Camp, Party, Journal, and Settings."
		_:
			_title.text = ""
			_body.text = ""
	_hint.text = "Tap or press any key to continue (%d/%d)" % [_step + 1, STEP_COUNT]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_back"):
		_advance()
		get_viewport().set_input_as_handled()
		event.set_handled()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_advance()
	elif event is InputEventMouseButton and event.pressed:
		_advance()

func _advance() -> void:
	_step += 1
	if _step >= STEP_COUNT:
		_animate_out()
	else:
		_show_step()

func _animate_in() -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(_blocker, "color:a", 0.6, 0.25)
	_tween.parallel().tween_property(_panel, "modulate:a", 1.0, 0.25).from(0.0)

func _animate_out() -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.tween_property(_blocker, "color:a", 0.0, 0.2)
	_tween.parallel().tween_property(_panel, "modulate:a", 0.0, 0.2)
	await _tween.finished
	dismissed.emit()
	queue_free()
