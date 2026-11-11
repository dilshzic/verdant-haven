class_name HotbarUI
extends Control

@onready var slots_container: HBoxContainer = $SlotsContainer

func _ready() -> void:
	SignalBus.active_slot_changed.connect(_on_active_slot_changed)
	SignalBus.inventory_changed.connect(render_slots)
	render_slots()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			var slot_idx = event.keycode - KEY_1
			InventoryManager.set_active_slot(slot_idx)

func render_slots() -> void:
	if not slots_container:
		return
		
	# Clear existing slot children if any
	for c in slots_container.get_children():
		c.queue_free()
		
	for i in range(InventoryManager.HOTBAR_SIZE):
		var slot_data = InventoryManager.hotbar[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(54, 54)
		btn.focus_mode = Control.FOCUS_NONE
		
		# Slot index label
		var num_lbl = Label.new()
		num_lbl.text = str(i + 1)
		num_lbl.position = Vector2(4, 2)
		btn.add_child(num_lbl)
		
		# Item icon
		if slot_data["icon_path"] != "" and ResourceLoader.exists(slot_data["icon_path"]):
			var icon_texture = load(slot_data["icon_path"])
			var icon_rect = TextureRect.new()
			icon_rect.texture = icon_texture
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.custom_minimum_size = Vector2(32, 32)
			icon_rect.position = Vector2(11, 11)
			btn.add_child(icon_rect)
			
		# Stack count label
		if slot_data["count"] > 1:
			var count_lbl = Label.new()
			count_lbl.text = str(slot_data["count"])
			count_lbl.position = Vector2(34, 34)
			btn.add_child(count_lbl)
			
		# Highlight active slot
		if i == InventoryManager.active_slot:
			btn.modulate = Color(1.2, 1.2, 0.7)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0)
			
		var slot_idx = i
		btn.pressed.connect(func(): InventoryManager.set_active_slot(slot_idx))
		slots_container.add_child(btn)

func _on_active_slot_changed(_slot: int) -> void:
	render_slots()
