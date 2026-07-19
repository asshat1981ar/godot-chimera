extends Control
## Journal screen: active/completed quests, unlocked lore entries, and scene records.

@onready var _tabs: TabContainer = $VBox/Tabs
@onready var _quest_entries: VBoxContainer = $VBox/Tabs/Quests/Scroll/Entries
@onready var _lore_entries: VBoxContainer = $VBox/Tabs/Lore/Scroll/Entries
@onready var _scene_entries: VBoxContainer = $VBox/Tabs/Scenes/Scroll/Entries

func _ready() -> void:
	_refresh()
	EventBus.state_changed.connect(_on_state_changed)
	EventBus.journal_updated.connect(_on_journal_updated)

func _on_state_changed(key: String, _value: Variant) -> void:
	if key in ["quest_states", "unlocked_lore", "completed_scenes"]:
		_refresh()

func _on_journal_updated(_entry_id: String) -> void:
	_refresh()

func _refresh() -> void:
	_refresh_quests()
	_refresh_lore()
	_refresh_scenes()

func _refresh_quests() -> void:
	for c in _quest_entries.get_children(): c.free()
	var any := false
	for q in Content.quests():
		var quest_id: String = q.get("id", "")
		var state: Dictionary = GameState.quest_states.get(quest_id, {})
		var status: String = state.get("status", "")
		if status == "":
			continue
		any = true
		var title: String = q.get("name", quest_id)
		var prefix := "[Active]" if status == "active" else "[Completed]"
		var lbl := _make_label("%s %s" % [prefix, title])
		_quest_entries.add_child(lbl)
		# Objectives with progress.
		for obj in q.get("objectives", []):
			var obj_id: String = obj.get("id", "")
			var progress: int = int(state.get("objectives", {}).get(obj_id, 0))
			var target: int = int(obj.get("count", 1))
			var desc: String = obj.get("description", obj_id)
			var obj_text := "  • %s (%d/%d)" % [desc, progress, target]
			_quest_entries.add_child(_make_label(obj_text, 16))
	if not any:
		_quest_entries.add_child(_make_empty("No quests yet. The ash has not asked anything of you."))

func _refresh_lore() -> void:
	for c in _lore_entries.get_children(): c.free()
	if GameState.unlocked_lore.is_empty():
		_lore_entries.add_child(_make_empty("No lore unlocked. Walk further; the hollow will give you words to keep."))
		return
	for entry_id in GameState.unlocked_lore:
		var entry := Content.lore_entry(entry_id)
		if entry.is_empty():
			continue
		var title: String = entry.get("title", entry_id)
		var category: String = entry.get("category", "")
		var text: String = entry.get("text", "")
		var header := _make_label("%s — %s" % [title, category.capitalize()], 20)
		header.add_theme_font_size_override("font_size", 20)
		_lore_entries.add_child(header)
		var body := _make_label(text, 16)
		_lore_entries.add_child(body)

func _refresh_scenes() -> void:
	for c in _scene_entries.get_children(): c.free()
	var completed := GameState.completed_scenes
	if completed.is_empty():
		_scene_entries.add_child(_make_empty("No scenes completed. The story has not yet turned."))
	else:
		var lbl := _make_label("Completed scenes:")
		_scene_entries.add_child(lbl)
		for scene_id in completed:
			_scene_entries.add_child(_make_label("  • %s" % scene_id, 16))
	if GameState.journal_entries.is_empty():
		_scene_entries.add_child(_make_empty("No journal entries yet."))
	else:
		_scene_entries.add_child(_make_label("Records:"))
		for entry in GameState.journal_entries:
			_scene_entries.add_child(_make_label("  • %s" % entry.get("title", "Untitled"), 16))

func _make_label(text: String, font_size: int = 18) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", font_size)
	return lbl

func _make_empty(text: String) -> Label:
	var lbl := _make_label(text, 16)
	lbl.modulate = Color(0.6, 0.6, 0.6)
	return lbl

func _on_back_pressed() -> void:
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
