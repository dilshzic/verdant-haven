class_name Plant
extends Node2D

@export var plant_id: String = "carrot"

var current_stage: int = 0
var stage_progress_hours: float = 0.0
var is_mature: bool = false
var is_withered: bool = false
var days_parched: int = 0

var plant_data: Dictionary = {}
var growth_speed_multiplier: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

func _ready() -> void:
	if AlmanacManager.plant_catalog.has(plant_id):
		plant_data = AlmanacManager.plant_catalog[plant_id]
	update_sprite()
	SignalBus.time_ticked.connect(_on_time_ticked)
	play_plant_spawn_fx()

func setup(p_id: String) -> void:
	plant_id = p_id
	if AlmanacManager.plant_catalog.has(plant_id):
		plant_data = AlmanacManager.plant_catalog[plant_id]
	current_stage = 0
	stage_progress_hours = 0.0
	is_mature = false
	is_withered = false
	update_sprite()

func _on_time_ticked(_minute: int, _hour: int, _day: int, _season: String) -> void:
	if is_mature or is_withered:
		return
		
	# Check growth progress (called every 10 in-game minutes = 1/6th of an hour)
	var hour_step = 1.0 / 6.0
	stage_progress_hours += hour_step * growth_speed_multiplier
	
	var grow_durations: Array = plant_data.get("grow_hours", [6.0, 10.0, 14.0])
	if current_stage < grow_durations.size():
		var required = grow_durations[current_stage]
		if stage_progress_hours >= required:
			advance_growth_stage()

func advance_growth_stage() -> void:
	stage_progress_hours = 0.0
	current_stage += 1
	
	if current_stage >= 3:
		current_stage = 3
		is_mature = true
		play_mature_fx()
	else:
		play_grow_bounce_fx()
		
	update_sprite()

func update_sprite() -> void:
	if not sprite:
		return
		
	if is_withered:
		var path = "res://assets/sprites/plants/%s_withered.png" % plant_id
		if ResourceLoader.exists(path):
			sprite.texture = load(path)
		return
		
	var path = "res://assets/sprites/plants/%s_stage_%d.png" % [plant_id, current_stage]
	if ResourceLoader.exists(path):
		sprite.texture = load(path)

func play_grow_bounce_fx() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.25, 1.25), 0.15)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)

func play_mature_fx() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)
	SignalBus.notification_posted.emit(plant_data.get("name", "Crop") + " is ready for harvest!", Color(1.0, 0.85, 0.2))

func play_plant_spawn_fx() -> void:
	if sprite:
		sprite.scale = Vector2(0.2, 0.2)
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25)

func harvest() -> Dictionary:
	if not is_mature or is_withered:
		return {}
		
	var yield_count = randi_range(1, 3)
	var harvest_result = {
		"plant_id": plant_id,
		"name": plant_data.get("name", "Harvest"),
		"sell_price": plant_data.get("sell_price", 20),
		"yield": yield_count,
		"icon_path": "res://assets/sprites/plants/%s_item.png" % plant_id
	}
	
	AlmanacManager.record_harvest(plant_id)
	
	# Check if perennial crop (regrows)
	if plant_data.get("regrows", false):
		current_stage = 1 # Drops back to sprout/stem
		is_mature = false
		stage_progress_hours = 0.0
		update_sprite()
		play_grow_bounce_fx()
	else:
		# Annual plant is consumed
		queue_free()
		
	return harvest_result
