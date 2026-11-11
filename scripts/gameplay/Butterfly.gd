class_name Butterfly
extends Node2D

enum State {
	FLYING,
	PERCHED,
	DEPARTING
}

@export var color_type: String = "orange" # orange, blue, yellow
@export var flutter_speed: float = 8.0
@export var move_speed: float = 45.0

var current_state: State = State.FLYING
var target_pos: Vector2 = Vector2.ZERO
var perch_timer: float = 0.0
var flight_time: float = 0.0

var tex_open: Texture2D
var tex_closed: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	tex_open = load("res://assets/sprites/creatures/butterfly_%s_open.png" % color_type)
	tex_closed = load("res://assets/sprites/creatures/butterfly_%s_closed.png" % color_type)
	if sprite:
		sprite.texture = tex_open

func setup(c_type: String, start_pos: Vector2, destination: Vector2) -> void:
	color_type = c_type
	global_position = start_pos
	target_pos = destination
	current_state = State.FLYING
	tex_open = load("res://assets/sprites/creatures/butterfly_%s_open.png" % color_type)
	tex_closed = load("res://assets/sprites/creatures/butterfly_%s_closed.png" % color_type)
	if sprite:
		sprite.texture = tex_open

func _process(delta: float) -> void:
	flight_time += delta
	
	# Wing flap animation
	var flap_phase = sin(flight_time * flutter_speed)
	if sprite:
		sprite.texture = tex_closed if flap_phase > 0.3 else tex_open
		
	match current_state:
		State.FLYING:
			handle_flying(delta)
		State.PERCHED:
			handle_perched(delta)
		State.DEPARTING:
			handle_departing(delta)

func handle_flying(delta: float) -> void:
	# Add natural flutter wandering
	var dir = (target_pos - global_position).normalized()
	var flutter_offset = Vector2(-dir.y, dir.x) * sin(flight_time * 6.0) * 15.0
	var vel = (dir * move_speed) + flutter_offset
	
	global_position += vel * delta
	
	if dir.x != 0 and sprite:
		sprite.flip_h = dir.x < 0
		
	if global_position.distance_to(target_pos) < 8.0:
		current_state = State.PERCHED
		perch_timer = randf_range(3.0, 6.0)
		flutter_speed = 2.0 # Slow wing fanning while drinking nectar
		SignalBus.notification_posted.emit("A %s butterfly landed to pollinate flowers!" % color_type.capitalize(), Color(0.9, 0.6, 1.0))

func handle_perched(delta: float) -> void:
	perch_timer -= delta
	if perch_timer <= 0:
		current_state = State.DEPARTING
		flutter_speed = 9.0
		# Pick off-screen exit direction
		target_pos = global_position + Vector2(randf_range(-150, 150), -300)

func handle_departing(delta: float) -> void:
	var dir = (target_pos - global_position).normalized()
	global_position += dir * (move_speed * 1.3) * delta
	if global_position.y < -50 or global_position.y > 800:
		queue_free()
