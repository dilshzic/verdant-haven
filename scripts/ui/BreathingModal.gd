class_name BreathingModal
extends Control

@onready var label_phase: Label = $Panel/VBox/PhaseLabel if has_node("Panel/VBox/PhaseLabel") else null
@onready var label_guide: Label = $Panel/VBox/GuideLabel if has_node("Panel/VBox/GuideLabel") else null
@onready var label_cycles: Label = $Panel/VBox/CyclesLabel if has_node("Panel/VBox/CyclesLabel") else null
@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar if has_node("Panel/VBox/ProgressBar") else null
@onready var start_btn: Button = $Panel/VBox/Buttons/StartBtn if has_node("Panel/VBox/Buttons/StartBtn") else null
@onready var lotus_visual: TextureRect = $Panel/LotusContainer/LotusVisual if has_node("Panel/LotusContainer/LotusVisual") else null

var controller: MindfulBreathingController

func _ready() -> void:
	controller = MindfulBreathingController.new()
	add_child(controller)
	
	controller.phase_updated.connect(_on_phase_updated)
	controller.session_completed.connect(_on_session_completed)

func open(pattern_id: String = "box") -> void:
	visible = true
	controller.start_session(pattern_id, 4)
	if start_btn:
		start_btn.text = "End Breathwork"

func close() -> void:
	if controller.is_active:
		controller.stop_session()
	visible = false

func _on_phase_updated(phase_name: String, guide_text: String, progress: float, scale_val: float) -> void:
	if label_phase:
		label_phase.text = phase_name.to_upper()
	if label_guide:
		label_guide.text = guide_text
	if progress_bar:
		progress_bar.value = progress * 100.0
	if label_cycles:
		label_cycles.text = "Cycle: %d / %d" % [controller.completed_cycles + 1, controller.target_cycles]
		
	if lotus_visual:
		lotus_visual.scale = Vector2(scale_val, scale_val)

func _on_session_completed(cycles: int, prana_dew: int) -> void:
	if label_phase:
		label_phase.text = "PEACEFUL RESTORATION"
	if label_guide:
		label_guide.text = "Session complete! Infused garden with +%d Prana Dew & holy moisture." % prana_dew
	if start_btn:
		start_btn.text = "Begin New Session"

func _on_start_btn_pressed() -> void:
	if controller.is_active:
		controller.stop_session()
		if start_btn:
			start_btn.text = "Begin Breathwork"
		if label_phase:
			label_phase.text = "READY"
		if label_guide:
			label_guide.text = "Select a rhythm and begin breathing."
	else:
		controller.start_session("box", 4)
		if start_btn:
			start_btn.text = "End Breathwork"

func _on_close_btn_pressed() -> void:
	close()
