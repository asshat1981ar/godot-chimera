extends Button
## Theme helper for parchment/gothic buttons. Applies ink-wash accent on focus.

@export var accent_color: Color = Color(0.62, 0.52, 0.40, 1)

func _ready() -> void:
	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)

func _on_focus() -> void:
	modulate = Color(1.1, 1.05, 1.0, 1)

func _on_unfocus() -> void:
	modulate = Color.WHITE
