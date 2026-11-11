class_name SoilCellData
extends Resource

@export var grid_coords: Vector2i = Vector2i.ZERO
@export var is_tilled: bool = false
@export var moisture: float = 0.0 # 0.0 (bone dry) to 1.0 (fully saturated)
@export var fertility: float = 0.5 # 0.0 (depleted) to 1.0 (enriched loam)
@export var is_fertilized: bool = false
@export var has_weed: bool = false
@export var days_without_water: int = 0
