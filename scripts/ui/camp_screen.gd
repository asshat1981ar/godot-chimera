extends Control
## Camp/rest screen with party disposition summary and night-event risk.

@onready var _risk_label: Label = $VBox/RiskLabel
@onready var _party_list: VBoxContainer = $VBox/Scroll/PartyList
@onready var _log_label: RichTextLabel = $VBox/LogLabel

func _ready() -> void:
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
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/main_menu.tscn")
