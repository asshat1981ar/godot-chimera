extends Control
## Party management screen: roster, companions, dispositions.

@onready var _party_list: VBoxContainer = $VBox/Scroll/PartyList
@onready var _available_list: VBoxContainer = $VBox/Scroll2/AvailableList

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	for c in _party_list.get_children(): c.free()
	for c in _available_list.get_children(): c.free()
	for npc in Content.npcs():
		var id: String = npc.get("id", "")
		var in_party := GameState.party.has(id)
		var hbox := HBoxContainer.new()
		var lbl := Label.new()
		lbl.text = "%s (%s) — %.2f" % [npc.get("name", id), npc.get("role", "?"), GameState.get_disposition(id)]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)
		var btn := Button.new()
		btn.text = "Remove" if in_party else "Recruit"
		btn.disabled = npc.get("role", "") == "FACTION_LEADER"
		btn.pressed.connect(_toggle_member.bind(id))
		hbox.add_child(btn)
		if in_party:
			_party_list.add_child(hbox)
		else:
			_available_list.add_child(hbox)

func _toggle_member(id: String) -> void:
	if GameState.party.has(id):
		GameState.party.erase(id)
		EventBus.emit_state_changed("party", GameState.party.duplicate())
	else:
		GameState.add_to_party(id)
	_refresh()

func _on_back_pressed() -> void:
	GameState.save_game("auto")
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		GameState.save_game("auto")
		SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
