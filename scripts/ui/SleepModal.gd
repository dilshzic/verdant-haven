class_name SleepModal
extends Control

@onready var intention_options: OptionButton = $Panel/VBox/IntentionRow/OptionBtn if has_node("Panel/VBox/IntentionRow/OptionBtn") else null
@onready var timer_options: OptionButton = $Panel/VBox/TimerRow/OptionBtn if has_node("Panel/VBox/TimerRow/OptionBtn") else null
@onready var sound_options: OptionButton = $Panel/VBox/SoundRow/OptionBtn if has_node("Panel/VBox/SoundRow/OptionBtn") else null

@onready var night_overlay: ColorRect = $NightOverlay if has_node("NightOverlay") else null
@onready var night_label: Label = $NightOverlay/VBox/NightLabel if has_node("NightOverlay/VBox/NightLabel") else null

var sanctuary_manager: SleepSanctuaryManager

func _ready() -> void:
	sanctuary_manager = SleepSanctuaryManager.new()
	add_child(sanctuary_manager)
	
	sanctuary_manager.sleep_state_changed.connect(_on_sleep_state_changed)
	sanctuary_manager.sleep_timer_updated.connect(_on_sleep_timer_updated)

func open() -> void:
	visible = true

func close() -> void:
	visible = false

func _on_sleep_state_changed(is_sleeping: bool) -> void:
	if night_overlay:
		night_overlay.visible = is_sleeping
	if is_sleeping and night_label:
		night_label.text = "🌙 Resting peacefully in the Sanctuary...\nIntention: %s" % sanctuary_manager.bedtime_intention

func _on_sleep_timer_updated(mins: int, secs: int) -> void:
	if night_label and sanctuary_manager.is_sleeping:
		night_label.text = "🌙 Resting in the Sanctuary...\nTimer: %02d:%02d\nSoundscape: %s" % [mins, secs, sanctuary_manager.selected_soundscape.capitalize()]

func _on_enter_sleep_pressed() -> void:
	var intention = "Deep Restoration"
	if intention_options:
		intention = intention_options.get_item_text(intention_options.selected)
		
	var timer_mins = 0
	if timer_options:
		var idx = timer_options.selected
		var timer_values = [0, 15, 30, 45, 60]
		if idx < timer_values.size():
			timer_mins = timer_values[idx]
			
	var sound = "rain"
	if sound_options:
		var sounds = ["rain", "crickets", "bowl", "pond"]
		var s_idx = sound_options.selected
		if s_idx < sounds.size():
			sound = sounds[s_idx]
			
	sanctuary_manager.enter_sleep_mode(intention, timer_mins, sound)

func _on_wake_up_pressed() -> void:
	sanctuary_manager.wake_up()

# Fast-forward simulation helper for testing offline growth
func _on_simulate_sleep_pressed(hours: float) -> void:
	if has_node("/root/OfflineGrowthManager"):
		get_node("/root/OfflineGrowthManager").simulate_offline_hours(hours)
