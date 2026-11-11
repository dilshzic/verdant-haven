class_name PlantData
extends Resource

enum Category {
	VEGETABLE,
	FRUIT,
	HERB,
	FLOWER,
	HYBRID,
	MAGICAL
}

@export var plant_id: String = "carrot"
@export var plant_name: String = "Crisp Carrot"
@export var scientific_name: String = "Daucus carota"
@export var description: String = "A crunchy root vegetable packed with sweet beta-carotene."
@export var category: Category = Category.VEGETABLE

# Economy
@export var seed_cost: int = 10
@export var harvest_sell_price: int = 25

# Growth Configuration
@export var growth_stage_hours: Array[float] = [6.0, 10.0, 14.0] # Total 30 in-game hours
@export var stage_textures: Array[Texture2D] = []
@export var withered_texture: Texture2D
@export var harvest_item_icon: Texture2D

# Care Requirements
@export var water_requirement_daily: float = 0.8
@export var fertility_drain: float = 0.15
@export var preferred_season: String = "All" # Spring, Summer, Autumn, Winter, All

# Yield & Regrowth
@export var min_yield: int = 1
@export var max_yield: int = 3
@export var regrows_after_harvest: bool = false
@export var regrow_stage_index: int = 1

# Botanical Traits & Synergies
@export var companion_tag: String = "none" # e.g. "pest_repeller", "growth_booster", "soil_enricher"
@export var companion_boost_range: int = 1 # Chebyshev tile distance
@export var mutation_potential_id: String = "" # ID of plant it can hybridize into
