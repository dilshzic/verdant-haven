extends Node

var plant_catalog: Dictionary = {}
var discoveries: Dictionary = {}

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
			"desc": "Crisp taproot. Thrives in moderate sun and evenly hydrated soil.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate (40-70%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 10,
			"sell_price": 24,
			"grow_hours": [6.0, 10.0, 12.0],
			"regrows": false,
			"companion": "Boosts adjacent potato growth"
		},
		{
			"id": "radish",
			"name": "Ruby Radish",
			"scientific": "Raphanus sativus",
			"category": "Vegetable",
			"desc": "Ultra-fast growing peppery bulb. Flexible with light and moisture.",
			"sunlight": "Partial Shade",
			"water_req_str": "Low-Moderate (30-60%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 8,
			"sell_price": 18,
			"grow_hours": [4.0, 6.0, 8.0],
			"regrows": false,
			"companion": "Loosens soil for root vegetables"
		},
		{
			"id": "potato",
			"name": "Earthbound Potato",
			"scientific": "Solanum tuberosum",
			"category": "Vegetable",
			"desc": "Hearty tuber. Sensitive to waterlogging; absorbs surplus moisture.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate (40-65%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 15,
			"sell_price": 40,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": false,
			"companion": "Absorbs excess soil moisture"
		},
		{
			"id": "golden_corn",
			"name": "Golden Maize",
			"scientific": "Zea mays",
			"category": "Vegetable",
			"desc": "Towering stalk that hungers for direct sun. Casts a cooling companion shadow!",
			"sunlight": "Full Sun",
			"water_req_str": "High (60-90%)",
			"casts_shade": true, # Tall companion shade!
			"scorch_prone": false,
			"seed_price": 25,
			"sell_price": 70,
			"grow_hours": [12.0, 18.0, 24.0],
			"regrows": false,
			"companion": "Casts protective shade for delicate herbs"
		},
		{
			"id": "giant_pumpkin",
			"name": "Cinnamon Pumpkin",
			"scientific": "Cucurbita maxima",
			"category": "Vegetable",
			"desc": "Heavy autumn gourd. Broad canopy leaves shade soil and suppress weeds.",
			"sunlight": "Full Sun",
			"water_req_str": "High (65-90%)",
			"casts_shade": true,
			"scorch_prone": false,
			"seed_price": 40,
			"sell_price": 130,
			"grow_hours": [16.0, 26.0, 36.0],
			"regrows": false,
			"companion": "Broad leaves shade soil and smother weeds"
		},

		# Fruits (Regrowing perennials)
		{
			"id": "strawberry",
			"name": "Sweet Dewberry",
			"scientific": "Fragaria vesca",
			"category": "Fruit",
			"desc": "Continuous regrowing berries. Benefits from straw mulch to keep berries clean.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate-High (50-80%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 30,
			"sell_price": 35,
			"grow_hours": [10.0, 16.0, 20.0],
			"regrows": true,
			"regrow_hours": 14.0,
			"companion": "Attracts friendly pollinators"
		},
		{
			"id": "tomato",
			"name": "Vine Cherry Tomato",
			"scientific": "Solanum lycopersicum",
			"category": "Fruit",
			"desc": "Vigorous vine clusters. Needs warm sun and consistent deep watering.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate (50-75%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 28,
			"sell_price": 32,
			"grow_hours": [9.0, 15.0, 18.0],
			"regrows": true,
			"regrow_hours": 12.0,
			"companion": "Pairs with Marigold to deter hornworms"
		},
		{
			"id": "blueberry",
			"name": "Indigo Bush Berry",
			"scientific": "Vaccinium corymbosum",
			"category": "Fruit",
			"desc": "Tart berries. Prefers dappled sunlight and organic mulched moisture.",
			"sunlight": "Partial Shade",
			"water_req_str": "Moderate-High (55-80%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 35,
			"sell_price": 42,
			"grow_hours": [12.0, 20.0, 24.0],
			"regrows": true,
			"regrow_hours": 16.0,
			"companion": "Enriches soil with micro-nutrients"
		},
		{
			"id": "sun_melon",
			"name": "Solar Honeydew",
			"scientific": "Cucumis melo",
			"category": "Fruit",
			"desc": "Golden melon. Requires intense midday sun to synthesize sweet nectar sugars.",
			"sunlight": "Full Sun",
			"water_req_str": "High (60-85%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 45,
			"sell_price": 145,
			"grow_hours": [14.0, 22.0, 30.0],
			"regrows": false,
			"companion": "Loves companionship with herbs"
		},

		# Herbs
		{
			"id": "lavender",
			"name": "Fragrant Lavender",
			"scientific": "Lavandula angustifolia",
			"category": "Herb",
			"desc": "Silver-green spires. Highly drought-tolerant; hates waterlogged soil.",
			"sunlight": "Full Sun",
			"water_req_str": "Low-Moderate (25-50%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 20,
			"sell_price": 48,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": true,
			"regrow_hours": 10.0,
			"companion": "Calming aura accelerates adjacent flower blooming"
		},
		{
			"id": "peppermint",
			"name": "Brisk Peppermint",
			"scientific": "Mentha piperita",
			"category": "Herb",
			"desc": "Crisp refreshing herb. Loves damp partial shade beneath tall crops.",
			"sunlight": "Partial Shade",
			"water_req_str": "Moderate-High (50-80%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 16,
			"sell_price": 36,
			"grow_hours": [6.0, 10.0, 14.0],
			"regrows": true,
			"regrow_hours": 8.0,
			"companion": "Spreads brisk mint scent that repels pests"
		},
		{
			"id": "chamomile",
			"name": "Sun Chamomile",
			"scientific": "Matricaria chamomilla",
			"category": "Herb",
			"desc": "Daisy-like blossoms. Heals neighbors from heat stress and sun scorch.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate (40-70%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 18,
			"sell_price": 42,
			"grow_hours": [6.0, 11.0, 15.0],
			"regrows": false,
			"companion": "Restores adjacent heat-stressed or parched crops"
		},

		# Flowers
		{
			"id": "scarlet_poppy",
			"name": "Scarlet Poppy",
			"scientific": "Papaver rhoeas",
			"category": "Flower",
			"desc": "Silk-thin scarlet petals. Basks in bright sun; crossbreeding parent.",
			"sunlight": "Full Sun",
			"water_req_str": "Low-Moderate (30-60%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 15,
			"sell_price": 38,
			"grow_hours": [7.0, 12.0, 16.0],
			"regrows": false,
			"companion": "Produces pollen that triggers hybrid mutations"
		},
		{
			"id": "azure_lily",
			"name": "Azure Star Lily",
			"scientific": "Lilium caeruleum",
			"category": "Flower",
			"desc": "Sapphire-tinted petals. Flourishes in morning sun with shaded roots.",
			"sunlight": "Partial Shade",
			"water_req_str": "Moderate (45-75%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 22,
			"sell_price": 55,
			"grow_hours": [8.0, 14.0, 18.0],
			"regrows": false,
			"companion": "Increases beauty score and butterfly visits"
		},
		{
			"id": "marigold",
			"name": "Golden Marigold",
			"scientific": "Tagetes patula",
			"category": "Flower",
			"desc": "Golden pompom petals. Loves intense heat and sunshine.",
			"sunlight": "Full Sun",
			"water_req_str": "Low-Moderate (30-60%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 14,
			"sell_price": 34,
			"grow_hours": [6.0, 10.0, 14.0],
			"regrows": false,
			"companion": "Completely repels weeds in 1-tile radius"
		},

		# Hybrids
		{
			"id": "moonlit_violet",
			"name": "Moonlit Violet",
			"scientific": "Viola nocturna",
			"category": "Hybrid",
			"desc": "Rare hybrid. Avoids harsh midday sun; petals store twilight luminescence.",
			"sunlight": "Partial Shade",
			"water_req_str": "Moderate (45-75%)",
			"casts_shade": false,
			"scorch_prone": true,
			"seed_price": 60,
			"sell_price": 160,
			"grow_hours": [12.0, 20.0, 26.0],
			"regrows": false,
			"companion": "Emits faint moonlight that allows night growth"
		},
		{
			"id": "solar_flare",
			"name": "Solar Flare Dahlia",
			"scientific": "Dahlia ignis",
			"category": "Hybrid",
			"desc": "Radiant fiery petals. Thrives on maximum solar radiation.",
			"sunlight": "Full Sun",
			"water_req_str": "Moderate-High (50-80%)",
			"casts_shade": false,
			"scorch_prone": false,
			"seed_price": 75,
			"sell_price": 195,
			"grow_hours": [14.0, 22.0, 30.0],
			"regrows": false,
			"companion": "Warms adjacent tiles, protecting against frost"
		},
		{
			"id": "twilight_orchid",
			"name": "Twilight Orchid",
			"scientific": "Orchis crepusculum",
			"category": "Hybrid",
			"desc": "Master botanical jewel. Requires gentle dappled shade and precise hydration.",
			"sunlight": "Partial Shade",
			"water_req_str": "Moderate (50-70%)",
			"casts_shade": false,
			"scorch_prone": true,
			"seed_price": 120,
			"sell_price": 350,
			"grow_hours": [18.0, 30.0, 42.0],
			"regrows": false,
			"companion": "Master flora: doubles adjacent crop sell value"
		},

		# Magical
		{
			"id": "chrono_fern",
			"name": "Chrono Fern",
			"scientific": "Osmunda temporis",
			"category": "Magical",
			"desc": "Prehistoric fern. Deep shade lover; scorches quickly under direct noon sun without mulch!",
			"sunlight": "Shade Loving",
			"water_req_str": "High (65-90%)",
			"casts_shade": false,
			"scorch_prone": true,
			"seed_price": 150,
			"sell_price": 280,
			"grow_hours": [20.0, 32.0, 48.0],
			"regrows": true,
			"regrow_hours": 24.0,
			"companion": "Accelerates growth of all 8 surrounding plots"
		},
		{
			"id": "glowcap_mushroom",
			"name": "Bioluminescent Glowcap",
			"scientific": "Mycena lux",
			"category": "Magical",
			"desc": "Teal mushroom. Needs cool shade and damp soil; will wither if left in blazing sun.",
			"sunlight": "Shade Loving",
			"water_req_str": "High (70-95%)",
			"casts_shade": false,
			"scorch_prone": true,
			"seed_price": 90,
			"sell_price": 220,
			"grow_hours": [10.0, 18.0, 24.0],
			"regrows": true,
			"regrow_hours": 12.0,
			"companion": "Spawns beneficial fungal mycorrhizae"
		}
	]

	for p in raw_plants:
		plant_catalog[p["id"]] = p
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
