local _, NS = ...
local Register = NS.RegisterMaterialFarmingSpot
local H = NS.MaterialFarmingSpotHelpers

-- Supplied Midnight mining exports, decoded without changing vertex order.
-- Mixed-deposit paths from williamlong.info and xScarlife Gaming, not ore-exclusive spawns.
-- Dazzling Thorium is rare bonus loot from base ore nodes and has no dedicated deposit.
local function SuppliedMiningRoute(id, sortOrder, mapID, mapName, location, packedCoords, tips, sourceUrl, routeImportString)
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
        routeType = "mining-loop",
        routeOrigin = "published-zone-gathering-loop",
        source = "Published mixed-deposit path: " .. sourceUrl .. "; supplied per-ore recommendations and tips",
        sourceUrls = { sourceUrl },
        routeImportString = routeImportString,
        tips = tips,
        coords = coords,
        isRoute = true,
        inGameTested = false,
        confidence = "medium",
        dropDifficulty = "Published mixed-deposit travel circuit, not guaranteed ore spawns. Dazzling Thorium is rare bonus loot from base ore nodes, not a dedicated deposit.",
    }
end

local SUPPLIED_MINING_ROUTES = {
    ["Refulgent Copper Ore"] = {
        SuppliedMiningRoute(
            "midnight-refulgent-copper-ore-2395-1-supplied", 1, 2395, "Eversong Woods",
            "Main - expansive Eversong circuit - Eversong Woods",
            {
                38386182, 37055968, 37395443, 37035147, 36544910, 37714768, 39464824, 43005177,
                45935448, 44554875, 43194061, 45033899, 45533770, 46583768, 49423906, 51083981,
                52694047, 55884184, 58373925, 59693885, 61374032, 61384038, 61804496, 62554791,
                60815197, 60575390, 60755853, 60356053, 60636310, 60156505, 60726821, 61157008,
                60457342, 59257516, 55847947, 55088051, 54968344, 55158551, 53808710, 52858504,
                52508419, 49728266, 46588113, 45158433, 43598771, 42028960, 41658880, 41118560,
                41348014, 40717871, 40237802, 39487661, 37727361, 36837093, 36796810, 38176698,
                39036343,
            },
            {
                "Sweep the outside of the zone and detour for Rich Copper nodes and cave Seams.",
                "Lightfused deposits yield Motes of Light; collect airborne/ground orbs after mining/Overload.",
                "Watch the southwest Alliance camp if playing Horde.",
            },
            "https://www.williamlong.info/archives/7540.html",
            "Retail:Routes:Refulgent Copper:Eversong Woods:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzgzODYxODJeTjJeTjM3MDU1OTY4Xk4zXk4zNzM5NTQ0M15ONF5OMzcwMzUxNDdeTjVeTjM2NTQ0OTEwXk42Xk4zNzcxNDc2OF5ON15OMzk0NjQ4MjReTjheTjQzMDA1MTc3Xk45Xk40NTkzNTQ0OF5OMTBeTjQ0NTU0ODc1Xk4xMV5ONDMxOTQwNjFeTjEyXk40NTAzMzg5OV5OMTNeTjQ1NTMzNzcwXk4xNF5ONDY1ODM3NjheTjE1Xk40OTQyMzkwNl5OMTZeTjUxMDgzOTgxXk4xN15ONTI2OTQwNDdeTjE4Xk41NTg4NDE4NF5OMTleTjU4MzczOTI1Xk4yMF5ONTk2OTM4ODVeTjIxXk42MTM3NDAzMl5OMjJeTjYxMzg0MDM4Xk4yM15ONjE4MDQ0OTZeTjI0Xk42MjU1NDc5MV5OMjVeTjYwODE1MTk3Xk4yNl5ONjA1NzUzOTBeTjI3Xk42MDc1NTg1M15OMjheTjYwMzU2MDUzXk4yOV5ONjA2MzYzMTBeTjMwXk42MDE1NjUwNV5OMzFeTjYwNzI2ODIxXk4zMl5ONjExNTcwMDheTjMzXk42MDQ1NzM0Ml5OMzReTjU5MjU3NTE2Xk4zNV5ONTU4NDc5NDdeTjM2Xk41NTA4ODA1MV5OMzdeTjU0OTY4MzQ0Xk4zOF5ONTUxNTg1NTFeTjM5Xk41MzgwODcxMF5ONDBeTjUyODU4NTA0Xk40MV5ONTI1MDg0MTleTjQyXk40OTcyODI2Nl5ONDNeTjQ2NTg4MTEzXk40NF5ONDUxNTg0MzNeTjQ1Xk40MzU5ODc3MV5ONDZeTjQyMDI4OTYwXk40N15ONDE2NTg4ODBeTjQ4Xk40MTExODU2MF5ONDleTjQxMzQ4MDE0Xk41MF5ONDA3MTc4NzFeTjUxXk40MDIzNzgwMl5ONTJeTjM5NDg3NjYxXk41M15OMzc3MjczNjFeTjU0Xk4zNjgzNzA5M15ONTVeTjM2Nzk2ODEwXk41Nl5OMzgxNzY2OTheTjU3Xk4zOTAzNjM0M150XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TUmVmdWxnZW50fmBDb3BwZXJeU1JvdXRlWm9uZV5OMjM5NV5TUm91dGVLZXleU1JlZnVsZ2VudP9Db3BwZXJedF5e"
        ),
        SuppliedMiningRoute(
            "midnight-refulgent-copper-ore-2437-2-supplied", 2, 2437, "Zul'Aman",
            "Alternative - perimeter / southern coast - Zul'Aman",
            {
                30492846, 38182519, 46123366, 46944570, 43064539, 39624605, 38405316, 47775287,
                48856025, 41287515, 32187487, 26018239, 19097579, 29577091, 35686164, 22896345,
                22075923, 29794531, 28893705,
            },
            {
                "Prioritize the southern coastal section of the loop, where Method reports particularly dense mining nodes.",
                "Mine both Wild deposit and spawned orelings for more Refulgent Copper; the adds may require combat.",
                "Test turning around early when your minimap shows sparse nodes on the northern stretch.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Refulgent Copper:Zul'Aman:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzA0OTI4NDZeTjJeTjM4MTgyNTE5Xk4zXk40NjEyMzM2Nl5ONF5ONDY5NDQ1NzBeTjVeTjQzMDY0NTM5Xk42Xk4zOTYyNDYwNV5ON15OMzg0MDUzMTZeTjheTjQ3Nzc1Mjg3Xk45Xk40ODg1NjAyNV5OMTBeTjQxMjg3NTE1Xk4xMV5OMzIxODc0ODdeTjEyXk4yNjAxODIzOV5OMTNeTjE5MDk3NTc5Xk4xNF5OMjk1NzcwOTFeTjE1Xk4zNTY4NjE2NF5OMTZeTjIyODk2MzQ1Xk4xN15OMjIwNzU5MjNeTjE4Xk4yOTc5NDUzMV5OMTleTjI4ODkzNzA1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5OMF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNSZWZ1bGdlbnR+YENvcHBlcl5TUm91dGVab25lXk4yNDM3XlNSb3V0ZUtleV5TUmVmdWxnZW50/0NvcHBlcl50Xl4="
        ),
        SuppliedMiningRoute(
            "midnight-refulgent-copper-ore-2405-3-supplied", 3, 2405, "Voidstorm",
            "Alternative - dense node circuit - Voidstorm",
            {
                35636525, 31616442, 32746248, 33776160, 36946082, 39815932, 41555858, 41555855,
                42405614, 45265360, 46205192, 46934975, 51094592, 51844470, 54614558, 55174610,
                56824824, 57694935, 59265025, 59315264, 59315740, 59285742, 59366240, 61116851,
                59507040, 55997362, 51987451, 50767648, 49677813, 47408304, 46868132, 45647979,
                43997886, 42148052, 40578051, 38208077, 36128237, 34907426, 35177255, 36806897,
                37616698,
            },
            {
                "Use only after campaign access; this has many deposits but substantial enemy/terrain interference.",
                "Do not take a Voidbound overload portal without return-portal specialization.",
                "Compare nodes gathered per 10 minutes against the safer Eversong circuit.",
            },
            "https://www.williamlong.info/archives/7540.html",
            "Retail:Routes:Refulgent Copper:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzU2MzY1MjVeTjJeTjMxNjE2NDQyXk4zXk4zMjc0NjI0OF5ONF5OMzM3NzYxNjBeTjVeTjM2OTQ2MDgyXk42Xk4zOTgxNTkzMl5ON15ONDE1NTU4NTheTjheTjQxNTU1ODU1Xk45Xk40MjQwNTYxNF5OMTBeTjQ1MjY1MzYwXk4xMV5ONDYyMDUxOTJeTjEyXk40NjkzNDk3NV5OMTNeTjUxMDk0NTkyXk4xNF5ONTE4NDQ0NzBeTjE1Xk41NDYxNDU1OF5OMTZeTjU1MTc0NjEwXk4xN15ONTY4MjQ4MjReTjE4Xk41NzY5NDkzNV5OMTleTjU5MjY1MDI1Xk4yMF5ONTkzMTUyNjReTjIxXk41OTMxNTc0MF5OMjJeTjU5Mjg1NzQyXk4yM15ONTkzNjYyNDBeTjI0Xk42MTExNjg1MV5OMjVeTjU5NTA3MDQwXk4yNl5ONTU5OTczNjJeTjI3Xk41MTk4NzQ1MV5OMjheTjUwNzY3NjQ4Xk4yOV5ONDk2Nzc4MTNeTjMwXk40NzQwODMwNF5OMzFeTjQ2ODY4MTMyXk4zMl5ONDU2NDc5NzleTjMzXk40Mzk5Nzg4Nl5OMzReTjQyMTQ4MDUyXk4zNV5ONDA1NzgwNTFeTjM2Xk4zODIwODA3N15OMzdeTjM2MTI4MjM3Xk4zOF5OMzQ5MDc0MjZeTjM5Xk4zNTE3NzI1NV5ONDBeTjM2ODA2ODk3Xk40MV5OMzc2MTY2OThedF5TbG9vcGVkXk4xXlNoaWRkZW5eYl5Tc2VsZWN0aW9uXlRedF5TdGFib29zXlRedF5TbGVuZ3RoXk4wXlN0YWJvb2xpc3ReVF50XlNkYl90eXBlXlRedF50XlNSb3V0ZU5hbWVeU1JlZnVsZ2VudH5gQ29wcGVyXlNSb3V0ZVpvbmVeTjI0MDVeU1JvdXRlS2V5XlNSZWZ1bGdlbnT/Q29wcGVyXnReXg=="
        ),
    },
    ["Umbral Tin Ore"] = {
        SuppliedMiningRoute(
            "midnight-umbral-tin-ore-2437-1-supplied", 1, 2437, "Zul'Aman",
            "Main - perimeter loop - Zul'Aman",
            {
                30492846, 38182519, 46123366, 46944570, 43064539, 39624605, 38405316, 47775287,
                48856025, 41287515, 32187487, 26018239, 19097579, 29577091, 35686164, 22896345,
                22075923, 29794531, 28893705,
            },
            {
                "Stay near the perimeter, including the southern shore, and mine all base ore types while tracking Tin yield.",
                "Wild node oreling spawns are extra mineable ore sources after combat.",
                "A Reddit farming report describes perimeter laps as consistent, but not tin-only.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Umbral Tin Ore:Zul'Aman:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzA0OTI4NDZeTjJeTjM4MTgyNTE5Xk4zXk40NjEyMzM2Nl5ONF5ONDY5NDQ1NzBeTjVeTjQzMDY0NTM5Xk42Xk4zOTYyNDYwNV5ON15OMzg0MDUzMTZeTjheTjQ3Nzc1Mjg3Xk45Xk40ODg1NjAyNV5OMTBeTjQxMjg3NTE1Xk4xMV5OMzIxODc0ODdeTjEyXk4yNjAxODIzOV5OMTNeTjE5MDk3NTc5Xk4xNF5OMjk1NzcwOTFeTjE1Xk4zNTY4NjE2NF5OMTZeTjIyODk2MzQ1Xk4xN15OMjIwNzU5MjNeTjE4Xk4yOTc5NDUzMV5OMTleTjI4ODkzNzA1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5OMF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNVbWJyYWx+YFRpbn5gT3JlXlNSb3V0ZVpvbmVeTjI0MzdeU1JvdXRlS2V5XlNVbWJyYWz/VGlu/09yZV50Xl4="
        ),
        SuppliedMiningRoute(
            "midnight-umbral-tin-ore-2405-2-supplied", 2, 2405, "Voidstorm",
            "Alternative - wide Voidstorm route - Voidstorm",
            {
                44642291, 47592551, 50913039, 53482809, 58702693, 61813139, 61223829, 59664048,
                56364201, 53444044, 50514181, 49104607, 45786006, 52786541, 58726211, 63015582,
                65455862, 63206103, 63846423, 55777194, 62907586, 62848099, 58828593, 55288081,
                53157439, 49778046, 39098051, 36047697, 28627390, 33696657, 28896324, 25385387,
                30785357, 31284771, 35064963, 38735073, 37384320, 36494025, 41053624, 39623423,
                38852861, 41262339,
            },
            {
                "Voidstorm has plentiful deposits; fly at ridge height to identify mining nodes on ledges.",
                "Voidbound Overload grants additional materials and void motes.",
                "Without the Voidbound specialization, the overload portal may transport you far away.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Umbral Tin Ore:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDIyOTFeTjJeTjQ3NTkyNTUxXk4zXk41MDkxMzAzOV5ONF5ONTM0ODI4MDleTjVeTjU4NzAyNjkzXk42Xk42MTgxMzEzOV5ON15ONjEyMjM4MjleTjheTjU5NjY0MDQ4Xk45Xk41NjM2NDIwMV5OMTBeTjUzNDQ0MDQ0Xk4xMV5ONTA1MTQxODFeTjEyXk40OTEwNDYwN15OMTNeTjQ1Nzg2MDA2Xk4xNF5ONTI3ODY1NDFeTjE1Xk41ODcyNjIxMV5OMTZeTjYzMDE1NTgyXk4xN15ONjU0NTU4NjJeTjE4Xk42MzIwNjEwM15OMTleTjYzODQ2NDIzXk4yMF5ONTU3NzcxOTReTjIxXk42MjkwNzU4Nl5OMjJeTjYyODQ4MDk5Xk4yM15ONTg4Mjg1OTNeTjI0Xk41NTI4ODA4MV5OMjVeTjUzMTU3NDM5Xk4yNl5ONDk3NzgwNDZeTjI3Xk4zOTA5ODA1MV5OMjheTjM2MDQ3Njk3Xk4yOV5OMjg2MjczOTBeTjMwXk4zMzY5NjY1N15OMzFeTjI4ODk2MzI0Xk4zMl5OMjUzODUzODdeTjMzXk4zMDc4NTM1N15OMzReTjMxMjg0NzcxXk4zNV5OMzUwNjQ5NjNeTjM2Xk4zODczNTA3M15OMzdeTjM3Mzg0MzIwXk4zOF5OMzY0OTQwMjVeTjM5Xk40MTA1MzYyNF5ONDBeTjM5NjIzNDIzXk40MV5OMzg4NTI4NjFeTjQyXk40MTI2MjMzOV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TVW1icmFsfmBUaW5+YE9yZV5TUm91dGVab25lXk4yNDA1XlNSb3V0ZUtleV5TVW1icmFs/1Rpbv9PcmVedF5e"
        ),
        SuppliedMiningRoute(
            "midnight-umbral-tin-ore-2413-3-supplied", 3, 2413, "Harandar",
            "Niche - low traffic Harandar loop - Harandar",
            {
                36262608, 41422315, 53002461, 56243113, 60933179, 65522688, 70783470, 60463717,
                55374127, 53594841, 59724246, 63674188, 70364579, 75385083, 72465384, 68235652,
                70866008, 74156576, 70716929, 68476662, 64986007, 59095662, 54296245, 51617616,
                41707362, 35587468, 34357835, 36378186, 33138642, 26507888, 38735684, 38255028,
                33754780, 33684239, 40564661, 39933431,
            },
            {
                "Use as a lower-competition experiment, not a high-yield default; Method found the zone relatively poor for ore.",
                "Follow outer edges but check ground-level rock faces under large vegetation.",
                "Primal deposits slow the miner; Druid shapeshifting can clear the debuff.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Umbral Tin Ore:Harandar:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzYyNjI2MDheTjJeTjQxNDIyMzE1Xk4zXk41MzAwMjQ2MV5ONF5ONTYyNDMxMTNeTjVeTjYwOTMzMTc5Xk42Xk42NTUyMjY4OF5ON15ONzA3ODM0NzBeTjheTjYwNDYzNzE3Xk45Xk41NTM3NDEyN15OMTBeTjUzNTk0ODQxXk4xMV5ONTk3MjQyNDZeTjEyXk42MzY3NDE4OF5OMTNeTjcwMzY0NTc5Xk4xNF5ONzUzODUwODNeTjE1Xk43MjQ2NTM4NF5OMTZeTjY4MjM1NjUyXk4xN15ONzA4NjYwMDheTjE4Xk43NDE1NjU3Nl5OMTleTjcwNzE2OTI5Xk4yMF5ONjg0NzY2NjJeTjIxXk42NDk4NjAwN15OMjJeTjU5MDk1NjYyXk4yM15ONTQyOTYyNDVeTjI0Xk41MTYxNzYxNl5OMjVeTjQxNzA3MzYyXk4yNl5OMzU1ODc0NjheTjI3Xk4zNDM1NzgzNV5OMjheTjM2Mzc4MTg2Xk4yOV5OMzMxMzg2NDJeTjMwXk4yNjUwNzg4OF5OMzFeTjM4NzM1Njg0Xk4zMl5OMzgyNTUwMjheTjMzXk4zMzc1NDc4MF5OMzReTjMzNjg0MjM5Xk4zNV5ONDA1NjQ2NjFeTjM2Xk4zOTkzMzQzMV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TVW1icmFsfmBUaW5+YE9yZV5TUm91dGVab25lXk4yNDEzXlNSb3V0ZUtleV5TVW1icmFs/1Rpbv9PcmVedF5e"
        ),
    },
    ["Brilliant Silver Ore"] = {
        SuppliedMiningRoute(
            "midnight-brilliant-silver-ore-2405-1-supplied", 1, 2405, "Voidstorm",
            "Main - broader mixed-deposit circuit - Voidstorm",
            {
                35636525, 31616442, 32746248, 33776160, 36946082, 39815932, 41555858, 41555855,
                42405614, 45265360, 46205192, 46934975, 51094592, 51844470, 54614558, 55174610,
                56824824, 57694935, 59265025, 59315264, 59315740, 59285742, 59366240, 61116851,
                59507040, 55997362, 51987451, 50767648, 49677813, 47408304, 46868132, 45647979,
                43997886, 42148052, 40578051, 38208077, 36128237, 34907426, 35177255, 36806897,
                37616698,
            },
            {
                "Prioritize Rich Brilliant Silver and Silver Seams when encountered, but do not expect silver-only spawns.",
                "Voidstorm is ore-rich, yet cliff navigation and hostile mobs can reduce effective gathers per hour.",
                "High Perception helps rare Thorium procs from the same route.",
            },
            "https://www.williamlong.info/archives/7540.html",
            "Retail:Routes:Brilliant Silver Ore:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzU2MzY1MjVeTjJeTjMxNjE2NDQyXk4zXk4zMjc0NjI0OF5ONF5OMzM3NzYxNjBeTjVeTjM2OTQ2MDgyXk42Xk4zOTgxNTkzMl5ON15ONDE1NTU4NTheTjheTjQxNTU1ODU1Xk45Xk40MjQwNTYxNF5OMTBeTjQ1MjY1MzYwXk4xMV5ONDYyMDUxOTJeTjEyXk40NjkzNDk3NV5OMTNeTjUxMDk0NTkyXk4xNF5ONTE4NDQ0NzBeTjE1Xk41NDYxNDU1OF5OMTZeTjU1MTc0NjEwXk4xN15ONTY4MjQ4MjReTjE4Xk41NzY5NDkzNV5OMTleTjU5MjY1MDI1Xk4yMF5ONTkzMTUyNjReTjIxXk41OTMxNTc0MF5OMjJeTjU5Mjg1NzQyXk4yM15ONTkzNjYyNDBeTjI0Xk42MTExNjg1MV5OMjVeTjU5NTA3MDQwXk4yNl5ONTU5OTczNjJeTjI3Xk41MTk4NzQ1MV5OMjheTjUwNzY3NjQ4Xk4yOV5ONDk2Nzc4MTNeTjMwXk40NzQwODMwNF5OMzFeTjQ2ODY4MTMyXk4zMl5ONDU2NDc5NzleTjMzXk40Mzk5Nzg4Nl5OMzReTjQyMTQ4MDUyXk4zNV5ONDA1NzgwNTFeTjM2Xk4zODIwODA3N15OMzdeTjM2MTI4MjM3Xk4zOF5OMzQ5MDc0MjZeTjM5Xk4zNTE3NzI1NV5ONDBeTjM2ODA2ODk3Xk40MV5OMzc2MTY2OThedF5TbG9vcGVkXk4xXlNoaWRkZW5eYl5Tc2VsZWN0aW9uXlRedF5TdGFib29zXlRedF5TbGVuZ3RoXk4wXlN0YWJvb2xpc3ReVF50XlNkYl90eXBlXlRedF50XlNSb3V0ZU5hbWVeU0JyaWxsaWFudH5gU2lsdmVyfmBPcmVeU1JvdXRlWm9uZV5OMjQwNV5TUm91dGVLZXleU0JyaWxsaWFudP9TaWx2ZXL/T3JlXnReXg=="
        ),
        SuppliedMiningRoute(
            "midnight-brilliant-silver-ore-2437-2-supplied", 2, 2437, "Zul'Aman",
            "Alternative - long perimeter loop - Zul'Aman",
            {
                30824643, 27873941, 28333700, 31813429, 34513062, 36052811, 39832702, 42763082,
                45433591, 48063755, 47694209, 44724843, 46325889, 48646478, 48656954, 48187157,
                43617865, 42197793, 37878021, 34298290, 31727980, 31117355, 32686630, 31856279,
            },
            {
                "Keep close to the southern coast where deposit density was independently reported strong.",
                "Take Rich Silver and Silver Seams where safe, along with other ore to avoid time-consuming detours.",
                "Wild orelings are especially valuable when their mineable loot yields more ore.",
            },
            "https://www.williamlong.info/archives/7540.html",
            "Retail:Routes:Brilliant Silver Ore:Zul'Aman:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzA4MjQ2NDNeTjJeTjI3ODczOTQxXk4zXk4yODMzMzcwMF5ONF5OMzE4MTM0MjleTjVeTjM0NTEzMDYyXk42Xk4zNjA1MjgxMV5ON15OMzk4MzI3MDJeTjheTjQyNzYzMDgyXk45Xk40NTQzMzU5MV5OMTBeTjQ4MDYzNzU1Xk4xMV5ONDc2OTQyMDleTjEyXk40NDcyNDg0M15OMTNeTjQ2MzI1ODg5Xk4xNF5ONDg2NDY0NzheTjE1Xk40ODY1Njk1NF5OMTZeTjQ4MTg3MTU3Xk4xN15ONDM2MTc4NjVeTjE4Xk40MjE5Nzc5M15OMTleTjM3ODc4MDIxXk4yMF5OMzQyOTgyOTBeTjIxXk4zMTcyNzk4MF5OMjJeTjMxMTE3MzU1Xk4yM15OMzI2ODY2MzBeTjI0Xk4zMTg1NjI3OV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TQnJpbGxpYW50fmBTaWx2ZXJ+YE9yZV5TUm91dGVab25lXk4yNDM3XlNSb3V0ZUtleV5TQnJpbGxpYW50/1NpbHZlcv9PcmVedF5e"
        ),
        SuppliedMiningRoute(
            "midnight-brilliant-silver-ore-2395-3-supplied", 3, 2395, "Eversong Woods",
            "Alternative - shorter low-level circuit - Eversong Woods",
            {
                44643335, 50653657, 62283586, 60163940, 56184164, 62274553, 61486458, 53498125,
                47367896, 45698787, 40598631, 41957460, 38816646, 37905929, 39345626, 42775813,
                43116245, 45666368, 47195981, 46305650, 43405385, 39165277, 40244694, 43023994,
                42673465,
            },
            {
                "Shorter multi-node farm to reduce travel and dangerous terrain.",
                "Mine all deposit variants, not only visible normal Brilliant Silver.",
                "Lightfused nodes additionally yield Motes of Light.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Brilliant Silver Ore:Eversong Woods:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDMzMzVeTjJeTjUwNjUzNjU3Xk4zXk42MjI4MzU4Nl5ONF5ONjAxNjM5NDBeTjVeTjU2MTg0MTY0Xk42Xk42MjI3NDU1M15ON15ONjE0ODY0NTheTjheTjUzNDk4MTI1Xk45Xk40NzM2Nzg5Nl5OMTBeTjQ1Njk4Nzg3Xk4xMV5ONDA1OTg2MzFeTjEyXk40MTk1NzQ2MF5OMTNeTjM4ODE2NjQ2Xk4xNF5OMzc5MDU5MjleTjE1Xk4zOTM0NTYyNl5OMTZeTjQyNzc1ODEzXk4xN15ONDMxMTYyNDVeTjE4Xk40NTY2NjM2OF5OMTleTjQ3MTk1OTgxXk4yMF5ONDYzMDU2NTBeTjIxXk40MzQwNTM4NV5OMjJeTjM5MTY1Mjc3Xk4yM15ONDAyNDQ2OTReTjI0Xk40MzAyMzk5NF5OMjVeTjQyNjczNDY1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5OMF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNCcmlsbGlhbnR+YFNpbHZlcn5gT3JlXlNSb3V0ZVpvbmVeTjIzOTVeU1JvdXRlS2V5XlNCcmlsbGlhbnT/U2lsdmVy/09yZV50Xl4="
        ),
    },
    ["Dazzling Thorium"] = {
        SuppliedMiningRoute(
            "midnight-dazzling-thorium-2437-1-supplied", 1, 2437, "Zul'Aman",
            "Main - broad base-node circuit - Zul'Aman",
            {
                30824643, 27873941, 28333700, 31813429, 34513062, 36052811, 39832702, 42763082,
                45433591, 48063755, 47694209, 44724843, 46325889, 48646478, 48656954, 48187157,
                43617865, 42197793, 37878021, 34298290, 31727980, 31117355, 32686630, 31856279,
            },
            {
                "There is no Dazzling Thorium deposit: mine Copper, Tin, and Silver nodes for rare Thorium procs.",
                "Focus on node interactions per hour; do not spend extra time searching for nonexistent Thorium icons.",
                "Aim for the 40-point ore-type mining specialization bonus that yields more Thorium.",
            },
            "https://www.williamlong.info/archives/7540.html",
            "Retail:Routes:Dazzling Thorium:Zul'Aman:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5OMzA4MjQ2NDNeTjJeTjI3ODczOTQxXk4zXk4yODMzMzcwMF5ONF5OMzE4MTM0MjleTjVeTjM0NTEzMDYyXk42Xk4zNjA1MjgxMV5ON15OMzk4MzI3MDJeTjheTjQyNzYzMDgyXk45Xk40NTQzMzU5MV5OMTBeTjQ4MDYzNzU1Xk4xMV5ONDc2OTQyMDleTjEyXk40NDcyNDg0M15OMTNeTjQ2MzI1ODg5Xk4xNF5ONDg2NDY0NzheTjE1Xk40ODY1Njk1NF5OMTZeTjQ4MTg3MTU3Xk4xN15ONDM2MTc4NjVeTjE4Xk40MjE5Nzc5M15OMTleTjM3ODc4MDIxXk4yMF5OMzQyOTgyOTBeTjIxXk4zMTcyNzk4MF5OMjJeTjMxMTE3MzU1Xk4yM15OMzI2ODY2MzBeTjI0Xk4zMTg1NjI3OV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TRGF6emxpbmd+YFRob3JpdW1eU1JvdXRlWm9uZV5OMjQzN15TUm91dGVLZXleU0RhenpsaW5n/1Rob3JpdW1edF5e"
        ),
        SuppliedMiningRoute(
            "midnight-dazzling-thorium-2405-2-supplied", 2, 2405, "Voidstorm",
            "Alternative - dense Voidstorm base nodes - Voidstorm",
            {
                44642291, 47592551, 50913039, 53482809, 58702693, 61813139, 61223829, 59664048,
                56364201, 53444044, 50514181, 49104607, 45786006, 52786541, 58726211, 63015582,
                65455862, 63206103, 63846423, 55777194, 62907586, 62848099, 58828593, 55288081,
                53157439, 49778046, 39098051, 36047697, 28627390, 33696657, 28896324, 25385387,
                30785357, 31284771, 35064963, 38735073, 37384320, 36494025, 41053624, 39623423,
                38852861, 41262339,
            },
            {
                "Dense node population gives frequent chances for rare Thorium, though combat and ledges may slow laps.",
                "Use Perception gear or relevant mining bonuses; individual Thorium drops are not guaranteed.",
                "Voidbound special nodes can provide valuable side materials.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Dazzling Thorium:Voidstorm:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDIyOTFeTjJeTjQ3NTkyNTUxXk4zXk41MDkxMzAzOV5ONF5ONTM0ODI4MDleTjVeTjU4NzAyNjkzXk42Xk42MTgxMzEzOV5ON15ONjEyMjM4MjleTjheTjU5NjY0MDQ4Xk45Xk41NjM2NDIwMV5OMTBeTjUzNDQ0MDQ0Xk4xMV5ONTA1MTQxODFeTjEyXk40OTEwNDYwN15OMTNeTjQ1Nzg2MDA2Xk4xNF5ONTI3ODY1NDFeTjE1Xk41ODcyNjIxMV5OMTZeTjYzMDE1NTgyXk4xN15ONjU0NTU4NjJeTjE4Xk42MzIwNjEwM15OMTleTjYzODQ2NDIzXk4yMF5ONTU3NzcxOTReTjIxXk42MjkwNzU4Nl5OMjJeTjYyODQ4MDk5Xk4yM15ONTg4Mjg1OTNeTjI0Xk41NTI4ODA4MV5OMjVeTjUzMTU3NDM5Xk4yNl5ONDk3NzgwNDZeTjI3Xk4zOTA5ODA1MV5OMjheTjM2MDQ3Njk3Xk4yOV5OMjg2MjczOTBeTjMwXk4zMzY5NjY1N15OMzFeTjI4ODk2MzI0Xk4zMl5OMjUzODUzODdeTjMzXk4zMDc4NTM1N15OMzReTjMxMjg0NzcxXk4zNV5OMzUwNjQ5NjNeTjM2Xk4zODczNTA3M15OMzdeTjM3Mzg0MzIwXk4zOF5OMzY0OTQwMjVeTjM5Xk40MTA1MzYyNF5ONDBeTjM5NjIzNDIzXk40MV5OMzg4NTI4NjFeTjQyXk40MTI2MjMzOV50XlNsb29wZWReTjFeU2hpZGRlbl5iXlNzZWxlY3Rpb25eVF50XlN0YWJvb3NeVF50XlNsZW5ndGheTjBeU3RhYm9vbGlzdF5UXnReU2RiX3R5cGVeVF50XnReU1JvdXRlTmFtZV5TRGF6emxpbmd+YFRob3JpdW1eU1JvdXRlWm9uZV5OMjQwNV5TUm91dGVLZXleU0RhenpsaW5n/1Rob3JpdW1edF5e"
        ),
        SuppliedMiningRoute(
            "midnight-dazzling-thorium-2395-3-supplied", 3, 2395, "Eversong Woods",
            "Alternative - easy fast repeat - Eversong Woods",
            {
                44643335, 50653657, 62283586, 60163940, 56184164, 62274553, 61486458, 53498125,
                47367896, 45698787, 40598631, 41957460, 38816646, 37905929, 39345626, 42775813,
                43116245, 45666368, 47195981, 46305650, 43405385, 39165277, 40244694, 43023994,
                42673465,
            },
            {
                "This faster, shorter xScarlife loop can be better when Voidstorm travel/mob time is high.",
                "Mine all Rich, normal, infused, and Seam nodes and prioritize gathering frequency.",
                "Lightfused motes can add value while targeting rare drops.",
            },
            "https://xscarlife-gaming.com/farming/retail/",
            "Retail:Routes:Dazzling Thorium:Eversong Woods:XjFeVF5TUm91dGVEYXRhXlReU3Zpc2libGVeQl5Tcm91dGVeVF5OMV5ONDQ2NDMzMzVeTjJeTjUwNjUzNjU3Xk4zXk42MjI4MzU4Nl5ONF5ONjAxNjM5NDBeTjVeTjU2MTg0MTY0Xk42Xk42MjI3NDU1M15ON15ONjE0ODY0NTheTjheTjUzNDk4MTI1Xk45Xk40NzM2Nzg5Nl5OMTBeTjQ1Njk4Nzg3Xk4xMV5ONDA1OTg2MzFeTjEyXk40MTk1NzQ2MF5OMTNeTjM4ODE2NjQ2Xk4xNF5OMzc5MDU5MjleTjE1Xk4zOTM0NTYyNl5OMTZeTjQyNzc1ODEzXk4xN15ONDMxMTYyNDVeTjE4Xk40NTY2NjM2OF5OMTleTjQ3MTk1OTgxXk4yMF5ONDYzMDU2NTBeTjIxXk40MzQwNTM4NV5OMjJeTjM5MTY1Mjc3Xk4yM15ONDAyNDQ2OTReTjI0Xk40MzAyMzk5NF5OMjVeTjQyNjczNDY1XnReU2xvb3BlZF5OMV5TaGlkZGVuXmJeU3NlbGVjdGlvbl5UXnReU3RhYm9vc15UXnReU2xlbmd0aF5OMF5TdGFib29saXN0XlRedF5TZGJfdHlwZV5UXnRedF5TUm91dGVOYW1lXlNEYXp6bGluZ35gVGhvcml1bV5TUm91dGVab25lXk4yMzk1XlNSb3V0ZUtleV5TRGF6emxpbmf/VGhvcml1bV50Xl4="
        ),
    },
}

local function RegisterOre(item)
    -- Own the list so later per-item catalog additions stay within the intended ore/rank.
    local spots = {}
    for _, spot in ipairs(SUPPLIED_MINING_ROUTES[item.itemName] or {}) do
        spots[#spots + 1] = spot
    end
    for _, spot in ipairs(item.spots or {}) do
        spots[#spots + 1] = spot
    end
    item.spots = spots
    item.isRoute = true
    Register(item)
end

RegisterOre(H.BuildMidnightItem(
    237359,
    "Refulgent Copper Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237359/refulgent-copper-ore",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
        "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
    },
    "Common Midnight ore gathered from Refulgent Copper nodes and seams. Mine all node variants because rich, seam, and infused versions change both yield and skill gains.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

RegisterOre(H.BuildMidnightItem(
    237361,
    "Refulgent Copper Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237361/refulgent-copper-ore",
        "https://www.wowdb.com/items/237361-refulgent-copper-ore",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
    },
    "High-quality Refulgent Copper Ore. The same node routes apply, with better results from skill, Finesse, and route uptime.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

RegisterOre(H.BuildMidnightItem(
    237362,
    "Umbral Tin Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237362/umbral-tin-ore",
        "https://warcraft.wiki.gg/wiki/Umbral_Tin",
        "https://www.wowdb.com/spells/1225366-umbral-tin-seam",
    },
    "Midnight ore found across the new zones, with seams favoring caves and underground spaces. Useful to route through darker or enclosed areas.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

RegisterOre(H.BuildMidnightItem(
    237363,
    "Umbral Tin Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237363/umbral-tin-ore",
        "https://warcraft.wiki.gg/wiki/Umbral_Tin",
        "https://www.wowdb.com/spells/1225366-umbral-tin-seam",
    },
    "High-quality Umbral Tin Ore. Underground and cave-heavy routes are useful because Umbral Tin seams are associated with those spaces.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

RegisterOre(H.BuildMidnightItem(
    237364,
    "Brilliant Silver Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237364/brilliant-silver-ore",
        "https://www.wowhead.com/object=523298/brilliant-silver-seam",
        "https://www.wow-professions.com/guides/wow-mining-leveling-guide",
    },
    "Less common Midnight ore gathered from Brilliant Silver nodes and seams. Prioritize full loops over camping because replacement node rolls matter.",
    H.MIDNIGHT_MINING_SPOTS,
    1
))

RegisterOre(H.BuildMidnightItem(
    237365,
    "Brilliant Silver Ore",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237365/brilliant-silver-ore",
        "https://www.wowdb.com/items/237365-brilliant-silver-ore",
        "https://www.wowhead.com/object=523298/brilliant-silver-seam",
    },
    "High-quality Brilliant Silver Ore. Better route uptime and mining skill are more reliable than waiting on a single node cluster.",
    H.MIDNIGHT_MINING_SPOTS,
    2
))

RegisterOre(H.BuildMidnightItem(
    237366,
    "Dazzling Thorium",
    { "mining" },
    "Ore",
    {
        "https://www.wowhead.com/item=237366/dazzling-thorium",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
    },
    "Rare mining side gather from Midnight ore nodes. Perception can increase bonus quantity when it appears, but does not make base ore routes unnecessary.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236949,
    "Mote of Light",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236949/mote-of-light",
        "https://www.wowhead.com/guide/midnight/professions/mining-overview-trainer-locations-ores-tools",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
    },
    "Lightfused node and herb side material. Eversong is the primary route because Lightfused nodes are concentrated there.",
    H.MIDNIGHT_HERB_SPOTS
))

Register(H.BuildMidnightItem(
    236950,
    "Mote of Primal Energy",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236950/mote-of-primal-energy",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Primal-infused node and herb side material. Harandar is the cleanest target zone.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236951,
    "Mote of Wild Magic",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236951/mote-of-wild-magic",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Wild-infused node and herb side material. Zul'Aman is the main target zone.",
    H.MIDNIGHT_MINING_SPOTS
))

Register(H.BuildMidnightItem(
    236952,
    "Mote of Pure Void",
    { "mining", "herbalism", "alchemy", "skinning" },
    "Elemental",
    {
        "https://www.wowhead.com/item=236952/mote-of-pure-void",
        "https://www.wow-professions.com/guides/wow-herbalism-leveling-guide",
        "https://www.method.gg/guides/midnight-ore-and-mote-farming-route",
    },
    "Voidbound node and herb side material. Voidstorm is the main target zone.",
    H.MIDNIGHT_MINING_SPOTS
))
