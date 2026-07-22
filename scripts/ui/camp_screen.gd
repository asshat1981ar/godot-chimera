extends Control
## Camp/rest screen with party disposition summary and night-event risk.

@onready var _risk_label: Label = $VBox/RiskLabel
@onready var _party_list: VBoxContainer = $VBox/Scroll/PartyList
@onready var _log_label: RichTextLabel = $VBox/LogLabel
@onready var _summary_vbox: VBoxContainer = $VBox/SummaryPanel/Margin/SummaryVBox

# Snapshots taken at the start of the rest to compute session deltas.
var _start_dispositions: Dictionary = {}
var _start_completed_scenes: Array[String] = []
var _start_inventory: Dictionary = {}
var _start_lore: Array[String] = []

func _ready() -> void:
	_take_snapshot()
	var risk := _calculate_camp_risk()
	_risk_label.text = "Night risk: %d%%" % int(risk * 100)
	for npc_id in GameState.party:
		var npc := Content.npc_by_id(npc_id)
		var lbl := Label.new()
		var disp := GameState.get_disposition(npc_id)
		lbl.text = "%s — disposition %.2f" % [npc.get("name", npc_id), disp]
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_party_list.add_child(lbl)
	_log_label.text = "The fire burns low. Rest grants no answers, only strength to walk further into the ashes."
	_build_summary()
	_toast_saved()
	_setup_focus()

func _setup_focus() -> void:
	# Only one primary action on this screen: Continue.
	var continue_btn: Button = $VBox/ContinueButton
	continue_btn.focus_mode = Control.FOCUS_ALL
	continue_btn.grab_focus()
	var menu_btn: Button = $VBox/MenuButton
	if menu_btn:
		menu_btn.focus_mode = Control.FOCUS_ALL
		continue_btn.focus_neighbor_bottom = menu_btn.get_path()
		menu_btn.focus_neighbor_top = continue_btn.get_path()

func _take_snapshot() -> void:
	_start_dispositions.clear()
	for npc_id in GameState.party:
		_start_dispositions[npc_id] = GameState.get_disposition(npc_id)
	_start_completed_scenes = GameState.completed_scenes.duplicate()
	_start_inventory = GameState.inventory.duplicate()
	_start_lore = GameState.unlocked_lore.duplicate()

func _calculate_camp_risk() -> float:
	var risk := 0.0
	for npc_id in GameState.party:
		var disp := GameState.get_disposition(npc_id)
		if disp < -0.2:
			risk += 0.15
		elif disp > 0.3:
			risk -= 0.10
	return clampf(risk, 0.0, 1.0)

func _on_continue_pressed() -> void:
	GameState.current_phase = GameState.Phase.OVERWORLD
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _on_menu_pressed() -> void:
	GameState.save_game("auto")
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")

func _build_summary() -> void:
	for c in _summary_vbox.get_children():
		c.free()
	var title := Label.new()
	title.text = "Since you last rested"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	_summary_vbox.add_child(title)
	# Disposition shifts.
	var has_deltas := false
	for npc_id in GameState.party:
		var start: float = float(_start_dispositions.get(npc_id, 0.0))
		var now := GameState.get_disposition(npc_id)
		var delta := now - start
		if absf(delta) > 0.001:
			has_deltas = true
			var npc := Content.npc_by_id(npc_id)
			var name: String = npc.get("name", npc_id)
			var sign := "+" if delta >= 0 else ""
			_summary_vbox.add_child(_make_label("%s: %s%.2f" % [name, sign, delta]))
	if not has_deltas:
		_summary_vbox.add_child(_make_label("No dispositions shifted."))
	# Completed scenes.
	var completed_delta := GameState.completed_scenes.size() - _start_completed_scenes.size()
	if completed_delta > 0:
		_summary_vbox.add_child(_make_label("Scenes completed: %d" % completed_delta))
	# Items gained.
	var gained := _inventory_gained()
	if gained.is_empty():
		_summary_vbox.add_child(_make_label("No items gained."))
	else:
		for line in gained:
			_summary_vbox.add_child(_make_label(line))
	# Lore unlocked.
	var lore_delta := GameState.unlocked_lore.size() - _start_lore.size()
	if lore_delta > 0:
		_summary_vbox.add_child(_make_label("Lore unlocked: %d" % lore_delta))
	# Saved indicator.
	var saved := Label.new()
	saved.text = "Saved"
	saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	saved.modulate = Color(0.6, 0.7, 0.6)
	_summary_vbox.add_child(saved)

func _inventory_gained() -> Array[String]:
	var out: Array[String] = []
	for item_id in GameState.inventory:
		var now: int = int(GameState.inventory[item_id])
		var before: int = int(_start_inventory.get(item_id, 0))
		var delta := now - before
		if delta > 0:
			var item := Content.item(item_id)
			var name: String = item.get("name", item_id) if not item.is_empty() else item_id
			out.append("Gained %s x%d" % [name, delta])
	return out

func _make_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl

func _toast_saved() -> void:
	# Autosave already happened in Simulation.rest_at_camp, so just show a toast.
	if SceneSwitcher:
		SceneSwitcher.toast("Saved", 1.5)
	Haptics.play(30)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		GameState.save_game("auto")
		GameState.current_phase = GameState.Phase.OVERWORLD
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
