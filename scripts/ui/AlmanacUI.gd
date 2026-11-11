class_name AlmanacUI
extends Control

@onready var plant_list: ItemList = $Panel/HSplit/PlantList
@onready var detail_name: Label = $Panel/HSplit/DetailVBox/NameLabel
@onready var detail_scientific: Label = $Panel/HSplit/DetailVBox/ScientificLabel
@onready var detail_category: Label = $Panel/HSplit/DetailVBox/CategoryLabel
@onready var detail_icon: TextureRect = $Panel/HSplit/DetailVBox/PlantIcon
@onready var detail_desc: RichTextLabel = $Panel/HSplit/DetailVBox/DescLabel
@onready var detail_stats: Label = $Panel/HSplit/DetailVBox/StatsLabel
@onready var detail_companion: Label = $Panel/HSplit/DetailVBox/CompanionLabel
@onready var close_btn: Button = $Panel/CloseButton

var current_plant_ids: Array[String] = []

func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(func(): visible = false)
	if plant_list:
		plant_list.item_selected.connect(_on_plant_selected)
	SignalBus.almanac_entry_updated.connect(func(_id): refresh_list())
	refresh_list()

func refresh_list() -> void:
	if not plant_list:
		return
	plant_list.clear()
	current_plant_ids.clear()
	
	for plant_id in AlmanacManager.plant_catalog.keys():
		var p = AlmanacManager.plant_catalog[plant_id]
		var is_discovered = AlmanacManager.discoveries[plant_id]["discovered"]
		current_plant_ids.append(plant_id)
		
		var display_text = p["name"] if is_discovered else "??? (Undiscovered)"
		var icon_path = "res://assets/sprites/plants/%s_item.png" % plant_id if is_discovered else "res://assets/sprites/tools/almanac.png"
		
		var tex = load(icon_path) if ResourceLoader.exists(icon_path) else null
		plant_list.add_item(display_text, tex)
		
	if current_plant_ids.size() > 0:
		_on_plant_selected(0)

func _on_plant_selected(index: int) -> void:
	if index < 0 or index >= current_plant_ids.size():
		return
	var pid = current_plant_ids[index]
	var p = AlmanacManager.plant_catalog[pid]
	var is_disc = AlmanacManager.discoveries[pid]["discovered"]
	
	if not is_disc:
		detail_name.text = "??? Undiscovered Flora"
		detail_scientific.text = "Unknown species"
		detail_category.text = "Category: " + p["category"]
		detail_desc.text = "Cultivate or crossbreed this plant in your garden plots to discover its botanical properties and journal entries."
		detail_stats.text = "Growth: ??? hrs | Value: ??? G"
		detail_companion.text = "Sunlight: ??? | Water: ???"
		return
		
	detail_name.text = p["name"]
	detail_scientific.text = "Scientific: " + p["scientific"]
	detail_category.text = "Category: " + p["category"]
	detail_desc.text = p["desc"]
	
	var total_hours = p["grow_hours"][0] + p["grow_hours"][1] + p["grow_hours"][2]
	var regrow_str = " (Regrows every %d hrs)" % p["regrow_hours"] if p.get("regrows", false) else " (Single Harvest)"
	var sun_info = p.get("sunlight", "Full Sun")
	var water_info = p.get("water_req_str", "Moderate")
	var shade_cast = " [Casts Companion Shade]" if p.get("casts_shade", false) else ""
	
	detail_stats.text = "Growth: ~%d hrs%s | Value: %d G\nSunlight: %s%s | Ideal Water: %s" % [
		int(total_hours), regrow_str, p["sell_price"], sun_info, shade_cast, water_info
	]
	detail_companion.text = "Synergy: " + p["companion"]
	
	var icon_path = "res://assets/sprites/plants/%s_stage_3.png" % pid
	if ResourceLoader.exists(icon_path):
		detail_icon.texture = load(icon_path)
