class_name Firefly
extends Area2D

@export var move_speed: float = 25.0
@export var glow_frequency: float = 2.0

var flight_time: float = 0.0
var target_pos: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var glow_light: PointLight2D = $PointLight2D if has_node("PointLight2D") else null

func _ready() -> void:
	base_position = position
	pick_new_flight_target()
	input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	flight_time += delta
	
	# Gentle sine-wave pulsing bioluminescence
	var pulse = 0.5 + 0.5 * sin(flight_time * glow_frequency * PI)
	modulate.a = 0.4 + pulse * 0.6
	scale = Vector2(0.9 + pulse * 0.2, 0.9 + pulse * 0.2)
	
	# Smooth floating path
	position = position.move_toward(target_pos, move_speed * delta)
	if position.distance_to(target_pos) < 6.0:
		pick_new_flight_target()

func pick_new_flight_target() -> void:
	target_pos = base_position + Vector2(randf_range(-40, 40), randf_range(-30, 30))

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		catch_firefly()

func catch_firefly() -> void:
	SignalBus.firefly_collected.emit(1)
	if has_node("/root/OfflineGrowthManager"):
		get_node("/root/OfflineGrowthManager").add_dream_dew(1)
	SignalBus.notification_posted.emit("✨ Caught Starlight Firefly! (+1 Dream Dew)", Color(0.9, 0.9, 0.4))
	
	# Poof fade-out
	set_process(false)
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.15)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(queue_free)
