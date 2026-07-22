extends Control
## Act transition screen. Displays act title and summary, then returns to the overworld.

@onready var _title: Label = $VBox/TitleLabel
@onready var _summary: RichTextLabel = $VBox/SummaryLabel
@onready var _continue: Button = $VBox/ContinueButton

var _next_act: int = 1

func _ready() -> void:
	_next_act = SceneSwitcher.pending_payload.get("next_act", GameState.current_act)
	_title.text = "Act %d" % _next_act
	_summary.text = _act_summary(_next_act)
	_continue.pressed.connect(_on_continue)

func _act_summary(act: int) -> String:
	var entry := Content.act_entry(act)
	if not entry.is_empty():
		return entry.get("summary", "The story turns.")
	match act:
		1:
			return "The Hollow Gate opens. A voice beneath the ash remembers your name before you speak it."
		2:
			return "The Ashen Reach. Crowns are offered, crowns are broken, and every ally is a question."
		3:
			return "The Hollow Tide. What the sea was given, the sea now asks back."
		_:
			return "The story turns."

func _on_continue() -> void:
	GameState.current_phase = GameState.Phase.OVERWORLD
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
