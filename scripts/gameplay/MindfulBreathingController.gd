class_name MindfulBreathingController
extends Node

const PATTERNS: Dictionary = {
	"box": {
		"name": "Box Breathing (4-4-4-4)",
		"desc": "Calms the nervous system, centers attention, and relieves anxiety.",
		"phases": [
			{"name": "Inhale", "duration": 4.0, "scale_target": 1.4, "guide": "Breathe in deeply through the nose..."},
			{"name": "Hold", "duration": 4.0, "scale_target": 1.4, "guide": "Gently hold the breath..."},
			{"name": "Exhale", "duration": 4.0, "scale_target": 0.8, "guide": "Slowly release through the mouth..."},
			{"name": "Rest", "duration": 4.0, "scale_target": 0.8, "guide": "Be still and present..."}
		]
	},
	"sleep_478": {
		"name": "Relaxing Breath (4-7-8)",
		"desc": "Natural tranquilizer for the nervous system, preparing the mind for sleep.",
		"phases": [
			{"name": "Inhale", "duration": 4.0, "scale_target": 1.5, "guide": "Inhale quietly through your nose..."},
			{"name": "Hold", "duration": 7.0, "scale_target": 1.5, "guide": "Hold your breath with soft relaxation..."},
			{"name": "Exhale", "duration": 8.0, "scale_target": 0.7, "guide": "Make a gentle whoosh sound as you exhale..."},
			{"name": "Rest", "duration": 1.0, "scale_target": 0.7, "guide": "Pause softly..."}
		]
	},
	"coherence_55": {
		"name": "Heart Coherence (5-5)",
		"desc": "Synchronizes heart rate variability, bringing mental clarity and peace.",
		"phases": [
			{"name": "Inhale", "duration": 5.0, "scale_target": 1.4, "guide": "Smooth, gentle inhale..."},
			{"name": "Exhale", "duration": 5.0, "scale_target": 0.8, "guide": "Smooth, gentle exhale..."}
		]
	}
}

var current_pattern_id: String = "box"
var is_active: bool = false

var current_phase_index: int = 0
var phase_elapsed: float = 0.0
var completed_cycles: int = 0
var target_cycles: int = 4

# Visual interpolation for UI lotus blossom
var current_scale: float = 1.0
var visual_progress: float = 0.0 # 0.0 to 1.0 within current phase

signal session_started(pattern_name: String)
signal phase_updated(phase_name: String, guide_text: String, progress: float, scale_val: float)
signal session_completed(cycles: int, prana_dew: int)

func start_session(pattern_id: String = "box", cycles: int = 4) -> void:
	if not PATTERNS.has(pattern_id):
		pattern_id = "box"
		
	current_pattern_id = pattern_id
	target_cycles = cycles
	completed_cycles = 0
	current_phase_index = 0
	phase_elapsed = 0.0
	is_active = true
	current_scale = 1.0
	
	var pattern = PATTERNS[current_pattern_id]
	session_started.emit(pattern["name"])
	
	var first_phase = pattern["phases"][0]
	SignalBus.breath_phase_changed.emit(first_phase["name"], first_phase["duration"])

func stop_session() -> void:
	is_active = false
	current_phase_index = 0
	phase_elapsed = 0.0

func _process(delta: float) -> void:
	if not is_active:
		return
		
	var pattern = PATTERNS[current_pattern_id]
	var phases: Array = pattern["phases"]
	var phase = phases[current_phase_index]
	var duration: float = phase["duration"]
	
	phase_elapsed += delta
	visual_progress = clamp(phase_elapsed / duration, 0.0, 1.0)
	
	# Smooth easing for visual lotus expansion
	var target_scale = phase["scale_target"]
	current_scale = lerp(current_scale, target_scale, delta * 3.0)
	
	phase_updated.emit(phase["name"], phase["guide"], visual_progress, current_scale)
	
	if phase_elapsed >= duration:
		phase_elapsed = 0.0
		current_phase_index += 1
		
		# Finished one full cycle
		if current_phase_index >= phases.size():
			current_phase_index = 0
			completed_cycles += 1
			
			if completed_cycles >= target_cycles:
				finish_session()
				return
				
		var next_phase = phases[current_phase_index]
		SignalBus.breath_phase_changed.emit(next_phase["name"], next_phase["duration"])

func finish_session() -> void:
	is_active = false
	var prana_dew = completed_cycles * 3
	
	# Award Dream/Prana Dew in offline manager
	if has_node("/root/OfflineGrowthManager"):
		get_node("/root/OfflineGrowthManager").add_dream_dew(prana_dew)
		
	SignalBus.breath_cycle_completed.emit(completed_cycles, prana_dew)
	SignalBus.garden_blessed.emit("prana")
	session_completed.emit(completed_cycles, prana_dew)
