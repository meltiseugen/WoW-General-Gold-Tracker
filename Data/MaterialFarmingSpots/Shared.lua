local _, NS = ...

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local TWW_MINING_SPOTS = {
    {
        id = "tww-mining-isle-of-dorn-bismuth-ironclaw-route",
        source = "Method route guide, Method mining guide, Wowhead mining object map pins",
        sourceUrls = {
            "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
            "https://www.wowhead.com/object=413046/bismuth",
            "https://www.wowhead.com/object=413049/ironclaw",
            "https://www.wowhead.com/object=430335/webbed-ore-deposit",
        },
        mapName = "Isle of Dorn",
        location = "Western mountain and cliff loop with repeated Bismuth, Ironclaw, and Webbed ore pins",
        routeType = "mining-loop",
        density = "High for Bismuth with useful Ironclaw checks",
        dropDifficulty = "Bismuth is common here; Ironclaw is less common and should be farmed by clearing "
            .. "every ore node on the loop.",
        tips = {
            "Use Finesse-focused gathering gear when farming for volume.",
            "Use Phial of Truesight and Darkmoon Firewater when available.",
            "Object pins cluster around the western Isle of Dorn slopes, so loop the ridge instead of "
                .. "crossing the full zone.",
            "Mine Webbed deposits too because they can replace normal ore spawns and may add Weavercloth.",
        },
        coords = {
            C(0.187, 0.583, "Bismuth and Ironclaw west ridge pins"),
            C(0.191, 0.596, "Western ridge return"),
            C(0.202, 0.612, "Southwest ore pocket"),
            C(0.203, 0.600, "Western slope ore cluster"),
            C(0.205, 0.604, "Bismuth and Webbed ore cluster"),
            C(0.207, 0.541, "Northern Ironclaw seam check"),
        },
        confidence = "medium",
    },
    {
        id = "tww-mining-ringing-deeps-ironclaw-bismuth-route",
        source = "Method mining guide and Wowhead Bismuth, Ironclaw, and Crystallized Ironclaw object map pins",
        sourceUrls = {
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
            "https://www.wowhead.com/object=413046/bismuth",
            "https://www.wowhead.com/object=413049/ironclaw",
            "https://www.wowhead.com/object=413900/crystallized-ironclaw",
        },
        mapName = "The Ringing Deeps",
        location = "Northern Ringing Deeps ore wall and tunnel loop",
        routeType = "mining-loop",
        density = "Medium to high for Bismuth and Ironclaw",
        dropDifficulty = "Strong Ironclaw targeting route, with Bismuth and modified deposits sharing the "
            .. "same wall clusters.",
        tips = {
            "Stay near the northern ore walls where Bismuth, Ironclaw, and Crystallized variants overlap.",
            "Clear adjacent ore types to force respawns instead of waiting on one node type.",
            "Crystallized deposits are worth clearing when Crystalline Powder prices are good.",
        },
        coords = {
            C(0.349, 0.164, "Northern rich Ironclaw pin"),
            C(0.352, 0.172, "Crystallized Ironclaw north pin"),
            C(0.355, 0.164, "Bismuth and Ironclaw wall cluster"),
            C(0.360, 0.195, "Northern bend ore cluster"),
            C(0.366, 0.229, "Bismuth and Ironclaw south bend"),
            C(0.371, 0.238, "Tunnel return ore pins"),
            C(0.376, 0.167, "Northern wall return"),
        },
        confidence = "high",
    },
    {
        id = "tww-mining-hallowfall-aqirite-bismuth-route",
        source = "Method route guide and Wowhead Aqirite, Aqirite Seam, Bismuth, and Weeping Aqirite object map pins",
        sourceUrls = {
            "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
            "https://www.wowhead.com/object=413047/aqirite",
            "https://www.wowhead.com/object=413881/aqirite-seam",
            "https://www.wowhead.com/object=413046/bismuth",
            "https://www.wowhead.com/object=413892/weeping-aqirite",
        },
        mapName = "Hallowfall",
        location = "Western and southern cliff loops where Aqirite and Bismuth pins overlap",
        routeType = "mining-loop",
        density = "Medium for Aqirite with common Bismuth",
        dropDifficulty = "Aqirite is uncommon, so clear the whole cliff route and treat seams as bonus checks.",
        tips = {
            "Hallowfall is a primary Aqirite target zone along with Azj-Kahet.",
            "Sweep cliff edges and cave-adjacent walls where Aqirite seams appear.",
            "Weeping and Crystallized variants can add secondary reagent value while mining the same route.",
        },
        coords = {
            C(0.210, 0.596, "West Hallowfall Bismuth and Aqirite pins"),
            C(0.212, 0.646, "West cliff ore pocket"),
            C(0.217, 0.624, "West cliff return"),
            C(0.394, 0.930, "Southern Weeping Aqirite pocket"),
            C(0.409, 0.865, "Southern ore bend"),
            C(0.517, 0.504, "Aqirite seam check"),
            C(0.605, 0.596, "Eastern Aqirite seam check"),
        },
        confidence = "high",
    },
    {
        id = "tww-mining-azj-kahet-aqirite-route",
        source = "Method mining guide and Wowhead Aqirite, Rich Aqirite, Aqirite Seam, and Webbed ore object map pins",
        sourceUrls = {
            "https://www.method.gg/guides/the-war-within-mining-profession-leveling-guide",
            "https://www.wowhead.com/object=413047/aqirite",
            "https://www.wowhead.com/object=413875/rich-aqirite",
            "https://www.wowhead.com/object=413881/aqirite-seam",
            "https://www.wowhead.com/object=430335/webbed-ore-deposit",
        },
        mapName = "Azj-Kahet",
        location = "Western Azj-Kahet Aqirite and Webbed ore loop",
        routeType = "mining-loop",
        density = "High for Aqirite-targeted checks",
        dropDifficulty = "Aqirite is still uncommon, but western object pins are dense enough for a targeted loop.",
        tips = {
            "Use this route when Aqirite value beats Bismuth volume.",
            "Clear Webbed deposits because they share the route and can add Weavercloth.",
            "Extend toward the central seam pins only if the western loop is crowded.",
        },
        coords = {
            C(0.210, 0.320, "Western Aqirite object pin"),
            C(0.211, 0.487, "Rich Aqirite and Webbed ore cluster"),
            C(0.216, 0.489, "Western Webbed ore pocket"),
            C(0.222, 0.483, "Rich Aqirite return"),
            C(0.227, 0.318, "Crystallized Aqirite check"),
            C(0.315, 0.568, "Aqirite seam western check"),
            C(0.389, 0.427, "Central Aqirite seam check"),
        },
        confidence = "high",
    },
}

local function CopyArray(values)
    local copy = {}
    for _, value in ipairs(values or {}) do
        copy[#copy + 1] = value
    end
    return copy
end

local TWW_HERB_SPOTS = {
    {
        id = "tww-herbalism-isle-of-dorn-general-route",
        source = "Wowhead herbalism overview, Method route guide, and Wowhead herb object map pins",
        sourceUrls = {
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
            "https://www.wowhead.com/object=414315/mycobloom",
            "https://www.wowhead.com/object=414318/blessing-blossom",
            "https://www.wowhead.com/object=414319/arathors-spear",
        },
        mapName = "Isle of Dorn",
        location = "Western Isle of Dorn herb loop with Mycobloom, Blessing Blossom, and Arathor's Spear pins",
        routeType = "herbalism-loop",
        density = "Medium to high for broad herb checks",
        dropDifficulty = "Mycobloom is widespread. Blessing Blossom and Arathor's Spear are terrain dependent "
            .. "but appear in this route.",
        tips = {
            "Mycobloom is the broad baseline herb and is found across most terrain.",
            "Blessing Blossom favors open or high places.",
            "Arathor's Spear favors bright outdoor areas.",
            "Use the same speed and Finesse setup as mining when dual-gathering.",
        },
        coords = {
            C(0.187, 0.580, "Blessing Blossom west ridge pin"),
            C(0.202, 0.585, "Arathor's Spear west ridge pin"),
            C(0.206, 0.601, "Arathor's Spear and Blessing Blossom cluster"),
            C(0.212, 0.543, "Mycobloom northwest pin"),
            C(0.259, 0.633, "Mycobloom southwest sweep"),
            C(0.295, 0.560, "Mycobloom center return"),
            C(0.379, 0.712, "Southern Mycobloom extension"),
        },
        confidence = "medium",
    },
    {
        id = "tww-ringing-deeps-underground-herb-route",
        source = "Wowhead herbalism overview and Mycobloom, Luredrop, Orbinid, and Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.wowhead.com/object=414315/mycobloom",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/object=414317/orbinid",
            "https://www.wowhead.com/object=414319/arathors-spear",
        },
        mapName = "The Ringing Deeps",
        location = "Northern underground herb loop",
        routeType = "underground-herb-loop",
        density = "Medium",
        dropDifficulty = "Good for cave and underground-leaning herb checks while still producing Mycobloom.",
        tips = {
            "Use this route for Luredrop and Orbinid checks without abandoning common herbs.",
            "Follow tunnel walls and cave pockets where object pins overlap.",
            "Irradiated herb variants here can add Leyline Residue.",
        },
        coords = {
            C(0.341, 0.157, "Luredrop and Mycobloom north pocket"),
            C(0.346, 0.174, "Northern herb wall"),
            C(0.351, 0.208, "Mycobloom and Luredrop bend"),
            C(0.373, 0.194, "Orbinid tunnel check"),
            C(0.382, 0.315, "Orbinid south tunnel"),
            C(0.399, 0.435, "Arathor's Spear mid-route check"),
            C(0.410, 0.408, "Arathor's Spear return"),
        },
        confidence = "high",
    },
    {
        id = "tww-hallowfall-rich-soil-beledars-bounty",
        source = "Wowhead herbalism overview and Hallowfall herb object map pins",
        sourceUrls = {
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.wowhead.com/object=414315/mycobloom",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/object=414318/blessing-blossom",
        },
        mapName = "Hallowfall",
        location = "Beledar's Bounty farm, central Hallowfall southeast of Mereldar",
        routeType = "localized-node-cluster",
        density = "Localized and high for repeated checks",
        dropDifficulty = "Useful for Rich Soil plus herb nodes around the same farm and nearby shore pockets.",
        tips = {
            "Check the farm area for concentrated Rich Soil.",
            "Clear nearby pests while moving between soil and herb nodes.",
            "This is also a useful Luredrop and Mycobloom pocket when broader routes are crowded.",
        },
        coords = {
            C(0.464, 0.647, "Beledar's Bounty west herb cluster"),
            C(0.467, 0.635, "Farm lane herb check"),
            C(0.470, 0.632, "Central farm return"),
            C(0.477, 0.634, "East farm herb check"),
            C(0.478, 0.645, "Southeast farm herb cluster"),
            C(0.480, 0.621, "North farm Luredrop check"),
            C(0.486, 0.632, "East Rich Soil and herb loop"),
        },
        confidence = "medium",
    },
    {
        id = "tww-hallowfall-arathors-spear-west-route",
        source = "Wowhead herbalism overview and Arathor's Spear object map pins",
        sourceUrls = {
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.wowhead.com/object=414319/arathors-spear",
            "https://www.wowhead.com/object=414339/irradiated-arathors-spear",
        },
        mapName = "Hallowfall",
        location = "Western bright outdoor ridges for Arathor's Spear",
        routeType = "terrain-targeted-herb-loop",
        density = "Medium",
        dropDifficulty = "Targeted Arathor's Spear checks; clear nearby herbs because spawns can rotate.",
        tips = {
            "Arathor's Spear favors bright outdoor terrain, and Hallowfall has dense western map pins.",
            "Check the west-side ridges before merging into a broader herb route.",
            "Irradiated variants can produce Leyline Residue along the same path.",
        },
        coords = {
            C(0.222, 0.614, "Western Arathor's Spear ridge"),
            C(0.223, 0.630, "West ridge return"),
            C(0.250, 0.557, "Bright ridge herb pin"),
            C(0.264, 0.531, "Irradiated Arathor's Spear check"),
            C(0.279, 0.490, "Northwest Spear extension"),
            C(0.294, 0.360, "Northern bright-ground check"),
        },
        confidence = "high",
    },
}

local MIDNIGHT_GATHERING_TIPS = {
    "Midnight materials use two quality levels instead of the older three-quality spread.",
    "Deftness helps avoid being interrupted in dense Midnight zones.",
    "Finesse is the best default stat when the goal is more base materials per hour.",
    "Perception is most useful when the target is a rare side gather such as Dazzling Thorium or Nocturnal Lotus.",
    "Darkmoon Firewater and the relevant Midnight tea or phial make long farming sessions smoother.",
}

local MIDNIGHT_EVERSONG_HERB_ORE_COORDS = {
    C(0.4055, 0.2693, "Eversong herb/ore route north start"),
    C(0.4378, 0.3681, "Fairbreeze north route bend"),
    C(0.4681, 0.3964, "Fairbreeze east gather check"),
    C(0.4980, 0.3774, "Central Eversong ore and herb check"),
    C(0.5472, 0.3699, "Goldenmist route shoulder"),
    C(0.6093, 0.4546, "East Eversong route extension"),
    C(0.5216, 0.4256, "Central return gather check"),
    C(0.4797, 0.4584, "Fairbreeze return node check"),
    C(0.5058, 0.5070, "Central south route bend"),
    C(0.4847, 0.6420, "Tranquillien north gather check"),
    C(0.5305, 0.5957, "Tranquillien east gather check"),
    C(0.5795, 0.5838, "Southeast river route"),
    C(0.6259, 0.5436, "Far southeast herb/ore route"),
    C(0.6183, 0.5964, "Southeast return route"),
    C(0.5695, 0.7081, "Southern Eversong gather line"),
    C(0.5721, 0.7556, "South road gather check"),
    C(0.5471, 0.7759, "South Tranquillien route"),
    C(0.5199, 0.8065, "Southwest route return"),
    C(0.4600, 0.8193, "Southwest Eversong gather check"),
    C(0.4452, 0.8711, "Windrunner south route"),
    C(0.4194, 0.8832, "Windrunner route end"),
    C(0.4064, 0.8390, "Windrunner return bend"),
    C(0.4175, 0.7956, "Southwest route return"),
    C(0.3962, 0.7855, "Southwest road gather check"),
    C(0.3824, 0.7642, "West river route"),
    C(0.3787, 0.7046, "West river return"),
    C(0.3836, 0.6259, "West Eversong gather line"),
    C(0.4210, 0.6545, "Central-west route cross"),
    C(0.4476, 0.6066, "Central-west gather check"),
    C(0.3533, 0.5118, "West Eversong loop shoulder"),
    C(0.3448, 0.4310, "Northwest return route"),
}

local MIDNIGHT_ZULAMAN_WILD_ORE_COORDS = {
    C(0.259, 0.378, "Wild Refulgent Copper northwest pin"),
    C(0.278, 0.656, "Wild Refulgent Copper west river pin"),
    C(0.289, 0.244, "Wild Refulgent Copper north ridge pin"),
    C(0.293, 0.859, "Wild Refulgent Copper south coast pin"),
    C(0.300, 0.724, "Wild ore west-south route"),
    C(0.342, 0.709, "Wild ore south interior pin"),
    C(0.386, 0.604, "Wild ore central route"),
    C(0.419, 0.696, "Wild ore southern road pin"),
    C(0.448, 0.795, "Wild ore southeast pin"),
    C(0.477, 0.786, "Wild ore southeast return"),
    C(0.532, 0.729, "Wild ore east loop"),
    C(0.596, 0.704, "Wild ore far east pin"),
}

local MIDNIGHT_HARANDAR_PRIMAL_ORE_COORDS = {
    C(0.483, 0.427, "Primal Refulgent Copper west-center pin"),
    C(0.488, 0.442, "Primal Refulgent Copper central cluster"),
    C(0.490, 0.483, "Primal ore middle route"),
    C(0.495, 0.491, "Primal ore center return"),
    C(0.496, 0.660, "Primal ore south route"),
    C(0.507, 0.434, "Primal ore central bend"),
    C(0.507, 0.476, "Primal ore central-east pin"),
    C(0.507, 0.613, "Primal ore southern middle pin"),
    C(0.508, 0.397, "Primal ore north-center pin"),
    C(0.509, 0.362, "Primal ore north return"),
    C(0.516, 0.409, "Primal ore upper center"),
    C(0.520, 0.437, "Primal ore east-center pin"),
    C(0.526, 0.446, "Primal ore east-center return"),
    C(0.528, 0.722, "Primal ore south extension"),
    C(0.529, 0.697, "Primal ore southern bend"),
    C(0.536, 0.349, "Primal ore north-east pin"),
    C(0.539, 0.434, "Primal ore east route"),
    C(0.539, 0.713, "Primal ore southeast route"),
}

local MIDNIGHT_VOIDSTORM_VOIDBOUND_ORE_COORDS = {
    C(0.227, 0.563, "Voidbound Refulgent Copper west pin"),
    C(0.242, 0.494, "Voidbound ore west ridge"),
    C(0.258, 0.444, "Voidbound ore northwest route"),
    C(0.279, 0.493, "Voidbound ore west return"),
    C(0.301, 0.588, "Voidbound ore southwest route"),
    C(0.313, 0.620, "Voidbound ore south-west pin"),
    C(0.332, 0.501, "Voidbound ore central-west pin"),
    C(0.342, 0.558, "Voidbound ore western middle"),
    C(0.360, 0.604, "Voidbound ore south bend"),
    C(0.371, 0.666, "Voidbound ore southern route"),
    C(0.424, 0.656, "Voidbound ore center route"),
    C(0.465, 0.606, "Voidbound ore center-east pin"),
    C(0.506, 0.548, "Voidbound ore east-center pin"),
    C(0.546, 0.564, "Voidbound ore eastern route"),
    C(0.580, 0.604, "Voidbound ore east bend"),
    C(0.602, 0.581, "Voidbound ore far-east pin"),
    C(0.630, 0.627, "Voidbound ore far-east return"),
    C(0.661, 0.629, "Voidbound ore southeast pin"),
}

local MIDNIGHT_ZULAMAN_HERB_COORDS = {
    C(0.414, 0.530, "Sanguithorn Zul'Aman central pin"),
    C(0.417, 0.488, "Sanguithorn west-central route"),
    C(0.418, 0.389, "Sanguithorn northwest route"),
    C(0.419, 0.329, "Sanguithorn north route"),
    C(0.422, 0.519, "Sanguithorn central return"),
    C(0.422, 0.590, "Sanguithorn center-south pin"),
    C(0.425, 0.778, "Sanguithorn southern pin"),
    C(0.426, 0.763, "Sanguithorn southern route"),
    C(0.428, 0.524, "Sanguithorn central-east pin"),
    C(0.429, 0.317, "Sanguithorn north return"),
    C(0.433, 0.570, "Sanguithorn central route"),
    C(0.436, 0.787, "Sanguithorn southeast route"),
    C(0.438, 0.324, "Sanguithorn north-east pin"),
    C(0.440, 0.294, "Sanguithorn north ridge pin"),
}

local MIDNIGHT_HARANDAR_HERB_COORDS = {
    C(0.374, 0.597, "Primal Argentleaf west Harandar pin"),
    C(0.378, 0.574, "Primal Argentleaf west route"),
    C(0.387, 0.516, "Primal Argentleaf northwest route"),
    C(0.404, 0.502, "Primal Argentleaf center-west pin"),
    C(0.415, 0.554, "Primal Argentleaf west-center return"),
    C(0.421, 0.542, "Primal Argentleaf center route"),
    C(0.425, 0.479, "Primal Argentleaf upper-center pin"),
    C(0.433, 0.507, "Primal Argentleaf center pin"),
    C(0.474, 0.701, "Primal Argentleaf south-west route"),
    C(0.476, 0.590, "Primal Argentleaf middle route"),
    C(0.527, 0.675, "Primal Argentleaf southern route"),
    C(0.534, 0.619, "Primal Argentleaf south-center pin"),
    C(0.556, 0.609, "Primal Argentleaf south-east pin"),
    C(0.570, 0.590, "Primal Argentleaf east route"),
    C(0.602, 0.551, "Primal Argentleaf east pin"),
    C(0.620, 0.562, "Primal Argentleaf east return"),
}

local MIDNIGHT_VOIDSTORM_HERB_COORDS = {
    C(0.263, 0.702, "Voidbound Azeroot west-south pin"),
    C(0.268, 0.654, "Voidbound Azeroot western route"),
    C(0.286, 0.505, "Voidbound Azeroot northwest route"),
    C(0.322, 0.473, "Voidbound Azeroot west-center pin"),
    C(0.343, 0.703, "Voidbound Azeroot south route"),
    C(0.347, 0.435, "Voidbound Azeroot center-west route"),
    C(0.350, 0.743, "Voidbound Azeroot south-center pin"),
    C(0.356, 0.383, "Voidbound Azeroot north-center pin"),
    C(0.361, 0.740, "Voidbound Azeroot southern return"),
    C(0.366, 0.450, "Voidbound Azeroot central route"),
    C(0.371, 0.441, "Voidbound Azeroot center return"),
    C(0.377, 0.477, "Voidbound Azeroot central-east pin"),
    C(0.475, 0.747, "Voidbound Argentleaf southeast route"),
    C(0.482, 0.535, "Voidbound Argentleaf middle route"),
    C(0.486, 0.459, "Voidbound Argentleaf north-east route"),
    C(0.492, 0.719, "Voidbound Argentleaf south-east pin"),
}

local MIDNIGHT_MANA_LILY_COORDS = {
    C(0.500, 0.635, "Mana Lily waterline pin"),
    C(0.500, 0.735, "Mana Lily southern water check"),
    C(0.501, 0.392, "Mana Lily north waterline"),
    C(0.504, 0.543, "Mana Lily central waterline"),
    C(0.508, 0.591, "Mana Lily river bend"),
    C(0.510, 0.803, "Mana Lily south waterline"),
    C(0.511, 0.509, "Mana Lily center pond"),
    C(0.519, 0.746, "Mana Lily south route return"),
    C(0.520, 0.806, "Mana Lily southern pond"),
    C(0.523, 0.587, "Mana Lily central return"),
    C(0.524, 0.344, "Mana Lily north river"),
    C(0.525, 0.421, "Mana Lily north-center pool"),
    C(0.527, 0.540, "Mana Lily central pool"),
}

local MIDNIGHT_EVERSONG_SKINNING_COORDS = {
    C(0.5753, 0.7772, "South of Tranquillien skinning route"),
    C(0.5672, 0.7833, "Tranquillien south route bend"),
    C(0.5711, 0.7984, "Southern Eversong beast pack"),
    C(0.5628, 0.8097, "Southern Eversong return"),
    C(0.5520, 0.7928, "Tranquillien south mixed beasts"),
    C(0.5475, 0.7954, "Tranquillien south skinning cluster"),
    C(0.5420, 0.7784, "Western return beast pack"),
    C(0.5596, 0.7630, "Northern return beast pack"),
    C(0.5772, 0.7419, "Northeast route bend"),
    C(0.5812, 0.7657, "Eastern return beast pack"),
}

local MIDNIGHT_FISHING_EVERSONG_SPOTS = {
    {
        id = "midnight-fishing-eversong-silvermoon-open-water",
        source = "Wowhead fishing overview and fish page comments",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
            "https://www.wowhead.com/item=238371/arcane-wyrmfish",
            "https://www.wowhead.com/item=238383/eversong-trout",
        },
        mapName = "Silvermoon City",
        location = "Silvermoon fountain and city open-water checks",
        routeType = "fishing-waterline",
        density = "Medium, with Eversong-specific pools",
        dropDifficulty = "Easy. Eversong fish are available from open water and local pools, with pool targeting improving results.",
        tips = {
            "Use Bubbling Bloom and Sunwell Swarm pools for Eversong fish when available.",
            "Open water still catches several target fish, so move between quick water checks instead of waiting on one pool.",
            "Arcane Wyrmfish comments call out Silvermoon fountain catches.",
        },
        coords = {
            C(0.4201, 0.6926, "Silvermoon fountain open-water comment"),
            C(0.3173, 0.9152, "Silvermoon open-water comment"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_FISHING_ZULAMAN_SPOTS = {
    {
        id = "midnight-fishing-zulaman-coast-and-pools",
        source = "Wowhead fishing overview and fish page comments",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
            "https://www.wowhead.com/item=238367/root-crab",
            "https://www.wowhead.com/item=238382/gore-guppy",
        },
        mapName = "Zul'Aman",
        location = "North and southeast Zul'Aman coast with Surface Ripple and Obscured School checks",
        routeType = "fishing-waterline",
        density = "Medium",
        dropDifficulty = "Easy to moderate. Shoreline movement is safer than fighting through inland packs.",
        tips = {
            "Root Crab comments point to the southeast-to-north Zul'Aman coast.",
            "Use Surface Ripple, Obscured School, and Hunter Surge pools for Zul'Aman targets.",
            "This route also supports Gore Guppy farming for Majestic Zul'Aman Lures.",
        },
        coords = {
            C(0.486, 0.258, "Old Koko north-coast fishing trainer waterline"),
            C(0.382, 0.214, "Hav'kalo north waterline"),
            C(0.462, 0.704, "Zel'kara southeast waterline"),
            C(0.247, 0.643, "Reventusk Sedge waterline"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_FISHING_HARANDAR_SPOTS = {
    {
        id = "midnight-fishing-harandar-blossoming-torrent",
        source = "Wowhead fishing overview and fish page comments",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
            "https://www.wowhead.com/item=238374/tender-lumifin",
            "https://www.wowhead.com/item=238369/bloomtail-minnow",
        },
        mapName = "Harandar",
        location = "Harandar inland water and Blossoming Torrent checks",
        routeType = "fishing-waterline",
        density = "Medium",
        dropDifficulty = "Moderate because many Harandar water checks are inland and near hostile creatures.",
        tips = {
            "Use Blossoming Torrent and Lashing Waves for Harandar fish.",
            "Tender Lumifin comments point to Harandar water near the Den.",
            "Combine with Harandar herb routes when Bloomtail Minnow and Primal motes are both valuable.",
        },
        coords = {
            C(0.335, 0.679, "Har'alor Harandar waterline"),
            C(0.562, 0.535, "Vale of Mists water check"),
            C(0.670, 0.464, "Lumenfin lure waterline"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_FISHING_VOIDSTORM_SPOTS = {
    {
        id = "midnight-fishing-voidstorm-viscous-void",
        source = "Wowhead fishing overview and Voidstorm fish page comments",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
            "https://www.wowhead.com/item=238380/null-voidfish",
            "https://www.wowhead.com/item=238373/ominous-octopus",
            "https://www.wowhead.com/item=238378/shimmersiren",
        },
        mapName = "Voidstorm",
        location = "Voidstorm green water, Viscous Void pools, and Oceanic Vortex checks",
        routeType = "fishing-waterline",
        density = "Medium",
        dropDifficulty = "Moderate. The guide calls out hostile terrain and ledges in Voidstorm.",
        tips = {
            "Fish green water in Voidscar Arena and northern Voidstorm when pools are scarce.",
            "Use Viscous Void and Oceanic Vortex pools for Voidstorm-only fish.",
            "Null Voidfish and Ominous Octopus are important lure and cooking inputs.",
        },
        coords = {
            C(0.510, 0.686, "Rinnoa trainer and Voidstorm waterline anchor"),
            C(0.372, 0.781, "Ethereum Refinery void-water route anchor"),
            C(0.5252, 0.4216, "Viscous Void pool comment"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_COOKING_PORK_SPOTS = {
    {
        id = "midnight-cooking-eversong-practically-pork",
        source = "Wowhead Practically Pork comments",
        sourceUrls = { "https://www.wowhead.com/item=242639/practically-pork" },
        mapName = "Eversong Woods",
        location = "Eversong beast packs around the 56,46 comment cluster",
        routeType = "meat-drop-loop",
        density = "Medium",
        dropDifficulty = "Easy to moderate from hawkstriders, lynx, and elder beasts in the area.",
        tips = {
            "A Wowhead comment reports steady drops around 56,46 in Eversong Woods.",
            "Skinning the same kills adds leather value if you have Midnight Skinning.",
            "Use this as the quick pork check before committing to longer Isle of Quel'Danas laps.",
        },
        coords = {
            C(0.560, 0.460, "Practically Pork Eversong comment"),
            C(0.5753, 0.7772, "South Tranquillien beast route option"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_COOKING_PLANT_PROTEIN_SPOTS = {
    {
        id = "midnight-cooking-plant-protein-fishing-and-creatures",
        source = "Wowhead Plant Protein page and Midnight fishing overview",
        sourceUrls = {
            "https://www.wowhead.com/item=242640/plant-protein",
            "https://www.wowhead.com/guide/midnight/professions/fishing-overview-trainer-locations-pools-tools",
        },
        mapName = "Eversong Woods",
        location = "Fishing waterlines and Eversong creature-heavy farming routes",
        routeType = "cooking-reagent-loop",
        density = "Low to medium",
        dropDifficulty = "Broad reagent. Wowhead lists fishing locations and describes it as sourced from various creatures.",
        tips = {
            "Treat Plant Protein as a side target while fishing or killing Midnight creatures.",
            "Use Eversong water and beast loops when you also need pork or common fish.",
            "Switch to Harandar water checks when combining it with Bloomtail Minnow or Tender Lumifin.",
        },
        coords = {
            C(0.4201, 0.6926, "Silvermoon fountain fishing check"),
            C(0.560, 0.460, "Eversong creature-loop check"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_COOKING_PETRIFIED_ROOT_SPOTS = {
    {
        id = "midnight-cooking-petrified-root-shadowguard",
        source = "Wowhead Petrified Root comments and Method Shadowguard Point delve guide",
        sourceUrls = {
            "https://www.wowhead.com/item=251285/petrified-root",
            "https://www.method.gg/guides/best-bright-linen-cloth-farming-locations",
        },
        mapName = "Voidstorm",
        location = "Shadowguard Point delve completion and reset loop",
        routeType = "delve-reward-loop",
        density = "Reward-gated",
        dropDifficulty = "Moderate. Comments identify delves and endgame reward boxes rather than outdoor creature drops.",
        tips = {
            "Farm this as a reward-source reagent, not as a normal meat or herb drop.",
            "Shadowguard Point is a repeatable coordinate-backed delve anchor also used for cloth farming.",
            "Do not mix this with ordinary herb routes when calculating open-world gathering yield.",
        },
        coords = {
            C(0.3738, 0.4774, "Shadowguard Point delve entrance"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_PROSPECTING_SPOTS = {
    {
        id = "midnight-prospecting-eversong-refulgent-copper-feed",
        source = "Method jewelcrafting guide, Wowhead prospecting item pages, Artisans of Azeroth route string",
        sourceUrls = {
            "https://www.method.gg/guides/midnight-jewelcrafting-profession-guide",
            "https://www.wowhead.com/item=242553/sanguine-garnet",
            "https://artisansofazeroth.com/eversong-woods-herb-ore-farming-route-fast-gold-farm-wow-route-guide-midnight/",
        },
        mapName = "Eversong Woods",
        location = "Refulgent Copper feed route for common Midnight gem prospecting",
        routeType = "prospecting-ore-feed",
        density = "High for ore feed",
        dropDifficulty = "Prospecting output depends on ore type, ore volume, and jewelcrafting specialization.",
        tips = {
            "Use this route when you need common prospecting gems from Refulgent Copper.",
            "Keep Dazzling Thorium for rare-gem and Eversong Diamond chances if market prices support it.",
            "Prospecting is a crafting action, but the route coordinates are the ore-feed farm.",
        },
        coords = MIDNIGHT_EVERSONG_HERB_ORE_COORDS,
        confidence = "high",
    },
    {
        id = "midnight-prospecting-voidstorm-umbral-tin-feed",
        source = "Method jewelcrafting guide and Wowhead Voidbound mining object pins",
        sourceUrls = {
            "https://www.method.gg/guides/midnight-jewelcrafting-profession-guide",
            "https://www.wowhead.com/item=242725/flawless-tenebrous-amethyst",
            "https://www.wowhead.com/object=523287/voidbound-refulgent-copper",
        },
        mapName = "Voidstorm",
        location = "Voidstorm ore feed for Umbral Tin and void-themed prospecting targets",
        routeType = "prospecting-ore-feed",
        density = "Medium",
        dropDifficulty = "Harder route because Voidstorm has ledges and dangerous mobs.",
        tips = {
            "Use when Tenebrous Amethyst or Umbral Tin prospecting outputs are the goal.",
            "Clear all ore nodes to keep replacement nodes moving.",
            "Avoid overload portals when travel time is hurting ore per hour.",
        },
        coords = MIDNIGHT_VOIDSTORM_VOIDBOUND_ORE_COORDS,
        confidence = "medium",
    },
}

local MIDNIGHT_MINING_SPOTS = {
    {
        id = "midnight-mining-eversong-starter-loop",
        source = "Wowhead mining overview, wow-professions mining guide, Wowhead mining object pages, Artisans of Azeroth route string",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
            "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
            "https://www.wowhead.com/object=523282/rich-refulgent-copper",
            "https://www.wowhead.com/object=523288/umbral-tin",
            "https://artisansofazeroth.com/eversong-woods-herb-ore-farming-route-fast-gold-farm-wow-route-guide-midnight/",
        },
        mapName = "Eversong Woods",
        location = "Broad Eversong Woods mining loop",
        routeType = "gathering-loop",
        density = "High for starter ore, with some infused variants",
        dropDifficulty = "Good starting route. Refulgent Copper is the most common; Dazzling Thorium is rare.",
        tips = {
            "Start here for the simplest terrain and lower mob density.",
            "Mine every node, because rich, seam, and infused versions can replace normal deposits.",
            "Lightfused deposits are more prevalent here and can produce Mote of Light.",
        },
        coords = MIDNIGHT_EVERSONG_HERB_ORE_COORDS,
        confidence = "high",
    },
    {
        id = "midnight-mining-zulaman-wild-loop",
        source = "Wowhead mining overview, wow-professions mining guide, Method ore and mote guide, Wowhead mining object pages",
        sourceUrls = {
            "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
            "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
            "https://www.wowhead.com/object=523286/wild-refulgent-copper",
            "https://www.wowhead.com/object=523300/wild-brilliant-silver",
        },
        mapName = "Zul'Aman",
        location = "Zul'Aman mining loop",
        routeType = "gathering-loop",
        density = "High, but more dangerous than Eversong",
        dropDifficulty = "Good ore and Wild mote route; infused nodes can be slower if your gear is weak.",
        tips = {
            "Wild deposits can spawn extra ore creatures; kill and mine them for more materials.",
            "This is a better route after you have enough Deftness to gather through mob pressure.",
            "Use it when Mote of Wild Magic is part of the target value.",
        },
        coords = MIDNIGHT_ZULAMAN_WILD_ORE_COORDS,
        confidence = "high",
    },
    {
        id = "midnight-mining-harandar-primal-loop",
        source = "Wowhead mining overview, wow-professions mining guide, Method ore and mote guide, Wowhead mining object pages",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
            "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
            "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
            "https://www.wowhead.com/object=523285/primal-refulgent-copper",
        },
        mapName = "Harandar",
        location = "Harandar primal deposit loops",
        routeType = "gathering-loop",
        density = "Medium to high",
        dropDifficulty = "Moderate. Primal overloads can be risky because the overload channel drains health.",
        tips = {
            "Use this route when Mote of Primal Energy is valuable.",
            "Do not overload Primal deposits unless you are healthy enough to survive the channel.",
        },
        coords = MIDNIGHT_HARANDAR_PRIMAL_ORE_COORDS,
        confidence = "medium",
    },
    {
        id = "midnight-mining-voidstorm-voidbound-loop",
        source = "Wowhead mining overview, wow-professions mining guide, Method ore and mote guide",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
            "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
            "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
            "https://www.wowhead.com/object=523287/voidbound-refulgent-copper",
        },
        mapName = "Voidstorm",
        location = "Voidstorm voidbound deposit loops",
        routeType = "gathering-loop",
        density = "Medium",
        dropDifficulty = "Moderate to hard because Voidbound nodes tend to be in more dangerous areas.",
        tips = {
            "Use this route when Mote of Pure Void is valuable.",
            "Move out of Voidbound pull zones quickly.",
            "The current guide notes that Voidbound overload portals can be inefficient, so use judgment before overloading.",
        },
        coords = MIDNIGHT_VOIDSTORM_VOIDBOUND_ORE_COORDS,
        confidence = "medium",
    },
}

local MIDNIGHT_HERB_SPOTS = {
    {
        id = "midnight-herbalism-eversong-loop",
        source = "Wowhead herbalism overview, wow-professions herbalism guide, Wowhead herb object pages, Artisans of Azeroth route string",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/herbalism-overview-trainer-locations-treasures-tools",
            "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            "https://www.wowhead.com/object=516932/tranquility-bloom",
            "https://www.wowhead.com/object=516934/sanguithorn",
            "https://www.wowhead.com/object=516935/azeroot",
            "https://artisansofazeroth.com/eversong-woods-herb-ore-farming-route-fast-gold-farm-wow-route-guide-midnight/",
        },
        mapName = "Eversong Woods",
        location = "Broad Eversong Woods herb loop",
        routeType = "gathering-loop",
        density = "High for common herbs",
        dropDifficulty = "Good starting route. Tranquility Bloom is common; rare side gathers remain RNG.",
        tips = {
            "Use this first because the terrain is straightforward and mob pressure is lower.",
            "Gather every herb because lush and infused variants replace normal herbs.",
            "Lightfused herbs here can produce Mote of Light.",
        },
        coords = MIDNIGHT_EVERSONG_HERB_ORE_COORDS,
        confidence = "high",
    },
    {
        id = "midnight-herbalism-zulaman-loop",
        source = "wow-professions herbalism guide, Wowhead herb object pages, EpicWoWGuides herb pages",
        sourceUrls = {
            "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            "https://www.wowhead.com/object=516932/tranquility-bloom",
            "https://www.wowhead.com/object=516935/azeroot",
            "https://epicwowguides.com/material/tranquility-bloom/",
            "https://epicwowguides.com/material/mana-lily/",
        },
        mapName = "Zul'Aman",
        location = "Zul'Aman double-gather route",
        routeType = "gathering-loop",
        density = "High",
        dropDifficulty = "Good route, but not ideal for undergeared gatherers because infused Wild nodes can summon tough enemies.",
        tips = {
            "Use Zul'Aman when you want herbs and ore together.",
            "High Deftness is recommended so hostile mobs do not slow the route.",
            "EpicWoWGuides points to Zul'Aman routes for Tranquility Bloom and Mana Lily.",
        },
        coords = MIDNIGHT_ZULAMAN_HERB_COORDS,
        confidence = "medium",
    },
    {
        id = "midnight-herbalism-harandar-primal-loop",
        source = "Wowhead herbalism overview, wow-professions herbalism guide",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/herbalism-overview-trainer-locations-treasures-tools",
            "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            "https://www.wowhead.com/object=516976/primal-argentleaf",
        },
        mapName = "Harandar",
        location = "Harandar herb loops",
        routeType = "gathering-loop",
        density = "Medium to high",
        dropDifficulty = "Moderate. Use when Primal-infused herbs and Mote of Primal Energy matter.",
        tips = {
            "Primal herbs can drain health when overloaded, so check health before using Overload.",
            "A Wowhead comment for Mote of Primal Energy specifically points herbalists to Harandar.",
        },
        coords = MIDNIGHT_HARANDAR_HERB_COORDS,
        confidence = "medium",
    },
    {
        id = "midnight-herbalism-voidstorm-voidbound-loop",
        source = "Wowhead herbalism overview, wow-professions herbalism guide",
        sourceUrls = {
            "https://www.wowhead.com/guide/midnight/professions/herbalism-overview-trainer-locations-treasures-tools",
            "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            "https://www.wowhead.com/object=516981/voidbound-azeroot",
            "https://www.wowhead.com/object=516980/voidbound-sanguithorn",
            "https://www.wowhead.com/object=516979/voidbound-argentleaf",
        },
        mapName = "Voidstorm",
        location = "Voidstorm herb loops",
        routeType = "gathering-loop",
        density = "Medium",
        dropDifficulty = "Moderate to hard. Voidbound herbs are more dangerous and portal overload value is inconsistent.",
        tips = {
            "Use this route when Mote of Pure Void is the value target.",
            "Move out of Voidbound pull zones quickly.",
        },
        coords = MIDNIGHT_VOIDSTORM_HERB_COORDS,
        confidence = "medium",
    },
}

local MIDNIGHT_MANA_LILY_SPOTS = {
    {
        id = "midnight-mana-lily-water-checks",
        source = "Warcraft Wiki, WoWDB spell text, Blizzard forum discussion",
        sourceUrls = {
            "https://www.wowhead.com/object=516936/mana-lily",
            "https://warcraft.wiki.gg/wiki/Mana_Lily",
            "https://www.wowdb.com/spells/1224899-voidbound-mana-lily",
            "https://us.forums.blizzard.com/en/wow/t/mana-lily-is-far-too-rare-compared-to-other-herbs/2280433",
        },
        mapName = "Eversong Woods",
        location = "Eversong Woods Mana Lily waterline checks",
        routeType = "waterline-herb-check",
        density = "Low to medium",
        dropDifficulty = "Harder than most Midnight herbs because players report it as constrained near water.",
        tips = {
            "Prioritize rivers, ponds, and water edges instead of pure land loops.",
            "Treat Mana Lily as a targeted detour inside broader herb routes.",
            "Community reports say routes can become contested because water is limited in some zones.",
        },
        coords = MIDNIGHT_MANA_LILY_COORDS,
        confidence = "medium",
    },
}

local MIDNIGHT_NOCTURNAL_LOTUS_SPOTS = {
    {
        id = "midnight-nocturnal-lotus-any-herb-imbued-mulch",
        source = "Wowhead item comments, Method Nocturnal Lotus guide, wow-professions herbalism guide",
        sourceUrls = {
            "https://www.wowhead.com/item=236780/nocturnal-lotus",
            "https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight",
            "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        },
        mapName = "Eversong Woods",
        location = "Any Midnight herb route, starting with the Eversong herb loop when using Imbued Mulch",
        routeType = "rare-side-gather",
        density = "Rare",
        dropDifficulty = "Hard. It is a rare herb side gather, and Perception improves bonus amount rather than base chance.",
        tips = {
            "Method identifies Nocturnal Lotus as a rare bonus drop from gathering Midnight herbs.",
            "A Wowhead comment points to Botany plus Mulching and Imbued Mulch to force rare-reagent behavior on the next Midnight harvest.",
            "Use Perception only if lotus prices justify it; otherwise farm with Finesse or Deftness.",
        },
        coords = MIDNIGHT_EVERSONG_HERB_ORE_COORDS,
        confidence = "medium",
    },
}

local MIDNIGHT_SKINNING_COMMON_SPOTS = {
    {
        id = "midnight-skinning-zulaman-solemn-valley",
        source = "Wowhead item comments, wow-professions skinning guide",
        sourceUrls = {
            "https://www.wowhead.com/item=238512/void-tempered-leather",
            "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
        },
        mapName = "Zul'Aman",
        location = "Solemn Valley, grass patch across the river from Amani-zar Village",
        routeType = "skinning-loop",
        density = "Medium to high",
        dropDifficulty = "Good general-purpose leather farm with mixed beasts and occasional high-value targets.",
        tips = {
            "A Wowhead comment reports Weeping Swine, Tearful Boars, and Melancholy Eagles around 46.28, 72.91.",
            "Nearby River Groupers can provide scale value when they are skinnable.",
            "Use Finesse for base materials and Perception when targeting rare skinning materials.",
        },
        coords = {
            { x = 0.4628, y = 0.7291, label = "Solemn Valley skinning loop" },
            C(0.5475, 0.7954, "South Tranquillien skinning route sample"),
            C(0.5812, 0.7657, "South Tranquillien route return"),
        },
        confidence = "medium",
    },
    {
        id = "midnight-skinning-high-value-beasts",
        source = "wow-professions skinning guide, Wowhead skinning overview",
        sourceUrls = {
            "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
            "https://www.wowhead.com/guide/midnight/professions/skinning-overview-trainer-locations-hides-tracking-tools",
        },
        mapName = "Eversong Woods",
        location = "High Value Beasts shown by Midnight Skinning tracking while running the south Tranquillien route",
        routeType = "tracking-target",
        density = "Opportunistic",
        dropDifficulty = "Variable. High Value Beasts give more leather or scales than normal beasts.",
        tips = {
            "Find High-Value Beasts is available after learning Midnight Skinning and marks targets with a skinning icon.",
            "Look for the red outlined/glowing beasts during normal route movement.",
        },
        coords = {
            C(0.5475, 0.7954, "South Tranquillien high-value beast route sample"),
            C(0.5812, 0.7657, "South Tranquillien high-value route return"),
        },
        confidence = "high",
    },
}

local MIDNIGHT_SKINNING_SCALE_SPOTS = {
    {
        id = "midnight-skinning-zulaman-scales",
        source = "wow-professions skinning guide, Wowhead item comments",
        sourceUrls = {
            "https://www.wow-professions.com/guides/wow-skinning-leveling-guide",
            "https://www.wowhead.com/item=238513/void-tempered-scales",
        },
        mapName = "Zul'Aman",
        location = "Agitated Wyrms, Territorial Dragonhawks, and River Grouper checks",
        routeType = "skinning-loop",
        density = "Medium",
        dropDifficulty = "Decent but slower than old static farms; larger dragonhawks take longer to kill.",
        tips = {
            "The wow-professions guide calls out Agitated Wyrms and Territorial Dragonhawks for scales.",
            "A Wowhead leather comment notes nearby River Groupers as a scale source while farming Solemn Valley.",
        },
        coords = {
            C(0.4628, 0.7291, "Solemn Valley River Grouper and scale loop"),
            C(0.476, 0.536, "Silverscale bridge and dragonhawk route anchor"),
            C(0.448, 0.795, "Southern Zul'Aman scale-bearing beast check"),
        },
        confidence = "medium",
    },
}

local MIDNIGHT_SPECIES_SKINNING_SPOTS = {
    {
        id = "midnight-species-eversong-creature-types",
        source = "Wowhead item comments and Artisans of Azeroth skinning route string",
        sourceUrls = {
            "https://www.wowhead.com/item=238525/fantastic-fur",
            "https://www.wowhead.com/item=238523/carving-canine",
            "https://artisansofazeroth.com/7336-2/",
        },
        mapName = "Eversong Woods",
        location = "Cats, bears, bats, hawkstriders, and dragonhawks",
        routeType = "species-skinning-loop",
        density = "Medium",
        dropDifficulty = "Moderate to hard. Comments indicate drops improved after fixes, but they remain specialized.",
        tips = {
            "Cats and bears can provide Carving Canine and Fantastic Fur.",
            "Bats around Windrunner Spire are called out for Fantastic Fur.",
            "Hawkstriders and dragonhawks are used for Peerless Plumage.",
        },
        coords = MIDNIGHT_EVERSONG_SKINNING_COORDS,
        confidence = "medium",
    },
    {
        id = "midnight-fantastic-fur-zulaman-kapara",
        source = "Wowhead Fantastic Fur comments",
        sourceUrls = { "https://www.wowhead.com/item=238525/fantastic-fur" },
        mapName = "Zul'Aman",
        location = "North end of Atal'Aman, destroyed wall and waterfall Kapara packs",
        routeType = "species-skinning-loop",
        density = "Localized",
        dropDifficulty = "Reported as strong after investing into Gainful Gathering and Trophy Taker.",
        tips = {
            "A Wowhead comment gives the area around 64.8, 9.4 for Kapara near the waterfall.",
            "The commenter recommends maxing Gainful Gathering and investing in Trophy Taker.",
        },
        coords = {
            { x = 0.648, y = 0.094, label = "Atal'Aman waterfall Kapara area" },
        },
        confidence = "medium",
    },
}

local MIDNIGHT_MAJESTIC_SKINNING_SPOTS = {
    {
        id = "midnight-majestic-gloomclaw",
        source = "Wowhead Majestic Claw and Majestic Hide comments",
        sourceUrls = {
            "https://www.wowhead.com/item=238528/majestic-claw",
            "https://www.wowhead.com/item=238529/majestic-hide",
        },
        mapName = "Eversong Woods",
        location = "Gloomclaw, summoned with Majestic Eversong Lure",
        routeType = "renowned-beast-lure",
        density = "Daily or lure-limited",
        dropDifficulty = "Hard and luck-dependent. Needs the lure system and Majestic Materials investment for best chance.",
        tips = {
            "Reported at 42.6, 79.6.",
            "Summon material list includes Arcane Wyrmfish and Lynxfish.",
            "Can provide Majestic Hide and Majestic Claw through skinning.",
        },
        coords = {
            { x = 0.426, y = 0.796, label = "Gloomclaw lure point" },
        },
        confidence = "high",
    },
    {
        id = "midnight-majestic-silverscale",
        source = "Wowhead Majestic Claw comments",
        sourceUrls = { "https://www.wowhead.com/item=238528/majestic-claw" },
        mapName = "Zul'Aman",
        location = "Silverscale, under bridge, summoned with Majestic Zul'Aman Lure",
        routeType = "renowned-beast-lure",
        density = "Daily or lure-limited",
        dropDifficulty = "Hard and luck-dependent.",
        tips = {
            "Reported at 47.6, 53.6 under the bridge.",
            "Summon material list includes Gore Guppy.",
            "Used when targeting Majestic Claw.",
        },
        coords = {
            { x = 0.476, y = 0.536, label = "Silverscale under-bridge lure point" },
        },
        confidence = "high",
    },
    {
        id = "midnight-majestic-lumenfin",
        source = "Wowhead Majestic Fin comments",
        sourceUrls = { "https://www.wowhead.com/item=238530/majestic-fin" },
        mapName = "Harandar",
        location = "Lumenfin, summoned with Majestic Harandar Lure",
        routeType = "renowned-beast-lure",
        density = "Daily or lure-limited",
        dropDifficulty = "Hard and luck-dependent.",
        tips = {
            "Reported at 67.0, 46.4.",
            "Summon material list includes Tender Lumifin and Fungalskin Pike.",
            "Used when targeting Majestic Fin.",
        },
        coords = {
            { x = 0.670, y = 0.464, label = "Lumenfin lure point" },
        },
        confidence = "high",
    },
    {
        id = "midnight-majestic-umbrafang",
        source = "Wowhead Majestic Claw and Majestic Hide comments",
        sourceUrls = {
            "https://www.wowhead.com/item=238528/majestic-claw",
            "https://www.wowhead.com/item=238529/majestic-hide",
        },
        mapName = "Voidstorm",
        location = "Umbrafang, summoned with Majestic Voidstorm Lure",
        routeType = "renowned-beast-lure",
        density = "Daily or lure-limited",
        dropDifficulty = "Hard and luck-dependent.",
        tips = {
            "Reported at 54.6, 65.6.",
            "Summon material list includes Ominous Octopus.",
            "Can provide Majestic Hide and Majestic Claw through skinning.",
        },
        coords = {
            { x = 0.546, y = 0.656, label = "Umbrafang lure point" },
        },
        confidence = "high",
    },
    {
        id = "midnight-majestic-netherscythe",
        source = "Wowhead Majestic materials comments",
        sourceUrls = {
            "https://www.wowhead.com/item=238528/majestic-claw",
            "https://www.wowhead.com/item=238529/majestic-hide",
            "https://www.wowhead.com/item=238530/majestic-fin",
        },
        mapName = "Voidstorm",
        location = "Netherscythe, summoned with Grand Beast Lure",
        routeType = "renowned-beast-lure",
        density = "Daily or lure-limited",
        dropDifficulty = "Hard and luck-dependent.",
        tips = {
            "Reported at 43.6, 82.8.",
            "Summon material list includes Null Voidfish.",
            "Can provide Majestic Hide, Majestic Fin, and Majestic Claw through skinning.",
        },
        coords = {
            { x = 0.436, y = 0.828, label = "Netherscythe lure point" },
        },
        confidence = "high",
    },
}

local MIDNIGHT_CLOTH_SPOTS = {
    {
        id = "midnight-cloth-shadowguard-point-delve",
        source = "Method Bright Linen cloth guide",
        sourceUrls = { "https://www.method.gg/guides/best-bright-linen-cloth-farming-locations" },
        mapName = "Voidstorm",
        location = "Shadowguard Point delve",
        routeType = "solo-delve-reset",
        density = "High",
        dropDifficulty = "Strong solo option, especially on low delve tier.",
        tips = {
            "Method gives /way Voidstorm 37.38 47.74 for the delve location.",
            "Set Valeera to healer, mount through to gather mobs, group casters around a corner, AoE, loot, leave, and reset.",
            "Tank specs are recommended, but other sturdy specs can work.",
        },
        coords = {
            { x = 0.3738, y = 0.4774, label = "Shadowguard Point delve" },
        },
        confidence = "high",
    },
}

local MIDNIGHT_ENCHANTING_SPOTS = {
    {
        id = "midnight-enchanting-disenchant-eligible-gear",
        source = "Wowhead enchanting material pages, DisenchantValue release notes, Blizzard forum discussion, Method delve farm",
        sourceUrls = {
            "https://www.wowhead.com/item=243599/eversinging-dust",
            "https://www.wowhead.com/item=243602/radiant-shard",
            "https://www.wowhead.com/item=243606/dawn-crystal",
            "https://www.curseforge.com/wow/addons/disenchantvalue/files/7701600",
            "https://us.forums.blizzard.com/en/wow/t/enchanting-leveling-with-self-gathered-materials/2272227",
            "https://www.method.gg/guides/best-bright-linen-cloth-farming-locations",
        },
        mapName = "Voidstorm",
        location = "Shadowguard Point delve and other eligible Midnight gear sources",
        routeType = "disenchanting-gear-feed",
        density = "Depends on gear acquisition, with a repeatable delve anchor",
        dropDifficulty = "Green gear produces dust, rare gear produces shards, and epic gear produces crystals.",
        tips = {
            "Do not treat enchanting materials as outdoor node farms; the input is disenchantable gear.",
            "Shadowguard Point is a coordinate-backed repeatable content anchor for cloth and gear-feed farming.",
            "Track crafted, dropped, and cheap Auction House gear separately when comparing gold per hour.",
            "Community discussion notes dust scarcity can bottleneck early enchanting leveling.",
        },
        coords = {
            C(0.3738, 0.4774, "Shadowguard Point delve entrance"),
        },
        confidence = "medium",
    },
}

local BFA_GATHERING_TIPS = {
    "Use Monel-Hardened Stirrups, Hoofplates, and Coarse Leather Barding when available.",
    "Use the Battle for Azeroth glove gathering enchant for the relevant profession.",
    "A tank specialization helps avoid daze when riding through dense areas.",
}

local function withBfaGatheringTips(extra)
    local tips = {}
    for _, tip in ipairs(BFA_GATHERING_TIPS) do
        tips[#tips + 1] = tip
    end
    for _, tip in ipairs(extra or {}) do
        tips[#tips + 1] = tip
    end
    return tips
end

local function BuildMidnightItem(itemID, itemName, professions, category, sourceUrls, summary, spots, qualityRank)
    return {
        itemID = itemID,
        itemName = itemName,
        expansion = "midnight",
        professions = professions,
        category = category,
        qualityRank = qualityRank,
        sourceUrls = sourceUrls,
        summary = summary,
        spots = spots,
    }
end

NS.MaterialFarmingSpotHelpers = {
    TWW_MINING_SPOTS = TWW_MINING_SPOTS,
    TWW_HERB_SPOTS = TWW_HERB_SPOTS,
    MIDNIGHT_MINING_SPOTS = MIDNIGHT_MINING_SPOTS,
    MIDNIGHT_HERB_SPOTS = MIDNIGHT_HERB_SPOTS,
    MIDNIGHT_MANA_LILY_SPOTS = MIDNIGHT_MANA_LILY_SPOTS,
    MIDNIGHT_NOCTURNAL_LOTUS_SPOTS = MIDNIGHT_NOCTURNAL_LOTUS_SPOTS,
    MIDNIGHT_SKINNING_COMMON_SPOTS = MIDNIGHT_SKINNING_COMMON_SPOTS,
    MIDNIGHT_SKINNING_SCALE_SPOTS = MIDNIGHT_SKINNING_SCALE_SPOTS,
    MIDNIGHT_SPECIES_SKINNING_SPOTS = MIDNIGHT_SPECIES_SKINNING_SPOTS,
    MIDNIGHT_MAJESTIC_SKINNING_SPOTS = MIDNIGHT_MAJESTIC_SKINNING_SPOTS,
    MIDNIGHT_CLOTH_SPOTS = MIDNIGHT_CLOTH_SPOTS,
    MIDNIGHT_ENCHANTING_SPOTS = MIDNIGHT_ENCHANTING_SPOTS,
    MIDNIGHT_FISHING_EVERSONG_SPOTS = MIDNIGHT_FISHING_EVERSONG_SPOTS,
    MIDNIGHT_FISHING_ZULAMAN_SPOTS = MIDNIGHT_FISHING_ZULAMAN_SPOTS,
    MIDNIGHT_FISHING_HARANDAR_SPOTS = MIDNIGHT_FISHING_HARANDAR_SPOTS,
    MIDNIGHT_FISHING_VOIDSTORM_SPOTS = MIDNIGHT_FISHING_VOIDSTORM_SPOTS,
    MIDNIGHT_COOKING_PORK_SPOTS = MIDNIGHT_COOKING_PORK_SPOTS,
    MIDNIGHT_COOKING_PLANT_PROTEIN_SPOTS = MIDNIGHT_COOKING_PLANT_PROTEIN_SPOTS,
    MIDNIGHT_COOKING_PETRIFIED_ROOT_SPOTS = MIDNIGHT_COOKING_PETRIFIED_ROOT_SPOTS,
    MIDNIGHT_PROSPECTING_SPOTS = MIDNIGHT_PROSPECTING_SPOTS,
    withBfaGatheringTips = withBfaGatheringTips,
    BuildMidnightItem = BuildMidnightItem,
}
