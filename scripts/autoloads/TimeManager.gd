extends Node

const SEASONS: Array[String] = ["Spring", "Summer", "Autumn", "Winter"]
const WEATHERS: Array[String] = ["Sunny", "Rainy", "Overcast", "Breezy", "Mystical Fog"]

# Real seconds per game minute (0.5s = 1 game minute, 30s = 1 game hour, 12 min = 1 game day)
@export var seconds_per_game_minute: float = 0.4

var game_minute: int = 0
var game_hour: int = 6 # Starts at 6:00 AM
var game_day: int = 1
var season_index: int = 0
var current_weather: String = "Sunny"

var time_accumulator: float = 0.0
var is_paused: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_paused:
		return
		
	time_accumulator += delta
	if time_accumulator >= seconds_per_game_minute:
		time_accumulator -= seconds_per_game_minute
		advance_minute()

func advance_minute() -> void:
	game_minute += 10 # Advances in 10-minute blocks for smooth pacing
	if game_minute >= 60:
		game_minute = 0
		advance_hour()
		
	SignalBus.time_ticked.emit(game_minute, game_hour, game_day, get_current_season())

func advance_hour() -> void:
	game_hour += 1
	if game_hour >= 24:
		game_hour = 0
		advance_day()

func advance_day() -> void:
	game_day += 1
	if game_day % 28 == 1 and game_day > 1: # 28 days per season
		season_index = (season_index + 1) % SEASONS.size()
		
	determine_daily_weather()
	SignalBus.day_advanced.emit(game_day, get_current_season())

func determine_daily_weather() -> void:
	var roll = randf()
	if get_current_season() == "Spring":
		current_weather = "Rainy" if roll < 0.35 else "Sunny"
	elif get_current_season() == "Summer":
		current_weather = "Rainy" if roll < 0.15 else "Sunny"
	elif get_current_season() == "Autumn":
		current_weather = "Breezy" if roll < 0.40 else "Overcast"
	elif get_current_season() == "Winter":
		current_weather = "Mystical Fog" if roll < 0.30 else "Overcast"
		
	SignalBus.weather_changed.emit(current_weather)

func get_current_season() -> String:
	return SEASONS[season_index]

func get_time_string() -> String:
	var ampm = "AM" if game_hour < 12 else "PM"
	var display_hour = game_hour % 12
	if display_hour == 0:
		display_hour = 12
	return "%02d:%02d %s" % [display_hour, game_minute, ampm]

func get_daylight_factor() -> float:
	# Returns 0.0 at midnight, peaks at 1.0 at noon
	if game_hour >= 6 and game_hour <= 18:
		var norm = (game_hour - 6.0 + game_minute / 60.0) / 12.0
		return sin(norm * PI)
	return 0.1 # Night ambient light
