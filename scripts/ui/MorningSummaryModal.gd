class_name MorningSummaryModal
extends Control

@onready var title_label: Label = $Panel/VBox/TitleLabel if has_node("Panel/VBox/TitleLabel") else null
@onready var hours_label: Label = $Panel/VBox/HoursLabel if has_node("Panel/VBox/HoursLabel") else null
@onready var dew_label: Label = $Panel/VBox/DewLabel if has_node("Panel/VBox/DewLabel") else null
@onready var crops_label: Label = $Panel/VBox/CropsLabel if has_node("Panel/VBox/CropsLabel") else null
@onready var quote_label: Label = $Panel/VBox/QuoteLabel if has_node("Panel/VBox/QuoteLabel") else null

func _ready() -> void:
	visible = false
	SignalBus.offline_growth_processed.connect(show_summary)

func show_summary(summary: Dictionary) -> void:
	visible = true
	var hours = summary.get("elapsed_hours", 0.0)
	var dew = summary.get("dream_dew_awarded", 0)
	var crops: Array = summary.get("matured_crops", [])
	var is_overnight = summary.get("is_overnight", false)
	var quote = summary.get("reflection_quote", "Nature does not hurry, yet everything is accomplished.")
	
	if title_label:
		title_label.text = "🌅 Dawn Awakening Sanctuary" if is_overnight else "🍃 Welcome Back, Gentle Gardener"
		
	if hours_label:
		if hours >= 1.0:
			hours_label.text = "Time Rested: %.1f Hours Away" % hours
		else:
			hours_label.text = "Time Rested: %d Minutes" % int(hours * 60.0)
			
	if dew_label:
		dew_label.text = "✨ Harvested %d Dream Dew Droplets" % dew
		
	if crops_label:
		if crops.size() > 0:
			crops_label.text = "Crops Ready for Harvest: " + ", ".join(crops)
		else:
			crops_label.text = "Roots have strengthened and soil is moistened with dew."
			
	if quote_label:
		quote_label.text = '"%s"' % quote

func _on_close_button_pressed() -> void:
	visible = false
