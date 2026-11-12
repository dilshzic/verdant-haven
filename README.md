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

## 🐟 Outdoor Koi & Lotus Pond (Aquatic Sanctuary & Aquaponics)

Nestled alongside the garden beds lies an **Outdoor Fish Pond & Aquatic Ecosystem**:

### 1. Aquatic Life & Fish Species
* **Golden Kohaku Koi:** Graceful orange and white koi that leaps happily when fed.
* **Calico Sanke Koi:** Vivid tricolor pattern (crimson, ink-black, and white).
* **Moonlit Danio:** Bioluminescent sapphire minnow that shimmers softly at dusk and night.
* **Celestial Dragon Koi:** Rare mythical fish with flowing golden whiskers and shimmering fins.

### 2. Interactions & Aquaponic Synergies
* **🦐 Fish Feeding:**
  * Sprinkle nutritional flakes using `tool_fish_food` or clicking the pond.
  * Fish excitedly swim to the surface and nibble with bubbly splashes.
  * Well-fed fish occasionally leap out of the water and gift the player **Pond Pearls** (+15 G)!
* **🌊 Aquaponic Watering Can Refill:**
  * Refilling your watering can directly from the fish pond charges it with **Nutrient-Rich Fish Emulsion Water**.
  * Watering crops with pond water grants **+50% Growth Speed** and automatically enriches the soil with natural organic nitrogen!
* **🌸 Sacred Lotus Blossom:**
  * Floating lotus flowers bloom on the water surface and can be harvested for **60 G** and Lotus Pod seeds.
* **🐸 Garden Frog:**
  * Perches peacefully on the lily pad, ribbiting in the evening and snapping up garden pests before they can damage crops.

---

## ☀️ Sunlight & 💧 Watering Management Systems

The game features realistic microclimate dynamics balancing solar radiation and soil moisture:

### 1. Sunlight Exposure & Solar Arc
* **Time & Weather Arc:** Sunlight intensity rises from soft morning dawn (**6:00 AM**) to peak solar radiation at noon (**12:00 PM**), mellowing into golden twilight before night. Weather clouds (Overcast, Rainy, Mystical Fog) diffuse direct rays.
* **Sunlight Preferences:**
  * **Full Sun (>70% light):** Golden Maize, Sun Melon, Scarlet Poppy, Golden Marigold. Craves blazing direct sun to trigger fruit sweetness and vibrant blooms.
  * **Partial Shade (40%–70% light):** Tomato, Strawberry, Lavender, Chamomile, Azure Lily. Balanced, resilient.
  * **Shade Loving (10%–45% light):** Chrono Fern, Glowcap Mushroom, Peppermint. Deep shade lovers that risk heat scorch if left bare in direct noon sun!
* **Companion Shade Canopy:** Tall crops like **Golden Maize (Corn)** and **Cinnamon Pumpkin** cast a cooling dappled shadow over neighboring plots, shielding delicate shade crops from sunburn.

### 2. Hydration, Evaporation & Mulch
* **Hydration Continuum:**
  * **0%–15% (Bone Dry):** Drought stress. After 2 consecutive dry days, plants wither.
  * **40%–80% (Optimal Hydration):** Plants achieve **Vibrant Vigor** (+25% to +40% growth speed).
  * **88%–100% (Waterlogged Puddles):** Standing water. Prolonged waterlogging (>2 days) leads to root rot.
* **🌾 Straw Mulch:** Apply straw mulch to insulate soil plots. Mulching:
  * Reduces evaporation rate by **60%**.
  * Completely insulates sensitive shade crops against midday sun scorching.
  * Preserves soil fertility from leeching.

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

---

## 🌙 Relaxation, Sleep Sanctuary & Generative Absence (Mindfulness Mode)

Verdant Haven is designed around the core philosophy of **Generative Absence**:
> *"The garden should never punish you for living your real life. When you close the app, sleep, study, or meditate, nature continues to flourish peacefully in your absence."*

### 1. ⏳ Real-Time Offline Growth & Dawn Dew Harvesting (`OfflineGrowthManager.gd`)
* **Timestamp Persistence:** When closing, minimizing, or backgrounding the application (`NOTIFICATION_APPLICATION_PAUSED`), Godot records the system timestamp (`user://garden_offline_state.json`).
* **Non-Punitive Natural Growth:**
  * Soil moisture gently equilibrates towards a minimum morning dew floor (35%–55%), preventing drought withering while you sleep.
  * For every hour of real-world rest, garden plants advance their growth cycle without risk of death or weeds.
* **Overnight Starlight Blooming:**
  * When away for $\ge 5$ hours or during real-world night hours, night-active species (**Moonlit Violet** and **Bioluminescent Glowcap**) receive a **2x growth acceleration** under starlight!
* **✨ Dream Dew Collection:**
  * You collect 1 Dream Dew droplet per 30 minutes of real rest (up to 24 per sleep session).
  * Dream Dew can be spent to instantly bless dry plots, soothe stressed crops, or accelerate botanical crossbreeding.
* **🌅 Dawn Awakening Summary:**
  * Waking up triggers a serene morning report detailing hours rested, Dream Dew collected, crops ready for harvest, and a tranquil daily botanical wisdom quote.

### 2. 🧘 Sacred Lotus Breathwork (`MindfulBreathingController.gd`)
* **Animated Sacred Lotus:** Smoothly opens and expands on inhale, suspends with a celestial glow, and softly contracts on exhale.
* **3 Breathing Cadences:**
  * **Box Breathing (4-4-4-4):** Inhale 4s $\rightarrow$ Hold 4s $\rightarrow$ Exhale 4s $\rightarrow$ Rest 4s (Centers focus and lowers cortisol).
  * **Relaxing Wind-Down (4-7-8):** Inhale 4s $\rightarrow$ Hold 7s $\rightarrow$ Exhale 8s (Activates the parasympathetic nervous system for sleep).
  * **Heart Coherence (5-5):** Inhale 5s $\rightarrow$ Exhale 5s (Synchronizes heart rate variability and mental calm).
* **Harmonic Tibetan Singing Bowl:** Generates warm 432 Hz and 528 Hz pure sine harmonics at each phase transition.
* **✨ Prana Blessing:** Completing 4 breath cycles infuses the garden bed with holy prana vitality (+12 Dream Dew, cleanses weeds, and hydrates all soil to 85%).

### 3. 🌙 Overnight Sleep Sanctuary (`SleepSanctuaryManager.gd`)
* **Bedtime Intentions:** Set an evening intention (*Deep Restoration*, *Quiet Reflection*, *Release the Day*, or *Inner Calm*).
* **Ambient Soundscapes:**
  * 🌧️ **Nocturnal Rain:** Gentle pink noise generator with warm low-pass acoustic filtering.
  * 🦗 **Summer Crickets:** Frequency-modulated night cicada chorus.
  * 🥣 **432 Hz Singing Bowl:** Deep meditative drone with golden ratio overtone resonance.
  * 🌊 **Pond Ripples:** Soft natural water bubbles and swimming koi splashes.
* **Night Sky Overlay:** Full-screen midnight indigo tint with animated stars and a soft night clock.

### 4. 🌳 Sacred Focus Grove (`FocusGroveManager.gd`)
* **Screen-Free Companion Timer:** 15m, 25m (Pomodoro), or 50m deep work sessions.
* **Living Bonsai Progression:** A sacred Bodhi tree grows through 5 visual stages from *Sprout of Intention* to *Sacred Golden Blossom*.
* **Zero Guilt Guarantee:** Navigating away or taking a break will never kill or wither your tree.
* **Compost Reward:** Completing a focus session rewards +8 Dream Dew and blesses every garden bed with rich organic compost.

