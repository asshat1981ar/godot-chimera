extends Control
## Credits screen. Lists team and attribution, returns to main menu.

@onready var _text: RichTextLabel = $VBox/Text
@onready var _back: Button = $VBox/BackButton

func _ready() -> void:
	_text.text = """[center][b]Chimera: Ashes of the Hollow King[/b][/center]

A deterministic narrative RPG rebuilt in Godot 4.

Team godot-chimera:
  • Lead architecture & integration
  • Code analyst — systems, saves, combat, crafting, audio
  • UX designer — mobile UX & UI engineering
  • Narrative designer — storyline, dialogue, lore
  • Market researcher — competitor analysis

Placeholder audio generated in-engine.
Map tiles, portraits, and item icons by the art pipeline.

Thank you for walking into the ash."""
	_back.pressed.connect(_on_back)

func _on_back() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")
