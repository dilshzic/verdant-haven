class_name SoilCellData
extends Resource

@export var grid_coords: Vector2i = Vector2i.ZERO
@export var is_tilled: bool = false
@export var moisture: float = 0.0 # 0.0 (bone dry) to 1.0 (waterlogged)
@export var fertility: float = 0.5 # 0.0 to 1.0
@export var is_fertilized: bool = false
@export var is_mulched: bool = false # Insulates against evaporation and sun scorch
@export var sunlight_exposure: float = 1.0 # 0.0 (deep shade) to 1.0 (full direct sunlight)
@export var has_weed: bool = false
@export var days_without_water: int = 0
@export var days_waterlogged: int = 0
