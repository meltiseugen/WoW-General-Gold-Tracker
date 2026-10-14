local _, NS = ...

-- Curated Retail mount-farm research for Drops > Mounts.
-- Coordinates are normalized UI-map coordinates. Research reviewed 2026-10-02.

local farms = {
    {
        id = "ggt:mount:poseidus",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Reins of Poseidus",
        expansion = "cataclysm",
        primaryItemID = 67151,
        routeCount = 2,
        mapIDs = { 205, 204 },
        mapNames = { "Shimmering Expanse", "Abyssal Depths" },
        targets = {},
        summary = "Poseidus is a rare spawn with five known Retail spawn points across Vashj'ir. The mount is a guaranteed, bind-on-equip drop when the rare is successfully looted.",
        guide = {
            label = "Rare spawn hunt",
            requirement = "Reach Vashj'ir and patrol both Shimmering Expanse and Abyssal Depths. Do not join a raid group before the kill.",
            action = "Cycle all five pins, targeting Poseidus at each point instead of camping only one location.",
            tips = {
                "Current Retail reports put the respawn window at roughly 2-8 hours; older 72-120 hour comments describe obsolete Cataclysm-era behavior.",
                "Use a target macro or a rare-alert addon that can detect non-vignette rares; Poseidus can be easy to miss in the water.",
                "A normal party can share the kill, but raid-group loot restrictions can prevent the mount from dropping.",
            },
        },
        details = {
            "Four spawn points are in Shimmering Expanse and one is in Abyssal Depths.",
            "No dependable evidence supports a shared timer with another Vashj'ir rare, so check every point on each circuit.",
        },
        sourceUrls = {
            { siteName = "Wowhead Poseidus guide", url = "https://www.wowhead.com/guide/poseidus-mount" },
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=67151/reins-of-poseidus" },
            { siteName = "Warcraft Wiki", url = "https://warcraft.wiki.gg/wiki/Poseidus" },
        },
        mapOptions = {
            {
                id = "ggt:mount:poseidus:shimmering-expanse",
                mapID = 205,
                mapLabel = "Shimmering Expanse",
                label = "Four Poseidus spawns",
                location = "Shimmering Expanse",
                isRoute = false,
                density = "Four separate rare-spawn checks",
                dropDifficulty = "Guaranteed mount from Poseidus; the difficulty is finding the rare alive.",
                pins = {
                    { x = 0.666, y = 0.414, label = "Ruins of Thelserai" },
                    { x = 0.584, y = 0.822, label = "Biel'aran Ridge" },
                    { x = 0.466, y = 0.500, label = "Glimmerdeep Gorge" },
                    { x = 0.400, y = 0.678, label = "Ruins of Vashj'ir" },
                },
            },
            {
                id = "ggt:mount:poseidus:abyssal-depths",
                mapID = 204,
                mapLabel = "Abyssal Depths",
                label = "Underlight Canyon spawn",
                location = "Underlight Canyon",
                isRoute = false,
                density = "One rare-spawn check",
                dropDifficulty = "Guaranteed mount from Poseidus; the difficulty is finding the rare alive.",
                pins = {
                    { x = 0.414, y = 0.763, label = "Underlight Canyon" },
                },
            },
        },
    },
    {
        id = "ggt:mount:garn-nighthowl",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Garn Nighthowl",
        expansion = "warlords",
        primaryItemID = 116794,
        routeCount = 1,
        mapIDs = { 525 },
        mapNames = { "Frostfire Ridge" },
        targets = {},
        summary = "Nok-Karosh patrols Frostboar Drifts north of Wor'gol and drops Garn Nighthowl for every eligible character on the kill.",
        guide = {
            label = "Rare spawn camp",
            requirement = "Reach Frostboar Drifts in Frostfire Ridge and wait near Nok-Karosh's patrol area.",
            action = "Camp the marked patrol point, kill Nok-Karosh when he appears, and loot the corpse.",
            tips = {
                "Modern characters can usually solo this old elite; launch-era group and taunt tactics are no longer representative.",
                "Community reports commonly place the respawn in the tens of minutes, but it is variable rather than a fixed timer.",
                "Some comments claim leaving the surrounding wolves alive helps the respawn, while later timing tests disagree; treat that as unconfirmed.",
            },
        },
        details = {
            "The marked point is the center of the NPC's small coordinate cluster around 13-15, 50-52.",
            "The drop is bind on pickup but is awarded to each eligible looter, so there is no need to compete with party members.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=116794/garn-nighthowl" },
            { siteName = "Warcraft Wiki", url = "https://warcraft.wiki.gg/wiki/Nok-Karosh" },
            { siteName = "True Endgame guide", url = "https://trueendgame.com/garn-nighthowl/" },
        },
        mapOptions = {
            {
                id = "ggt:mount:garn-nighthowl:frostboar-drifts",
                mapID = 525,
                mapLabel = "Frostfire Ridge",
                label = "Nok-Karosh patrol",
                location = "Frostboar Drifts",
                isRoute = false,
                density = "Single rare patrol area",
                dropDifficulty = "Guaranteed for eligible looters; wait time depends on the respawn.",
                pins = {
                    { x = 0.136, y = 0.510, label = "Nok-Karosh patrol center" },
                },
            },
        },
    },
    {
        id = "ggt:mount:goldenmanes-reins",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Goldenmane's Reins",
        expansion = "battle-for-azeroth",
        primaryItemID = 163573,
        routeCount = 1,
        mapIDs = { 942 },
        mapNames = { "Stormsong Valley" },
        targets = {},
        summary = "Goldenmane is an extremely rare bind-on-equip world drop from Stormsong Valley enemies. The Brineworks provides a compact circuit of confirmed eligible Brinebrawn and Shipwright mobs.",
        guide = {
            label = "World-drop circuit",
            requirement = "Use a character that can quickly tag and loot dense level-scaled enemies in Stormsong Valley.",
            action = "Circle the Brineworks pins and kill Brinebrawn Cannoneers and Shipwright Turncoats as they respawn.",
            tips = {
                "This is a very long-RNG farm: complete comment reports range from thousands to well over 100,000 kills.",
                "Current reports describe the solo respawn as slower than the old launch-era hyperspawn; group tagging still raises kills per hour.",
                "Avoid judging the route from a short session. Track kills and treat the mount as a bonus world drop, not an expected hourly yield.",
            },
        },
        details = {
            "The route follows the dense Brineworks coordinate clusters for Brinebrawn Cannoneers and Shipwright Turncoats.",
            "Old comments describe a much faster hyperspawn. Recent 2025-2026 reports still confirm the drop here, but not the old solo throughput.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=163573/goldenmanes-reins" },
            { siteName = "Wowhead Brinebrawn map", url = "https://www.wowhead.com/npc=130039/brinebrawn-cannoneer" },
            { siteName = "Method BfA farm article", url = "https://www.method.gg/things-to-do-before-shadowlands" },
        },
        mapOptions = {
            {
                id = "ggt:mount:goldenmane:brineworks",
                mapID = 942,
                mapLabel = "Stormsong Valley",
                label = "Brineworks mob loop",
                location = "The Brineworks",
                isRoute = false,
                density = "Compact Brinebrawn and Shipwright circuit",
                dropDifficulty = "Extremely rare bind-on-equip world drop with no guaranteed kill count.",
                pins = {
                    { x = 0.698, y = 0.492, label = "North Brineworks" },
                    { x = 0.708, y = 0.504, label = "Northeast packs" },
                    { x = 0.706, y = 0.518, label = "East packs" },
                    { x = 0.700, y = 0.528, label = "Southeast packs" },
                    { x = 0.694, y = 0.538, label = "South packs" },
                    { x = 0.688, y = 0.524, label = "Southwest packs" },
                    { x = 0.682, y = 0.514, label = "West packs" },
                    { x = 0.692, y = 0.504, label = "Central packs" },
                },
            },
        },
    },
    {
        id = "ggt:mount:tamed-bloodfeaster",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Reins of a Tamed Bloodfeaster",
        expansion = "battle-for-azeroth",
        primaryItemID = 163575,
        routeCount = 3,
        mapIDs = { 863 },
        mapNames = { "Nazmir" },
        targets = {},
        summary = "The Bloodfeaster is a very rare bind-on-equip world drop from loot-bearing Nazmir creatures. The best documented targeted farm is the ordinary Loa-Gutter Drudge population at Torga's Rest and inside Torga's Innards; Koramar is a separate alternate blood-troll farm.",
        guide = {
            label = "World-drop circuit",
            requirement = "Use a character that can continuously pull and loot blood trolls in northern Nazmir.",
            action = "Use the recommended Torga loop to clear Loa-Gutter Drudges continuously. Switch to the exact-spawn map when learning the cave, or Koramar when Torga is crowded.",
            tips = {
                "Do not camp only named rares: complete drop reports repeatedly confirm the mount from ordinary Loa-Gutter Drudges and other Nazmir mobs.",
                "The Torga circuit is the strongest solo recommendation because its packs are close together and begin respawning as a lap completes.",
                "Koramar was a high-throughput group spot around 46.4, 51.3, but its usefulness can vary with phasing, competition, and respawn changes.",
                "This remains severe RNG. Confirmed Torga reports range from hundreds to tens of thousands of kills, with no guaranteed threshold.",
            },
        },
        details = {
            "Exact spawn map: all 22 Loa-Gutter Drudge coordinates currently embedded in Wowhead's Nazmir mapper.",
            "Recommended loop: a readable circuit derived from the outer and inner edges of that exact coordinate cluster.",
            "Alternate Koramar map: the documented 2x4/group center at 46.4, 51.3 plus a confirmed Nazmani Ritualist drop report at 47, 56.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=163575/reins-of-a-tamed-bloodfeaster" },
            { siteName = "Wowhead Loa-Gutter map", url = "https://www.wowhead.com/npc=127928/loa-gutter-drudge" },
            { siteName = "T'as Pas 1 Po guide", url = "https://taspas1po.fr/guide-monture-obtenir-les-renes-de-sanguivore-apprivoise/" },
            { siteName = "Blizzard forum Koramar report", url = "https://us.forums.blizzard.com/en/wow/t/parties-farming-in-koramar-nazmir/205245" },
        },
        mapOptions = {
            {
                id = "ggt:mount:bloodfeaster:torga-spawns",
                mapID = 863,
                mapLabel = "Nazmir",
                label = "Torga exact Loa-Gutter spawns",
                location = "Torga's Rest and Torga's Innards",
                isRoute = false,
                density = "All 22 mapped Loa-Gutter Drudge spawn points",
                dropDifficulty = "Very rare bind-on-equip world drop; the pins show eligible ordinary mobs, not named rares.",
                pins = {
                    { x = 0.584, y = 0.204, label = "Loa-Gutter Drudge" },
                    { x = 0.584, y = 0.210, label = "Loa-Gutter Drudge" },
                    { x = 0.588, y = 0.208, label = "Loa-Gutter Drudge" },
                    { x = 0.588, y = 0.220, label = "Loa-Gutter Drudge" },
                    { x = 0.590, y = 0.226, label = "Loa-Gutter Drudge" },
                    { x = 0.594, y = 0.202, label = "Loa-Gutter Drudge" },
                    { x = 0.596, y = 0.204, label = "Loa-Gutter Drudge" },
                    { x = 0.598, y = 0.224, label = "Loa-Gutter Drudge" },
                    { x = 0.598, y = 0.226, label = "Loa-Gutter Drudge" },
                    { x = 0.600, y = 0.194, label = "Loa-Gutter Drudge" },
                    { x = 0.600, y = 0.212, label = "Loa-Gutter Drudge" },
                    { x = 0.604, y = 0.174, label = "Loa-Gutter Drudge" },
                    { x = 0.604, y = 0.182, label = "Loa-Gutter Drudge" },
                    { x = 0.604, y = 0.238, label = "Loa-Gutter Drudge" },
                    { x = 0.606, y = 0.230, label = "Loa-Gutter Drudge" },
                    { x = 0.608, y = 0.200, label = "Loa-Gutter Drudge" },
                    { x = 0.608, y = 0.210, label = "Loa-Gutter Drudge" },
                    { x = 0.608, y = 0.220, label = "Loa-Gutter Drudge" },
                    { x = 0.610, y = 0.182, label = "Loa-Gutter Drudge" },
                    { x = 0.610, y = 0.194, label = "Loa-Gutter Drudge" },
                    { x = 0.616, y = 0.192, label = "Loa-Gutter Drudge" },
                    { x = 0.616, y = 0.196, label = "Loa-Gutter Drudge" },
                },
            },
            {
                id = "ggt:mount:bloodfeaster:torga",
                mapID = 863,
                mapLabel = "Nazmir",
                label = "Recommended Torga farming loop",
                location = "Torga's Rest and Torga's Innards",
                isRoute = false,
                density = "Continuous Loa-Gutter Drudge circuit",
                dropDifficulty = "Very rare bind-on-equip world drop with no guaranteed kill count.",
                pins = {
                    { x = 0.604, y = 0.174, label = "North Torga packs" },
                    { x = 0.616, y = 0.192, label = "Northeast packs" },
                    { x = 0.608, y = 0.200, label = "East packs" },
                    { x = 0.608, y = 0.220, label = "Southeast packs" },
                    { x = 0.604, y = 0.238, label = "South Torga packs" },
                    { x = 0.590, y = 0.226, label = "Southwest packs" },
                    { x = 0.584, y = 0.210, label = "West packs" },
                    { x = 0.594, y = 0.202, label = "Inner west packs" },
                    { x = 0.600, y = 0.194, label = "Inner north packs" },
                },
            },
            {
                id = "ggt:mount:bloodfeaster:koramar",
                mapID = 863,
                mapLabel = "Nazmir",
                label = "Koramar alternate farm",
                location = "Koramar",
                isRoute = false,
                density = "Two documented Koramar blood-troll farm points",
                dropDifficulty = "Alternate group farm; phasing and current respawn behavior can affect throughput.",
                pins = {
                    { x = 0.464, y = 0.513, label = "Documented Koramar group-farm center" },
                    { x = 0.470, y = 0.560, label = "Confirmed Nazmani Ritualist drop report" },
                },
            },
        },
    },
    {
        id = "ggt:mount:captured-dune-scavenger",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Captured Dune Scavenger",
        expansion = "battle-for-azeroth",
        primaryItemID = 163576,
        routeCount = 2,
        mapIDs = { 864 },
        mapNames = { "Vol'dun" },
        targets = {},
        summary = "The Dune Scavenger is a very rare bind-on-equip Vol'dun world drop. The strongest current evidence favors the Sethrak Relic Hunter and Site Guardian circuit near 47-51, 72-78.",
        guide = {
            label = "World-drop circuit",
            requirement = "Use a character that can quickly tag, loot, and move between eligible Vol'dun enemies.",
            action = "Prioritize the southern Sethrak relic-site loop; use the Scalefang camp as an alternate circuit when the main area is busy.",
            tips = {
                "A 2024 report confirms a drop from a Sethrak Relic Hunter near 48, 75, matching the primary route's NPC coordinate data.",
                "The old launch-era 55,40 and 33,60 hyperspawn tips were reported nerfed in 2018 and are not the recommended current route.",
                "Expect severe RNG and sparse groups. Current comments commonly describe solo grinds of many thousands of kills.",
            },
        },
        details = {
            "Primary: Sethrak Relic Hunters and Site Guardians around the southern relic site.",
            "Alternate: Scalefang Warguards and nearby eligible mobs around 30-32, 74-79.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=163576/captured-dune-scavenger" },
            { siteName = "Wowhead Relic Hunter map", url = "https://www.wowhead.com/npc=127406/sethrak-relic-hunter" },
            { siteName = "Warcraft Mounts BfA sources", url = "https://www.warcraftmounts.com/bfasource.php" },
        },
        mapOptions = {
            {
                id = "ggt:mount:dune-scavenger:sethrak-relic-site",
                mapID = 864,
                mapLabel = "Vol'dun",
                label = "Sethrak relic-site loop",
                location = "Southern Vol'dun relic site",
                isRoute = false,
                density = "Relic Hunter and Site Guardian circuit",
                dropDifficulty = "Very rare bind-on-equip world drop with no guaranteed kill count.",
                pins = {
                    { x = 0.472, y = 0.728, label = "Northwest relic packs" },
                    { x = 0.490, y = 0.732, label = "North relic packs" },
                    { x = 0.504, y = 0.728, label = "Northeast relic packs" },
                    { x = 0.512, y = 0.736, label = "East relic packs" },
                    { x = 0.500, y = 0.766, label = "Southeast relic packs" },
                    { x = 0.486, y = 0.774, label = "South relic packs" },
                    { x = 0.472, y = 0.772, label = "Southwest relic packs" },
                    { x = 0.470, y = 0.756, label = "West relic packs" },
                    { x = 0.484, y = 0.744, label = "Central relic packs" },
                },
            },
            {
                id = "ggt:mount:dune-scavenger:scalefang",
                mapID = 864,
                mapLabel = "Vol'dun",
                label = "Scalefang alternate loop",
                location = "Scalefang camp",
                isRoute = false,
                density = "Alternate Scalefang Warguard circuit",
                dropDifficulty = "Very rare bind-on-equip world drop with no guaranteed kill count.",
                pins = {
                    { x = 0.314, y = 0.744, label = "North Scalefang packs" },
                    { x = 0.304, y = 0.752, label = "Northwest packs" },
                    { x = 0.304, y = 0.766, label = "West packs" },
                    { x = 0.312, y = 0.772, label = "Southwest packs" },
                    { x = 0.318, y = 0.786, label = "South packs" },
                    { x = 0.318, y = 0.776, label = "Southeast packs" },
                    { x = 0.322, y = 0.762, label = "East packs" },
                    { x = 0.310, y = 0.758, label = "Central packs" },
                },
            },
        },
    },
    {
        id = "ggt:mount:terrified-pack-mule",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Chewed-On Reins of the Terrified Pack Mule",
        expansion = "battle-for-azeroth",
        primaryItemID = 163574,
        routeCount = 1,
        mapIDs = { 896 },
        mapNames = { "Drustvar" },
        targets = {},
        summary = "The Pack Mule is a very rare bind-on-equip world drop from Drustvar's Hexthralled enemies. A current 2026 route spreads across Corlain, Pikeman Ridge, the Armory, and the Aviary because the old hyperspawn no longer sustains a stationary farm.",
        guide = {
            label = "World-drop sweep",
            requirement = "Use a mobile character that can clear and loot Hexthralled enemies across northern Drustvar.",
            action = "Sweep the marked Corlain-area points, targeting Hexthralled enemies instead of waiting at the obsolete Barrowknoll hyperspawn.",
            tips = {
                "The old Pikeman Ridge/Barrowknoll hyperspawn is obsolete; current reports describe roughly five-minute local respawns and recommend moving between areas.",
                "A /tar Hexthralled macro helps identify eligible enemies while traveling between the marked clusters.",
                "The mount is a very rare bind-on-equip world drop. Clearing more eligible mobs improves attempts, not the per-kill chance.",
            },
        },
        details = {
            "The 13 researched coordinates come from a March 2026 route report and cover several Corlain sub-areas.",
            "The pins are ordered as a geographic sweep to reduce backtracking; reverse the route if another farmer is ahead of you.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=163574/chewed-on-reins-of-the-terrified-pack-mule" },
            { siteName = "Warcraft Mounts", url = "https://www.warcraftmounts.com/mounts/terrifiedpackmule.php" },
            { siteName = "Riddlepop farm guide", url = "https://riddlepop.com/farms/mounts/terrifiedpackmule" },
        },
        mapOptions = {
            {
                id = "ggt:mount:pack-mule:corlain-sweep",
                mapID = 896,
                mapLabel = "Drustvar",
                label = "Corlain Hexthralled sweep",
                location = "Corlain, Pikeman Ridge, Armory, and Aviary",
                isRoute = false,
                density = "Thirteen current Hexthralled farm points",
                dropDifficulty = "Very rare bind-on-equip world drop with no guaranteed kill count.",
                pins = {
                    { x = 0.355, y = 0.130, label = "Northern Aviary" },
                    { x = 0.341, y = 0.173, label = "Upper Corlain" },
                    { x = 0.332, y = 0.209, label = "Corlain northeast" },
                    { x = 0.316, y = 0.212, label = "Corlain east" },
                    { x = 0.304, y = 0.206, label = "Corlain center" },
                    { x = 0.298, y = 0.180, label = "Northern Corlain" },
                    { x = 0.290, y = 0.208, label = "Corlain west" },
                    { x = 0.293, y = 0.223, label = "Western Corlain" },
                    { x = 0.274, y = 0.243, label = "Pikeman Ridge north" },
                    { x = 0.283, y = 0.256, label = "Pikeman Ridge" },
                    { x = 0.276, y = 0.279, label = "Corlain Armory west" },
                    { x = 0.298, y = 0.276, label = "Corlain Armory east" },
                    { x = 0.288, y = 0.319, label = "Southern Corlain" },
                },
            },
        },
    },
    {
        id = "ggt:mount:great-sea-ray",
        sourceType = "curated",
        sourceDataset = "GGTMountFarmData",
        sourceCategory = "mounts",
        sourcePath = "Drops > Mounts",
        activity = "mount",
        name = "Great Sea Ray",
        expansion = "battle-for-azeroth",
        primaryItemID = 163131,
        routeCount = 2,
        mapIDs = { 942, 862 },
        mapNames = { "Stormsong Valley", "Zuldazar" },
        targets = {},
        summary = "The Great Sea Ray is a bind-on-equip fishing catch from Battle for Azeroth waters. Current reports confirm it in both open water and pools, with no dependable evidence that one spot, skill level, bait, or fishing gear improves the mount chance.",
        guide = {
            label = "Stationary fishing",
            requirement = "Fish in Battle for Azeroth waters. Expansion fishing skill is useful but no minimum has been proven for the mount itself.",
            action = "Choose either confirmed stationary pin and keep casting; change spots for convenience or competition, not for a promised drop-rate boost.",
            tips = {
                "Ignore early BfA claims of roughly one mount per 200 casts. The rate was reduced, and current complete reports often run into thousands or tens of thousands of casts.",
                "Open water, normal pools, inland water, and coastal water all have confirmed reports; there is no verified best-water bonus.",
                "Recent comments also report catches from Secret Fish bubbles, but that is a bonus path rather than an efficient targeted farm.",
            },
        },
        details = {
            "Seeker's Vista has repeated 2025-2026 confirmations and is a quiet stationary Alliance-side option.",
            "Port of Zandalar has repeated 2025-2026 confirmations and is a convenient Horde-side city option.",
            "Buying the bind-on-equip mount teaches it, but the Catchin' Some Rays achievement requires personally fishing it up.",
        },
        sourceUrls = {
            { siteName = "Wowhead comments", url = "https://www.wowhead.com/item=163131/great-sea-ray" },
            { siteName = "Legacy Gaming BfA fishing guide", url = "https://www.legacy-gaming.com/fishing-guide-battle-for-azeroth/" },
            { siteName = "Warcraft Mounts BfA sources", url = "https://www.warcraftmounts.com/bfasource.php" },
        },
        mapOptions = {
            {
                id = "ggt:mount:great-sea-ray:seekers-vista",
                mapID = 942,
                mapLabel = "Stormsong Valley",
                label = "Seeker's Vista fishing",
                location = "Seeker's Vista",
                isRoute = false,
                density = "Confirmed stationary fishing water",
                dropDifficulty = "Extremely rare fishing catch; expect potentially thousands of casts.",
                pins = {
                    { x = 0.401, y = 0.348, label = "Seeker's Vista fishing spot" },
                },
            },
            {
                id = "ggt:mount:great-sea-ray:port-of-zandalar",
                mapID = 862,
                mapLabel = "Zuldazar",
                label = "Port of Zandalar fishing",
                location = "Port of Zandalar",
                isRoute = false,
                density = "Confirmed stationary fishing water",
                dropDifficulty = "Extremely rare fishing catch; expect potentially thousands of casts.",
                pins = {
                    { x = 0.5783, y = 0.6323, label = "Port of Zandalar fishing spot" },
                },
            },
        },
    },
}

local catalog = NS.FarmCatalog
if type(catalog) ~= "table" then
    catalog = {
        farms = {},
        byID = {},
        indexes = {},
        sourceCounts = {},
    }
    NS.FarmCatalog = catalog
end

catalog.farms = type(catalog.farms) == "table" and catalog.farms or {}
catalog.byID = type(catalog.byID) == "table" and catalog.byID or {}
catalog.indexes = type(catalog.indexes) == "table" and catalog.indexes or {}
catalog.sourceCounts = type(catalog.sourceCounts) == "table" and catalog.sourceCounts or {}

local function AddIndex(indexName, key, position)
    if key == nil then
        return
    end
    local index = catalog.indexes[indexName]
    if type(index) ~= "table" then
        index = {}
        catalog.indexes[indexName] = index
    end
    local entries = index[key]
    if type(entries) ~= "table" then
        entries = {}
        index[key] = entries
    end
    entries[#entries + 1] = position
end

local uniqueItemsAdded = 0
for _, farm in ipairs(farms) do
    if not catalog.byID[farm.id] then
        local itemIndex = catalog.indexes.byItemID
        local isNewItem = type(itemIndex) ~= "table" or type(itemIndex[farm.primaryItemID]) ~= "table"
        local position = #catalog.farms + 1
        catalog.farms[position] = farm
        catalog.byID[farm.id] = position
        AddIndex("byItemID", farm.primaryItemID, position)
        AddIndex("byActivity", farm.activity, position)
        AddIndex("byExpansion", farm.expansion, position)
        AddIndex("bySourceCategory", farm.sourceCategory, position)
        AddIndex("bySourceType", farm.sourceType, position)
        for _, mapID in ipairs(farm.mapIDs or {}) do
            AddIndex("byMapID", mapID, position)
        end
        if isNewItem then
            uniqueItemsAdded = uniqueItemsAdded + 1
        end
    end
end

catalog.farmCount = #catalog.farms
catalog.uniqueItemCount = (tonumber(catalog.uniqueItemCount) or 0) + uniqueItemsAdded
catalog.sourceCounts.curatedMounts = #farms

NS.MountFarmData = {
    dataVersion = 1,
    researchedAt = "2026-10-03",
    farms = farms,
}
