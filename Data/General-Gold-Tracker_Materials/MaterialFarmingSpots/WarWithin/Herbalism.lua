local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

local function C(x, y, label)
    return { x = x, y = y, label = label }
end

local function ItemUrl(itemID)
    return "https://www.wowhead.com/item=" .. tostring(itemID)
end

local LUREDROP_SPOTS = {
    {
        id = "tww-luredrop-ringing-deeps-dark-route",
        source = "Wowhead Luredrop comments, herbalism overview, and Luredrop object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210799/luredrop",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "The Ringing Deeps",
        location = "Northern dark tunnel route where Luredrop object pins overlap Mycobloom and Orbinid checks",
        routeType = "terrain-targeted-herb-loop",
        density = "Medium",
        dropDifficulty = "Moderate to hard because Luredrop favors hidden, dark, cave, and rare-spawn-adjacent spaces.",
        tips = {
            "Prioritize low-light cave pockets over bright surface loops.",
            "Gather nearby herbs because Luredrop can share respawn space with common nodes.",
            "Use Phial of Truesight while checking underground side paths.",
        },
        coords = {
            C(0.341, 0.157, "Northern Luredrop pocket"),
            C(0.346, 0.174, "North tunnel Luredrop check"),
            C(0.350, 0.131, "Dark tunnel north edge"),
            C(0.351, 0.188, "Luredrop and Mycobloom wall"),
            C(0.351, 0.208, "South bend Luredrop pin"),
            C(0.355, 0.147, "Northern return check"),
        },
        confidence = "high",
    },
    {
        id = "tww-luredrop-hallowfall-beledars-bounty-route",
        source = "Wowhead Luredrop object map pins and herbalism overview",
        sourceUrls = {
            "https://www.wowhead.com/item=210799/luredrop",
            "https://www.wowhead.com/object=414316/luredrop",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "Hallowfall",
        location = "Beledar's Bounty farm pockets and nearby shaded herb checks",
        routeType = "localized-herb-check",
        density = "Localized",
        dropDifficulty = "Useful secondary Luredrop spot when Hallowfall herb prices are favorable.",
        tips = {
            "Work this into the Rich Soil route rather than flying only for Luredrop.",
            "Check farm edges and shaded pockets, then continue if no Luredrop is up.",
        },
        coords = {
            C(0.464, 0.647, "West farm Luredrop pin"),
            C(0.465, 0.649, "Farm edge Luredrop"),
            C(0.477, 0.634, "Central farm Luredrop check"),
            C(0.478, 0.645, "Southeast farm Luredrop"),
            C(0.480, 0.621, "North farm Luredrop check"),
        },
        confidence = "medium",
    },
}

local ORBINID_SPOTS = {
    {
        id = "orbinid-isle-of-dorn-freywold-cave",
        source = "Wowhead item comments and Orbinid object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
        },
        mapName = "Isle of Dorn",
        location = "Mushroom cave southeast/southwest of Freywold Village",
        routeType = "cave-check",
        density = "Localized",
        dropDifficulty = "Moderate. Reported as a good specific cave check after surface routes produced little.",
        tips = {
            "Fly over or into caves to inspect node spawns quickly.",
            "A reported cave entrance is around 33.56, 80.05.",
            "Use Phial of Truesight while checking nearby camouflaged herbs.",
        },
        coords = {
            C(0.3356, 0.8005, "Reported Freywold cave entrance"),
            C(0.338, 0.794, "Nearby Orbinid object pin"),
            C(0.340, 0.797, "Freywold cave return"),
        },
        confidence = "medium",
    },
    {
        id = "orbinid-isle-of-dorn-three-shields-caves",
        source = "Wowhead item comments and Orbinid object map pins",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
        },
        mapName = "Isle of Dorn",
        location = "The Three Shields cave and rocky herb checks",
        routeType = "cave-check",
        density = "Localized",
        dropDifficulty = "Moderate. Check quickly, then continue the broader route if no nodes are up.",
        tips = {
            "Use the cave checks as a detour from the western Isle of Dorn gathering loop.",
            "Object pins near 24,57 and the Three Shields area support repeated Orbinid checks.",
        },
        coords = {
            C(0.244, 0.577, "Three Shields Orbinid check"),
            C(0.245, 0.574, "Cave-side Orbinid pin"),
            C(0.346, 0.735, "Three Shields south cave check"),
            C(0.349, 0.761, "Three Shields return"),
            C(0.352, 0.748, "Rocky Orbinid pocket"),
        },
        confidence = "medium",
    },
    {
        id = "orbinid-ringing-deeps-underground-route",
        source = "Wowhead Orbinid object map pins and herbalism overview",
        sourceUrls = {
            "https://www.wowhead.com/item=210802/orbinid",
            "https://www.wowhead.com/object=414317/orbinid",
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        },
        mapName = "The Ringing Deeps",
        location = "General underground Orbinid route through northern and central tunnels",
        routeType = "underground-herb-loop",
        density = "Medium",
        dropDifficulty = "Better than surface-only routes because the zone matches Orbinid's cave and "
            .. "dark-spawn pattern.",
        tips = {
            "Use this as the broad farm after checking compact Isle of Dorn caves.",
            "Combine with Luredrop checks along the same underground route.",
            "Gather Irradiated variants for Leyline Residue while moving.",
        },
        coords = {
            C(0.373, 0.194, "Northern Orbinid wall"),
            C(0.376, 0.202, "North tunnel Orbinid pin"),
            C(0.382, 0.315, "Central tunnel Orbinid"),
            C(0.383, 0.302, "South bend Orbinid check"),
            C(0.386, 0.317, "Underground return"),
            C(0.412, 0.174, "Irradiated Orbinid extension"),
        },
        confidence = "high",
    },
}

-- Supplied Retail Routes exports, decoded without changing vertex order.
-- Most are shared herb/ore travel loops; only the dedicated Phantom Bloom export is herb-specific.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, routeOrigin, source, packedCoords, tips, sourceUrls)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = C(math.floor(packed / 10000) / 10000, (packed % 10000) / 10000,
            location .. " #" .. index)
    end
    table.insert(tips, 1, "Supplied route provenance: " .. source)
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeOrigin = routeOrigin,
        routeType = "herbalism-loop",
        source = source,
        sourceUrls = sourceUrls,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Published gathering travel anchors, not guaranteed node spawns. Follow herb habitat and cave elevation.",
    }
end

local SUPPLIED_HERB_ROUTES = {
    ["Mycobloom"] = {
        SuppliedHerbRoute(
            "tww-mycobloom-2214-1-supplied", 1, 2214, "The Ringing Deeps",
            "Main - The Ringing Deeps long circuit", "published-zone-gathering-loop", "xScarlife Gaming long route. xscarlife-gaming.com",
            {
                51882478, 60122841, 55154006, 56024831, 58205424, 57626165, 61697218, 66648117,
                66759364, 61829352, 58127771, 53027154, 50126404, 53836266, 51925954, 51015361,
                41863920, 43622918,
            },
            {
                "Treat this as a volume route rather than a Mycobloom-only hunt. Mycobloom is common enough that staying moving generally wins over detouring.",
                "Use Phial of Truesight so camouflaged Mycobloom becomes visible.",
                "The Ringing Deeps also has substantial Luredrop/Orbinid presence, so this is particularly useful for a dual-herbalism farming profile rather than discarding secondary nodes. Blizzard Forums",
                "With enough Botany specialization, mounted gathering significantly reduces route downtime.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://us.forums.blizzard.com/en/wow/t/mining-and-herb-location-questions/1946428?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-mycobloom-2248-2-supplied", 2, 2248, "Isle of Dorn",
            "Alternative - Isle of Dorn quick loop", "published-zone-gathering-loop", "Artisans of Azeroth compact herb/ore loop. Artisans of Azeroth",
            {
                43656836, 46196478, 46745881, 48485452, 51265456, 53525043, 56985234, 58724810,
                61945448, 58315881, 56835831, 54955958, 56746431, 63406488, 60766715, 57606773,
                56167206, 53687836, 48867611, 47667833,
            },
            {
                "Better than the Ringing Deeps loop when you want short laps and faster node respawn cycling.",
                "Isle of Dorn has a particularly good combination of Mycobloom + Blessing Blossom, so collect both.",
                "Because terrain is comparatively open, this route loses less time to vertical cave navigation.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/isle-of-dorn-quick-herb-farm-tight-loop-for-fast-respawns/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
    ["Blessing Blossom"] = {
        SuppliedHerbRoute(
            "tww-blessing-blossom-2248-1-supplied", 1, 2248, "Isle of Dorn",
            "Main - Isle of Dorn long circuit", "published-zone-gathering-loop", "xScarlife Gaming long route. xscarlife-gaming.com",
            {
                40872173, 43071785, 47021662, 51481934, 55282769, 60022670, 67442815, 70272019,
                75422150, 75532618, 79232912, 77923593, 80293931, 80564664, 78995014, 76204918,
                73935586, 68995296, 64814922, 63995458, 59925745, 66296539, 68367152, 61617088,
                59797340, 56207263, 53497594, 49347728, 42328426, 35328211, 29977170, 18735948,
                26994579, 32725426, 32396142, 36256643, 41536655, 45946073, 47135348, 41484788,
                42564245, 42493833,
            },
            {
                "Favor nodes on open ridges, plateaus and exposed ground rather than wasting time inside caves.",
                "Keep Phial of Truesight active because camouflaged Blessing Blossom is part of the TWW node pool.",
                "This route also produces large amounts of Mycobloom, so it works well as a two-herb commodity farm.",
                "Finesse is generally the attractive stat when the objective is maximum herb quantity per hour.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/object%3D414318/blessing-blossom?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-blessing-blossom-2248-2-supplied", 2, 2248, "Isle of Dorn",
            "Alternative - Isle of Dorn quick circuit", "published-zone-gathering-loop", "Artisans of Azeroth. Artisans of Azeroth",
            {
                43656836, 46196478, 46745881, 48485452, 51265456, 53525043, 56985234, 58724810,
                61945448, 58315881, 56835831, 54955958, 56746431, 63406488, 60766715, 57606773,
                56167206, 53687836, 48867611, 47667833,
            },
            {
                "Prefer this variant when the zone is lightly populated and you can repeatedly cycle the same spawn network.",
                "It is less comprehensive than the long route but has a better travel-time-to-node-density ratio.",
                "If competition is stripping the loop faster than respawns occur, switch to the long circuit rather than forcing the short one.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/object%3D414318/blessing-blossom?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/isle-of-dorn-quick-herb-farm-tight-loop-for-fast-respawns/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
    ["Arathor's Spear"] = {
        SuppliedHerbRoute(
            "tww-arathor-s-spear-2215-1-supplied", 1, 2215, "Hallowfall",
            "Main - Hallowfall short V2", "published-zone-gathering-loop", "xScarlife Gaming. xscarlife-gaming.com",
            {
                57501834, 57042575, 55583052, 61693509, 60203756, 57623537, 54373500, 57903821,
                54864135, 50393910, 52373436, 51373046, 48493266, 45733237, 43442973, 42812511,
                44502263, 44421107, 47391210, 45512603, 48051935, 48481384, 50631517, 50242063,
                52001722, 54311396, 55971425, 53602290,
            },
            {
                "Hallowfall is one of the strongest zones when your explicit target is Arathor's Spear rather than generic herbs.",
                "Stay on open surface terrain instead of following every underground ping.",
                "Truesight is valuable because camouflaged Arathor's Spear can otherwise be missed.",
                "The shorter route is useful because the herb's spawn habitat is more specific than Mycobloom; you do not need to sweep every remote corner of Hallowfall.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-arathor-s-spear-2248-2-supplied", 2, 2248, "Isle of Dorn",
            "Alternative - Isle of Dorn long route", "published-zone-gathering-loop", "xScarlife Gaming. xscarlife-gaming.com",
            {
                40872173, 43071785, 47021662, 51481934, 55282769, 60022670, 67442815, 70272019,
                75422150, 75532618, 79232912, 77923593, 80293931, 80564664, 78995014, 76204918,
                73935586, 68995296, 64814922, 63995458, 59925745, 66296539, 68367152, 61617088,
                59797340, 56207263, 53497594, 49347728, 42328426, 35328211, 29977170, 18735948,
                26994579, 32725426, 32396142, 36256643, 41536655, 45946073, 47135348, 41484788,
                42564245, 42493833,
            },
            {
                "Isle of Dorn is a good fallback when Hallowfall is heavily farmed.",
                "The zone gives more Blessing Blossom/Mycobloom along the way, making it better when total gold/hour matters more than pure Arathor's Spear/hour.",
                "Open terrain makes high-speed mounted gathering efficient.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
    ["Orbinid"] = {
        SuppliedHerbRoute(
            "tww-orbinid-2255-1-supplied", 1, 2255, "Azj-Kahet",
            "Main - Azj-Kahet Lightless Channels circuit", "published-zone-gathering-loop", "Artisans of Azeroth Lightless Channels herb/ore path. Artisans of Azeroth",
            {
                61203232, 58563137, 58962845, 57032694, 52272781, 49822521, 50632322, 53552341,
                55872390, 57622236, 59482288, 61672057, 63761882, 64381528, 63570874, 64010368,
                66290800, 65041133, 67091218, 65571615, 66821854, 68402066, 71041915, 73351869,
                74861546, 76872132, 76562474, 74532500, 74082287, 72252576, 69762334, 66862488,
                64592684, 64032860,
            },
            {
                "Prioritize actual subterranean passages rather than flying above the zone and expecting the minimap to represent reachable nodes.",
                "Keep Truesight up; camouflaged Orbinid adds meaningful extra nodes on a specialized farm.",
                "Azj-Kahet has comparatively little Blessing Blossom/Arathor's Spear, which is actually useful when you want a node pool biased toward underground herbs. Blizzard Forums",
                "This is also a strong Luredrop farm, so Orbinid + Luredrop should normally be gathered together.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/azj-kahet-farming-route-lightless-channels-herb-ore-path-tww/?utm_source=chatgpt.com",
                "https://us.forums.blizzard.com/en/wow/t/mining-and-herb-location-questions/1946428?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-orbinid-2214-2-supplied", 2, 2214, "The Ringing Deeps",
            "Alternative - Eastern Ringing Deeps", "published-zone-gathering-loop", "Artisans of Azeroth eastern herb/ore route. Artisans of Azeroth",
            {
                55592697, 58333129, 61743144, 65502859, 67763061, 66203266, 66913576, 61873683,
                61553877, 64084066, 68214029, 68563737, 68463330, 69843211, 70743268, 70203463,
                71093555, 73123403, 73893474, 72783775, 74544042, 74224413, 72724626, 71584120,
                69384466, 65064316, 62434807, 60354641, 59254746, 57154835, 57574460, 56694106,
                54534546, 52353948, 54833769, 55543530, 53923104,
            },
            {
                "Better if you want Orbinid without spending the whole session in Azj-Kahet.",
                "Ringing Deeps gives a broader mix of herbs, so total AH value can be steadier.",
                "Do not skip recessed cave/tunnel sections merely to maintain flight speed; that is where the underground-biased herbs justify the route.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/ringing-deeps-farming-route-eastern-loop-herb-ore-route-tww/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
    ["Luredrop"] = {
        SuppliedHerbRoute(
            "tww-luredrop-2255-1-supplied", 1, 2255, "Azj-Kahet",
            "Main - Azj-Kahet Lightless Channels", "published-zone-gathering-loop", "Artisans of Azeroth. Artisans of Azeroth",
            {
                61203232, 58563137, 58962845, 57032694, 52272781, 49822521, 50632322, 53552341,
                55872390, 57622236, 59482288, 61672057, 63761882, 64381528, 63570874, 64010368,
                66290800, 65041133, 67091218, 65571615, 66821854, 68402066, 71041915, 73351869,
                74861546, 76872132, 76562474, 74532500, 74082287, 72252576, 69762334, 66862488,
                64592684, 64032860,
            },
            {
                "This is one of the strongest fits between route geography and herb ecology in the list.",
                "Remain inside the channel/cavern network. Flying into open sections primarily to shorten the geometric loop defeats the purpose.",
                "Run Phial of Truesight for camouflaged Luredrop.",
                "Luredrop and Orbinid overlap enough that you should gather both rather than filtering Orbinid out.",
                "Sporefused/Crystallized/Irradiated modifiers can be worth Overloading depending on specialization; modified nodes can provide additional node opportunities rather than merely the base gather. Warcraft Wiki",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/azj-kahet-farming-route-lightless-channels-herb-ore-path-tww/?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Crystallized_Arathor%27s_Spear?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-luredrop-2214-2-supplied", 2, 2214, "The Ringing Deeps",
            "Alternative - Ringing Deeps eastern loop", "published-zone-gathering-loop", "Artisans of Azeroth. Artisans of Azeroth",
            {
                55592697, 58333129, 61743144, 65502859, 67763061, 66203266, 66913576, 61873683,
                61553877, 64084066, 68214029, 68563737, 68463330, 69843211, 70743268, 70203463,
                71093555, 73123403, 73893474, 72783775, 74544042, 74224413, 72724626, 71584120,
                69384466, 65064316, 62434807, 60354641, 59254746, 57154835, 57574460, 56694106,
                54534546, 52353948, 54833769, 55543530, 53923104,
            },
            {
                "Experienced gatherers specifically report good Luredrop concentration in the northern/darker Ringing Deeps. Blizzard Forums",
                "Follow the cave architecture rather than treating this as a flat outdoor perimeter route.",
                "This alternative is useful when Azj-Kahet has too many farmers or when you also want Mycobloom and other general TWW herbs.",
                "K'aresh alternative: farm Phantom Bloom and compare the Resource Market exchange rate for the desired Khaz Algar herb before converting; rates change. These are exchange materials, not direct spawns of this herb in K'aresh.",
            },
            {
                "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview?utm_source=chatgpt.com",
                "https://artisansofazeroth.com/ringing-deeps-farming-route-eastern-loop-herb-ore-route-tww/?utm_source=chatgpt.com",
                "https://us.forums.blizzard.com/en/wow/t/mining-and-herb-location-questions/1946428?utm_source=chatgpt.com",
                "https://warcraft.wiki.gg/wiki/Camouflaged_herb?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
    ["Phantom Bloom"] = {
        SuppliedHerbRoute(
            "tww-phantom-bloom-2371-1-supplied", 1, 2371, "K'aresh",
            "Main - Dedicated Phantom Bloom route", "published-herb-route", "GamingHero dedicated Phantom Bloom export. This is the strongest route here in terms of being an actual herb-specific published import rather than a general gathering circuit. Gaminghero.io",
            {
                69132899, 72632619, 75342574, 78012838, 79223176, 77713748, 77624313, 78624603,
                77685271, 74325206, 69855268, 67115039, 66164744, 62984831, 56525476, 58335556,
                60285909, 58986099, 55905906, 54206052, 53106357, 52176509, 51846791, 47016559,
                44325716, 44845413, 46295246, 47325008, 49464964, 51705008, 53844728, 55655103,
                56485478, 63014822, 62334404, 62733972, 66473790, 68003654, 68373255,
            },
            {
                "Prioritize the eastern/south-western landmasses, which are repeatedly used by published Phantom Bloom routes. Method",
                "Do not spend time sweeping Eco-Domes specifically for Phantom Bloom; the herb's distribution is biased outside them.",
                "Many nodes are close to hostile mobs, so Darkmoon Firewater is useful for improving gathering speed and reducing exposure time. Method",
                "Unlike the original five herbs, I would not build your Phantom Bloom addon recommendation around Truesight revealing hidden Phantom Bloom. Current gather data lists normal/lush variants rather than a camouflaged one. Wowhead",
                "Compare the Resource Market exchange rate before converting Phantom Bloom into Khaz Algar herbs; rates change, so compare direct gathering against the exchange for the desired herb.",
            },
            {
                "https://warcraft.wiki.gg/wiki/Phantom_Bloom?utm_source=chatgpt.com",
                "https://gaminghero.io/best-gathering-routes-patch-11-2/",
                "https://www.method.gg/guides/best-phantom-bloom-and-desolate-talus-farming-routes-for-patch-11-2?utm_source=chatgpt.com",
                "https://www.wowhead.com/item%3D239691/phantom-bloom?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
        SuppliedHerbRoute(
            "tww-phantom-bloom-2371-2-supplied", 2, 2371, "K'aresh",
            "Alternative - K'aresh long coverage route", "published-zone-gathering-loop", "xScarlife Gaming long circuit. xscarlife-gaming.com",
            {
                68792833, 71252577, 74012464, 76452441, 78872808, 79263254, 77903670, 77104028,
                78364411, 79714648, 80055360, 76095771, 73105991, 70735928, 69305696, 67645603,
                66425791, 65485443, 67284998, 69714859, 71614966, 73364893, 72804600, 70984226,
                68634578, 65114705, 62255077, 61254741, 61184417, 60094311, 61683818, 63743718,
                66473861, 66813408, 67923172,
            },
            {
                "This is a better choice when the dedicated Phantom Bloom circuit is heavily contested.",
                "It covers a broader portion of K'aresh, which sacrifices some route compactness in exchange for access to more independent spawn clusters.",
                "Because Phantom Bloom is the only herb unique to K'aresh, you can use the long route without worrying about moving into a fundamentally wrong zone for the target.",
                "Compare the Resource Market exchange rate before converting Phantom Bloom into Khaz Algar herbs; rates change, so compare direct gathering against the exchange for the desired herb.",
            },
            {
                "https://warcraft.wiki.gg/wiki/Phantom_Bloom?utm_source=chatgpt.com",
                "https://xscarlife-gaming.com/farming-retail/?utm_source=chatgpt.com",
                "https://www.wowhead.com/ptr-2/item%3D239692/phantom-bloom?utm_source=chatgpt.com",
            }
        ),
    },
}

local function WithSuppliedRoutes(itemName, existingSpots)
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(existingSpots or {}) do
        spots[#spots + 1] = spot
    end
    return spots
end

local function RegisterHerb(itemID, itemName, qualityRank, summary, spots)
    Register({
        itemID = itemID,
        itemName = itemName,
        expansion = "warWithin",
        professions = { "herbalism", "alchemy", "inscription" },
        category = "Herb",
        qualityRank = qualityRank,
        isRoute = true,
        sourceUrls = {
            ItemUrl(itemID),
            "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
            "https://www.method.gg/guides/the-war-within-herbalism-profession-leveling-guide",
        },
        summary = summary,
        spots = WithSuppliedRoutes(itemName, spots),
    })
end

RegisterHerb(210796, "Mycobloom", 1,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)
RegisterHerb(210797, "Mycobloom", 2,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)
RegisterHerb(210798, "Mycobloom", 3,
    "Widespread Khaz Algar herb. Use shared War Within herb loops and gather modified variants along the route.",
    H.TWW_HERB_SPOTS)

RegisterHerb(210805, "Blessing Blossom", 1,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })
RegisterHerb(210806, "Blessing Blossom", 2,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })
RegisterHerb(210807, "Blessing Blossom", 3,
    "Open and high-place Khaz Algar herb. Use shared War Within herb loops and Hallowfall Rich Soil pockets.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[3] })

Register({
    itemID = 210799,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 1,
    sourceUrls = {
        "https://www.wowhead.com/item=210799/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Comments point to hidden areas, caves, rare-spawn-adjacent places, "
        .. "darker Hallowfall pockets, The Ringing Deeps, and Azj-Kahet.",
    isRoute = true,
    spots = WithSuppliedRoutes("Luredrop", LUREDROP_SPOTS),
})

Register({
    itemID = 210800,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 2,
    sourceUrls = {
        "https://www.wowhead.com/item=210800/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Target shaded pockets, caves, and underground routes rather than "
        .. "wide open surface herb loops.",
    isRoute = true,
    spots = WithSuppliedRoutes("Luredrop", LUREDROP_SPOTS),
})

Register({
    itemID = 210801,
    itemName = "Luredrop",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 3,
    sourceUrls = {
        "https://www.wowhead.com/item=210801/luredrop",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Dark-area Khaz Algar herb. Target shaded pockets, caves, and underground routes rather than "
        .. "wide open surface herb loops.",
    isRoute = true,
    spots = WithSuppliedRoutes("Luredrop", LUREDROP_SPOTS),
})

Register({
    itemID = 210802,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 1,
    sourceUrls = {
        "https://www.wowhead.com/item=210802/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Wowhead comments repeatedly point to caves on "
        .. "Isle of Dorn and The Ringing Deeps.",
    isRoute = true,
    spots = WithSuppliedRoutes("Orbinid", ORBINID_SPOTS),
})

Register({
    itemID = 210803,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 2,
    sourceUrls = {
        "https://www.wowhead.com/item=210803/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Use compact Isle of Dorn cave checks and "
        .. "Ringing Deeps tunnel loops.",
    isRoute = true,
    spots = WithSuppliedRoutes("Orbinid", ORBINID_SPOTS),
})

Register({
    itemID = 210804,
    itemName = "Orbinid",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    qualityRank = 3,
    sourceUrls = {
        "https://www.wowhead.com/item=210804/orbinid",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
    },
    summary = "Cave and underground-leaning Khaz Algar herb. Use compact Isle of Dorn cave checks and "
        .. "Ringing Deeps tunnel loops.",
    isRoute = true,
    spots = WithSuppliedRoutes("Orbinid", ORBINID_SPOTS),
})

RegisterHerb(210808, "Arathor's Spear", 1,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })
RegisterHerb(210809, "Arathor's Spear", 2,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })
RegisterHerb(210810, "Arathor's Spear", 3,
    "Bright outdoor Khaz Algar herb. Target Hallowfall west ridges and the shared broad herb loops.",
    { H.TWW_HERB_SPOTS[1], H.TWW_HERB_SPOTS[4] })

Register({
    itemID = 213197,
    itemName = "Null Lotus",
    expansion = "warWithin",
    professions = { "herbalism", "alchemy", "inscription" },
    category = "Herb",
    sourceUrls = {
        "https://www.wowhead.com/item=213197/null-lotus",
        "https://www.wowhead.com/guide/the-war-within/professions/herbalism-overview",
        "https://www.method.gg/guides/best-mining-and-herbalism-routes-for-the-war-within",
    },
    summary = "Rare Khaz Algar herb side gather. Farm any dense War Within herb route and value it as a "
        .. "bonus rare hit rather than a standalone node.",
    spots = H.TWW_HERB_SPOTS,
})

RegisterHerb(239690, "Phantom Bloom", 1,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
RegisterHerb(239691, "Phantom Bloom", 2,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
RegisterHerb(239692, "Phantom Bloom", 3,
    "K'aresh herb and Resource Market exchange material. Choose the dedicated Phantom Bloom circuit or the longer coverage loop.")
