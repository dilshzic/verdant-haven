class_name FocusGroveManager
extends Node

var is_focusing: bool = false
var focus_target_minutes: int = 25
var focus_start_timestamp: int = 0
var focus_elapsed_seconds: float = 0.0

var tree_stage: int = 0 # 0: Sprout, 1: Sapling, 2: Young Tree, 3: Full Canopy, 4: Sacred Blossom

signal focus_tick(remaining_seconds: float, progress_ratio: float, current_stage: int)
signal focus_completed(minutes_done: int)

func start_focus(minutes: int = 25) -> void:
	focus_target_minutes = minutes
	focus_start_timestamp = int(Time.get_unix_time_from_system())
	focus_elapsed_seconds = 0.0
	tree_stage = 0
	is_focusing = true
	
	SignalBus.focus_grove_started.emit(minutes)
	SignalBus.notification_posted.emit("Focus session began (%d min). Your sacred tree begins to grow..." % minutes, Color(0.3, 0.9, 0.5))

func cancel_focus() -> void:
	if not is_focusing:
		return
	is_focusing = false
	# Generative Absence: Even if canceled, we don't punish the player!
	SignalBus.notification_posted.emit("Focus session paused gently. You can return whenever ready.", Color(0.8, 0.8, 0.6))

func _process(delta: float) -> void:
	if not is_focusing:
		return
		
	focus_elapsed_seconds += delta
	var total_target_seconds = focus_target_minutes * 60.0
	var progress = clamp(focus_elapsed_seconds / total_target_seconds, 0.0, 1.0)
	
	# Determine tree stage
	tree_stage = int(progress * 4.0)
	var remaining = max(0.0, total_target_seconds - focus_elapsed_seconds)
	focus_tick.emit(remaining, progress, tree_stage)
	
	if focus_elapsed_seconds >= total_target_seconds:
		finish_focus()

func finish_focus() -> void:
	is_focusing = false
	tree_stage = 4
	
	# Reward bonus compost and focus blessings
	SignalBus.garden_blessed.emit("focus")
	SignalBus.focus_grove_completed.emit(focus_target_minutes, tree_stage)
	focus_completed.emit(focus_target_minutes)
