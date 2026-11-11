extends Node

const HOTBAR_SIZE: int = 8

var coins: int = 150
var active_slot: int = 0

var hotbar: Array[Dictionary] = []
var inventory: Dictionary = {}

var watering_can_level: int = 1
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
	# Slot 2: Straw Mulch (Sun & Moisture Protection)
	hotbar.append({
		"id": "tool_mulch",
		"type": "tool",
		"name": "Straw Mulch",
		"count": 6,
		"icon_path": "res://assets/sprites/tools/mulch.png"
	})
	# Slot 3: Fertilizer
	hotbar.append({
		"id": "tool_fertilizer",
		"type": "tool",
		"name": "Compost Fertilizer",
		"count": 4,
		"icon_path": "res://assets/sprites/tools/fertilizer.png"
	})
	# Slot 4: Shears
	hotbar.append({
		"id": "tool_shears",
		"type": "tool",
		"name": "Pruning Shears",
		"count": 1,
		"icon_path": "res://assets/sprites/tools/shears.png"
	})
	# Slot 5: Starter Seeds: Golden Corn (Sun lover & casts shade!)
	hotbar.append({
		"id": "seed_golden_corn",
		"type": "seed",
		"plant_id": "golden_corn",
		"name": "Corn Seeds",
		"count": 4,
		"icon_path": "res://assets/sprites/plants/golden_corn_stage_0.png"
	})
	# Slot 6: Starter Seeds: Strawberry
	hotbar.append({
		"id": "seed_strawberry",
		"type": "seed",
		"plant_id": "strawberry",
		"name": "Strawberry Seeds",
		"count": 4,
		"icon_path": "res://assets/sprites/plants/strawberry_stage_0.png"
	})
	# Slot 7: Starter Seeds: Azure Lily
	hotbar.append({
		"id": "seed_azure_lily",
		"type": "seed",
		"plant_id": "azure_lily",
		"name": "Lily Seeds",
		"count": 3,
		"icon_path": "res://assets/sprites/plants/azure_lily_stage_0.png"
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
		if it["type"] in ["seed", "fertilizer"] or it["id"] == "tool_mulch":
			it["count"] -= 1
			if it["count"] <= 0:
				hotbar[active_slot] = {"id": "", "type": "empty", "name": "Empty Slot", "count": 0, "icon_path": ""}
			SignalBus.inventory_changed.emit()

func add_item(item_id: String, item_type: String, item_name: String, count: int, icon_path: String, plant_id: String = "") -> bool:
	for slot in hotbar:
		if slot["id"] == item_id and slot["type"] == item_type:
			slot["count"] += count
			SignalBus.inventory_changed.emit()
			return true
			
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
