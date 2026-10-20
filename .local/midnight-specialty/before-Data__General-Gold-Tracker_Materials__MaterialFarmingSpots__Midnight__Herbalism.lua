local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

-- Supplied Midnight herb recommendations use xScarlife's shared multifarm loops.
-- Eversong, Harandar and Zul'Aman vertices are decoded from the attachment.
-- Its omitted Voidstorm export was recovered from the publisher's public route library.
-- These are travel paths, not guaranteed herb spawns or measured herb-specific yield rankings.
local function SuppliedHerbRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrls, routeImportString)
    local coords = {}
    for index, packed in ipairs(packedCoords) do
        coords[index] = {
            x = math.floor(packed / 10000) / 10000,
            y = (packed % 10000) / 10000,
            label = location .. " #" .. index,
        }
    end
    return {
        id = id,
        sortOrder = sortOrder,
        mapID = mapID,
        mapName = mapName,
        location = location,
        dropdownLabel = mapName .. ": " .. location,
        routeType = "herbalism-loop",
        routeOrigin = "published-zone-gathering-loop",
        source = "xScarlife Gaming published multifarm path; supplied per-herb recommendations and tips",
        sourceUrls = sourceUrls,
        routeImportString = routeImportString,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Mixed-herb travel circuit; follow nearby herb habitats. Not a measured single-herb yield ranking or a guarantee of node spawns.",
    }
end

local ZONE_ROUTE_COORDS = {
    [2395] = {
        44643335, 50653657, 62283586, 60163940, 56184164, 62274553, 61486458, 53498125,
        47367896, 45698787, 40598631, 41957460, 38816646, 37905929, 39345626, 42775813,
        43116245, 45666368, 47195981, 46305650, 43405385, 39161277, 40244694, 43023994,
        42673465,
    },
    [2413] = {
        36262608, 41422315, 53002461, 56243113, 60933179, 65522688, 70783470, 60463717,
        55374127, 53594841, 59724246, 63674188, 70364579, 75385083, 72465384, 68235652,
        70866008, 74156576, 70716929, 68476662, 64986007, 59095662, 54296245, 51617616,
        41707362, 35587468, 34357835, 36378186, 33138642, 26507888, 38735684, 38255028,
        33754780, 33684239, 40564661, 39933431,
    },
    [2437] = {
        30492846, 38182519, 46123366, 46944570, 43064539, 39624605, 38405316, 47775287,
        48856025, 41287515, 32187487, 26018239, 19097579, 29577091, 35686164, 22896345,
        22075923, 29794531, 28893705,
    },
    [2405] = {
        44642291, 47592551, 50913039, 53482809, 58702693, 61813139, 61223829, 59664048,
        56364201, 53444044, 50514181, 49104607, 45786006, 52786541, 58726211, 63015582,
        65455862, 63206103, 63846423, 55777194, 62907586, 62848099, 58828593, 55288081,
        53157439, 49778046, 39098051, 36047697, 28627390, 33696657, 28896324, 25385387,
        30785357, 31284771, 35064963, 38735073, 37384320, 36494025, 41053624, 39623423,
        38852861, 41262339,
    },
}

local SUPPLIED_HERB_ROUTES = {
    ["Tranquility Bloom"] = {
        SuppliedHerbRoute(
            "midnight-tranquility-bloom-2395-1-supplied", 1, 2395, "Eversong Woods",
            "Main - Eversong Woods", ZONE_ROUTE_COORDS[2395],
            {
                "Eversong has comparatively straightforward terrain, suitable for repeated herb-gathering circuits.",
                "Watch for nodes near the rivers, as Method reports high herb density along waterways.",
                "Collect Tranquility Bloom even when it no longer provides Herbalism skill points; it is useful for Mulching.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236761",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            },
            "Retail:Routes:Tranquility Bloom:Eversong Woods:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDMzMzVeTjJeTjUwNjUzNjU3Xk4zXk42MjI4MzU4Nl5ONF5ONjAxNjM5NDBeTjVeTjU2MTg0MTY0Xk42Xk42MjI3NDU1M15ON15ONjE0ODY0NTheTjheTjUzNDk4MTI1Xk45Xk40NzM2Nzg5Nl5OMTBeTjQ1Njk4Nzg3Xk4xMV5ONDA1OTg2MzFeTjEyXk40MTk1NzQ2MF5OMTNeTjM4ODE2NjQ2Xk4xNF5OMzc5MDU5MjleTjE1Xk4zOTM0NTYyNl5OMTZeTjQyNzc1ODEzXk4xN15ONDMxMTYyNDVeTjE4Xk40NTY2NjM2OF5OMTleTjQ3MTk1OTgxXk4yMF5ONDYzMDU2NTBeTjIxXk40MzQwNTM4NV5OMjJeTjM5MTYxMjc3Xk4yM15ONDAyNDQ2OTReTjI0Xk40MzAyMzk5NF5OMjVeTjQyNjczNDY1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5GNDU0NTc4Mzc3MDk0NzU5OV5mLTM4XlN0YWJvb2xpc3ReVF50XlNkYl90eXBlXlRedF50XlNSb3V0ZU5hbWVeU1RyYW5xdWlsaXR5fmBCbG9vbV5TUm91dGVab25lXk4yMzk1XlNSb3V0ZUtleV5TVHJhbnF1aWxpdHn/Qmxvb21edF5e"
        ),
        SuppliedHerbRoute(
            "midnight-tranquility-bloom-2413-2-supplied", 2, 2413, "Harandar",
            "Alternative 1 - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "Search mushroom platforms, roots, and forest clearings.",
                "Consider manually extending the southwestern segment toward The Blinding Bloom, where Method specifically reports substantial Tranquility Bloom and Argentleaf.",
                "This route involves more vertical travel and hostile mobs.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236761",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            }
        ),
        SuppliedHerbRoute(
            "midnight-tranquility-bloom-2437-3-supplied", 3, 2437, "Zul'Aman",
            "Alternative 2 - Zul'Aman", ZONE_ROUTE_COORDS[2437],
            {
                "Useful when also collecting Wild-infused herbs and Motes of Wild Magic.",
                "Focus on lower-travel-time deviations along the zone's edges.",
                "Be prepared for lashers summoned by Wild nodes.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236761",
            }
        ),
    },
    ["Argentleaf"] = {
        SuppliedHerbRoute(
            "midnight-argentleaf-2413-1-supplied", 1, 2413, "Harandar",
            "Main - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "The Blinding Bloom in southwestern Harandar is an especially promising Argentleaf farming area.",
                "The imported circuit covers broader Harandar; detour to The Blinding Bloom if specifically targeting Argentleaf.",
                "Invest in Botany for mounted gathering and Silver Searcher within Bountiful Harvests for Argentleaf yield.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236776",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            },
            "Retail:Routes:Argentleaf:Harandar:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzYyNjI2MDheTjJeTjQxNDIyMzE1Xk4zXk41MzAwMjQ2MV5ONF5ONTYyNDMxMTNeTjVeTjYwOTMzMTc5Xk42Xk42NTUyMjY4OF5ON15ONzA3ODM0NzBeTjheTjYwNDYzNzE3Xk45Xk41NTM3NDEyN15OMTBeTjUzNTk0ODQxXk4xMV5ONTk3MjQyNDZeTjEyXk42MzY3NDE4OF5OMTNeTjcwMzY0NTc5Xk4xNF5ONzUzODUwODNeTjE1Xk43MjQ2NTM4NF5OMTZeTjY4MjM1NjUyXk4xN15ONzA4NjYwMDheTjE4Xk43NDE1NjU3Nl5OMTleTjcwNzE2OTI5Xk4yMF5ONjg0NzY2NjJeTjIxXk42NDk4NjAwN15OMjJeTjU5MDk1NjYyXk4yM15ONTQyOTYyNDVeTjI0Xk41MTYxNzYxNl5OMjVeTjQxNzA3MzYyXk4yNl5OMzU1ODc0NjheTjI3Xk4zNDM1NzgzNV5OMjheTjM2Mzc4MTg2Xk4yOV5OMzMxMzg2NDJeTjMwXk4yNjUwNzg4OF5OMzFeTjM4NzM1Njg0Xk4zMl5OMzgyNTUwMjheTjMzXk4zMzc1NDc4MF5OMzReTjMzNjg0MjM5Xk4zNV5ONDA1NjQ2NjFeTjM2Xk4zOTkzMzQzMV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjczMTIzODk0NDU2Mzk4MDReZi0zOV5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNBcmdlbnRsZWFmXlNSb3V0ZVpvbmVeTjI0MTNeU1JvdXRlS2V5XlNBcmdlbnRsZWFmXnReXg=="
        ),
        SuppliedHerbRoute(
            "midnight-argentleaf-2395-2-supplied", 2, 2395, "Eversong Woods",
            "Alternative 1 - Eversong Woods", ZONE_ROUTE_COORDS[2395],
            {
                "Check bushes and vegetation away from the main river path for Argentleaf.",
                "Lower terrain complexity makes it a useful alternative to Harandar.",
                "Compare Argentleaf gathered per minute to account for Harandar's slower node access.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236776",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            }
        ),
        SuppliedHerbRoute(
            "midnight-argentleaf-2405-3-supplied", 3, 2405, "Voidstorm",
            "Alternative 2 - Voidstorm", ZONE_ROUTE_COORDS[2405],
            {
                "Provides broad herb coverage and opportunities to gather Lush or modified plants.",
                "Expect ledges and elevation changes that can make minimap node positions misleading.",
                "Skip lengthy fights when your objective is Argentleaf quantity rather than mixed materials.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236776",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            },
            "Retail:Routes:Multifarm - xScarlife Gaming:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDIyOTFeTjJeTjQ3NTkyNTUxXk4zXk41MDkxMzAzOV5ONF5ONTM0ODI4MDleTjVeTjU4NzAyNjkzXk42Xk42MTgxMzEzOV5ON15ONjEyMjM4MjleTjheTjU5NjY0MDQ4Xk45Xk41NjM2NDIwMV5OMTBeTjUzNDQ0MDQ0Xk4xMV5ONTA1MTQxODFeTjEyXk40OTEwNDYwN15OMTNeTjQ1Nzg2MDA2Xk4xNF5ONTI3ODY1NDFeTjE1Xk41ODcyNjIxMV5OMTZeTjYzMDE1NTgyXk4xN15ONjU0NTU4NjJeTjE4Xk42MzIwNjEwM15OMTleTjYzODQ2NDIzXk4yMF5ONTU3NzcxOTReTjIxXk42MjkwNzU4Nl5OMjJeTjYyODQ4MDk5Xk4yM15ONTg4Mjg1OTNeTjI0Xk41NTI4ODA4MV5OMjVeTjUzMTU3NDM5Xk4yNl5ONDk3NzgwNDZeTjI3Xk4zOTA5ODA1MV5OMjheTjM2MDQ3Njk3Xk4yOV5OMjg2MjczOTBeTjMwXk4zMzY5NjY1N15OMzFeTjI4ODk2MzI0Xk4zMl5OMjUzODUzODdeTjMzXk4zMDc4NTM1N15OMzReTjMxMjg0NzcxXk4zNV5OMzUwNjQ5NjNeTjM2Xk4zODczNTA3M15OMzdeTjM3Mzg0MzIwXk4zOF5OMzY0OTQwMjVeTjM5Xk40MTA1MzYyNF5ONDBeTjM5NjIzNDIzXk40MV5OMzg4NTI4NjFeTjQyXk40MTI2MjMzOV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjQ5MTE1MzcwNTY2MjkyMTReZi0zOF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNNdWx0aWZhcm1+YC1+YHhTY2FybGlmZX5gR2FtaW5nXlNSb3V0ZVpvbmVeTjI0MDVeU1JvdXRlS2V5XlNNdWx0aWZhcm3/Lf94U2NhcmxpZmX/R2FtaW5nXnReXg=="
        ),
    },
    ["Azeroot"] = {
        SuppliedHerbRoute(
            "midnight-azeroot-2413-1-supplied", 1, 2413, "Harandar",
            "Main - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "Focus on the huge root systems, including elevated roots around Shaladrassil.",
                "Azeroot has specifically been reported around the southwestern Lightbloom area of Harandar.",
                "Watch the vertical position of herb nodes. An icon may be far above the ground rather than directly beside you.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236774",
                "https://us.forums.blizzard.com/en/wow/t/azeroot-nightmare/2272323",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            },
            "Retail:Routes:Azeroot:Harandar:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzYyNjI2MDheTjJeTjQxNDIyMzE1Xk4zXk41MzAwMjQ2MV5ONF5ONTYyNDMxMTNeTjVeTjYwOTMzMTc5Xk42Xk42NTUyMjY4OF5ON15ONzA3ODM0NzBeTjheTjYwNDYzNzE3Xk45Xk41NTM3NDEyN15OMTBeTjUzNTk0ODQxXk4xMV5ONTk3MjQyNDZeTjEyXk42MzY3NDE4OF5OMTNeTjcwMzY0NTc5Xk4xNF5ONzUzODUwODNeTjE1Xk43MjQ2NTM4NF5OMTZeTjY4MjM1NjUyXk4xN15ONzA4NjYwMDheTjE4Xk43NDE1NjU3Nl5OMTleTjcwNzE2OTI5Xk4yMF5ONjg0NzY2NjJeTjIxXk42NDk4NjAwN15OMjJeTjU5MDk1NjYyXk4yM15ONTQyOTYyNDVeTjI0Xk41MTYxNzYxNl5OMjVeTjQxNzA3MzYyXk4yNl5OMzU1ODc0NjheTjI3Xk4zNDM1NzgzNV5OMjheTjM2Mzc4MTg2Xk4yOV5OMzMxMzg2NDJeTjMwXk4yNjUwNzg4OF5OMzFeTjM4NzM1Njg0Xk4zMl5OMzgyNTUwMjheTjMzXk4zMzc1NDc4MF5OMzReTjMzNjg0MjM5Xk4zNV5ONDA1NjQ2NjFeTjM2Xk4zOTkzMzQzMV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjczMTIzODk0NDU2Mzk4MDReZi0zOV5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNBemVyb290XlNSb3V0ZVpvbmVeTjI0MTNeU1JvdXRlS2V5XlNBemVyb290XnReXg=="
        ),
        SuppliedHerbRoute(
            "midnight-azeroot-2437-2-supplied", 2, 2437, "Zul'Aman",
            "Alternative 1 - Zul'Aman", ZONE_ROUTE_COORDS[2437],
            {
                "Useful for avoiding Harandar's difficult vertical geometry.",
                "Gather all available herbs between Azeroot sightings to maintain useful material output.",
                "Wild-infused nodes add combat overhead but can yield extra materials.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236774",
                "https://us.forums.blizzard.com/en/wow/t/azeroot-nightmare/2272323",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            }
        ),
        SuppliedHerbRoute(
            "midnight-azeroot-2395-3-supplied", 3, 2395, "Eversong Woods",
            "Alternative 2 - Eversong Woods", ZONE_ROUTE_COORDS[2395],
            {
                "Easier for starting Herbalism characters and lower-geared characters.",
                "Check root-covered hills rather than exclusively following riverbanks.",
                "Treat this as a fallback: players have reported lower Azeroot availability here than in Harandar.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236774",
                "https://us.forums.blizzard.com/en/wow/t/azeroot-nightmare/2272323",
                "https://www.method.gg/guides/where-to-farm-argentleaf-midnight-herbalism-route",
            }
        ),
    },
    ["Mana Lily"] = {
        SuppliedHerbRoute(
            "midnight-mana-lily-2395-1-supplied", 1, 2395, "Eversong Woods",
            "Main - Eversong Woods", ZONE_ROUTE_COORDS[2395],
            {
                "Mana Lily commonly appears around rivers, lakes, and other water.",
                "Eversong is a strong starting choice because it has accessible waterways and relatively easy terrain.",
                "Follow nearby waterside nodes instead of adhering rigidly to the general multifarming route.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236778",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            },
            "Retail:Routes:Mana Lily:Eversong Woods:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDMzMzVeTjJeTjUwNjUzNjU3Xk4zXk42MjI4MzU4Nl5ONF5ONjAxNjM5NDBeTjVeTjU2MTg0MTY0Xk42Xk42MjI3NDU1M15ON15ONjE0ODY0NTheTjheTjUzNDk4MTI1Xk45Xk40NzM2Nzg5Nl5OMTBeTjQ1Njk4Nzg3Xk4xMV5ONDA1OTg2MzFeTjEyXk40MTk1NzQ2MF5OMTNeTjM4ODE2NjQ2Xk4xNF5OMzc5MDU5MjleTjE1Xk4zOTM0NTYyNl5OMTZeTjQyNzc1ODEzXk4xN15ONDMxMTYyNDVeTjE4Xk40NTY2NjM2OF5OMTleTjQ3MTk1OTgxXk4yMF5ONDYzMDU2NTBeTjIxXk40MzQwNTM4NV5OMjJeTjM5MTYxMjc3Xk4yM15ONDAyNDQ2OTReTjI0Xk40MzAyMzk5NF5OMjVeTjQyNjczNDY1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5GNDU0NTc4Mzc3MDk0NzU5OV5mLTM4XlN0YWJvb2xpc3ReVF50XlNkYl90eXBlXlRedF50XlNSb3V0ZU5hbWVeU01hbmF+YExpbHleU1JvdXRlWm9uZV5OMjM5NV5TUm91dGVLZXleU01hbmH/TGlseV50Xl4="
        ),
        SuppliedHerbRoute(
            "midnight-mana-lily-2413-2-supplied", 2, 2413, "Harandar",
            "Alternative 1 - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "Inspect pools and rivers where the route passes through wet terrain.",
                "High overall herb density makes mixed gathering worthwhile.",
                "Avoid inefficient climbs for isolated nodes on elevated vegetation.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236778",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            }
        ),
        SuppliedHerbRoute(
            "midnight-mana-lily-2437-3-supplied", 3, 2437, "Zul'Aman",
            "Alternative 2 - Zul'Aman", ZONE_ROUTE_COORDS[2437],
            {
                "Use this route as a framework and deviate toward waterways to hunt Mana Lily.",
                "The zone offers additional Wild-infused gathering opportunities.",
                "This is not a Mana Lily-only path, so monitor actual Mana Lily yield rather than total node count.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236778",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            }
        ),
    },
    ["Sanguithorn"] = {
        SuppliedHerbRoute(
            "midnight-sanguithorn-2437-1-supplied", 1, 2437, "Zul'Aman",
            "Main - Zul'Aman", ZONE_ROUTE_COORDS[2437],
            {
                "The primary route is selected for accessible mixed gathering and useful Wild-node rewards, not because Sanguithorn is exclusive to Zul'Aman.",
                "Following the zone's edges can reduce difficult elevation changes.",
                "Wild nodes can spawn lashers, creating opportunities for additional herbs if your character can defeat them quickly.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236770",
            },
            "Retail:Routes:Sanguithorn:Zul'Aman:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzA0OTI4NDZeTjJeTjM4MTgyNTE5Xk4zXk40NjEyMzM2Nl5ONF5ONDY5NDQ1NzBeTjVeTjQzMDY0NTM5Xk42Xk4zOTYyNDYwNV5ON15OMzg0MDUzMTZeTjheTjQ3Nzc1Mjg3Xk45Xk40ODg1NjAyNV5OMTBeTjQxMjg3NTE1Xk4xMV5OMzIxODc0ODdeTjEyXk4yNjAxODIzOV5OMTNeTjE5MDk3NTc5Xk4xNF5OMjk1NzcwOTFeTjE1Xk4zNTY4NjE2NF5OMTZeTjIyODk2MzQ1Xk4xN15OMjIwNzU5MjNeTjE4Xk4yOTc5NDUzMV5OMTleTjI4ODkzNzA1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5GODY0MjU1MTk1NTYwODM0Nl5mLTM5XlN0YWJvb2xpc3ReVF50XlNkYl90eXBlXlRedF50XlNSb3V0ZU5hbWVeU1Nhbmd1aXRob3JuXlNSb3V0ZVpvbmVeTjI0MzdeU1JvdXRlS2V5XlNTYW5ndWl0aG9ybl50Xl4="
        ),
        SuppliedHerbRoute(
            "midnight-sanguithorn-2413-2-supplied", 2, 2413, "Harandar",
            "Alternative 1 - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "Good alternative for substantial mixed-herb density.",
                "Gather Sanguithorn alongside other herbs and watch root and mushroom elevations.",
                "Mounted harvesting helps reduce downtime.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236770",
            }
        ),
        SuppliedHerbRoute(
            "midnight-sanguithorn-2405-3-supplied", 3, 2405, "Voidstorm",
            "Alternative 2 - Voidstorm", ZONE_ROUTE_COORDS[2405],
            {
                "Wide coverage and numerous opportunities to collect different herb variants.",
                "Prioritize easily accessible Sanguithorn; aggressive mobs can reduce efficiency.",
                "Consider Voidbound material yields as a secondary benefit when deciding whether to farm here.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236770",
            },
            "Retail:Routes:Multifarm - xScarlife Gaming:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDIyOTFeTjJeTjQ3NTkyNTUxXk4zXk41MDkxMzAzOV5ONF5ONTM0ODI4MDleTjVeTjU4NzAyNjkzXk42Xk42MTgxMzEzOV5ON15ONjEyMjM4MjleTjheTjU5NjY0MDQ4Xk45Xk41NjM2NDIwMV5OMTBeTjUzNDQ0MDQ0Xk4xMV5ONTA1MTQxODFeTjEyXk40OTEwNDYwN15OMTNeTjQ1Nzg2MDA2Xk4xNF5ONTI3ODY1NDFeTjE1Xk41ODcyNjIxMV5OMTZeTjYzMDE1NTgyXk4xN15ONjU0NTU4NjJeTjE4Xk42MzIwNjEwM15OMTleTjYzODQ2NDIzXk4yMF5ONTU3NzcxOTReTjIxXk42MjkwNzU4Nl5OMjJeTjYyODQ4MDk5Xk4yM15ONTg4Mjg1OTNeTjI0Xk41NTI4ODA4MV5OMjVeTjUzMTU3NDM5Xk4yNl5ONDk3NzgwNDZeTjI3Xk4zOTA5ODA1MV5OMjheTjM2MDQ3Njk3Xk4yOV5OMjg2MjczOTBeTjMwXk4zMzY5NjY1N15OMzFeTjI4ODk2MzI0Xk4zMl5OMjUzODUzODdeTjMzXk4zMDc4NTM1N15OMzReTjMxMjg0NzcxXk4zNV5OMzUwNjQ5NjNeTjM2Xk4zODczNTA3M15OMzdeTjM3Mzg0MzIwXk4zOF5OMzY0OTQwMjVeTjM5Xk40MTA1MzYyNF5ONDBeTjM5NjIzNDIzXk40MV5OMzg4NTI4NjFeTjQyXk40MTI2MjMzOV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjQ5MTE1MzcwNTY2MjkyMTReZi0zOF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNNdWx0aWZhcm1+YC1+YHhTY2FybGlmZX5gR2FtaW5nXlNSb3V0ZVpvbmVeTjI0MDVeU1JvdXRlS2V5XlNNdWx0aWZhcm3/Lf94U2NhcmxpZmX/R2FtaW5nXnReXg=="
        ),
    },
    ["Nocturnal Lotus"] = {
        SuppliedHerbRoute(
            "midnight-nocturnal-lotus-2413-1-supplied", 1, 2413, "Harandar",
            "Main - Harandar", ZONE_ROUTE_COORDS[2413],
            {
                "Nocturnal Lotus can drop from any Midnight herb. Collecting herbs consistently is more important than targeting a specific plant species.",
                "Harandar offers dense herb coverage, although elevation changes can limit actual collection speed.",
                "Imbued Mulch is particularly valuable for targeting rare reagent outcomes. Method describes it as allowing an hourly guaranteed rare gather using 10 Tranquility Bloom, although player reports indicate results may vary.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236780",
                "https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            },
            "Retail:Routes:Nocturnal Lotus:Harandar:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzYyNjI2MDheTjJeTjQxNDIyMzE1Xk4zXk41MzAwMjQ2MV5ONF5ONTYyNDMxMTNeTjVeTjYwOTMzMTc5Xk42Xk42NTUyMjY4OF5ON15ONzA3ODM0NzBeTjheTjYwNDYzNzE3Xk45Xk41NTM3NDEyN15OMTBeTjUzNTk0ODQxXk4xMV5ONTk3MjQyNDZeTjEyXk42MzY3NDE4OF5OMTNeTjcwMzY0NTc5Xk4xNF5ONzUzODUwODNeTjE1Xk43MjQ2NTM4NF5OMTZeTjY4MjM1NjUyXk4xN15ONzA4NjYwMDheTjE4Xk43NDE1NjU3Nl5OMTleTjcwNzE2OTI5Xk4yMF5ONjg0NzY2NjJeTjIxXk42NDk4NjAwN15OMjJeTjU5MDk1NjYyXk4yM15ONTQyOTYyNDVeTjI0Xk41MTYxNzYxNl5OMjVeTjQxNzA3MzYyXk4yNl5OMzU1ODc0NjheTjI3Xk4zNDM1NzgzNV5OMjheTjM2Mzc4MTg2Xk4yOV5OMzMxMzg2NDJeTjMwXk4yNjUwNzg4OF5OMzFeTjM4NzM1Njg0Xk4zMl5OMzgyNTUwMjheTjMzXk4zMzc1NDc4MF5OMzReTjMzNjg0MjM5Xk4zNV5ONDA1NjQ2NjFeTjM2Xk4zOTkzMzQzMV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjczMTIzODk0NDU2Mzk4MDReZi0zOV5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNOb2N0dXJuYWx+YExvdHVzXlNSb3V0ZVpvbmVeTjI0MTNeU1JvdXRlS2V5XlNOb2N0dXJuYWz/TG90dXNedF5e"
        ),
        SuppliedHerbRoute(
            "midnight-nocturnal-lotus-2405-2-supplied", 2, 2405, "Voidstorm",
            "Alternative 1 - Voidstorm", ZONE_ROUTE_COORDS[2405],
            {
                "This is the highest-waypoint-count route in the pack.",
                "Players have reported strong Herbalism yields in Voidstorm, but waypoint count alone does not establish higher Nocturnal Lotus yields.",
                "Use Perception-oriented tools and consumables where appropriate, and prioritize frequent herb pickups.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236780",
                "https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            },
            "Retail:Routes:Multifarm - xScarlife Gaming:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDIyOTFeTjJeTjQ3NTkyNTUxXk4zXk41MDkxMzAzOV5ONF5ONTM0ODI4MDleTjVeTjU4NzAyNjkzXk42Xk42MTgxMzEzOV5ON15ONjEyMjM4MjleTjheTjU5NjY0MDQ4Xk45Xk41NjM2NDIwMV5OMTBeTjUzNDQ0MDQ0Xk4xMV5ONTA1MTQxODFeTjEyXk40OTEwNDYwN15OMTNeTjQ1Nzg2MDA2Xk4xNF5ONTI3ODY1NDFeTjE1Xk41ODcyNjIxMV5OMTZeTjYzMDE1NTgyXk4xN15ONjU0NTU4NjJeTjE4Xk42MzIwNjEwM15OMTleTjYzODQ2NDIzXk4yMF5ONTU3NzcxOTReTjIxXk42MjkwNzU4Nl5OMjJeTjYyODQ4MDk5Xk4yM15ONTg4Mjg1OTNeTjI0Xk41NTI4ODA4MV5OMjVeTjUzMTU3NDM5Xk4yNl5ONDk3NzgwNDZeTjI3Xk4zOTA5ODA1MV5OMjheTjM2MDQ3Njk3Xk4yOV5OMjg2MjczOTBeTjMwXk4zMzY5NjY1N15OMzFeTjI4ODk2MzI0Xk4zMl5OMjUzODUzODdeTjMzXk4zMDc4NTM1N15OMzReTjMxMjg0NzcxXk4zNV5OMzUwNjQ5NjNeTjM2Xk4zODczNTA3M15OMzdeTjM3Mzg0MzIwXk4zOF5OMzY0OTQwMjVeTjM5Xk40MTA1MzYyNF5ONDBeTjM5NjIzNDIzXk40MV5OMzg4NTI4NjFeTjQyXk40MTI2MjMzOV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheRjQ5MTE1MzcwNTY2MjkyMTReZi0zOF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNNdWx0aWZhcm1+YC1+YHhTY2FybGlmZX5gR2FtaW5nXlNSb3V0ZVpvbmVeTjI0MDVeU1JvdXRlS2V5XlNNdWx0aWZhcm3/Lf94U2NhcmxpZmX/R2FtaW5nXnReXg=="
        ),
        SuppliedHerbRoute(
            "midnight-nocturnal-lotus-2395-3-supplied", 3, 2395, "Eversong Woods",
            "Alternative 2 - Eversong Woods", ZONE_ROUTE_COORDS[2395],
            {
                "Easier terrain supports consistent, lower-interruption gathering.",
                "Follow rivers where herb density is good, including nearby nodes outside the exact path.",
                "Useful for repeated gathering sessions or applying Imbued Mulch without traveling into more hostile zones.",
            },
            {
                "https://xscarlife-gaming.com/farming/retail/",
                "https://www.method.gg/guides/midnight-herb-and-mote-farming-routes",
                "https://www.wowhead.com/item=236780",
                "https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight",
                "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
            }
        ),
    },
}

local function RegisterHerb(item)
    -- Each rank owns its spot list, so later catalog additions cannot bleed into other herbs/ranks.
    local spots = {}
    for _, spot in ipairs(SUPPLIED_HERB_ROUTES[item.itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(item.spots or {}) do
        spots[#spots + 1] = spot
    end
    item.spots = spots
    item.isRoute = true
    Register(item)
end

RegisterHerb(H.BuildMidnightItem(
    236761,
    "Tranquility Bloom",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236761/tranquility-bloom",
        "https://www.wowhead.com/object=516932/tranquility-bloom",
        "https://epicwowguides.com/material/tranquility-bloom/",
    },
    "Common Midnight herb and a good baseline route material. Pick every node to create lush and infused replacement chances.",
    H.MIDNIGHT_HERB_SPOTS,
    1
))

RegisterHerb(H.BuildMidnightItem(
    236767,
    "Tranquility Bloom",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236767/tranquility-bloom",
        "https://www.wowhead.com/object=516932/tranquility-bloom",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "High-quality Tranquility Bloom. Same farm routes as the base quality, with better yields from skill and Finesse.",
    H.MIDNIGHT_HERB_SPOTS,
    2
))

RegisterHerb(H.BuildMidnightItem(
    236770,
    "Sanguithorn",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236770/sanguithorn",
        "https://www.wowhead.com/object=516934/sanguithorn",
        "https://warcraft.wiki.gg/wiki/Sanguithorn",
    },
    "Midnight herb found broadly across the new zones. Eversong, Zul'Aman, and Harandar object data show high node presence.",
    H.MIDNIGHT_HERB_SPOTS,
    1
))

RegisterHerb(H.BuildMidnightItem(
    236771,
    "Sanguithorn",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236771/sanguithorn",
        "https://www.wowhead.com/object=516934/sanguithorn",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "High-quality Sanguithorn. Use broad Midnight herb loops and prioritize Finesse once Deftness feels comfortable.",
    H.MIDNIGHT_HERB_SPOTS,
    2
))

RegisterHerb(H.BuildMidnightItem(
    236774,
    "Azeroot",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236774/azeroot",
        "https://www.wowhead.com/object=516935/azeroot",
        "https://www.wowhead.com/object=516981/voidbound-azeroot",
    },
    "Midnight herb with strong value reports in community discussion. Broad herb loops apply, with Voidstorm checks for Voidbound variants.",
    H.MIDNIGHT_HERB_SPOTS,
    1
))

RegisterHerb(H.BuildMidnightItem(
    236775,
    "Azeroot",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236775/azeroot",
        "https://www.wowhead.com/object=516935/azeroot",
        "https://warcraft.wiki.gg/wiki/Tranquility_Bloom",
    },
    "High-quality Azeroot. Gather every nearby herb to keep replacement nodes moving.",
    H.MIDNIGHT_HERB_SPOTS,
    2
))

RegisterHerb(H.BuildMidnightItem(
    236776,
    "Argentleaf",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236776/argentleaf",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "Midnight herb with comments reporting it can feel less common than other herbs. Use broad zone loops rather than camping.",
    H.MIDNIGHT_HERB_SPOTS,
    1
))

RegisterHerb(H.BuildMidnightItem(
    236777,
    "Argentleaf",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236777/argentleaf",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "High-quality Argentleaf. Finesse and full route coverage matter more than a single fixed location.",
    H.MIDNIGHT_HERB_SPOTS,
    2
))

RegisterHerb(H.BuildMidnightItem(
    236778,
    "Mana Lily",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236778/mana-lily",
        "https://warcraft.wiki.gg/wiki/Mana_Lily",
        "https://us.forums.blizzard.com/en/wow/t/mana-lily-is-far-too-rare-compared-to-other-herbs/2280433",
    },
    "Waterline Midnight herb. It is more constrained than broad land herbs, so route around water while still clearing nearby herb nodes.",
    H.MIDNIGHT_MANA_LILY_SPOTS,
    1
))

RegisterHerb(H.BuildMidnightItem(
    236779,
    "Mana Lily",
    { "herbalism", "alchemy", "inscription" },
    "Herb",
    {
        "https://www.wowhead.com/item=236779/mana-lily",
        "https://warcraft.wiki.gg/wiki/Mana_Lily",
        "https://epicwowguides.com/material/mana-lily/",
    },
    "High-quality Mana Lily. Follow waterline routes and use Finesse once you can gather without interruption.",
    H.MIDNIGHT_MANA_LILY_SPOTS,
    2
))

RegisterHerb(H.BuildMidnightItem(
    236780,
    "Nocturnal Lotus",
    { "herbalism", "alchemy" },
    "Herb",
    {
        "https://www.wowhead.com/item=236780/nocturnal-lotus",
        "https://www.method.gg/guides/how-to-farm-nocturnal-lotus-in-wow-midnight",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "Rare Midnight herb side gather. Farm any Midnight herb route, and use Imbued Mulch/Mulching when you specifically want lotus behavior.",
    H.MIDNIGHT_NOCTURNAL_LOTUS_SPOTS
))
