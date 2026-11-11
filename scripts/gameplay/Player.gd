class_name Player
extends CharacterBody2D

@export var move_speed: float = 120.0
@export var garden_grid: GardenGrid

@onready var sprite: Sprite2D = $Sprite2D
@onready var selector: Sprite2D = $SelectorIndicator

var targeted_grid_pos: Vector2i = Vector2i.ZERO

func _physics_process(_delta: float) -> void:
	handle_movement()
	update_targeted_grid_pos()

func handle_movement() -> void:
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vec.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vec = input_vec.normalized()
	
	velocity = input_vec * move_speed
	move_and_slide()
	
	if input_vec.x != 0:
		sprite.flip_h = input_vec.x < 0

func update_targeted_grid_pos() -> void:
	if not garden_grid:
		return
		
	# Determine target cell either by mouse position or player facing offset
	var mouse_world = get_global_mouse_position()
	var grid_local = garden_grid.to_local(mouse_world)
	var tile_x = int(grid_local.x / GardenGrid.TILE_SIZE)
	var tile_y = int(grid_local.y / GardenGrid.TILE_SIZE)
	
	targeted_grid_pos = Vector2i(tile_x, tile_y)
	
	# Clamp to grid bounds
	if targeted_grid_pos.x >= 0 and targeted_grid_pos.x < GardenGrid.GRID_WIDTH and \
	   targeted_grid_pos.y >= 0 and targeted_grid_pos.y < GardenGrid.GRID_HEIGHT:
		selector.visible = true
		selector.global_position = garden_grid.to_global(Vector2(
			targeted_grid_pos.x * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0,
			targeted_grid_pos.y * GardenGrid.TILE_SIZE + GardenGrid.TILE_SIZE / 2.0
		))
	else:
		selector.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"):
		perform_action()

func perform_action() -> void:
	if not selector.visible or not garden_grid:
		return
		
	# Tool swing animation
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(sprite, "rotation", deg_to_rad(-15.0 if sprite.flip_h else 15.0), 0.08)
	tw.tween_property(sprite, "rotation", 0.0, 0.1)
	
	garden_grid.interact_with_tile(targeted_grid_pos)
