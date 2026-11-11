class_name HUD
extends CanvasLayer

@onready var label_time: Label = $TopBar/TimeLabel
@onready var label_date: Label = $TopBar/DateLabel
@onready var label_weather: Label = $TopBar/WeatherLabel
@onready var label_coins: Label = $TopBar/CoinsLabel
@onready var notify_container: VBoxContainer = $NotificationContainer

@onready var shop_modal: Control = $ShopModal
@onready var almanac_modal: Control = $AlmanacModal

func _ready() -> void:
	SignalBus.time_ticked.connect(_on_time_ticked)
	SignalBus.coins_changed.connect(_on_coins_changed)
	SignalBus.weather_changed.connect(_on_weather_changed)
	SignalBus.notification_posted.connect(show_notification)
	
	update_coins_display(InventoryManager.coins)
	update_time_display()

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
