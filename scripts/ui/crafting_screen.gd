extends Control
## Crafting screen: lists craftable recipes, honors scene/npc gates, consumes inventory.

@onready var _recipe_list: VBoxContainer = $VBox/HBox/RecipePanel/Margin/VBox/RecipeList
@onready var _detail_title: Label = $VBox/HBox/DetailPanel/Margin/VBox/TitleLabel
@onready var _detail_desc: RichTextLabel = $VBox/HBox/DetailPanel/Margin/VBox/DescLabel
@onready var _ingredients_label: Label = $VBox/HBox/DetailPanel/Margin/VBox/IngredientsLabel
@onready var _gates_label: Label = $VBox/HBox/DetailPanel/Margin/VBox/GatesLabel
@onready var _craft_button: Button = $VBox/HBox/DetailPanel/Margin/VBox/CraftButton
@onready var _inventory_list: VBoxContainer = $VBox/HBox/InventoryPanel/Margin/VBox/InventoryList
@onready var _result_label: Label = $VBox/HBox/DetailPanel/Margin/VBox/ResultLabel

var _recipes: Array = []
var _selected_index: int = -1

func _ready() -> void:
	_refresh_recipes()
	_refresh_inventory()
	_select_recipe(0)

func _refresh_recipes() -> void:
	for c in _recipe_list.get_children():
		c.free()
	_recipes = Content.recipes()
	if _recipes.is_empty():
		_recipes = _fallback_recipes()
	if _recipes.is_empty():
		_recipe_list.add_child(_make_placeholder("Nothing here yet.\nNo recipes are known to the ash."))
		return
	for i in _recipes.size():
		var recipe: Dictionary = _recipes[i]
		var btn := Button.new()
		btn.text = recipe.get("name", recipe.get("id", "Unknown"))
		btn.custom_minimum_size = Vector2(0, 84)
		btn.pressed.connect(_select_recipe.bind(i))
		_recipe_list.add_child(btn)

func _fallback_recipes() -> Array:
	# Defensive fallback if Content.items() is empty so the screen never breaks.
	return []

func _select_recipe(index: int) -> void:
	if index < 0 or index >= _recipes.size():
		_detail_title.text = "No recipe selected"
		_craft_button.disabled = true
		return
	_selected_index = index
	var recipe: Dictionary = _recipes[index]
	_detail_title.text = recipe.get("name", recipe.get("id", ""))
	_detail_desc.text = recipe.get("description", "")
	_ingredients_label.text = "Ingredients:\n" + _format_ingredients(recipe)
	_gates_label.text = _format_gates(recipe)
	var can_craft := _can_craft(recipe)
	_craft_button.disabled = not can_craft
	_craft_button.text = "Craft" if can_craft else "Unavailable"
	_result_label.text = "Creates: %s" % recipe.get("resultName", recipe.get("resultItemId", ""))

func _format_ingredients(recipe: Dictionary) -> String:
	var out := ""
	for ingredient in _parse_ingredients(recipe):
		var item_id: String = ingredient.get("itemId", "")
		var need: int = int(ingredient.get("quantity", 0))
		var have: int = int(GameState.inventory.get(item_id, 0))
		var item := Content.item(item_id)
		var label: String = item.get("name", item_id) if not item.is_empty() else item_id
		out += "  • %s: %d / %d\n" % [label, have, need]
	return out

func _format_gates(recipe: Dictionary) -> String:
	var required_scene: String = recipe.get("requiredScene", "")
	var required_npc: String = recipe.get("requiredNpc", "")
	if required_scene.is_empty() and required_npc.is_empty():
		return "No location gate."
	var parts: Array[String] = []
	if not required_scene.is_empty():
		var completed := GameState.is_scene_completed(required_scene)
		parts.append("Scene %s: %s" % [required_scene, "met" if completed else "locked"])
	if not required_npc.is_empty():
		parts.append("Requires NPC: %s" % required_npc)
	return "Gates: " + ", ".join(parts)

func _parse_ingredients(recipe: Dictionary) -> Array:
	var raw: Variant = recipe.get("ingredientsJson", "")
	if raw is String and not (raw as String).is_empty():
		var parsed: Variant = JSON.parse_string(raw as String)
		if parsed is Array:
			return parsed
	elif raw is Array:
		return raw
	return []

func _can_craft(recipe: Dictionary) -> bool:
	var required_scene: String = recipe.get("requiredScene", "")
	if not required_scene.is_empty() and not GameState.is_scene_completed(required_scene):
		return false
	for ingredient in _parse_ingredients(recipe):
		var item_id: String = ingredient.get("itemId", "")
		var need: int = int(ingredient.get("quantity", 0))
		if int(GameState.inventory.get(item_id, 0)) < need:
			return false
	return true

func _on_craft_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _recipes.size():
		return
	var recipe: Dictionary = _recipes[_selected_index]
	if not _can_craft(recipe):
		return
	for ingredient in _parse_ingredients(recipe):
		var item_id: String = ingredient.get("itemId", "")
		var need: int = int(ingredient.get("quantity", 0))
		GameState.add_inventory(item_id, -need)
	var result_id: String = recipe.get("resultItemId", "")
	if not result_id.is_empty():
		GameState.add_inventory(result_id, 1)
	_refresh_inventory()
	_select_recipe(_selected_index)

func _refresh_inventory() -> void:
	for c in _inventory_list.get_children():
		c.free()
	var items := Content.items()
	if items.is_empty():
		_inventory_list.add_child(_make_placeholder("Nothing here yet.\nNo item catalog loaded."))
		return
	var any := false
	for item in items:
		var id: String = item.get("id", "")
		var qty: int = int(GameState.inventory.get(id, 0))
		if qty <= 0:
			continue
		any = true
		_inventory_list.add_child(_make_label("%s x%d" % [item.get("name", id), qty]))
	if not any:
		_inventory_list.add_child(_make_placeholder("Nothing here yet.\nYour pack is empty."))

func _make_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl

func _make_placeholder(text: String) -> Label:
	var lbl := _make_label(text)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.modulate = Color(0.6, 0.6, 0.6)
	return lbl

func _on_back_pressed() -> void:
	GameState.save_game()
	SceneSwitcher.switch_to("res://scenes/screens/overhead_map.tscn")
