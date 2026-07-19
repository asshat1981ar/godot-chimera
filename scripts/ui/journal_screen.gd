extends Control
## Journal screen: records scenes, vows, and key simulation changes.

@onready var _entries: VBoxContainer = $VBox/Scroll/Entries

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	for c in _entries.get_children(): c.free()
	for entry in GameState.journal_entries:
		var lbl := Label.new()
		lbl.text = entry.get("title", "Untitled")
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_entries.add_child(lbl)
	var completed := Label.new()
	completed.text = "Completed scenes: %s" % ", ".join(GameState.completed_scenes)
	completed.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_entries.add_child(completed)
	if GameState.journal_entries.is_empty():
		var empty := Label.new()
		empty.text = "No entries yet. The hollow has not yet given you words to keep."
		_entries.add_child(empty)

func _on_back_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
