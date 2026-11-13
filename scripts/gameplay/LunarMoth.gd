class_name LunarMoth
extends Area2D

@export var flight_speed: float = 40.0

var target_position: Vector2 = Vector2.ZERO
var target_grid_pos: Vector2i = Vector2i(-1, -1)
var state: String = "entering" # "entering", "pollinating", "leaving"
var pollinate_timer: float = 0.0
var flap_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	pick_pollination_target()

func _process(delta: float) -> void:
	flap_timer += delta
	# Delicate wing flutter
	if sprite:
		sprite.scale.x = sin(flap_timer * 12.0)
		
	if state == "entering":
		position = position.move_toward(target_position, flight_speed * delta)
		if position.distance_to(target_position) < 8.0:
			state = "pollinating"
			pollinate_timer = 3.5
			SignalBus.notification_posted.emit("A Lunar Silk Moth is bathing a night flower in starlight...", Color(0.6, 0.9, 0.9))
	elif state == "pollinating":
		pollinate_timer -= delta
		if pollinate_timer <= 0.0:
			SignalBus.lunar_moth_pollinated.emit(target_grid_pos)
			SignalBus.notification_posted.emit("✨ Lunar Moon Dust accelerated crop growth!", Color(0.5, 1.0, 0.8))
			state = "leaving"
			target_position = position + Vector2(randf_range(-300, 300), -400)
	elif state == "leaving":
		position = position.move_toward(target_position, (flight_speed + 20.0) * delta)
		if position.y < -100 or position.x < -100 or position.x > 1400:
			queue_free()

func pick_pollination_target() -> void:
	# Default target near garden center
	target_position = Vector2(640, 360) + Vector2(randf_range(-60, 60), randf_range(-40, 40))
