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

enum SunlightPreference {
	FULL_SUN,       # 75% - 100% direct sunlight (Corn, Melon, Poppy, Marigold)
	PARTIAL_SHADE,  # 40% - 75% dappled sunlight (Tomato, Strawberry, Lavender)
	SHADE_LOVING    # 10% - 40% cool shade/night (Chrono Fern, Glowcap, Peppermint)
}

@export var plant_id: String = "carrot"
@export var plant_name: String = "Crisp Carrot"
@export var scientific_name: String = "Daucus carota"
@export var description: String = "A crunchy root vegetable packed with sweet beta-carotene."
@export var category: Category = Category.VEGETABLE

# Sunlight & Watering Ecology
@export var sunlight_preference: SunlightPreference = SunlightPreference.FULL_SUN
@export var casts_companion_shade: bool = false # Tall crops like corn cast shade on neighbors
@export var ideal_moisture_min: float = 0.30
@export var ideal_moisture_max: float = 0.85
@export var water_requirement_daily: float = 0.8
@export var scorch_susceptible: bool = false # Shade crops scorch in high noon direct sun without mulch/shade

# Economy
@export var seed_cost: int = 10
@export var harvest_sell_price: int = 25

# Growth Configuration
@export var growth_stage_hours: Array[float] = [6.0, 10.0, 14.0]
@export var stage_textures: Array[Texture2D] = []
@export var withered_texture: Texture2D
@export var harvest_item_icon: Texture2D

# Yield & Regrowth
@export var fertility_drain: float = 0.15
@export var preferred_season: String = "All"
@export var min_yield: int = 1
@export var max_yield: int = 3
@export var regrows_after_harvest: bool = false
@export var regrow_stage_index: int = 1

# Botanical Traits & Synergies
@export var companion_tag: String = "none"
@export var companion_boost_range: int = 1
@export var mutation_potential_id: String = ""
