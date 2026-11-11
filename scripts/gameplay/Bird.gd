class_name Bird
extends Node2D

enum State {
	APPROACHING,
	IDLE,
	PECKING,
	FLEEING
}

@export var bird_type: String = "robin" # robin or bluebird
@export var flight_speed: float = 90.0

var current_state: State = State.APPROACHING
var target_landing: Vector2 = Vector2.ZERO
var state_timer: float = 0.0
var pecks_remaining: int = 3
var has_gifted: bool = false

var tex_idle: Texture2D
var tex_peck: Texture2D
var tex_fly: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
var player_ref: Node2D = null

func _ready() -> void:
	tex_idle = load("res://assets/sprites/creatures/bird_%s_idle.png" % bird_type)
	tex_peck = load("res://assets/sprites/creatures/bird_%s_peck.png" % bird_type)
	tex_fly = load("res://assets/sprites/creatures/bird_%s_fly.png" % bird_type)
	if sprite:
		sprite.texture = tex_fly

func setup(b_type: String, start_pos: Vector2, landing_pos: Vector2, player: Node2D = null) -> void:
	bird_type = b_type
	global_position = start_pos
	target_landing = landing_pos
	player_ref = player
	current_state = State.APPROACHING
	
	tex_idle = load("res://assets/sprites/creatures/bird_%s_idle.png" % bird_type)
	tex_peck = load("res://assets/sprites/creatures/bird_%s_peck.png" % bird_type)
	tex_fly = load("res://assets/sprites/creatures/bird_%s_fly.png" % bird_type)
	if sprite:
		sprite.texture = tex_fly

func _process(delta: float) -> void:
	check_player_proximity()
	
	match current_state:
		State.APPROACHING:
			handle_approaching(delta)
		State.IDLE:
			handle_idle(delta)
		State.PECKING:
			handle_pecking(delta)
		State.FLEEING:
			handle_fleeing(delta)

func check_player_proximity() -> void:
	if current_state == State.FLEEING or not player_ref:
		return
	if global_position.distance_to(player_ref.global_position) < 55.0:
		startle_and_flee()

func handle_approaching(delta: float) -> void:
	if sprite:
		sprite.texture = tex_fly
	var dir = (target_landing - global_position).normalized()
	global_position += dir * flight_speed * delta
	if dir.x != 0 and sprite:
		sprite.flip_h = dir.x < 0
		
	if global_position.distance_to(target_landing) < 6.0:
		global_position = target_landing
		current_state = State.IDLE
		state_timer = randf_range(1.5, 3.0)
		if sprite:
			sprite.texture = tex_idle

func handle_idle(delta: float) -> void:
	if sprite:
		sprite.texture = tex_idle
	state_timer -= delta
	if state_timer <= 0:
		# Randomly decide to peck, hop, or leave
		if pecks_remaining > 0 and randf() < 0.7:
			current_state = State.PECKING
			state_timer = 0.6
			pecks_remaining -= 1
		else:
			# Hop slightly or fly away
			if randf() < 0.4:
				startle_and_flee()
			else:
				# Hop a few pixels
				hop_to(global_position + Vector2(randf_range(-12, 12), randf_range(-6, 6)))
				state_timer = 2.0

func handle_pecking(delta: float) -> void:
	if sprite:
		sprite.texture = tex_peck
	state_timer -= delta
	if state_timer <= 0:
		current_state = State.IDLE
		state_timer = 1.2
		# Chance to drop gift seed on third peck
		if pecks_remaining == 0 and not has_gifted and randf() < 0.45:
			gift_seed_to_garden()

func gift_seed_to_garden() -> void:
	has_gifted = true
	var gifts = ["radish", "chamomile", "peppermint", "strawberry"]
	var chosen = gifts[randi() % gifts.size()]
	var p_data = AlmanacManager.plant_catalog.get(chosen, {})
	InventoryManager.add_item("seed_" + chosen, "seed", p_data.get("name", "Wild") + " Seeds", 1, "res://assets/sprites/plants/%s_stage_0.png" % chosen, chosen)
	SignalBus.notification_posted.emit("A visiting %s gifted you wild seeds!" % bird_type.capitalize(), Color(0.4, 0.9, 0.5))

func hop_to(new_pos: Vector2) -> void:
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "global_position:y", global_position.y - 6.0, 0.1)
	tw.tween_property(self, "global_position:y", new_pos.y, 0.1)
	tw.parallel().tween_property(self, "global_position:x", new_pos.x, 0.2)

func startle_and_flee() -> void:
	if current_state == State.FLEEING:
		return
	current_state = State.FLEEING
	if sprite:
		sprite.texture = tex_fly
		
	# Hop up first, then soar into the sky
	var escape_dir = Vector2(randf_range(-1.0, 1.0), -1.5).normalized()
	if escape_dir.x != 0 and sprite:
		sprite.flip_h = escape_dir.x < 0
	SignalBus.notification_posted.emit("The songbird fluttered away into the sky!", Color(0.7, 0.8, 1.0))

func handle_fleeing(delta: float) -> void:
	global_position += Vector2(sprite.flip_h and -1.0 or 1.0, -1.2).normalized() * (flight_speed * 1.4) * delta
	if global_position.y < -60:
		queue_free()
