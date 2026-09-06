

### Materials research

Redo/expand material farming spots for [EXPANSION] using the strict coordinate-backed research standard.

Requirements:
- Use every relevant raw/directly farmable material from Data/FarmingItems.lua for this expansion.
- Ignore composed/crafted-only materials unless I explicitly ask for them.
- Every researched item must have at least one farming spot.
- Every farming spot must have coords.
- For narrow drops, open the actual source NPC/object pages and use map-pin coordinate clusters.
- For broad drops, do not list every possible source; use confirmed dense farming spots from guides/comments/NPC pins.
- Read Wowhead item/object/NPC pages, Wowhead comments where accessible, wow-professions, WoWDB/evowow, Warcraft Wiki, and other farming guides.
- Store only researched entries; anything not properly researched should remain missing/pending.
- Add/update tests so this expansion cannot regress to empty coords or fake fallback data.
- At the end, give me the pending/missing item IDs and explain why.
- IMPORTANT: USE ONLY RETAIL DATA, WE ARE NOT INTERESTED IN CLASSIC DATA FROM CLASSIC VERSIONS OF WEBSITES (like wowhead classic, or wowhead classic the burning crusage, wrath of the lich king, caraclism, or mists of pandaria)
- - redo all the searching indexing and exploring from a retail perspective
- IMPORTANT: try to find more crafing materials that we are missing
- IMPORTANT: FOR MINING AND HERBALISM, TRY TO FIND AND SAVE/STORE FARMING ROUTES, YOU CAN USE HERE A MORE DENSE COLLECTION OF COORDS. WE CAN LATER USE THIS TO RECONSTRUCT A ROUTE IN OUR ADDON.
- DO THIS IN THE PERSPECTIVE THAT THIS DATA WILL LATER BE EXPOSED IN OUR OWN MAP STYLE WINDOW
- THIS IS A SECOND PASS ALSO, IN THE SENSE THAT WE AIM TO FIND MORE MATERIALS AND TO REFINE THE LOCATIONS, TIPS, TRICKS, AND FARMING DETAILS
- Also I have found a new reference site: "A helpful source popped up: Artisans of Azeroth publishes Routes import strings, and those embed actual coordinate pairs. I’m extracting only a small set of pins from those strings for route loops, then cross-checking the target material/source against Wowhead/wow-professions text."
- - Only use it for retail data, and not as the single source of truth for data, use it along side the other sites.
- Also I want to note that classic versions of farming sites is relevant and can be used, but you should first try to find data that is from retail sites, because i am farming in retail version
- However yes, i can agree that, say spawn points for mineral nodes and  specific trash mobs does not change between classic version and retail version
- - I guess what i want to say is that you can use both for getting data, retail vesions and classic version, as well as "classic" data. What i mean by classic here is not the acctual classic/vanilla base game from 2004, but rather the classic versions of expanssions like classic tbc, classic wrath, classic cataclism, classic mists of pandaria
- include prospecting as well along side fishing, cooking

Expansion: 