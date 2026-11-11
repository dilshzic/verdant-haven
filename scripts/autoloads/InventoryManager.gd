extends Node

const HOTBAR_SIZE: int = 8

var coins: int = 150
var active_slot: int = 0

# Hotbar items array: Dictionary with keys {"id", "type", "count", "name", "icon"}
var hotbar: Array[Dictionary] = []
var inventory: Dictionary = {} # item_id -> count

# Tool upgrades
var watering_can_level: int = 1 # 1: 1x1, 2: 1x3, 3: 3x3
var hoe_level: int = 1

func _ready() -> void:
	init_default_loadout()

func init_default_loadout() -> void:
	hotbar.clear()
	# Slot 0: Hoe
	hotbar.append({
		"id": "tool_hoe",
		"type": "tool",
		"name": "Gardener's Hoe",
		"count": 1,
		"icon_path": "res://assets/sprites/tools/hoe.png"
	})
	# Slot 1: Watering Can
	hotbar.append({
		"id": "tool_water",
		"type": "tool",
		"name": "Watering Can",
		"count": 1,
		"icon_path": "res://assets/sprites/tools/watering_can.png"
	})
	# Slot 2: Fertilizer
	hotbar.append({
		"id": "tool_fertilizer",
		"type": "tool",
		"name": "Compost Fertilizer",
		"count": 5,
		"icon_path": "res://assets/sprites/tools/fertilizer.png"
	})
	# Slot 3: Shears
	hotbar.append({
		"id": "tool_shears",
		"type": "tool",
		"name": "Pruning Shears",
		"count": 1,
		"icon_path": "res://assets/sprites/tools/shears.png"
	})
	# Slot 4: Starter Seeds: Carrot
	hotbar.append({
		"id": "seed_carrot",
		"type": "seed",
		"plant_id": "carrot",
		"name": "Carrot Seeds",
		"count": 6,
		"icon_path": "res://assets/sprites/plants/carrot_stage_0.png"
	})
	# Slot 5: Starter Seeds: Strawberry
	hotbar.append({
		"id": "seed_strawberry",
		"type": "seed",
		"plant_id": "strawberry",
		"name": "Strawberry Seeds",
		"count": 4,
		"icon_path": "res://assets/sprites/plants/strawberry_stage_0.png"
	})
	# Slot 6: Starter Seeds: Azure Lily (Flower)
	hotbar.append({
		"id": "seed_azure_lily",
		"type": "seed",
		"plant_id": "azure_lily",
		"name": "Azure Lily Seeds",
		"count": 4,
		"icon_path": "res://assets/sprites/plants/azure_lily_stage_0.png"
	})
	# Slot 7: Empty slot
	hotbar.append({
		"id": "",
		"type": "empty",
		"name": "Empty Slot",
		"count": 0,
		"icon_path": ""
	})

func set_active_slot(slot: int) -> void:
	if slot >= 0 and slot < HOTBAR_SIZE:
		active_slot = slot
		SignalBus.active_slot_changed.emit(active_slot)

func get_active_item() -> Dictionary:
	if active_slot >= 0 and active_slot < hotbar.size():
		return hotbar[active_slot]
	return {}

func consume_active_item() -> void:
	if active_slot < hotbar.size():
		var it = hotbar[active_slot]
		if it["type"] in ["seed", "fertilizer"]:
			it["count"] -= 1
			if it["count"] <= 0:
				hotbar[active_slot] = {"id": "", "type": "empty", "name": "Empty Slot", "count": 0, "icon_path": ""}
			SignalBus.inventory_changed.emit()

func add_item(item_id: String, item_type: String, item_name: String, count: int, icon_path: String, plant_id: String = "") -> bool:
	# Try stacking in hotbar first
	for slot in hotbar:
		if slot["id"] == item_id and slot["type"] == item_type:
			slot["count"] += count
			SignalBus.inventory_changed.emit()
			return true
			
	# Find empty hotbar slot
	for i in range(hotbar.size()):
		if hotbar[i]["type"] == "empty":
			hotbar[i] = {
				"id": item_id,
				"type": item_type,
				"name": item_name,
				"count": count,
				"icon_path": icon_path,
				"plant_id": plant_id
			}
			SignalBus.inventory_changed.emit()
			return true
			
	# Else store in backup inventory dictionary
	if inventory.has(item_id):
		inventory[item_id] += count
	else:
		inventory[item_id] = count
	SignalBus.inventory_changed.emit()
	return true

func add_coins(amount: int) -> void:
	coins += amount
	SignalBus.coins_changed.emit(coins)

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		SignalBus.coins_changed.emit(coins)
		return true
	return false
