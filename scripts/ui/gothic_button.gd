extends Button
## Theme helper for parchment/gothic buttons. Applies ink-wash accent on focus
## and a small press pulse, unless reduced motion is enabled.

@export var accent_color: Color = Color(0.62, 0.52, 0.40, 1)
@export var play_click_sound: bool = true

func _ready() -> void:
	focus_entered.connect(_on_focus)
	focus_exited.connect(_on_unfocus)
	pressed.connect(_on_pressed)
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	# Ensure every primary button is legally touchable on a 720p logical canvas.
	if custom_minimum_size.y < 84.0:
		custom_minimum_size.y = 84.0

func _on_focus() -> void:
	modulate = Color(1.1, 1.05, 1.0, 1)
	# Godot's built-in focus style handles the visible border; modulate gives a warm glow.

func _on_unfocus() -> void:
	modulate = Color.WHITE

func _on_pressed() -> void:
	if play_click_sound and AudioManager:
		AudioManager.play_ui_click()
	Haptics.play(12)

func _on_down() -> void:
	if UIAdapt.is_reduced_motion():
		return
	scale = Vector2(0.96, 0.96)

func _on_up() -> void:
	if UIAdapt.is_reduced_motion():
		return
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)
