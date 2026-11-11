class_name GardenGrid
extends Node2D

const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 8
const TILE_SIZE: int = 32

# Mapping Vector2i -> Cell Dictionary
var cells: Dictionary = {}

@onready var plants_container: Node2D = $PlantsContainer
@onready var selector: Sprite2D = $Selector

# Preloaded textures
var tex_untilled: Texture2D
var tex_dry: Texture2D
var tex_wet: Texture2D
var tex_fertilized: Texture2D
var tex_weed: Texture2D

var hovered_tile: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	tex_untilled = load("res://assets/sprites/tiles/soil_untilled.png")
	tex_dry = load("res://assets/sprites/tiles/soil_dry.png")
	tex_wet = load("res://assets/sprites/tiles/soil_wet.png")
	tex_fertilized = load("res://assets/sprites/tiles/soil_fertilized.png")
	tex_weed = load("res://assets/sprites/tiles/weed.png")
	
	init_grid()
	
	SignalBus.day_advanced.connect(_on_day_advanced)
	SignalBus.weather_changed.connect(_on_weather_changed)

func init_grid() -> void:
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var pos = Vector2i(x, y)
			cells[pos] = {
				"is_tilled": false,
				"moisture": 0.0,
				"fertility": 0.5,
				"is_fertilized": false,
				"has_weed": false,
				"plant": null,
				"sprite": null
			}
			create_cell_sprite(pos)

func create_cell_sprite(pos: Vector2i) -> void:
	var s = Sprite2D.new()
	s.position = Vector2(pos.x * TILE_SIZE + TILE_SIZE / 2.0, pos.y * TILE_SIZE + TILE_SIZE / 2.0)
	s.texture = tex_untilled
	add_child(s)
	cells[pos]["sprite"] = s

func update_cell_visual(pos: Vector2i) -> void:
	if not cells.has(pos):
		return
	var c = cells[pos]
	var s: Sprite2D = c["sprite"]
	
	if not c["is_tilled"]:
		s.texture = tex_untilled
	elif c["moisture"] > 0.1:
		s.texture = tex_wet
	elif c["is_fertilized"]:
		s.texture = tex_fertilized
	else:
		s.texture = tex_dry

func interact_with_tile(pos: Vector2i) -> void:
	if not cells.has(pos):
		return
		
	var cell = cells[pos]
	var active_item = InventoryManager.get_active_item()
	var item_type = active_item.get("type", "")
	var item_id = active_item.get("id", "")
	
	# 1. Hoe Interaction
	if item_id == "tool_hoe":
		if cell["has_weed"]:
			cell["has_weed"] = false
			SignalBus.notification_posted.emit("Cleared troublesome weed!", Color(0.3, 0.8, 0.4))
			update_cell_visual(pos)
		elif not cell["is_tilled"]:
			cell["is_tilled"] = true
			cell["moisture"] = 0.0
			update_cell_visual(pos)
			SignalBus.notification_posted.emit("Tilled soil bed.", Color(0.8, 0.6, 0.4))
		elif cell["plant"] and cell["plant"].is_withered:
			cell["plant"].queue_free()
			cell["plant"] = null
			SignalBus.notification_posted.emit("Removed dead crop.", Color(0.7, 0.5, 0.3))
			
	# 2. Watering Can Interaction
	elif item_id == "tool_water":
		if cell["is_tilled"]:
			cell["moisture"] = 1.0
			update_cell_visual(pos)
			SignalBus.cell_watered.emit(pos)
			# Small juicy splash fx
			play_splash_fx(pos)
			
	# 3. Fertilizer
	elif item_id == "tool_fertilizer":
		if cell["is_tilled"] and not cell["is_fertilized"]:
			cell["is_fertilized"] = true
			cell["fertility"] = 1.0
			InventoryManager.consume_active_item()
			update_cell_visual(pos)
			SignalBus.notification_posted.emit("Enriched soil with nutrient compost!", Color(0.9, 0.8, 0.2))
			
	# 4. Seeds
	elif item_type == "seed":
		if cell["is_tilled"] and cell["plant"] == null and not cell["has_weed"]:
			var plant_id = active_item.get("plant_id", "")
			if plant_id != "":
				spawn_plant(pos, plant_id)
				InventoryManager.consume_active_item()
				SignalBus.notification_posted.emit("Planted " + active_item.get("name", "Seed"), Color(0.4, 0.9, 0.4))
				
	# 5. Shears / Harvest Hand
	elif item_id == "tool_shears" or item_type == "empty":
		if cell["plant"] and cell["plant"].is_mature:
			var harvest_data = cell["plant"].harvest()
			if harvest_data.size() > 0:
				var p_name = harvest_data["name"]
				var yield_count = harvest_data["yield"]
				var sell_val = harvest_data["sell_price"] * yield_count
				InventoryManager.add_coins(sell_val)
				InventoryManager.add_item("produce_" + harvest_data["plant_id"], "produce", p_name, yield_count, harvest_data["icon_path"])
				SignalBus.notification_posted.emit("Harvested %d %s! (+%d Coins)" % [yield_count, p_name, sell_val], Color(1.0, 0.85, 0.2))
				
				# If not perennial, clear reference
				if not AlmanacManager.plant_catalog[harvest_data["plant_id"]].get("regrows", false):
					cell["plant"] = null
					
				# Check cross-pollination hybridization!
				check_nearby_hybridization(pos)

func spawn_plant(pos: Vector2i, plant_id: String) -> void:
	var plant_scene = preload("res://scenes/gameplay/Plant.tscn")
	var p: Plant = plant_scene.instantiate()
	p.position = Vector2(pos.x * TILE_SIZE + TILE_SIZE / 2.0, pos.y * TILE_SIZE + TILE_SIZE / 2.0)
	p.setup(plant_id)
	
	# Apply companion bonuses from surrounding tiles
	var speed_bonus = calculate_companion_buffs(pos)
	p.growth_speed_multiplier = speed_bonus
	
	plants_container.add_child(p)
	cells[pos]["plant"] = p

func calculate_companion_buffs(pos: Vector2i) -> float:
	var mult = 1.0
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var neighbor = pos + Vector2i(dx, dy)
			if cells.has(neighbor) and cells[neighbor]["plant"]:
				var np = cells[neighbor]["plant"]
				if np.plant_id == "chrono_fern":
					mult += 0.25 # Chrono fern speeds up by 25%
				elif np.plant_id == "chamomile":
					mult += 0.10 # Chamomile invigorates
	return mult

func check_nearby_hybridization(pos: Vector2i) -> void:
	var current_plant_id = ""
	# Find adjacent mature flowers
	var neighbors = [pos + Vector2i.UP, pos + Vector2i.DOWN, pos + Vector2i.LEFT, pos + Vector2i.RIGHT]
	for n in neighbors:
		if cells.has(n) and cells[n]["plant"] and cells[n]["plant"].is_mature:
			for n2 in neighbors:
				if n != n2 and cells.has(n2) and cells[n2]["plant"] and cells[n2]["plant"].is_mature:
					var hybrid_result = AlmanacManager.check_hybridization(cells[n]["plant"].plant_id, cells[n2]["plant"].plant_id)
					if hybrid_result != "" and randf() < 0.40:
						# Spawn hybrid seed in empty adjacent plot or gift to player
						var hybrid_data = AlmanacManager.plant_catalog[hybrid_result]
						InventoryManager.add_item("seed_" + hybrid_result, "seed", hybrid_data["name"] + " Seeds", 1, "res://assets/sprites/plants/%s_stage_0.png" % hybrid_result, hybrid_result)
						SignalBus.hybrid_discovered.emit(hybrid_result, cells[n]["plant"].plant_id, cells[n2]["plant"].plant_id)
						SignalBus.notification_posted.emit("Cross-pollination success! Discovered " + hybrid_data["name"] + " Seed!", Color(0.9, 0.4, 0.9))
						return

func _on_day_advanced(_day: int, _season: String) -> void:
	# Moisture evaporates; weeds might sprout
	for pos in cells.keys():
		var cell = cells[pos]
		if cell["is_tilled"]:
			if cell["moisture"] <= 0.1:
				if cell["plant"]:
					cell["plant"].days_parched += 1
					if cell["plant"].days_parched >= 2:
						cell["plant"].is_withered = true
						cell["plant"].update_sprite()
			else:
				cell["moisture"] = 0.0 # Dried up for the new day
				if cell["plant"]:
					cell["plant"].days_parched = 0
		else:
			# Chance for weed to spread on wild untilled soil
			if not cell["has_weed"] and randf() < 0.08:
				cell["has_weed"] = true
				
		update_cell_visual(pos)

func _on_weather_changed(weather: String) -> void:
	if weather == "Rainy":
		# Rain automatically waters all tilled plots!
		for pos in cells.keys():
			if cells[pos]["is_tilled"]:
				cells[pos]["moisture"] = 1.0
				update_cell_visual(pos)
		SignalBus.notification_posted.emit("Gentle rain showers hydrate all garden plots!", Color(0.3, 0.7, 1.0))

func play_splash_fx(pos: Vector2i) -> void:
	var tw = create_tween()
	var s = cells[pos]["sprite"]
	tw.tween_property(s, "scale", Vector2(1.15, 1.15), 0.1)
	tw.tween_property(s, "scale", Vector2(1.0, 1.0), 0.15)
