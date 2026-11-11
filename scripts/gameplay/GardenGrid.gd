class_name GardenGrid
extends Node2D

const GRID_WIDTH: int = 10
const GRID_HEIGHT: int = 8
const TILE_SIZE: int = 32

var cells: Dictionary = {}

@onready var plants_container: Node2D = $PlantsContainer
@onready var selector: Sprite2D = $Selector

# Preloaded textures
var tex_untilled: Texture2D
var tex_dry: Texture2D
var tex_wet: Texture2D
var tex_fertilized: Texture2D
var tex_mulched: Texture2D
var tex_waterlogged: Texture2D
var tex_weed: Texture2D

var hovered_tile: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	tex_untilled = load("res://assets/sprites/tiles/soil_untilled.png")
	tex_dry = load("res://assets/sprites/tiles/soil_dry.png")
	tex_wet = load("res://assets/sprites/tiles/soil_wet.png")
	tex_fertilized = load("res://assets/sprites/tiles/soil_fertilized.png")
	tex_mulched = load("res://assets/sprites/tiles/soil_mulched.png")
	tex_waterlogged = load("res://assets/sprites/tiles/soil_waterlogged.png")
	tex_weed = load("res://assets/sprites/tiles/weed.png")
	
	init_grid()
	
	SignalBus.day_advanced.connect(_on_day_advanced)
	SignalBus.time_ticked.connect(_on_time_ticked)
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
				"is_mulched": false,
				"sunlight_exposure": 1.0,
				"has_weed": false,
				"days_waterlogged": 0,
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
	elif c["moisture"] >= 0.90:
		s.texture = tex_waterlogged
	elif c["is_mulched"]:
		s.texture = tex_mulched
	elif c["moisture"] > 0.15:
		s.texture = tex_wet
	elif c["is_fertilized"]:
		s.texture = tex_fertilized
	else:
		s.texture = tex_dry

func calculate_tile_sunlight(pos: Vector2i) -> float:
	var daylight = TimeManager.get_daylight_factor()
	var weather_factor = 1.0
	if TimeManager.current_weather == "Rainy":
		weather_factor = 0.35
	elif TimeManager.current_weather == "Overcast":
		weather_factor = 0.45
	elif TimeManager.current_weather == "Mystical Fog":
		weather_factor = 0.25
		
	var base_sun = daylight * weather_factor
	
	# Check companion shade cast by adjacent tall crops (e.g. Corn, Pumpkin)
	var has_shade_canopy = false
	var neighbors = [pos + Vector2i.UP, pos + Vector2i.LEFT, pos + Vector2i.RIGHT]
	for n in neighbors:
		if cells.has(n) and cells[n]["plant"]:
			var p_id = cells[n]["plant"].plant_id
			var p_cat = AlmanacManager.plant_catalog.get(p_id, {})
			if p_cat.get("casts_shade", false) and cells[n]["plant"].current_stage >= 2:
				has_shade_canopy = true
				break
				
	if has_shade_canopy:
		base_sun *= 0.45 # Reduced by 55% into pleasant dappled shade
		
	return base_sun

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
			
	# 2. Watering Can Interaction (adds +0.50 moisture)
	elif item_id == "tool_water":
		if cell["is_tilled"]:
			cell["moisture"] = min(1.0, cell["moisture"] + 0.50)
			if cell["moisture"] >= 0.90:
				SignalBus.notification_posted.emit("Soil is saturated with water!", Color(0.3, 0.8, 1.0))
			else:
				SignalBus.notification_posted.emit("Watered soil bed to %d%%" % int(cell["moisture"] * 100), Color(0.4, 0.85, 1.0))
			update_cell_visual(pos)
			play_splash_fx(pos)
			
	# 3. Mulch Application (insulates against scorch & halves evaporation)
	elif item_id == "tool_mulch":
		if cell["is_tilled"] and not cell["is_mulched"]:
			cell["is_mulched"] = true
			InventoryManager.consume_active_item()
			update_cell_visual(pos)
			SignalBus.notification_posted.emit("Spread straw mulch! Retains moisture & blocks sun scorch.", Color(0.9, 0.8, 0.3))
			
	# 4. Fertilizer
	elif item_id == "tool_fertilizer":
		if cell["is_tilled"] and not cell["is_fertilized"]:
			cell["is_fertilized"] = true
			cell["fertility"] = 1.0
			InventoryManager.consume_active_item()
			update_cell_visual(pos)
			SignalBus.notification_posted.emit("Enriched soil with nutrient compost!", Color(0.9, 0.8, 0.2))
			
	# 5. Seeds
	elif item_type == "seed":
		if cell["is_tilled"] and cell["plant"] == null and not cell["has_weed"]:
			var plant_id = active_item.get("plant_id", "")
			if plant_id != "":
				spawn_plant(pos, plant_id)
				InventoryManager.consume_active_item()
				SignalBus.notification_posted.emit("Planted " + active_item.get("name", "Seed"), Color(0.4, 0.9, 0.4))
				
	# 6. Shears / Harvest Hand
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
				
				if not AlmanacManager.plant_catalog[harvest_data["plant_id"]].get("regrows", false):
					cell["plant"] = null
					
				check_nearby_hybridization(pos)

func spawn_plant(pos: Vector2i, plant_id: String) -> void:
	var plant_scene = preload("res://scenes/gameplay/Plant.tscn")
	var p: Plant = plant_scene.instantiate()
	p.position = Vector2(pos.x * TILE_SIZE + TILE_SIZE / 2.0, pos.y * TILE_SIZE + TILE_SIZE / 2.0)
	p.setup(plant_id)
	
	plants_container.add_child(p)
	cells[pos]["plant"] = p

func _on_time_ticked(_minute: int, _hour: int, _day: int, _season: String) -> void:
	# Continuous sunlight & moisture evaluation
	for pos in cells.keys():
		var cell = cells[pos]
		cell["sunlight_exposure"] = calculate_tile_sunlight(pos)
		
		# If plant exists, evaluate microclimate speed
		if cell["plant"] and not cell["plant"].is_mature and not cell["plant"].is_withered:
			var p_id = cell["plant"].plant_id
			var p_data = AlmanacManager.plant_catalog.get(p_id, {})
			var sun_pref = p_data.get("sunlight", "Full Sun")
			var sun = cell["sunlight_exposure"]
			var moisture = cell["moisture"]
			
			var speed = 1.0
			
			# Sunlight evaluation
			if sun_pref == "Full Sun":
				if sun >= 0.70:
					speed += 0.25 # Full sun bonus
				elif sun < 0.35:
					speed *= 0.50 # Stunted by shade
			elif sun_pref == "Shade Loving":
				if sun > 0.75 and not cell["is_mulched"]:
					# Heat stress / sun scorch!
					speed *= 0.30
				elif sun <= 0.45:
					speed += 0.35 # Thrives in cool shade
					
			# Moisture evaluation
			if moisture >= 0.40 and moisture <= 0.85:
				speed += 0.20 # Optimal hydration vigor
			elif moisture < 0.15:
				speed *= 0.40 # Parched drought slowdown
				
			if cell["is_fertilized"]:
				speed += 0.30
				
			cell["plant"].growth_speed_multiplier = speed

func _on_day_advanced(_day: int, _season: String) -> void:
	for pos in cells.keys():
		var cell = cells[pos]
		if cell["is_tilled"]:
			# Evaporation rate affected by sun heat and mulch
			var sun = cell["sunlight_exposure"]
			var evap_rate = 0.45 * (1.0 + sun * 0.5)
			if cell["is_mulched"]:
				evap_rate *= 0.40 # Mulch reduces evaporation by 60%!
				
			cell["moisture"] = max(0.0, cell["moisture"] - evap_rate)
			
			# Check drought withering
			if cell["moisture"] <= 0.05:
				if cell["plant"]:
					cell["plant"].days_parched += 1
					if cell["plant"].days_parched >= 2:
						cell["plant"].is_withered = true
						cell["plant"].update_sprite()
			else:
				if cell["plant"]:
					cell["plant"].days_parched = 0
					
			# Check waterlogging (root rot)
			if cell["moisture"] >= 0.90:
				cell["days_waterlogged"] += 1
				if cell["days_waterlogged"] >= 3 and cell["plant"]:
					cell["plant"].is_withered = true
					cell["plant"].update_sprite()
					SignalBus.notification_posted.emit("A plant wilted from waterlogged root rot!", Color(0.8, 0.4, 0.4))
			else:
				cell["days_waterlogged"] = 0
		else:
			if not cell["has_weed"] and randf() < 0.08:
				cell["has_weed"] = true
				
		update_cell_visual(pos)

func _on_weather_changed(weather: String) -> void:
	if weather == "Rainy":
		for pos in cells.keys():
			if cells[pos]["is_tilled"]:
				cells[pos]["moisture"] = 0.85
				update_cell_visual(pos)
		SignalBus.notification_posted.emit("Gentle rain showers hydrate all garden plots to 85%!", Color(0.3, 0.7, 1.0))

func check_nearby_hybridization(pos: Vector2i) -> void:
	var neighbors = [pos + Vector2i.UP, pos + Vector2i.DOWN, pos + Vector2i.LEFT, pos + Vector2i.RIGHT]
	for n in neighbors:
		if cells.has(n) and cells[n]["plant"] and cells[n]["plant"].is_mature:
			for n2 in neighbors:
				if n != n2 and cells.has(n2) and cells[n2]["plant"] and cells[n2]["plant"].is_mature:
					var hybrid_result = AlmanacManager.check_hybridization(cells[n]["plant"].plant_id, cells[n2]["plant"].plant_id)
					if hybrid_result != "" and randf() < 0.40:
						var hybrid_data = AlmanacManager.plant_catalog[hybrid_result]
						InventoryManager.add_item("seed_" + hybrid_result, "seed", hybrid_data["name"] + " Seeds", 1, "res://assets/sprites/plants/%s_stage_0.png" % hybrid_result, hybrid_result)
						SignalBus.hybrid_discovered.emit(hybrid_result, cells[n]["plant"].plant_id, cells[n2]["plant"].plant_id)
						SignalBus.notification_posted.emit("Cross-pollination success! Discovered " + hybrid_data["name"] + " Seed!", Color(0.9, 0.4, 0.9))
						return

func play_splash_fx(pos: Vector2i) -> void:
	var tw = create_tween()
	var s = cells[pos]["sprite"]
	tw.tween_property(s, "scale", Vector2(1.15, 1.15), 0.1)
	tw.tween_property(s, "scale", Vector2(1.0, 1.0), 0.15)
