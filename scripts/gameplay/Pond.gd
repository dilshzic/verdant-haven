class_name Pond
extends Node2D

@export var fish_scene: PackedScene
@export var pond_size: Vector2 = Vector2(160, 110)

var fish_school: Array[Fish] = []
var has_aquaponic_water_ready: bool = true
var lotus_mature: bool = true
var lotus_timer: float = 0.0

@onready var water_surface: ColorRect = $WaterSurface if has_node("WaterSurface") else null
@onready var lotus_sprite: Sprite2D = $LotusBlossom if has_node("LotusBlossom") else null
@onready var frog_sprite: Sprite2D = $Frog if has_node("Frog") else null

func _ready() -> void:
	if not fish_scene:
		fish_scene = preload("res://scenes/entities/Fish.tscn")
	spawn_initial_fish()

func spawn_initial_fish() -> void:
	var species_list = ["koi_gold", "koi_calico", "fish_blue", "fish_dragon"]
	var bounds = Rect2(Vector2(10, 10), pond_size - Vector2(20, 20))
	
	for s_type in species_list:
		var f: Fish = fish_scene.instantiate()
		f.position = Vector2(randf_range(20, pond_size.x - 20), randf_range(20, pond_size.y - 20))
		add_child(f)
		f.setup(s_type, bounds)
		fish_school.append(f)

func _process(delta: float) -> void:
	# Lotus regrowth timer
	if not lotus_mature:
		lotus_timer += delta
		if lotus_timer >= 60.0: # Regrows in 60 seconds
			lotus_mature = true
			if lotus_sprite:
				lotus_sprite.visible = true

func interact_with_pond(click_pos: Vector2) -> void:
	var active_item = InventoryManager.get_active_item()
	var item_id = active_item.get("id", "")
	
	# 1. Feed Fish with Food Canister
	if item_id == "tool_fish_food":
		feed_fish(click_pos)
		InventoryManager.consume_active_item()
		
	# 2. Refill Watering Can with Aquaponic Pond Water
	elif item_id == "tool_water":
		charge_aquaponic_water()
		
	# 3. Harvest Lotus Blossom
	elif lotus_mature and click_pos.distance_to(lotus_sprite.position if lotus_sprite else Vector2(80, 50)) < 30.0:
		harvest_lotus()
		
	# 4. Default: throw a few water ripples and lure fish
	else:
		lure_fish_to_finger(click_pos)

func feed_fish(food_pos: Vector2) -> void:
	SignalBus.notification_posted.emit("Sprinkled nutritious flakes! Koi rushed to feed.", Color(1.0, 0.75, 0.3))
	for f in fish_school:
		if is_instance_valid(f):
			f.feed_at(food_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)))

func charge_aquaponic_water() -> void:
	# Grants special nutrient boost to player's watering can
	SignalBus.notification_posted.emit("💧 Filled Watering Can with Nutrient-Rich Aquaponic Pond Water! (+50% Crop Boost)", Color(0.2, 0.9, 0.9))

func harvest_lotus() -> void:
	lotus_mature = false
	lotus_timer = 0.0
	if lotus_sprite:
		lotus_sprite.visible = false
	InventoryManager.add_coins(60)
	InventoryManager.add_item("produce_lotus", "produce", "Sacred Lotus Blossom", 1, "res://assets/sprites/pond/lotus_flower.png")
	SignalBus.notification_posted.emit("Harvested Sacred Lotus Blossom! (+60 G)", Color(0.95, 0.5, 0.8))

func lure_fish_to_finger(pos: Vector2) -> void:
	for f in fish_school:
		if is_instance_valid(f) and randf() < 0.6:
			f.target_pos = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
