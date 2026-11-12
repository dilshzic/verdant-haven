extends Node

# Time & Environmental Signals
signal time_ticked(minute: int, hour: int, day: int, season: String)
signal day_advanced(day: int, season: String)
signal weather_changed(weather: String)

# Garden Grid & Interaction Signals
signal cell_selected(grid_pos: Vector2i)
signal cell_tilled(grid_pos: Vector2i)
signal cell_watered(grid_pos: Vector2i)
signal cell_fertilized(grid_pos: Vector2i)
signal seed_planted(grid_pos: Vector2i, plant_data: PlantData)
signal crop_harvested(plant_data: PlantData, yield_amount: int)
signal weed_cleared(grid_pos: Vector2i)
signal hybrid_discovered(hybrid_id: String, parent_a: String, parent_b: String)

# Inventory & Economy Signals
signal active_slot_changed(slot_index: int)
signal inventory_changed()
signal coins_changed(new_amount: int)
signal item_bought(item_id: String, cost: int)
signal item_sold(item_id: String, gain: int)

# Almanac & UI
signal almanac_entry_updated(plant_id: String)
signal notification_posted(text: String, color: Color)

# Relaxation, Mindfulness & Offline Growth Signals
signal offline_growth_processed(summary: Dictionary)
signal dream_dew_collected(amount: int)
signal breath_phase_changed(phase_name: String, duration_seconds: float)
signal breath_cycle_completed(completed_cycles: int, prana_awarded: int)
signal sleep_sanctuary_started(intention: String, timer_minutes: int)
signal sleep_sanctuary_awakened(summary: Dictionary)
signal focus_grove_started(duration_minutes: int)
signal focus_grove_completed(completed_minutes: int, tree_stage: int)
signal garden_blessed(blessing_type: String)
