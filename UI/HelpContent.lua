local _, NS = ...
local GoldTracker = NS.GoldTracker

-- Text-only reference data. Reading the guide must never load a farming catalog,
-- scan bags, query TSM prices, or start a farm/location tracker.
local VALUE_SOURCE_HELP = {
    TSM_DBMARKET = {
        meaning = "TSM's market value for the item in its applicable auction market.",
        bestFor = "General local market estimates that are less jumpy than the cheapest current auction.",
        watchFor = "Can lag behind sudden price changes.",
    },
    TSM_DBRECENT = {
        meaning = "TSM's more recent local market value.",
        bestFor = "Reacting faster to current market movement.",
        watchFor = "Usually more volatile than Market Value or historical sources.",
    },
    TSM_DBREGIONMARKETAVG = {
        meaning = "TSM's region-wide market average.",
        bestFor = "Rare or thinly traded items where your realm has few auctions.",
        watchFor = "May not match what buyers are actually paying on your realm.",
    },
    TSM_DBMINBUYOUT = {
        meaning = "TSM's current minimum buyout.",
        bestFor = "Mirroring the cheapest visible auction. This is the addon's default primary source.",
        watchFor = "Can swing sharply, can be manipulated by one very low auction, and can be missing when the item is not posted.",
    },
    TSM_DBHISTORICAL = {
        meaning = "TSM's historical local price.",
        bestFor = "Stable realm-based estimates that smooth short-term spikes.",
        watchFor = "Reacts slowly when an item's value genuinely changes.",
    },
    TSM_DBREGIONHISTORICAL = {
        meaning = "TSM's region-wide historical price.",
        bestFor = "Stable fallback pricing for slow-moving or rare items.",
        watchFor = "Less specific to your realm's actual auction house.",
    },
    TSM_DBREGIONSALEAVG = {
        meaning = "TSM's region-wide average sale price.",
        bestFor = "Sale-realistic pricing when sold-price history matters more than listing price.",
        watchFor = "May be unavailable or stale for items with low sale volume.",
    },
    TSM_AUCTIONINGOPMIN = {
        meaning = "The minimum price from the item's assigned TSM Auctioning operation.",
        bestFor = "Respecting the hard floor from your own TSM posting rules.",
        watchFor = "Depends on the item having a matching TSM group and Auctioning operation.",
    },
    TSM_AUCTIONINGOPNORMAL = {
        meaning = "The normal price from the item's assigned TSM Auctioning operation.",
        bestFor = "Using your own TSM pricing rules as the estimate.",
        watchFor = "Only works well when your TSM groups and operations are configured.",
    },
    TSM_AUCTIONINGOPMAX = {
        meaning = "The maximum price from the item's assigned TSM Auctioning operation.",
        bestFor = "Using the optimistic ceiling from your TSM posting rules.",
        watchFor = "Can overstate practical session value if your max price is intentionally aggressive.",
    },
    TSM_CRAFTING = {
        meaning = "TSM's crafting cost/value for the item.",
        bestFor = "Crafted items where material cost is more useful than auction price.",
        watchFor = "Is not a buyer-facing sale price and depends on usable TSM crafting/material data.",
    },
}

local function Section(title, ...)
    return { title = title, bullets = { ... } }
end

function GoldTracker:GetHelpTopicDefinitions()
    local topics = {
        {
            key = "overview", group = "START HERE", label = "Getting started",
            summary = "Track a run, choose your next farm, and learn what the numbers mean.",
            keywords = "quick start beginner tutorial modules welcome favorites favourite",
            sections = {
                Section("Your first farming session",
                    "1. Type /gt. On first use, choose your Explorer modules; change them later in Options > Modules.",
                    "2. Open Options > Pricing and choose a tracker value source. TSM is optional, but its data is needed for TSM auction estimates.",
                    "3. Type /gt start, farm normally, then /gt stop. Open History to review the recording when session history is enabled.",
                    "4. Open Explorer to compare targets, save favorites, inspect maps, or build a farm. Start with one route and measure several comparable runs."),
                Section("Find your way around",
                    "The main tracker has Explorer, History, Options, diagnostics when enabled, and ? for this guide.",
                    "Explorer brings together Favorites, Alts, Market Watch, Rares, Instances, Drops, Materials, Farms, and Bags. Disabled modules are hidden; Options > Modules brings them back.",
                    "Search this guide by feature or task, such as 'bank', 'fallback', 'resume', or 'route'. Select a topic on the left; each topic remembers its reading position until /reload."),
                Section("Estimated value versus earned gold",
                    "Session Total combines raw looted gold with the estimated auction value of tracked loot. An unsold item is inventory, not spendable gold.",
                    "Raw Total combines raw looted gold and the vendor value of tracked items. AH Value is the auction estimate for items. These are alternative valuations: do not add Raw Total to Session Total.",
                    "Per-hour values divide the corresponding total by recorded session time. Short runs and one rare drop can distort the result; auction fees, supplies, travel, repairs, and time spent selling are not automatically deducted."),
            },
        },
        {
            key = "session", group = "START HERE", label = "Sessions & totals",
            summary = "Start, stop, hide, and resume a recording without losing track of its scope.",
            keywords = "tracking timer start stop new compact tiny minimize reload automatic",
            sections = {
                Section("Recording controls",
                    "Start Session or /gt start begins tracking; Stop Session or /gt stop ends it. /gt new forces a fresh session.",
                    "Closing the window with X hides it while an active session continues. Stop the session explicitly when the run is over.",
                    "Options > Sessions & Loot controls automatic starts, reload continuation, and location boundaries. Continuous recording is the default; optional rules split at instances or major locations."),
                Section("Window modes",
                    "The full view shows totals and the loot stream. The compact view keeps the main totals, rate, and latest highlight visible. Tiny mode keeps the session total and window controls.",
                    "Use the header mode controls to shrink or restore the tracker. /gt opens the mode chosen in Options > Appearance.",
                    "The minimap button provides another way to reach the addon; hover it for the available mouse actions."),
                Section("Measure useful runs",
                    "Keep the same pricing source and include a comparable amount of travel and setup in each test. Rename or pin representative recordings in History.",
                    "Use separate recordings for different farming methods when you want an easy comparison. Watch raw value, estimated auction value, duration, and what actually sells over time."),
            },
        },
        {
            key = "loot", group = "START HERE", label = "Loot & highlights",
            summary = "Understand the loot stream, quality filters, source labels, and notifications.",
            keywords = "soulbound boe vendor threshold sound alert notification unit node aoe mailbox",
            sections = {
                Section("Read the loot stream",
                    "Recent tracked item and money events show their time, item, value, and source information. Collapse the stream when only the summary is needed.",
                    "Soulbound, Below min quality, and Vendor only labels explain why an item may appear without auction value. Raw gold and vendor values are separate from the AH quality filter.",
                    "Loot source tracking attempts to record mobs, nodes, zones, and instance context. Missing source or coordinate data stays unknown rather than proving that an item cannot drop there."),
                Section("Highlights and alert rules",
                    "A loot entry becomes a highlight when its stack value reaches your configured threshold. The counter counts qualifying loot entries, not unique item types or confirmed sales.",
                    "Last Highlight shows the latest qualifying entry; compact mode includes its stack and unit values.",
                    "Options > Alerts configures notifications and rules. Use a rule's Test control to check its output; chat logging preferences can silence the chat part separately."),
                Section("Control what belongs in a farm",
                    "Options > Sessions & Loot contains item-quality, source, and available mail-related tracking preferences. Review them before comparing sessions.",
                    "Moving old stock between characters or collecting mail should not be mistaken for newly farmed profit. Compare the recording with the items you actually obtained on that run."),
            },
        },
        {
            key = "history", group = "START HERE", label = "Session history",
            summary = "Compare recordings, inspect visits, resume a session, and manage saved results.",
            keywords = "recording csv export merge split pin rename delete locations breakdown legacy",
            sections = {
                Section("Find and compare recordings",
                    "History stores completed sessions when enabled. Search and filter by date, character, or main location; sort by duration, estimated value, or value per hour.",
                    "Pin important recordings. Select rows for merge or delete, and review the confirmation before removing saved data.",
                    "The actions menu includes rename, CSV export, split by main location, and saved diagnosis snapshots."),
                Section("Loot, Locations, and Breakdown",
                    "Details has Loot, Locations, and Breakdown tabs. Location and style filters affect scoped totals; the loot-view filter affects the item table.",
                    "New recordings measure separate visits and recording periods. Older records label their elapsed span as legacy and show unknown visit durations.",
                    "Continuous sessions are the default. Sessions & Loot options can split at instance boundaries or each major location; subzones and floors stay together."),
                Section("Resume Session",
                    "Resume saves any active session, then continues the selected history recording in the tracker. Stopping updates the same history row.",
                    "Recording periods exclude gaps between runs and UI reloads. The original run does not have to be active, and reconstructed highlights remain available.",
                    "A farm's Runs view opens its linked History record. Route run records describe route duration and progress; they do not measure loot earnings."),
            },
        },
        {
            key = "explorer", group = "EXPLORER", label = "Explorer & favorites",
            summary = "Browse targets, keep a shortlist, and use the shared item and table tools.",
            keywords = "modules tabs sorting shift click favorite search filters details price evolution wowhead",
            sections = {
                Section("Modules and saved favorites",
                    "Open Explorer from the tracker or /gt explorer. Enabled tabs follow the module choices in Options > Modules.",
                    "Use a target's favorite/track control where available to keep it in Favorites. Favorites are a saved shortlist; adding a target does not start farming it.",
                    "Catalogs and heavier views load when a feature needs them. A module switch controls Explorer access and keeps saved data; it does not uninstall its addon files."),
                Section("Shared item tools",
                    "Item details can show price observations, available value sources, farming sources, map guidance, and links. The tools shown depend on the item and available data.",
                    "Map opens available farming guidance. Missing maps mean usable guidance is not recorded; a map or source area is not a guarantee of a drop.",
                    "Add sends a target to your selected saved farm. Watch the 'Adding to' strip across Explorer tabs; View farm returns to that farm, and Done clears the addition destination."),
                Section("Table sorting",
                    "Click a column header to sort by that column only. Shift-click other headers to add secondary and tertiary sorts.",
                    "Priority numbers show the sort order. Shift-click an active header reverses its direction; Shift-right-click removes only that column from the order.",
                    "Search and filters narrow the current view. Price thresholds and value-source selectors belong to that view; they do not all change the tracker source."),
            },
        },
        {
            key = "bags", group = "EXPLORER", label = "Bags & selling",
            summary = "Value auctionable bag stock and move from an inventory row to the Auction House.",
            keywords = "inventory auction sell posting scan bag stock restock",
            sections = {
                Section("Review your stock",
                    "Bags scans auctionable items carried by the current character and values them using its selected price source. It is not a complete account, bank, mailbox, or auction inventory.",
                    "Use search, categories, the minimum value, and sorting to find useful stock. Item details provide supported prices, maps, and market history.",
                    "Choose the default Bags source in Options > Pricing. A bag estimate can differ from the tracker when their selected sources differ."),
                Section("At the Auction House",
                    "When enabled in Options > Bags, opening the Auction House opens Bags for quick review. Disabling the Bags module also stops that popup.",
                    "The Sell shortcut uses the selected bag item with the Auction House selling interface while the AH is open. Check the item, quantity, and price before posting through the game UI.",
                    "GGT estimates stock value; it does not confirm that a buyer exists or that your items have sold. Check your auctions and sale proceeds separately."),
            },
        },
        {
            key = "alts", group = "EXPLORER", label = "Alts & destinations",
            summary = "Organize characters, professions, roles, recorded locations, and assigned farms.",
            keywords = "bank main other character gold level continent low level profession destination offline",
            sections = {
                Section("Build your character roster",
                    "Log into each character so GGT can record that character's information. Offline characters show saved information, not a live view of another character.",
                    "Search by name, realm, profession, farm, role, or zone. Groups remember their collapsed state; searching does not overwrite it.",
                    "Details exposes recorded location, role, and destination controls. Use Main, Bank, and Other roles to organize your roster; a role is an organizational label, not a profession or gameplay unlock."),
                Section("Choose who farms what",
                    "Review recorded professions and assigned farms when selecting a character. Farm suggestions use available profession and recorded-location information; verify access, skill, and travel yourself.",
                    "Set a destination as a plan for a character. A destination does not move the character or replace the last recorded location.",
                    "The Bank group is useful for an auction or storage alt. Read Bank characters in the gold guide for a practical setup."),
                Section("Character and global maps",
                    "Recorded character pins show the last captured location. Use character/continent views and Global Map tabs to plan across your roster.",
                    "Fit zone or Fit continent frames the map; Center recenters a saved character position without changing zoom. Expand map gives the map more room.",
                    "Locations can become stale while a character is offline. Log into that character to refresh its recorded information."),
            },
        },
        {
            key = "materials", group = "EXPLORER", label = "Materials",
            summary = "Find profession inputs, compare prices, and inspect supported farming areas.",
            keywords = "mats gathering herb ore mining skinning fishing cooking enchanting elemental composed expansion profession",
            sections = {
                Section("Find a material",
                    "Open Materials or /gt mats. Filter the curated catalog by expansion, profession, categories such as Elemental, name, and value source.",
                    "Prices come from the selected TSM source and available fallback data. Materials include gathering resources and other curated profession or consumable inputs.",
                    "Normal and expanded views share the material actions, filters, and item details. Add a suitable target to a farm or keep it in Favorites."),
                Section("Read farming evidence",
                    "Details and Map can include curated source areas, recorded loot coordinates, and learned drop/hour information when available.",
                    "An area-only source is broad guidance. A coordinate is an observation or authored location, not a guaranteed spawn. Compare the source and method before travelling.",
                    "Composed entries describe material inputs or component relationships; do not treat a crafted component as a gathering node."),
                Section("Your own material knowledge",
                    "Eligible history observations can inform learned materials and rates. Item-detail profession/category overrides and recorded observations save locally.",
                    "Advanced: /gt addmat <itemID> <expansionID> <professionID> [tag] adds a custom material. Use the actual catalog IDs; /gt help lists the command syntax.",
                    "Keep the same method and a meaningful sample when comparing yields. One lucky drop or a brief test is weak evidence for an hourly expectation."),
            },
        },
        {
            key = "drops", group = "EXPLORER", label = "Drops & collections",
            summary = "Explore tradeable drops and collection targets alongside your own recorded loot.",
            keywords = "observed session boe mounts pets toys recipes cosmetics transmog scan saved sessions",
            sections = {
                Section("Browse the available catalogs",
                    "Open Drops or /gt drops to browse the available drop categories, including BoE loot and supported mounts, pets, toys, recipes, and cosmetics.",
                    "Inspect binding, sources, price data, and acquisition method. A collection target appearing in the catalog does not mean it can be auctioned.",
                    "Use its Map, favorite, details, and farm actions where available. Source coverage varies by item."),
                Section("Session Observed",
                    "Eligible uncommon-or-better BoE loot is added automatically to Drops > Session Observed. This is your evidence from recorded loot, separate from bundled catalog claims.",
                    "Scan saved sessions appends older eligible loot without clearing existing observations or repeatedly counting the same loot.",
                    "Recorded coordinates are available through Map when captured. Unknown coordinates stay unavailable, and an observed location does not establish a drop chance."),
            },
        },
        {
            key = "rares", group = "EXPLORER", label = "Rares & instances",
            summary = "Scan rare, dungeon, and raid loot for potential farming targets.",
            keywords = "rarescanner atlasloot att boss boe dungeon raid scan saved threshold background",
            sections = {
                Section("Rares",
                    "Open Rares or /gt rares. On-demand scans use bundled RareScanner-derived rare loot plus usable runtime RareScanner saved loot when available.",
                    "Choose a value source and threshold to shortlist valuable targets. Inspect each item's binding and source before making a trip.",
                    "Rare loot data identifies possibilities; it does not mean a rare is currently alive or that it will drop the listed item."),
                Section("Instances",
                    "Open Instances or /gt instances to scan bundled dungeon, raid, and boss loot for likely auctionable targets.",
                    "Use saved scans, favorites, background scanning, item details, and price history to compare candidates without rescanning everything each time.",
                    "Verify difficulty, loot rules, character access, and the instance's lockout in game. A catalog entry is not a live lockout tracker or a guaranteed BoE drop."),
            },
        },
        {
            key = "farms", group = "EXPLORER", label = "Farms & sharing",
            summary = "Browse farm guides, build a saved farm, assign a character, and share it.",
            keywords = "my farms catalog build method targets import export share string tips sources runs",
            sections = {
                Section("My Farms and the farm catalog",
                    "Explorer > Farms has My Farms for your saved farms and Farms for the bundled catalog. Review targets, methods, tips, source links, and estimates before choosing a farm.",
                    "The catalog's Details action opens the relevant farm details and maps. Category, type, expansion, and search controls help narrow the catalog.",
                    "In My Farms, select a saved farm to assign one character, rename it, delete it, edit its targets, or plan a route. New Farm creates a saved farm."),
                Section("Build a farm and run its route",
                    "Select Build on a saved farm, then use Add in other Explorer lists to add targets. Add controls appear while a farm is being built. Choose a method or map source when prompted.",
                    "Method changes an existing target's farming method; Remove deletes that target. Finish Build stops adding entries and keeps the saved farm.",
                    "Build or Finish Build stays beside the farm name. Plan Route creates its first route; Start and Stop then occupy that slot. The ... menu groups route tools, Rename, and Delete. Linked runs appear in Session History for duration and progress; use a tracker session to measure loot earnings."),
                Section("Import and export",
                    "Open Farms > My Farms > Share. Export farm shares the selected farm; Export all shares your saved collection.",
                    "Copy the entire string with Ctrl+A and Ctrl+C. The recipient opens Import string, pastes it, and clicks Import farms. Line breaks and surrounding whitespace are accepted.",
                    "Imports create new copies and preserve existing farms. Routes, methods, supported maps, assignments, saved progress, and linked run history travel with the export; importing does not start navigation.",
                    "Assignments and saved context can include character identities. Share only with that in mind. Incomplete or unsupported strings produce an error instead of a partial import."),
            },
        },
        {
            key = "maps", group = "EXPLORER", label = "Maps & routes",
            summary = "Read farming maps and plan stops with the navigation tools.",
            keywords = "waypoint tomtom minimap world map hud trail recovery route lock location reset seamless terrain",
            sections = {
                Section("Map controls and confidence",
                    "Drag interactive maps to pan and use the wheel to zoom. Use the view's Fit or Reset view controls to restore framing; Expand opens a larger map where supported.",
                    "Fully revealed Blizzard paintings are the default. Options > Experimental > Seamless maps enables the unfinished stitched-zone and terrain view.",
                    "Source areas, exact points, and approximate pins have different precision. Approximate route pins may represent zone centres; inspect stop location/confidence before following them."),
                Section("Plan and adjust a route",
                    "In My Farms, use Plan Route to create a route. The farm's ... menu contains Open route plan, Overview map, and Replan route. Overview map shows planned stops together when a shared map is available.",
                    "The planner provides Up/Down, Lock, Location, Map data, and Recalculate. Locks and location overrides let you refine the proposed order and guidance.",
                    "Use Navigate, Complete, Navigate Next, and Skip to follow the route. Reset clears the character's saved route progress; it is separate from deleting the farm.",
                    "When stops do not share a usable overview map, use its map selector to view each location with the original stop numbers. Stops without map data are listed in the overview details. Individual stop maps also remain available. A planned route does not guarantee a traversable path between all points."),
                Section("Follow an active farm",
                    "The farming HUD and supported world-map/minimap overlays provide active-route guidance, stops, and available recovery/trail tools.",
                    "Start the farm deliberately and stop it when finished. Route progress describes the trip; use a separate loot session to measure its earnings.",
                    "Options > Maps controls map presentation. /gt clearpins clears the visible farming map pins; it does not delete your saved farms or source data."),
            },
        },
        {
            key = "market", group = "EXPLORER", label = "Market Watch",
            summary = "Compare recorded prices and demand signals before choosing what to farm.",
            keywords = "price alerts increase decrease sold day sale rate trend evolution graph history demand sample",
            sections = {
                Section("Spot a change, then investigate",
                    "Open Market Watch or /gt alerts to inspect available price-change candidates and their selected comparison basis. Review item details, source, and sample times.",
                    "Price evolution charts show observations GGT has recorded, not a complete history of every auction or transaction. /gt market <item> opens market history for an item.",
                    "Options > History & Storage controls retention days, samples per item, and the maximum tracked items. Unlimited items removes the item-count cap; time/sample limits still apply."),
                Section("Price is only one signal",
                    "A large percentage increase from a tiny base can still be a low-value opportunity. A sparse or old sample can make a change misleading.",
                    "TSM regional sell rate and sold-per-day data, when available, describe regional activity. They do not predict your personal time to sale or provide a separate sell rate for each realm.",
                    "Check current listings and competition before farming a large stockpile. Missing demand data is unknown demand, not proof that an item never sells."),
            },
        },
        {
            key = "values", group = "REFERENCE", label = "Prices & TSM setup",
            summary = "Choose realistic estimates, understand fallbacks, and enable realm comparisons.",
            keywords = "value sources primary fallback min buyout market historical crafting operation realm desktop apphelper",
            sections = {
                Section("Realm setup: compare prices across realms",
                    "1. In WoW's AddOns list, enable TradeSkillMaster, TradeSkillMaster_AppHelper, and General Gold Tracker - TSM Realm Prices.",
                    "2. Open the TSM Desktop Application. In Settings > General, add the Retail realms you want to compare in your region.",
                    "3. Restart the TSM Desktop Application after adding realms and wait for their price data to download.",
                    "4. Return to WoW and type /reload, then open a supported armour, weapon, mount, pet, or toy item's details and select Realm prices.",
                    "GGT automatically lists the realms downloaded by TSM. A newly added realm may require a full WoW restart after the download finishes.",
                    "These are downloaded snapshots, not live auction searches. Hover values for snapshot times; -- means unavailable. Region sell rate is shared regional data.",
                    "The optional realm module can be disabled in AddOns; reload afterward to release GGT's retained realm data. Other GGT features remain usable."),
                Section("Primary source and missing-price fallbacks",
                    "GGT asks TSM for a unit value and stores the returned copper estimate. It does not build TSM's market data itself.",
                    "Each view tries its selected source first, then the configured missing-price fallback order until a positive value is found. Configure that order in Options > Pricing; a fallback is not a guarantee that an item has data.",
                    "Tracker and Bags defaults are separate; other Explorer views keep their own selectors. Check the source actually used when comparing numbers.",
                    "TSM and its desktop updates are recommended for auction estimates. Without usable TSM data, TSM prices may be zero or unavailable; raw looted gold and known vendor values remain useful."),
                Section("Choose a valuation style",
                    "Min Buyout follows the lowest available listing snapshot and can be distorted by a single cheap listing. Market and historical sources are smoother but can lag changes.",
                    "Regional sources help compare thin markets but may differ from what your realm's buyers pay. Region Sale Avg reflects reported sales rather than your own guaranteed proceeds.",
                    "Auctioning operation sources use your configured TSM rules and require an applicable operation. Crafting cost describes inputs, not a promised selling price."),
            },
        },
        {
            key = "gold", group = "MAKE GOLD", label = "Gold-farming tips",
            summary = "Build a repeatable routine around demand, realistic results, and manageable stock.",
            keywords = "gold farming tricks beginner profit gold per hour gph money gathering transmog diversification",
            sections = {
                Section("Start with a small experiment",
                    "Pick a method your character can already do. Check its requirements, travel, available bag space, and current prices before investing in upgrades or supplies.",
                    "Farm a small batch first, record the run, and try to sell it. Repeat comparable runs before deciding what a method is worth.",
                    "Gathering materials can be easier to test in small batches; rare transmog and collectibles may take much longer to sell. Let your own sales decide how much stock to keep."),
                Section("Measure usable results",
                    "Compare median or typical runs, not your luckiest screenshot. Track ordinary material yield separately from exceptional rare drops.",
                    "Keep your own net result: sale proceeds plus raw gold, minus supplies, repairs, travel costs, and auction costs. GGT's estimated session value does not automatically calculate this profit.",
                    "Include time spent travelling, sorting, posting, and collecting sales when judging your routine. A high farming-only hourly rate can shrink after that work."),
                Section("Farm demand, not just a high listing",
                    "Compare current listings, the selected TSM source, available demand data, and recent observations. One expensive auction is weak evidence of a useful market.",
                    "Commodities such as herbs, ore, and many consumables trade region-wide in Retail. A different realm does not create a separate commodity price pool.",
                    "Non-commodity markets can differ by realm. For rare gear and collectibles, compare snapshots, likely demand, posting effort, and how long your own stock takes to sell."),
                Section("Keep stock under control",
                    "Set a stock limit for each slow seller and avoid farming many duplicates before the first batch sells. Review old stock instead of endlessly relisting without a plan.",
                    "Diversify across a few methods you enjoy. A steady material route plus occasional rare-drop runs can spread the risk of relying on one lucky item.",
                    "Check binding before equipping, learning, or converting a sale target. A collectible or Warbound item is not automatically auctionable."),
                Section("Build a sustainable routine",
                    "Use Favorites for the next few targets and My Farms for repeatable routes. Assign gathering routes to characters with the needed professions and access.",
                    "Empty bags before leaving, group nearby targets, and use a bank character to consolidate posting. Stop a farm session when you switch to unrelated play.",
                    "Recheck prices and demand periodically. No guide or hourly estimate can guarantee profit; choose methods that work for your available time."),
            },
        },
        {
            key = "bank", group = "MAKE GOLD", label = "Bank characters",
            summary = "Keep a dedicated auction and storage alt so farming characters spend more time farming.",
            keywords = "bank alt character auction house mailbox warband warbank storage main other bags mail",
            sections = {
                Section("Set up a bank alt",
                    "Choose a character with convenient Auction House, mailbox, and bank access. Give it enough bag space and a little working gold for posting and other costs.",
                    "Log into it so GGT records it, then open Alts > Details and give it the Bank role. The label helps you organize the roster; it does not unlock bank access or move items.",
                    "Keep gathering and travel on your farming characters. Consolidate saleable stock on the bank alt using transfer methods the game allows."),
                Section("Use storage deliberately",
                    "The Warband Bank can share eligible items and gold between your characters. Check item restrictions in game; being transferable within your Warband does not make an item auctionable.",
                    "Keep sale stock, crafting inputs, and personal collection items separate in your own organization. Avoid accidentally using or equipping something intended for sale.",
                    "Mail and storage still need your attention. Collect transfers, check expiry or return notices in the game UI, and keep enough free space for incoming stock."),
                Section("A simple posting routine",
                    "1. Finish the farm and stop its loot session. Transfer eligible stock to the bank alt.",
                    "2. Log into the bank alt, collect transfers, and open Bags at the Auction House. Review quantity, binding, and current market conditions.",
                    "3. Post through the Auction House or your chosen auction addon. Review unsold stock, replenish only useful quantities, and collect sale proceeds.",
                    "GGT provides bag estimates and recorded character information. It does not automatically transfer items, manage mail, or maintain a complete account-wide inventory or sales ledger."),
                Section("Organize more alts when useful",
                    "Keep a Main for general play, a Bank for stock and auctions, and profession or gathering characters for methods they can access efficiently.",
                    "Assign suitable farms and destinations in GGT as planning aids. Saved locations are snapshots; verify a character's access and position before starting.",
                    "Add another character only when it saves more time than maintaining it costs. A clear routine on two characters can be more useful than an unused roster."),
            },
        },
        {
            key = "options", group = "REFERENCE", label = "Options & saved data",
            summary = "Find settings, customize the UI, and understand what is saved across characters.",
            keywords = "settings skin theme appearance reset modules logging chat retention savedvariables backup storage",
            sections = {
                Section("Find the right setting",
                    "Open /gt options. The sidebar groups Appearance, Modules, Sessions & Loot, Pricing, Bags, Alts, Maps, History & Storage, Alerts, Logging, Advanced, and Experimental controls.",
                    "Search setting names and their help. Hover a control or its ? for details, an example, defaults, units/ranges, and the reason a control is disabled.",
                    "Preferences save automatically across characters. Appearance includes the available skins and tracker presentation choices."),
                Section("Resets and storage",
                    "Reset this page needs a second click and restores that page's preferences. It does not clear saved sessions, farms, or recorded observations.",
                    "History & Storage distinguishes session records from market observations. Later maintenance still applies the configured retention and sample limits, including after a reset.",
                    "WoW writes account-wide GGT data to WoWGeneralGoldTrackerDB in its SavedVariables file. Back up that file after a normal logout or /reload before a manual move or reinstall; do not edit it while WoW is running."),
                Section("Logging and experimental tools",
                    "Logging controls GGT's default-chat output, categories, and optional timestamps. Test chat checks the current choice; there is no separate saved chat log file.",
                    "The chat master switch also covers warnings, command replies, /gttsm output, and alert chat. It does not mute alert sounds or remove tracker loot entries.",
                    "Experimental controls expose diagnostics and unfinished features such as seamless maps. Read their contextual help before enabling them."),
            },
        },
        {
            key = "troubleshooting", group = "REFERENCE", label = "Troubleshooting",
            summary = "Resolve missing tabs, catalogs, prices, maps, and unexpected tracking results.",
            keywords = "diagnosis diagnostics missing zero empty install data modules reload tsm addon error memory",
            sections = {
                Section("A tab or catalog is missing",
                    "Check Options > Modules first. A disabled module keeps its saved data and can be enabled again immediately.",
                    "Install all sibling folders from the release ZIP: the main addon plus Rares, Instances, Drops, Materials, Farms, MapData, and optional TSMRealmData modules.",
                    "After adding addon folders for the first time, fully exit and restart WoW so it discovers them. /reload is sufficient for later updates to already discovered folders."),
                Section("Prices are zero, missing, or surprising",
                    "Check that TSM is loaded and its desktop data has downloaded, then /reload. Review the selected value source and missing-price fallback order.",
                    "Operation prices need a matching TSM group and operation. Sparse markets and old snapshots can produce missing or unrealistic values.",
                    "For missing cross-realm snapshots, follow Prices & TSM setup. /gttsm provides TSM diagnostics; enable command output in Logging if nothing appears."),
                Section("Missing maps or stale character information",
                    "Check the selected item, method, map support, and installed MapData module. Some sources only have a broad area or no usable coordinates.",
                    "Log into an alt to update its recorded information. A destination is a plan and an offline pin is a snapshot.",
                    "Loaded catalogs can remain in memory until /reload. Closing views can release rebuildable view caches, but module switches are not a live unload of installed addon code."),
                Section("Investigate tracking",
                    "Review session state, mail and loot filters, quality settings, value sources, and the loot entry's reason label before comparing totals.",
                    "Enable diagnostics in Options > Advanced, reproduce the issue, then open Diagnosis and press Refresh. Choose Runtime or Current session and inspect Overview, Loot pipeline, Events, or Timings. Copy report includes every metric; Reset runtime preserves session snapshots. History can retain a saved diagnosis snapshot with a recording.",
                    "When reporting a problem, include the addon version, character activity, feature, steps to reproduce, selected price source, and any visible error. Distinguish estimated values from actual auction sales."),
            },
        },
        {
            key = "commands", group = "REFERENCE", label = "Commands",
            summary = "Shortcuts for the tracker, Explorer, item prices, and map cleanup.",
            keywords = "slash gt ggt gtt gttsm help command",
            sections = {
                Section("Tracker and settings",
                    "/gt - Open the tracker; first use offers module setup.",
                    "/gt start - Start tracking. /gt new - Force a fresh session. /gt stop - Stop tracking.",
                    "/gt options - Open searchable settings. /gt help - Print command help in chat. Use the tracker's ? button for this guide."),
                Section("Explorer shortcuts",
                    "/gt explorer - Open Explorer. /gt rares - Rares. /gt instances - Instances.",
                    "/gt mats - Materials. /gt drops - Drops. /gt alerts - Market Watch.",
                    "Favorites, Alts, Farms, and Bags are reached through Explorer. Enable their modules in Options if the tabs are hidden."),
                Section("Items and maps",
                    "/gt market <item> - Open market history for an item.",
                    "/gt addmat <itemID> <expansionID> <professionID> [tag] - Add a custom material. Example: /gt addmat 14256 classic tailoring Cloth.",
                    "/gt clearpins - Clear visible farming map pins. /gt maptest - Open the farming map test overlay.",
                    "/gttsm - TSM diagnostics. Some additional commands depend on optional features. Logging must allow command replies to see chat output."),
            },
        },
    }

    local current = self:GetCurrentValueSource()
    local fallbackLabels = {}
    for _, sourceID in ipairs(self:GetValueSourceFallbackOrder()) do
        local source = self.VALUE_SOURCE_BY_ID[sourceID]
        if source and (not current or source.id ~= current.id) then
            fallbackLabels[#fallbackLabels + 1] = source.label
        end
    end
    table.insert(topics[1].sections, Section("Your current pricing defaults",
        "Tracker source: " .. (current and current.label or "Unavailable") .. ".",
        "Missing-price fallback order: " .. (#fallbackLabels > 0 and table.concat(fallbackLabels, " > ") or "None") .. ". Change this in Options > Pricing."))
    for _, topic in ipairs(topics) do
        if topic.key == "values" then
            for _, source in ipairs(self.VALUE_SOURCES or {}) do
                local help = VALUE_SOURCE_HELP[source.id] or {}
                topic.sections[#topic.sections + 1] = Section(source.label,
                    "Meaning: " .. (help.meaning or "A TSM value source."),
                    "Useful for: " .. (help.bestFor or "Estimates that match this pricing source."),
                    "Watch for: " .. (help.watchFor or "Availability depends on TSM data."))
            end
        end
        local text = { topic.label, topic.summary, topic.keywords or "" }
        for _, section in ipairs(topic.sections) do
            text[#text + 1] = section.title
            for _, bullet in ipairs(section.bullets) do text[#text + 1] = bullet end
        end
        topic.searchText = string.lower(table.concat(text, " "))
    end
    local ordered = {}
    for _, group in ipairs({ "START HERE", "MAKE GOLD", "EXPLORER", "REFERENCE" }) do
        for _, topic in ipairs(topics) do
            if topic.group == group then ordered[#ordered + 1] = topic end
        end
    end
    return ordered
end

function GoldTracker:SearchHelpTopics(query, topics)
    local words, matches = {}, {}
    for word in string.lower(query or ""):gmatch("%S+") do words[#words + 1] = word end
    for _, topic in ipairs(topics) do
        local matched = true
        for _, word in ipairs(words) do
            if not topic.searchText:find(word, 1, true) then matched = false; break end
        end
        if matched then matches[#matches + 1] = topic end
    end
    return matches
end
