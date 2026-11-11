extends Node

# Dictionary of all plant definitions in the game
var plant_catalog: Dictionary = {}

# Tracking discoveries: plant_id -> {"discovered": bool, "times_harvested": int}
var discoveries: Dictionary = {}

# Hybrid recipes: [parentA, parentB] -> result_id
var hybrid_recipes: Array[Dictionary] = [
	{
		"parent_a": "azure_lily",
		"parent_b": "peppermint",
		"result": "moonlit_violet",
		"name": "Moonlit Violet",
		"hint": "Cross an Azure Lily with aromatic Peppermint under cool dusk."
	},
	{
		"parent_a": "scarlet_poppy",
		"parent_b": "marigold",
		"result": "solar_flare",
		"name": "Solar Flare Dahlia",
		"hint": "Cross a vibrant Scarlet Poppy with Golden Marigold for fiery petals."
	},
	{
		"parent_a": "lavender",
		"parent_b": "moonlit_violet",
		"result": "twilight_orchid",
		"name": "Twilight Orchid",
		"hint": "The ultimate floral jewel: cross Lavender with the rare Moonlit Violet."
	}
]

func _ready() -> void:
	register_all_plants()

func register_all_plants() -> void:
	var raw_plants = [
		# Vegetables
		{
			"id": "carrot",
			"name": "Crisp Carrot",
			"scientific": "Daucus carota",
			"category": "Vegetable",
			"desc": "Crisp, sweet, and nutritious taproot. Grows quickly and thrives in well-tilled soil.",
			"seed_price": 10,
			"sell_price": 24,
			"grow_hours": [6.0, 10.0, 12.0],
			"regrows": false,
			"water_req": 0.8,
			"companion": "Boosts adjacent potato growth"
		},
		{
			"id": "radish",
			"name": "Ruby Radish",
			"scientific": "Raphanus sativus",
			"category": "Vegetable",
			"desc": "An ultra-fast growing peppery bulb. Great for quick revenue.",
			"seed_price": 8,
			"sell_price": 18,
			"grow_hours": [4.0, 6.0, 8.0],
			"regrows": false,
			"water_req": 0.6,
			"companion": "Loosens soil for root vegetables"
		},
		{
			"id": "potato",
			"name": "Earthbound Potato",
			"scientific": "Solanum tuberosum",
			"category": "Vegetable",
			"desc": "Hearty, reliable tuber that yields bountiful harvests per seed.",
			"seed_price": 15,
			"sell_price": 40,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": false,
			"water_req": 0.7,
			"companion": "Absorbs excess soil moisture"
		},
		{
			"id": "golden_corn",
			"name": "Golden Maize",
			"scientific": "Zea mays",
			"category": "Vegetable",
			"desc": "Towering stalk producing sweet golden cobs. Requires high moisture.",
			"seed_price": 25,
			"sell_price": 70,
			"grow_hours": [12.0, 18.0, 24.0],
			"regrows": false,
			"water_req": 1.2,
			"companion": "Provides shade for delicate herbs"
		},
		{
			"id": "giant_pumpkin",
			"name": "Cinnamon Pumpkin",
			"scientific": "Cucurbita maxima",
			"category": "Vegetable",
			"desc": "Heavy, aromatic autumnal gourd. Takes long to mature but commands a king's ransom.",
			"seed_price": 40,
			"sell_price": 130,
			"grow_hours": [16.0, 26.0, 36.0],
			"regrows": false,
			"water_req": 1.4,
			"companion": "Broad leaves smother nearby weeds"
		},

		# Fruits (Regrowing perennials)
		{
			"id": "strawberry",
			"name": "Sweet Dewberry",
			"scientific": "Fragaria vesca",
			"category": "Fruit",
			"desc": "Plump crimson berries that continue regrowing every 2 days after first harvest.",
			"seed_price": 30,
			"sell_price": 35,
			"grow_hours": [10.0, 16.0, 20.0],
			"regrows": true,
			"regrow_hours": 14.0,
			"water_req": 0.9,
			"companion": "Attracts friendly pollinators"
		},
		{
			"id": "tomato",
			"name": "Vine Cherry Tomato",
			"scientific": "Solanum lycopersicum",
			"category": "Fruit",
			"desc": "Vigorous vine clusters bursting with sweet, sun-warmed cherry tomatoes.",
			"seed_price": 28,
			"sell_price": 32,
			"grow_hours": [9.0, 15.0, 18.0],
			"regrows": true,
			"regrow_hours": 12.0,
			"water_req": 1.0,
			"companion": "Pairs with Marigold to deter hornworms"
		},
		{
			"id": "blueberry",
			"name": "Indigo Bush Berry",
			"scientific": "Vaccinium corymbosum",
			"category": "Fruit",
			"desc": "Tart, anthocyanin-rich berries. Thrives in rich, fertile organic matter.",
			"seed_price": 35,
			"sell_price": 42,
			"grow_hours": [12.0, 20.0, 24.0],
			"regrows": true,
			"regrow_hours": 16.0,
			"water_req": 0.9,
			"companion": "Enriches soil with micro-nutrients"
		},
		{
			"id": "sun_melon",
			"name": "Solar Honeydew",
			"scientific": "Cucumis melo",
			"category": "Fruit",
			"desc": "Golden melon with nectar-like sweetness. Needs plenty of warmth and sun.",
			"seed_price": 45,
			"sell_price": 145,
			"grow_hours": [14.0, 22.0, 30.0],
			"regrows": false,
			"water_req": 1.1,
			"companion": "Loves companionship with herbs"
		},

		# Herbs
		{
			"id": "lavender",
			"name": "Fragrant Lavender",
			"scientific": "Lavandula angustifolia",
			"category": "Herb",
			"desc": "Silver-green spires topped with soothing purple florets. Cherished by bees.",
			"seed_price": 20,
			"sell_price": 48,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": true,
			"regrow_hours": 10.0,
			"water_req": 0.6,
			"companion": "Calming aura accelerates adjacent flower blooming"
		},
		{
			"id": "peppermint",
			"name": "Brisk Peppermint",
			"scientific": "Mentha piperita",
			"category": "Herb",
			"desc": "Invigorating herb with crisp serrated leaves. Naturally resistant to cold.",
			"seed_price": 16,
			"sell_price": 36,
			"grow_hours": [6.0, 10.0, 14.0],
			"regrows": true,
			"regrow_hours": 8.0,
			"water_req": 0.8,
			"companion": "Spreads brisk mint scent that repels pests"
		},
		{
			"id": "chamomile",
			"name": "Sun Chamomile",
			"scientific": "Matricaria chamomilla",
			"category": "Herb",
			"desc": "Daisy-like blossoms with apple scent. Brews into calming restorative tea.",
			"seed_price": 18,
			"sell_price": 42,
			"grow_hours": [6.0, 11.0, 15.0],
			"regrows": false,
			"water_req": 0.7,
			"companion": "Heals adjacent sick or dehydrated crops"
		},

		# Flowers & Ornamentals
		{
			"id": "scarlet_poppy",
			"name": "Scarlet Poppy",
			"scientific": "Papaver rhoeas",
			"category": "Flower",
			"desc": "Silk-thin scarlet petals around a dark center. Hybridization parent plant.",
			"seed_price": 15,
			"sell_price": 38,
			"grow_hours": [7.0, 12.0, 16.0],
			"regrows": false,
			"water_req": 0.7,
			"companion": "Produces pollen that triggers hybrid mutations"
		},
		{
			"id": "azure_lily",
			"name": "Azure Star Lily",
			"scientific": "Lilium caeruleum",
			"category": "Flower",
			"desc": "Striking sapphire-tinted petals that shimmer under morning dew.",
			"seed_price": 22,
			"sell_price": 55,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": false,
			"water_req": 0.8,
			"companion": "Increases beauty score and butterfly visits"
		},
		{
			"id": "marigold",
			"name": "Golden Marigold",
			"scientific": "Tagetes patula",
			"category": "Flower",
			"desc": "Dense golden pompom petals. Famous natural repellent for all garden pests.",
			"seed_price": 14,
			"sell_price": 34,
			"grow_hours": [6.0, 10.0, 14.0],
			"regrows": false,
			"water_req": 0.6,
			"companion": "Completely repels weeds in 1-tile radius"
		},

		# Hybrids
		{
			"id": "moonlit_violet",
			"name": "Moonlit Violet",
			"scientific": "Viola nocturna",
			"category": "Hybrid",
			"desc": "Rare hybrid born from Azure Lily and Peppermint. Petals faintly glow at twilight.",
			"seed_price": 60,
			"sell_price": 160,
			"grow_hours": [12.0, 20.0, 26.0],
			"regrows": false,
			"water_req": 0.9,
			"companion": "Emits faint moonlight that allows night growth"
		},
		{
			"id": "solar_flare",
			"name": "Solar Flare Dahlia",
			"scientific": "Dahlia ignis",
			"category": "Hybrid",
			"desc": "Radiant explosion of orange and yellow petals born from Poppy and Marigold.",
			"seed_price": 75,
			"sell_price": 195,
			"grow_hours": [14.0, 22.0, 30.0],
			"regrows": false,
			"water_req": 1.0,
			"companion": "Warms adjacent tiles, protecting against frost"
		},
		{
			"id": "twilight_orchid",
			"name": "Twilight Orchid",
			"scientific": "Orchis crepusculum",
			"category": "Hybrid",
			"desc": "Extremely rare botanical wonder. Crossbred from Lavender and Moonlit Violet.",
			"seed_price": 120,
			"sell_price": 350,
			"grow_hours": [18.0, 30.0, 42.0],
			"regrows": false,
			"water_req": 1.2,
			"companion": "Master flora: doubles adjacent crop sell value"
		},

		# Magical & Exotic Flora
		{
			"id": "chrono_fern",
			"name": "Chrono Fern",
			"scientific": "Osmunda temporis",
			"category": "Magical",
			"desc": "Mystical prehistoric fern. Whispers of time dilation speed up neighbor crops by 25%.",
			"seed_price": 150,
			"sell_price": 280,
			"grow_hours": [20.0, 32.0, 48.0],
			"regrows": true,
			"regrow_hours": 24.0,
			"water_req": 1.3,
			"companion": "Accelerates growth of all 8 surrounding plots"
		},
		{
			"id": "glowcap_mushroom",
			"name": "Bioluminescent Glowcap",
			"scientific": "Mycena lux",
			"category": "Magical",
			"desc": "Ethereal teal mushroom that thrives in darkness and damp soil.",
			"seed_price": 90,
			"sell_price": 220,
			"grow_hours": [10.0, 18.0, 24.0],
			"regrows": true,
			"regrow_hours": 12.0,
			"water_req": 1.5,
			"companion": "Spawns beneficial fungal mycorrhizae"
		}
	]

	for p in raw_plants:
		plant_catalog[p["id"]] = p
		# Starter discoveries
		if p["id"] in ["carrot", "strawberry", "azure_lily"]:
			discoveries[p["id"]] = {"discovered": true, "harvest_count": 0}
		else:
			discoveries[p["id"]] = {"discovered": false, "harvest_count": 0}

func record_harvest(plant_id: String) -> void:
	if discoveries.has(plant_id):
		if not discoveries[plant_id]["discovered"]:
			discoveries[plant_id]["discovered"] = true
			SignalBus.almanac_entry_updated.emit(plant_id)
			SignalBus.notification_posted.emit("New Botanical Entry: " + plant_catalog[plant_id]["name"] + "!", Color(0.2, 0.9, 0.4))
		discoveries[plant_id]["harvest_count"] += 1

func check_hybridization(plant_a: String, plant_b: String) -> String:
	for r in hybrid_recipes:
		if (r["parent_a"] == plant_a and r["parent_b"] == plant_b) or (r["parent_a"] == plant_b and r["parent_b"] == plant_a):
			return r["result"]
	return ""
