class_name Fish
extends Node2D

enum State {
	SWIMMING,
	EATING,
	BASKING
}

@export var fish_type: String = "koi_gold" # koi_gold, koi_calico, fish_blue, fish_dragon
@export var swim_speed: float = 30.0

var current_state: State = State.SWIMMING
var pond_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(160, 110))
var target_pos: Vector2 = Vector2.ZERO
var swim_time: float = 0.0
var velocity: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	update_texture()
	pick_random_target()

func setup(f_type: String, bounds: Rect2) -> void:
	fish_type = f_type
	pond_bounds = bounds
	update_texture()
	pick_random_target()

func update_texture() -> void:
	if sprite:
		var path = "res://assets/sprites/pond/%s.png" % fish_type
		if ResourceLoader.exists(path):
			sprite.texture = load(path)

func _process(delta: float) -> void:
	swim_time += delta
	
	match current_state:
		State.SWIMMING:
			handle_swimming(delta)
		State.EATING:
			handle_eating(delta)
		State.BASKING:
			handle_basking(delta)

func handle_swimming(delta: float) -> void:
	var to_target = target_pos - position
	if to_target.length() < 8.0:
		pick_random_target()
		if randf() < 0.25:
			current_state = State.BASKING
			return
			
	var dir = to_target.normalized()
	# Add subtle swimming fish sine wag
	var wag = Vector2(-dir.y, dir.x) * sin(swim_time * 5.0) * 8.0
	velocity = velocity.lerp((dir * swim_speed) + wag, delta * 3.0)
	position += velocity * delta
	
	# Clamp inside pond bounds
	position.x = clamp(position.x, pond_bounds.position.x, pond_bounds.position.x + pond_bounds.size.x)
	position.y = clamp(position.y, pond_bounds.position.y, pond_bounds.position.y + pond_bounds.size.y)
	
	# Rotate towards velocity
	if velocity.length() > 2.0 and sprite:
		sprite.rotation = velocity.angle()
		# Keep fish right-side up visually
		sprite.flip_v = abs(sprite.rotation) > PI / 2.0

func pick_random_target() -> void:
	target_pos = Vector2(
		randf_range(pond_bounds.position.x + 10, pond_bounds.position.x + pond_bounds.size.x - 10),
		randf_range(pond_bounds.position.y + 10, pond_bounds.position.y + pond_bounds.size.y - 10)
	)

func feed_at(food_pos: Vector2) -> void:
	target_pos = food_pos
	current_state = State.EATING
	swim_speed = 55.0 # Rush excitedly to food

func handle_eating(delta: float) -> void:
	var to_target = target_pos - position
	var dir = to_target.normalized()
	position += dir * swim_speed * delta
	if sprite:
		sprite.rotation = dir.angle()
		
	if to_target.length() < 10.0:
		# Nibble food and splash
		play_happy_splash()
		swim_speed = 30.0
		current_state = State.SWIMMING
		pick_random_target()

func handle_basking(delta: float) -> void:
	# Gently float in place under water lily
	position += Vector2(sin(swim_time * 1.5) * 2.0, cos(swim_time * 1.5) * 1.5) * delta
	if randf() < 0.01:
		current_state = State.SWIMMING
		pick_random_target()

func play_happy_splash() -> void:
	var tw = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.15)
	tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Drop bonus pond pearl
	if randf() < 0.35:
		InventoryManager.add_coins(15)
		SignalBus.notification_posted.emit("The Koi leaped happily and gifted a Pond Pearl! (+15 G)", Color(0.3, 0.9, 1.0))
