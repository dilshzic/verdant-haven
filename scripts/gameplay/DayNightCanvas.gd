class_name DayNightCanvas
extends CanvasModulate

@export var dawn_color: Color = Color(0.90, 0.75, 0.70)
@export var noon_color: Color = Color(1.0, 1.0, 1.0)
@export var dusk_color: Color = Color(0.95, 0.65, 0.45)
@export var night_color: Color = Color(0.35, 0.40, 0.65)

func _ready() -> void:
	SignalBus.time_ticked.connect(_on_time_ticked)

func _on_time_ticked(_minute: int, hour: int, _day: int, _season: String) -> void:
	var target_color = calculate_sky_color(hour)
	var tw = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "color", target_color, 1.0)

func calculate_sky_color(hour: int) -> Color:
	if hour >= 5 and hour < 8:
		# Dawn transition
		var factor = (hour - 5.0) / 3.0
		return night_color.lerp(dawn_color, factor)
	elif hour >= 8 and hour < 17:
		# Full daylight
		return noon_color
	elif hour >= 17 and hour < 20:
		# Dusk transition
		var factor = (hour - 17.0) / 3.0
		return noon_color.lerp(dusk_color, factor)
	elif hour >= 20 and hour < 22:
		# Twilight into night
		var factor = (hour - 20.0) / 2.0
		return dusk_color.lerp(night_color, factor)
	else:
		# Deep night
		return night_color
