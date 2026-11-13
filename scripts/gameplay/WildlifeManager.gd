class_name WildlifeManager
extends Node2D

@export var butterfly_scene: PackedScene
@export var bird_scene: PackedScene
@export var firefly_scene: PackedScene
@export var lunar_moth_scene: PackedScene
@export var garden_grid: GardenGrid
@export var player_node: Node2D

var spawn_timer: float = 0.0
const SPAWN_INTERVAL: float = 8.0 # Checks every 8 seconds

func _ready() -> void:
	if not butterfly_scene:
		butterfly_scene = preload("res://scenes/entities/Butterfly.tscn")
	if not bird_scene:
		bird_scene = preload("res://scenes/entities/Bird.tscn")
	if not firefly_scene:
		firefly_scene = preload("res://scenes/entities/Firefly.tscn")
	if not lunar_moth_scene:
		lunar_moth_scene = preload("res://scenes/entities/LunarMoth.tscn")
	SignalBus.weather_changed.connect(_on_weather_changed)

func _process(delta: float) -> void:
	spawn_timer += delta
	if spawn_timer >= SPAWN_INTERVAL:
		spawn_timer = 0.0
		evaluate_wildlife_spawn()

func evaluate_wildlife_spawn() -> void:
	if not garden_grid:
		return
		
	var hour = TimeManager.game_hour
	var weather = TimeManager.current_weather
	var is_night = hour >= 19 or hour <= 5
	var has_night_tea_buff = false
	if has_node("/root/ApothecaryManager"):
		has_night_tea_buff = (get_node("/root/ApothecaryManager").active_buff_id == "buff_night_fauna")
	
	# Rain suppresses butterflies and birds
	if weather == "Rainy" and not has_night_tea_buff:
		return
		
	# 1. Daytime Butterflies (Hours 8 to 18)
	if hour >= 8 and hour <= 18:
		var blooming_flower_pos = find_blooming_flower_pos()
		if blooming_flower_pos != Vector2.ZERO and randf() < 0.65:
			spawn_butterfly(blooming_flower_pos)
			
	# 2. Visiting Songbirds (Morning 6-11, Afternoon 15-18)
	if (hour >= 6 and hour <= 11) or (hour >= 15 and hour <= 18):
		if randf() < 0.40:
			spawn_visiting_bird()
			
	# 3. Nocturnal Fireflies (Night hours 19 to 5, or Twilight Cordial Buff)
	if (is_night or has_night_tea_buff) and randf() < 0.70:
		spawn_firefly()
		
	# 4. Rare Lunar Silk Moth (Attracted to night-blooming flowers or tea buff)
	if (is_night or has_night_tea_buff) and randf() < 0.45:
		spawn_lunar_moth()

func find_blooming_flower_pos() -> Vector2:
	# Search garden grid for blooming flowers or herbs
	var candidate_positions: Array[Vector2] = []
	for pos in garden_grid.cells.keys():
		var cell = garden_grid.cells[pos]
		if cell["plant"]:
			var p_id = cell["plant"].plant_id
			var p_cat = AlmanacManager.plant_catalog.get(p_id, {}).get("category", "")
			if p_cat in ["Flower", "Herb", "Hybrid"] or cell["plant"].current_stage >= 2:
				candidate_positions.append(garden_grid.to_global(Vector2(
					pos.x * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0,
					pos.y * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0
				)))
				
	if candidate_positions.size() > 0:
		return candidate_positions[randi() % candidate_positions.size()]
	return Vector2.ZERO

func spawn_butterfly(target_flower_pos: Vector2) -> void:
	if not butterfly_scene:
		return
	var b = butterfly_scene.instantiate()
	var color_types = ["orange", "blue", "yellow"]
	var chosen_color = color_types[randi() % color_types.size()]
	
	# Spawn from outside camera edge
	var start_pos = target_flower_pos + Vector2(randf_range(-250, 250), -180)
	add_child(b)
	b.setup(chosen_color, start_pos, target_flower_pos)

func spawn_visiting_bird() -> void:
	if not bird_scene:
		return
	var b = bird_scene.instantiate()
	var bird_types = ["robin", "bluebird"]
	var chosen_type = bird_types[randi() % bird_types.size()]
	
	# Pick random garden ground spot
	var rx = randi_range(1, GardenGrid.GRID_WIDTH - 2)
	var ry = randi_range(1, GardenGrid.GRID_HEIGHT - 2)
	var landing_pos = garden_grid.to_global(Vector2(
		rx * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0,
		ry * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0
	))
	var start_pos = landing_pos + Vector2(randf_range(-300, 300), -220)
	
	add_child(b)
	b.setup(chosen_type, start_pos, landing_pos, player_node)

func spawn_firefly() -> void:
	if not firefly_scene or not garden_grid:
		return
	var rx = randi_range(0, GardenGrid.GRID_WIDTH - 1)
	var ry = randi_range(0, GardenGrid.GRID_HEIGHT - 1)
	var plot_pos = garden_grid.to_global(Vector2(
		rx * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0,
		ry * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0
	))
	var f = firefly_scene.instantiate()
	f.position = plot_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15))
	add_child(f)

func spawn_lunar_moth() -> void:
	if not lunar_moth_scene:
		return
	var m = lunar_moth_scene.instantiate()
	m.position = Vector2(randf_range(200, 1000), -50)
	add_child(m)

func _on_weather_changed(_weather: String) -> void:
	pass
