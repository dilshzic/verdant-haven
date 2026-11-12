class_name FocusModal
extends Control

@onready var timer_label: Label = $Panel/VBox/TimerLabel if has_node("Panel/VBox/TimerLabel") else null
@onready var tree_label: Label = $Panel/VBox/TreeLabel if has_node("Panel/VBox/TreeLabel") else null
@onready var progress_bar: ProgressBar = $Panel/VBox/ProgressBar if has_node("Panel/VBox/ProgressBar") else null
@onready var action_btn: Button = $Panel/VBox/ActionBtn if has_node("Panel/VBox/ActionBtn") else null

var focus_manager: FocusGroveManager

const STAGE_NAMES = [
	"🌱 Delicate Sprout",
	"🌿 Growing Sapling",
	"🌳 Branching Bodhi Tree",
	"🍃 Lush Full Canopy",
	"🌸 Sacred Golden Blossom"
]

func _ready() -> void:
	focus_manager = FocusGroveManager.new()
	add_child(focus_manager)
	
	focus_manager.focus_tick.connect(_on_focus_tick)
	focus_manager.focus_completed.connect(_on_focus_completed)

func open() -> void:
	visible = true

func close() -> void:
	visible = false

func _on_focus_tick(remaining_seconds: float, progress: float, stage: int) -> void:
	var mins = int(remaining_seconds / 60.0)
	var secs = int(remaining_seconds) % 60
	if timer_label:
		timer_label.text = "%02d:%02d" % [mins, secs]
	if progress_bar:
		progress_bar.value = progress * 100.0
	if tree_label and stage < STAGE_NAMES.size():
		tree_label.text = STAGE_NAMES[stage]

func _on_focus_completed(minutes_done: int) -> void:
	if timer_label:
		timer_label.text = "Session Complete!"
	if tree_label:
		tree_label.text = "🌸 Sacred Bodhi Tree Blossomed! (+Garden Compost)"
	if action_btn:
		action_btn.text = "Start Another Session"

func _on_action_btn_pressed() -> void:
	if focus_manager.is_focusing:
		focus_manager.cancel_focus()
		if action_btn:
			action_btn.text = "Start Focus (25m)"
		if timer_label:
			timer_label.text = "25:00"
	else:
		focus_manager.start_focus(25)
		if action_btn:
			action_btn.text = "Cancel Session"

func _on_close_btn_pressed() -> void:
	close()
