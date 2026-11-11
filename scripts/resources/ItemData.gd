class_name ItemData
extends Resource

enum ItemType {
	TOOL,
	SEED,
	PRODUCE,
	FERTILIZER,
	SPECIAL
}

@export var item_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.PRODUCE
@export var icon: Texture2D
@export var buy_price: int = 10
@export var sell_price: int = 20
@export var max_stack: int = 99
@export var associated_plant_data: PlantData
