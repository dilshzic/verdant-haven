# 🌱 Verdant Haven: Botanical Garden Simulator (Godot 4)

A complete, extensible gardening simulation game engineered with **Godot Engine 4.3+**. Features deep soil ecology, hydration dynamics, day/night cycles, companion planting auras, and a Mendelian cross-pollination hybridization system across 20 distinct plant species.

---

## 🎮 How to Open & Run in Godot 4

1. Launch **Godot Engine 4.3** (or later).
2. Click **Import** $\rightarrow$ Navigate to this directory (`/home/antigravity/godot_gardening_game/`) and select `project.godot`.
3. Press **F5** (or click the **Play** button in the top right) to run the project.

---

## 🕹️ Controls

| Action | Key / Input |
|---|---|
| **Move Gardener** | `W, A, S, D` or `Arrow Keys` |
| **Use Tool / Plant / Harvest** | `Left Mouse Click` or `Spacebar` |
| **Select Hotbar Slot** | Keys `1` through `8` or click slot |
| **Open Seed Merchant Shop** | Click `🛒 Shop` in top bar or press `B` |
| **Open Botanical Almanac** | Click `📖 Almanac` in top bar or press `J` |

---

## 🌾 The 20 Crop Varieties Catalog

| Category | Crop Name | Growth Time | Perennial? | Special Trait / Synergy |
|---|---|---|---|---|
| **Vegetable** | Crisp Carrot | ~28 hrs | No | Quick starter crop; boosts adjacent potatoes |
| **Vegetable** | Ruby Radish | ~18 hrs | No | Ultra-fast turnover; loosens compacted soil |
| **Vegetable** | Earthbound Potato | ~40 hrs | No | High yield (up to 3x); absorbs excess moisture |
| **Vegetable** | Golden Maize (Corn) | ~54 hrs | No | Tall crop; creates shade for sensitive herbs |
| **Vegetable** | Cinnamon Pumpkin | ~78 hrs | No | Giant autumn gourd; broad leaves suppress weeds |
| **Fruit** | Sweet Dewberry (Strawberry) | ~46 hrs | **Yes** (regrows 14h) | Continuous yield; attracts friendly pollinators |
| **Fruit** | Vine Cherry Tomato | ~42 hrs | **Yes** (regrows 12h) | Prolific vine; pairs with Marigold against pests |
| **Fruit** | Indigo Bush Berry | ~56 hrs | **Yes** (regrows 16h) | Tart berry; enriches soil with micronutrients |
| **Fruit** | Solar Honeydew Melon | ~66 hrs | No | High cash crop; sweet aroma attracts rare bugs |
| **Herb** | Fragrant Lavender | ~40 hrs | **Yes** (regrows 10h) | Bee favorite; speeds up adjacent flower blooms |
| **Herb** | Brisk Peppermint | ~30 hrs | **Yes** (regrows 8h) | Cool scent; naturally repels garden pests |
| **Herb** | Sun Chamomile | ~32 hrs | No | Medicinal bloom; heals adjacent sick/dry crops |
| **Flower** | Scarlet Poppy | ~35 hrs | No | Rich pollen; parent of Solar Flare Dahlia |
| **Flower** | Azure Star Lily | ~40 hrs | No | Sapphire petals; parent of Moonlit Violet |
| **Flower** | Golden Marigold | ~30 hrs | No | Complete weed immunity in 1-tile radius |
| **Hybrid** | Moonlit Violet | ~58 hrs | No | *Azure Lily + Peppermint*; glows at twilight |
| **Hybrid** | Solar Flare Dahlia | ~66 hrs | No | *Scarlet Poppy + Marigold*; warms against frost |
| **Hybrid** | Twilight Orchid | ~90 hrs | No | *Lavender + Moonlit Violet*; doubles neighbor sell value |
| **Magical** | Chrono Fern | ~100 hrs | **Yes** (regrows 24h) | **Time dilation:** +25% speed to all 8 adjacent plots |
| **Magical** | Bioluminescent Glowcap | ~52 hrs | **Yes** (regrows 12h) | Night fungus; thrives in damp dark plots |

---

## 🦋 Visiting Wildlife & Biodiversity Sanctuary

The garden now attracts visiting creatures based on time of day, weather, and floral biodiversity:

### 1. Visiting Butterflies
* **Species:** Monarch (Orange), Blue Morpho (Azure), and Swallowtail (Yellow).
* **Behavior:** Flutters gently into the garden during sunny daytime hours (8:00 AM – 6:00 PM). Attracted to blooming flowers (Lily, Poppy, Marigold, Lavender, Violet).
* **Ecological Benefit:** Perches on mature blooms to sip nectar, creating a **Pollination Aura** that increases adjacent flower hybridization chance by **+15% to +20%**!

### 2. Visiting Songbirds
* **Species:** European Robin (warm red breast) and Eastern Bluebird (azure plumage).
* **Behavior:** Arrive in the early morning (6:00 AM – 11:00 AM) and late afternoon (3:00 PM – 6:00 PM). Lands on soil beds to hop around and peck for earthworms.
* **Ecological Benefit:**
  * Occasionally unearths and gifts the player **wild starter seed packets**.
  * Pecks away harmful slugs, hornworms, and weeds.
  * Startles and takes flight into the canopy if approached too quickly by the player.

---

## 🧬 Cross-Pollination & Hybridization Mechanics

When two mature compatible parent flowers or herbs are planted adjacent to each other:
1. When either plant is harvested, bees and wind trigger a **35-40% hybridization roll**.
2. If successful, the player receives a rare hybrid seed pouch in their inventory!
3. Discoveries are automatically recorded in the Botanical Almanac.

---

## 🏗️ Architectural Systems Overview

* **`SignalBus.gd` (Autoload):** Decoupled global event hub eliminating hard dependencies between player, tiles, HUD, and time.
* **`TimeManager.gd` (Autoload):** Manages continuous daylight interpolation, seasonal calendar (28-day seasons), and dynamic weather rolls (rain auto-hydrates all plots).
* **`InventoryManager.gd` (Autoload):** Handles hotbar slots, stackable storage, currency, and tool switching.
* **`AlmanacManager.gd` (Autoload):** Botanical encyclopedia tracking discovered species, harvest statistics, and hybrid recipes.
* **`GardenGrid.gd`:** Grid-based soil management with tile-state tracking (untilled, tilled dry, hydrated, enriched loam, weeds).
* **`Plant.gd`:** Node lifecycle with growth timers, visual stage transitions, juicy bounce tweens, and regrowth states.
* **`DayNightCanvas.gd`:** `CanvasModulate` atmospheric shader smoothly tinting the world from dawn rose to noon sunlight to twilight amber and midnight indigo.
