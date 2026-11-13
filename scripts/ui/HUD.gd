class_name HUD
extends CanvasLayer

@onready var label_time: Label = $TopBar/TimeLabel
@onready var label_date: Label = $TopBar/DateLabel
@onready var label_weather: Label = $TopBar/WeatherLabel
@onready var label_coins: Label = $TopBar/CoinsLabel
@onready var label_dew: Label = $TopBar/DewLabel if has_node("TopBar/DewLabel") else null
@onready var notify_container: VBoxContainer = $NotificationContainer

@onready var shop_modal: Control = $ShopModal if has_node("ShopModal") else null
@onready var almanac_modal: Control = $AlmanacModal if has_node("AlmanacModal") else null
@onready var breathing_modal: Control = $BreathingModal if has_node("BreathingModal") else null
@onready var sleep_modal: Control = $SleepModal if has_node("SleepModal") else null
@onready var focus_modal: Control = $FocusModal if has_node("FocusModal") else null
@onready var morning_modal: Control = $MorningSummaryModal if has_node("MorningSummaryModal") else null
@onready var tea_modal: Control = $TeaBrewingModal if has_node("TeaBrewingModal") else null

func _ready() -> void:
	SignalBus.time_ticked.connect(_on_time_ticked)
	SignalBus.coins_changed.connect(_on_coins_changed)
	SignalBus.weather_changed.connect(_on_weather_changed)
	SignalBus.notification_posted.connect(show_notification)
	SignalBus.dream_dew_collected.connect(_on_dream_dew_collected)
	
	update_coins_display(InventoryManager.coins)
	update_dew_display()
	update_time_display()

func _on_dream_dew_collected(_amount: int) -> void:
	update_dew_display()

func update_dew_display() -> void:
	if label_dew:
		var dew_count = 0
		if has_node("/root/OfflineGrowthManager"):
			dew_count = get_node("/root/OfflineGrowthManager").dream_dew_count
		label_dew.text = "✨ %d Dew" % dew_count

func _on_time_ticked(_minute: int, _hour: int, day: int, season: String) -> void:
	if label_time:
		label_time.text = TimeManager.get_time_string()
	if label_date:
		label_date.text = "%s, Day %d" % [season, day]

func _on_coins_changed(amount: int) -> void:
	update_coins_display(amount)

func _on_weather_changed(weather: String) -> void:
	if label_weather:
		label_weather.text = "Weather: " + weather

func update_coins_display(amount: int) -> void:
	if label_coins:
		label_coins.text = "🪙 %d G" % amount

func update_time_display() -> void:
	if label_time:
		label_time.text = TimeManager.get_time_string()
	if label_date:
		label_date.text = "%s, Day %d" % [TimeManager.get_current_season(), TimeManager.game_day]
	if label_weather:
		label_weather.text = "Weather: " + TimeManager.current_weather

func show_notification(text: String, color: Color = Color.WHITE) -> void:
	if not notify_container:
		return
		
	var lbl = Label.new()
	lbl.text = "✦ " + text
	lbl.modulate = color
	notify_container.add_child(lbl)
	
	var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(lbl, "position:y", lbl.position.y - 10.0, 0.2)
	tw.tween_interval(2.5)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)

func _on_shop_button_pressed() -> void:
	if shop_modal:
		shop_modal.visible = not shop_modal.visible

func _on_almanac_button_pressed() -> void:
	if almanac_modal:
		almanac_modal.visible = not almanac_modal.visible

func _on_breathe_button_pressed() -> void:
	if breathing_modal:
		if breathing_modal.has_method("open") and not breathing_modal.visible:
			breathing_modal.open()
		else:
			breathing_modal.visible = not breathing_modal.visible

func _on_sleep_button_pressed() -> void:
	if sleep_modal:
		sleep_modal.visible = not sleep_modal.visible

func _on_focus_button_pressed() -> void:
	if focus_modal:
		focus_modal.visible = not focus_modal.visible

func _on_simulate_sleep_button_pressed(hours: float) -> void:
	if has_node("/root/OfflineGrowthManager"):
		get_node("/root/OfflineGrowthManager").simulate_offline_hours(hours)

func _on_tea_button_pressed() -> void:
	if tea_modal:
		if tea_modal.has_method("open") and not tea_modal.visible:
			tea_modal.open()
		else:
			tea_modal.visible = not tea_modal.visible
