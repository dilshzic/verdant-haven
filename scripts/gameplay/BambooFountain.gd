class_name BambooFountain
extends Node2D

@export var fill_duration: float = 6.0
@export var is_active: bool = true

var current_fill: float = 0.0
var is_tipping: bool = false

@onready var bamboo_rocker: Sprite2D = $RockerArm if has_node("RockerArm") else null
@onready var base_sprite: Sprite2D = $BaseSprite if has_node("BaseSprite") else null

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if not is_active or is_tipping:
		return
		
	current_fill += delta
	# Slight subtle weight sag as water accumulates
	if bamboo_rocker:
		bamboo_rocker.rotation_degrees = -5.0 + (current_fill / fill_duration) * 8.0
		
	if current_fill >= fill_duration:
		trigger_clack()

func trigger_clack() -> void:
	is_tipping = true
	current_fill = 0.0
	
	if not bamboo_rocker:
		is_tipping = false
		return
		
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# 1. Tips forward dumping water
	tw.tween_property(bamboo_rocker, "rotation_degrees", 28.0, 0.4)
	# 2. Snaps back down striking the rock
	tw.tween_property(bamboo_rocker, "rotation_degrees", -8.0, 0.15)
	tw.tween_callback(self._on_struck_stone)
	# 3. Settles back to resting position
	tw.tween_property(bamboo_rocker, "rotation_degrees", -5.0, 0.2)
	tw.tween_callback(func(): is_tipping = false)

func _on_struck_stone() -> void:
	SignalBus.bamboo_fountain_clacked.emit()
	# Screen-space subtle pulse or notification
	SignalBus.notification_posted.emit("🎋 *CLACK* — Mindful presence returns to the haven.", Color(0.6, 0.85, 0.5))

func toggle_fountain() -> void:
	is_active = not is_active
	if is_active:
		SignalBus.notification_posted.emit("Bamboo water fountain turned on.", Color(0.4, 0.8, 1.0))
	else:
		SignalBus.notification_posted.emit("Bamboo water fountain paused.", Color(0.7, 0.7, 0.7))
