class_name ShopUI
extends Control

@onready var items_container: VBoxContainer = $Panel/ScrollContainer/ItemsContainer
@onready var close_btn: Button = $Panel/CloseButton
@onready var balance_label: Label = $Panel/BalanceLabel

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(func(): visible = false)
	SignalBus.coins_changed.connect(update_balance)
	populate_shop_items()
	update_balance(InventoryManager.coins)

func update_balance(coins: int) -> void:
	if balance_label:
		balance_label.text = "Available Funds: %d G" % coins

func populate_shop_items() -> void:
	if not items_container:
		return
		
	for c in items_container.get_children():
		c.queue_free()
		
	# 1. Straw Mulch (Sunlight & Moisture protection)
	create_shop_row("Straw Mulch (x5)", "Insulates soil, cuts water evaporation by 60%, prevents sun scorch", 15, "tool_mulch", "res://assets/sprites/tools/mulch.png", func():
		if InventoryManager.spend_coins(15):
			InventoryManager.add_item("tool_mulch", "tool", "Straw Mulch", 5, "res://assets/sprites/tools/mulch.png")
			SignalBus.notification_posted.emit("Purchased 5 Straw Mulch bundles!", Color(0.9, 0.8, 0.2))
	)

	# 2. Fish Food Flakes Canister
	create_shop_row("Nutritional Fish Food (x5)", "Feed outdoor Koi & Minnows for happy splashes, pearls & coins", 12, "tool_fish_food", "res://assets/sprites/pond/fish_food.png", func():
		if InventoryManager.spend_coins(12):
			InventoryManager.add_item("tool_fish_food", "tool", "Fish Food", 5, "res://assets/sprites/pond/fish_food.png")
			SignalBus.notification_posted.emit("Purchased 5 Fish Food canisters!", Color(1.0, 0.7, 0.3))
	)

	# 3. Organic Fertilizer
	create_shop_row("Fertilizer Compost (x5)", "Boosts soil fertility and growth rate", 20, "tool_fertilizer", "res://assets/sprites/tools/fertilizer.png", func():
		if InventoryManager.spend_coins(20):
			InventoryManager.add_item("tool_fertilizer", "tool", "Compost Fertilizer", 5, "res://assets/sprites/tools/fertilizer.png")
			SignalBus.notification_posted.emit("Purchased 5 Compost Fertilizers!", Color(0.9, 0.8, 0.2))
	)

	# 3. Base Plant Seeds
	for plant_id in AlmanacManager.plant_catalog.keys():
		var p = AlmanacManager.plant_catalog[plant_id]
		if p["category"] == "Hybrid":
			continue
			
		var p_name = p["name"] + " Seeds"
		var p_desc = "%s (%s) • %s • %s" % [p["desc"], p["category"], p["sunlight"], p["water_req_str"]]
		var p_cost = p["seed_price"]
		var icon_p = "res://assets/sprites/plants/%s_stage_0.png" % plant_id
		var pid = plant_id
		
		create_shop_row(p_name, p_desc, p_cost, "seed_" + pid, icon_p, func():
			if InventoryManager.spend_coins(p_cost):
				InventoryManager.add_item("seed_" + pid, "seed", p_name, 1, icon_p, pid)
				SignalBus.notification_posted.emit("Bought " + p_name, Color(0.4, 0.9, 0.4))
		)

func create_shop_row(title: String, desc: String, cost: int, _item_id: String, icon_path: String, buy_action: Callable) -> void:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 50)
	
	if ResourceLoader.exists(icon_path):
		var icon_rect = TextureRect.new()
		icon_rect.texture = load(icon_path)
		icon_rect.custom_minimum_size = Vector2(36, 36)
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		row.add_child(icon_rect)
		
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lbl_title = Label.new()
	lbl_title.text = title
	var lbl_desc = Label.new()
	lbl_desc.text = desc
	lbl_desc.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(lbl_title)
	vbox.add_child(lbl_desc)
	row.add_child(vbox)
	
	var btn = Button.new()
	btn.text = "Buy (%d G)" % cost
	btn.custom_minimum_size = Vector2(100, 36)
	btn.pressed.connect(buy_action)
	row.add_child(btn)
	
	items_container.add_child(row)
