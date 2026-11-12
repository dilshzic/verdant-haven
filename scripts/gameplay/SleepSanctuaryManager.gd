class_name SleepSanctuaryManager
extends Node

var is_sleeping: bool = false
var sleep_start_timestamp: int = 0
var sleep_timer_minutes: int = 0
var timer_remaining_seconds: float = 0.0

var selected_soundscape: String = "rain" # rain, crickets, bowl, pond
var bedtime_intention: String = "Restful Healing"

signal sleep_state_changed(is_sleeping: bool)
signal sleep_timer_updated(minutes_left: int, seconds_left: int)
signal soundscape_changed(sound_id: String)

func enter_sleep_mode(intention: String = "Peaceful Rest", timer_minutes: int = 0, soundscape: String = "rain") -> void:
	is_sleeping = true
	sleep_start_timestamp = int(Time.get_unix_time_from_system())
	bedtime_intention = intention
	sleep_timer_minutes = timer_minutes
	timer_remaining_seconds = timer_minutes * 60.0
	selected_soundscape = soundscape
	
	sleep_state_changed.emit(true)
	soundscape_changed.emit(selected_soundscape)
	SignalBus.sleep_sanctuary_started.emit(intention, timer_minutes)
	SignalBus.notification_posted.emit("Entering Sleep Sanctuary... Sweet dreams.", Color(0.6, 0.7, 1.0))

func wake_up() -> void:
	if not is_sleeping:
		return
		
	var current_time = int(Time.get_unix_time_from_system())
	var seconds_slept = max(60, current_time - sleep_start_timestamp)
	var hours_slept = seconds_slept / 3600.0
	
	is_sleeping = false
	sleep_state_changed.emit(false)
	
	# Process offline/sleep growth
	if has_node("/root/OfflineGrowthManager"):
		get_node("/root/OfflineGrowthManager").apply_offline_growth(seconds_slept)

func _process(delta: float) -> void:
	if not is_sleeping:
		return
		
	if sleep_timer_minutes > 0:
		timer_remaining_seconds -= delta
		var mins = int(timer_remaining_seconds / 60.0)
		var secs = int(timer_remaining_seconds) % 60
		sleep_timer_updated.emit(mins, secs)
		
		if timer_remaining_seconds <= 0.0:
			# Gentle timer completion
			sleep_timer_minutes = 0
			SignalBus.notification_posted.emit("Sleep timer finished. Soundscape gently fading...", Color(0.7, 0.8, 1.0))

func set_soundscape(sound_id: String) -> void:
	selected_soundscape = sound_id
	soundscape_changed.emit(selected_soundscape)
