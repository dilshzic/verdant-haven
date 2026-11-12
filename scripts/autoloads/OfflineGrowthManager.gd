class_name OfflineGrowthManager
extends Node

const SAVE_PATH: String = "user://garden_offline_state.json"
const MIN_OFFLINE_SECONDS_FOR_PROGRESS: float = 60.0 # At least 1 minute away

var last_active_timestamp: int = 0
var dream_dew_count: int = 0
var total_sleep_hours_accumulated: float = 0.0

var garden_grid_ref: Node = null # Set by GameWorld or GardenGrid

func _ready() -> void:
	load_offline_state()
	process_offline_progression()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_offline_state()
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		process_offline_progression()

func register_garden_grid(grid: Node) -> void:
	garden_grid_ref = grid

func save_offline_state() -> void:
	last_active_timestamp = int(Time.get_unix_time_from_system())
	var state = {
		"last_active_timestamp": last_active_timestamp,
		"dream_dew_count": dream_dew_count,
		"total_sleep_hours": total_sleep_hours_accumulated,
		"save_date_utc": Time.get_datetime_string_from_system(true)
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state, "\t"))
		file.close()

func load_offline_state() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		last_active_timestamp = int(Time.get_unix_time_from_system())
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(content)
		if parse_result == OK and json.data is Dictionary:
			var data = json.data
			last_active_timestamp = int(data.get("last_active_timestamp", Time.get_unix_time_from_system()))
			dream_dew_count = int(data.get("dream_dew_count", 0))
			total_sleep_hours_accumulated = float(data.get("total_sleep_hours", 0.0))
		else:
			last_active_timestamp = int(Time.get_unix_time_from_system())

func process_offline_progression() -> void:
	var current_time = int(Time.get_unix_time_from_system())
	if last_active_timestamp <= 0:
		last_active_timestamp = current_time
		save_offline_state()
		return
		
	var elapsed_seconds = current_time - last_active_timestamp
	if elapsed_seconds < MIN_OFFLINE_SECONDS_FOR_PROGRESS:
		last_active_timestamp = current_time
		return
		
	apply_offline_growth(elapsed_seconds)
	last_active_timestamp = current_time
	save_offline_state()

func simulate_offline_hours(hours: float) -> void:
	var simulated_seconds = int(hours * 3600.0)
	apply_offline_growth(simulated_seconds, true)
	save_offline_state()

func apply_offline_growth(elapsed_seconds: int, is_simulation: bool = false) -> void:
	var elapsed_hours = elapsed_seconds / 3600.0
	var elapsed_minutes = elapsed_seconds / 60.0
	
	total_sleep_hours_accumulated += elapsed_hours
	
	# Generative Absence: Calculate Dream Dew droplets (1 per 30 mins, max 24 per session)
	var new_dew = int(clamp(elapsed_minutes / 30.0, 1.0, 24.0))
	dream_dew_count += new_dew
	SignalBus.dream_dew_collected.emit(new_dew)
	
	# Detect overnight sleep (either >= 6 hours away or away across real midnight 23:00 - 06:00)
	var is_overnight = elapsed_hours >= 5.0
	
	# Equivalent game days to advance: in our game, 12 real minutes = 1 game day.
	# But for offline sleep balance, 1 real hour away = 1 full game day of serene growth.
	var simulated_game_days = max(1, int(elapsed_hours))
	if elapsed_hours < 1.0:
		simulated_game_days = 1
	
	var matured_crops: Array[String] = []
	
	# If GardenGrid is bound, apply gentle offline growth directly
	if garden_grid_ref and garden_grid_ref.has_method("apply_offline_cycle"):
		matured_crops = garden_grid_ref.apply_offline_cycle(simulated_game_days, is_overnight)
	
	var summary = {
		"elapsed_seconds": elapsed_seconds,
		"elapsed_hours": elapsed_hours,
		"simulated_days": simulated_game_days,
		"dream_dew_awarded": new_dew,
		"total_dream_dew": dream_dew_count,
		"matured_crops": matured_crops,
		"is_overnight": is_overnight,
		"is_simulation": is_simulation,
		"reflection_quote": get_random_reflection()
	}
	
	SignalBus.offline_growth_processed.emit(summary)
	
	var notice_text = "Awakened from rest! Collected %d Dream Dew drops." % new_dew
	if is_overnight:
		notice_text = "Good morning! Night dew has nourished your garden (+%d Dream Dew)." % new_dew
	SignalBus.notification_posted.emit(notice_text, Color(0.4, 0.9, 0.8))

func spend_dream_dew(amount: int) -> bool:
	if dream_dew_count >= amount:
		dream_dew_count -= amount
		save_offline_state()
		return true
	return false

func add_dream_dew(amount: int) -> void:
	dream_dew_count += amount
	save_offline_state()
	SignalBus.dream_dew_collected.emit(amount)

func get_random_reflection() -> String:
	var reflections = [
		"In the quiet stillness of the earth, unseen roots reach deep.",
		"Growth does not hurry; yet everything is accomplished.",
		"Like a garden resting under moonlight, your mind renews in silence.",
		"Morning dew brings gentle blessings to the patient heart.",
		"Each breath is a seedling; each pause is fertile soil.",
		"You do not have to strive constantly. Nature flourishes when you let it be."
	]
	return reflections[randi() % reflections.size()]
