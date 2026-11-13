class_name TeaBrewingModal
extends Control

@onready var recipes_list: ItemList = $Panel/HSplit/RecipeList if has_node("Panel/HSplit/RecipeList") else null
@onready var title_label: Label = $Panel/HSplit/DetailVBox/TitleLabel if has_node("Panel/HSplit/DetailVBox/TitleLabel") else null
@onready var desc_label: Label = $Panel/HSplit/DetailVBox/DescLabel if has_node("Panel/HSplit/DetailVBox/DescLabel") else null
@onready var ingredients_label: Label = $Panel/HSplit/DetailVBox/IngredientsLabel if has_node("Panel/HSplit/DetailVBox/IngredientsLabel") else null
@onready var buff_label: Label = $Panel/HSplit/DetailVBox/BuffLabel if has_node("Panel/HSplit/DetailVBox/BuffLabel") else null
@onready var owned_label: Label = $Panel/HSplit/DetailVBox/OwnedLabel if has_node("Panel/HSplit/DetailVBox/OwnedLabel") else null
@onready var brew_btn: Button = $Panel/HSplit/DetailVBox/Buttons/BrewBtn if has_node("Panel/HSplit/DetailVBox/Buttons/BrewBtn") else null
@onready var drink_btn: Button = $Panel/HSplit/DetailVBox/Buttons/DrinkBtn if has_node("Panel/HSplit/DetailVBox/Buttons/DrinkBtn") else null

var selected_recipe_id: String = "tea_chamomile_lavender"
var recipe_keys: Array = []

func _ready() -> void:
	visible = false
	recipe_keys = ApothecaryManager.TEA_RECIPES.keys()
	populate_recipes_list()
	if recipe_keys.size() > 0:
		select_recipe(recipe_keys[0])

func open() -> void:
	visible = true
	populate_recipes_list()
	update_recipe_details()

func close() -> void:
	visible = false

func populate_recipes_list() -> void:
	if not recipes_list:
		return
	recipes_list.clear()
	for key in recipe_keys:
		var recipe = ApothecaryManager.TEA_RECIPES[key]
		var owned = ApothecaryManager.tea_inventory.get(key, 0)
		recipes_list.add_item("%s (x%d)" % [recipe["name"], owned])

func select_recipe(key: String) -> void:
	selected_recipe_id = key
	update_recipe_details()

func update_recipe_details() -> void:
	if not ApothecaryManager.TEA_RECIPES.has(selected_recipe_id):
		return
		
	var recipe = ApothecaryManager.TEA_RECIPES[selected_recipe_id]
	if title_label:
		title_label.text = "🍵 " + recipe["name"]
	if desc_label:
		desc_label.text = recipe["desc"]
	if buff_label:
		buff_label.text = "Restorative Effect: " + recipe["buff_name"]
		
	if ingredients_label:
		var ing_text = "Required Ingredients:\n"
		var ingredients: Dictionary = recipe["ingredients"]
		for item_id in ingredients.keys():
			var needed = ingredients[item_id]
			var have = InventoryManager.get_item_count(item_id)
			var item_name = item_id.replace("produce_", "").capitalize()
			ing_text += " • %s: %d / %d\n" % [item_name, have, needed]
		ingredients_label.text = ing_text
		
	var owned_count = ApothecaryManager.tea_inventory.get(selected_recipe_id, 0)
	if owned_label:
		owned_label.text = "In Inventory: %d Cups" % owned_count
		
	if brew_btn:
		brew_btn.disabled = not ApothecaryManager.can_brew(selected_recipe_id)
	if drink_btn:
		drink_btn.disabled = (owned_count <= 0)

func _on_brew_btn_pressed() -> void:
	if ApothecaryManager.brew_tea(selected_recipe_id):
		populate_recipes_list()
		update_recipe_details()

func _on_drink_btn_pressed() -> void:
	if ApothecaryManager.drink_tea(selected_recipe_id):
		populate_recipes_list()
		update_recipe_details()

func _on_recipe_selected(index: int) -> void:
	if index >= 0 and index < recipe_keys.size():
		select_recipe(recipe_keys[index])

func _on_close_btn_pressed() -> void:
	close()
