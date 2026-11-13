class_name ApothecaryManager
extends Node

const TEA_RECIPES: Dictionary = {
	"tea_chamomile_lavender": {
		"id": "tea_chamomile_lavender",
		"name": "Serene Dream Tea",
		"desc": "A fragrant, calming blend of dried lavender and chamomile blossoms. Deepens restful sleep.",
		"ingredients": {
			"produce_lavender": 1,
			"produce_chamomile": 1
		},
		"buff_name": "Serene Slumber (+50% Overnight Dew)",
		"buff_id": "buff_sleep_dew",
		"duration_sec": 300.0,
		"color": Color(0.7, 0.6, 0.9)
	},
	"tea_mint_lotus": {
		"id": "tea_mint_lotus",
		"name": "Mint Lotus Clarity Brew",
		"desc": "Crisp aromatic peppermint infused with sacred lotus petals. Clears mental fog and sharpens mindfulness.",
		"ingredients": {
			"produce_peppermint": 1,
			"produce_sacred_lotus": 1
		},
		"buff_name": "Zen Clarity (2x Focus Speed)",
		"buff_id": "buff_focus_speed",
		"duration_sec": 240.0,
		"color": Color(0.4, 0.9, 0.8)
	},
	"tea_solar_dawn": {
		"id": "tea_solar_dawn",
		"name": "Radiant Solar Brew",
		"desc": "Fiery blend of golden marigold, scarlet poppy petals, and sweet dewberries. Radiates solar warmth.",
		"ingredients": {
			"produce_marigold": 1,
			"produce_scarlet_poppy": 1,
			"produce_strawberry": 1
		},
		"buff_name": "Solar Aura (Protects Against Cold/Fog)",
		"buff_id": "buff_solar_warmth",
		"duration_sec": 360.0,
		"color": Color(1.0, 0.7, 0.2)
	},
	"tea_twilight_cordial": {
		"id": "tea_twilight_cordial",
		"name": "Twilight Dream Cordial",
		"desc": "Enchanting night elixir of moonlit violet and brisk mint. Attracts bioluminescent fireflies and lunar moths.",
		"ingredients": {
			"produce_moonlit_violet": 1,
			"produce_peppermint": 1
		},
		"buff_name": "Lunar Radiance (Spawns Night Wildlife)",
		"buff_id": "buff_night_fauna",
		"duration_sec": 300.0,
		"color": Color(0.6, 0.4, 0.9)
	},
	"tea_golden_ambrosia": {
		"id": "tea_golden_ambrosia",
		"name": "Golden Bodhi Nectar",
		"desc": "Master botanical brew of honeydew melon, star lily, and starlight dew. Fills garden with fertile vigor.",
		"ingredients": {
			"produce_sun_melon": 1,
			"produce_azure_lily": 1
		},
		"buff_name": "Flora Vitality (+40% Crop Growth)",
		"buff_id": "buff_vitality",
		"duration_sec": 300.0,
		"color": Color(1.0, 0.85, 0.3)
	}
}

var tea_inventory: Dictionary = {}
var active_buff_id: String = ""
var active_buff_name: String = ""
var buff_time_remaining: float = 0.0

func _ready() -> void:
	for id in TEA_RECIPES.keys():
		tea_inventory[id] = 0

func _process(delta: float) -> void:
	if active_buff_id != "":
		buff_time_remaining -= delta
		if buff_time_remaining <= 0.0:
			clear_active_buff()

func can_brew(recipe_id: String) -> bool:
	if not TEA_RECIPES.has(recipe_id):
		return false
	var recipe = TEA_RECIPES[recipe_id]
	var ingredients: Dictionary = recipe["ingredients"]
	for item_id in ingredients.keys():
		var needed: int = ingredients[item_id]
		var have: int = InventoryManager.get_item_count(item_id)
		if have < needed:
			return false
	return true

func brew_tea(recipe_id: String) -> bool:
	if not can_brew(recipe_id):
		return false
		
	var recipe = TEA_RECIPES[recipe_id]
	var ingredients: Dictionary = recipe["ingredients"]
	
	# Consume required ingredients from inventory
	for item_id in ingredients.keys():
		var count: int = ingredients[item_id]
		InventoryManager.remove_item(item_id, count)
		
	tea_inventory[recipe_id] = tea_inventory.get(recipe_id, 0) + 1
	SignalBus.tea_brewed.emit(recipe_id, recipe["name"])
	SignalBus.notification_posted.emit("Brewed artisanal %s!" % recipe["name"], recipe["color"])
	return true

func drink_tea(recipe_id: String) -> bool:
	if tea_inventory.get(recipe_id, 0) <= 0:
		return false
		
	tea_inventory[recipe_id] -= 1
	var recipe = TEA_RECIPES[recipe_id]
	active_buff_id = recipe["buff_id"]
	active_buff_name = recipe["buff_name"]
	buff_time_remaining = recipe["duration_sec"]
	
	# Apply instant effects if any
	if active_buff_id == "buff_vitality":
		SignalBus.garden_blessed.emit("prana")
	elif active_buff_id == "buff_solar_warmth":
		SignalBus.weather_changed.emit("Sunny")
		
	SignalBus.tea_consumed.emit(recipe_id, active_buff_name, buff_time_remaining)
	SignalBus.notification_posted.emit("Sipped %s! Buff: %s" % [recipe["name"], active_buff_name], recipe["color"])
	return true

func clear_active_buff() -> void:
	active_buff_id = ""
	active_buff_name = ""
	buff_time_remaining = 0.0
	SignalBus.notification_posted.emit("Tea buff effect has gently faded.", Color(0.7, 0.7, 0.7))

func get_active_buff_string() -> String:
	if active_buff_id == "":
		return "None"
	var mins = int(buff_time_remaining / 60.0)
	var secs = int(buff_time_remaining) % 60
	return "%s (%02d:%02d)" % [active_buff_name, mins, secs]
