extends CanvasLayer
## Floating toast layer. Created by SceneSwitcher so it persists across scenes.

@onready var _panel: PanelContainer
@onready var _label: Label
var _tween: Tween

func _ready() -> void:
	layer = 100
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.offset_top = 24.0
	_panel.custom_minimum_size = Vector2(360, 56)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_panel.add_child(_label)
	_panel.modulate.a = 0.0
	_panel.hide()

func show_toast(text: String, duration := 2.0) -> void:
	if _label == null or _panel == null:
		return
	_label.text = text
	_panel.show()
	if _tween != null:
		_tween.kill()
	if UIAdapt.is_reduced_motion():
		_panel.modulate.a = 1.0
		await get_tree().create_timer(duration).timeout
		_panel.modulate.a = 0.0
		_panel.hide()
	else:
		_panel.modulate.a = 0.0
		_tween = create_tween()
		_tween.set_ease(Tween.EASE_OUT)
		_tween.tween_property(_panel, "modulate:a", 1.0, 0.2)
		_tween.tween_interval(duration)
		_tween.tween_property(_panel, "modulate:a", 0.0, 0.3)
		_tween.tween_callback(_panel.hide)
