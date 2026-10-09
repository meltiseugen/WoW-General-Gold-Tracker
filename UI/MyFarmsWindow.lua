local _, NS = ...
local GoldTracker = NS.GoldTracker
local Theme = NS.JanisTheme

local WINDOW_WIDTH = 1080
local WINDOW_HEIGHT = 620
local WINDOW_MIN_WIDTH = 900
local WINDOW_MIN_HEIGHT = 480
local WINDOW_MAX_WIDTH = 1440
local WINDOW_MAX_HEIGHT = 920
local FARM_LIST_WIDTH = 300
local FARM_ROW_HEIGHT = 54
local FARM_ROW_GAP = 4
local STEP_ROW_HEIGHT = 52
local STEP_ROW_GAP = 3
local ENTRY_ROW_HEIGHT = 38
local ENTRY_ROW_GAP = 3
local SUGGESTION_HEADER_HEIGHT = 24
local SUGGESTION_ROW_HEIGHT = 36
local SUGGESTION_LIMIT = 5
local CATALOG_ROW_HEIGHT = 36
local CATALOG_ROW_GAP = 2
local CATALOG_GROUP_ROW_HEIGHT = 30
local CATALOG_ITEM_ROW_HEIGHT = 30
local CATALOG_ITEM_ROW_GAP = 1
local CATALOG_DETAILS_WIDTH = 68
local CATALOG_QUANTITY_WIDTH = 82
local CATALOG_UNIT_VALUE_WIDTH = 126
local CATALOG_TOTAL_VALUE_WIDTH = 144
local CATALOG_LOCATION_WIDTH = 190
local CATALOG_EXPANDED_WIDTH = 1320
local CATALOG_EXPANDED_HEIGHT = 780
local CATALOG_EXPANDED_MIN_WIDTH = 920
local CATALOG_EXPANDED_MIN_HEIGHT = 520
local CATALOG_EXPANDED_MAX_WIDTH = 1680
local CATALOG_EXPANDED_MAX_HEIGHT = 1040
local CATALOG_REFRESH_BUDGET_MS = 7
local CATALOG_REFRESH_FALLBACK_BATCH_SIZE = 2
local NEW_DIALOG_KEY = "GGT_NEW_CUSTOM_FARM"
local RENAME_DIALOG_KEY = "GGT_RENAME_CUSTOM_FARM"
local DELETE_DIALOG_KEY = "GGT_DELETE_CUSTOM_FARM"
local REMOVE_ENTRY_DIALOG_KEY = "GGT_REMOVE_CUSTOM_FARM_ENTRY"
local ITEM_ONLY_METHOD = "__item_only"

local FARM_CATALOG_CATEGORIES = {
    {
        id = "gathering",
        label = "Gathering",
        subcategories = {
            { id = "Mining", label = "Mining" },
            { id = "Herb", label = "Herb" },
            { id = "Fishing", label = "Fishing" },
            { id = "Skinning", label = "Skinning" },
            { id = "Cloth", label = "Cloth" },
            { id = "Misc", label = "Misc" },
            { id = "MultiFarms", label = "Multi Farms" },
        },
    },
    {
        id = "instances",
        label = "Instances",
        subcategories = {
            { id = "transmog", label = "Transmog", sourceCategory = "instances" },
            {
                id = "noteworthyItems",
                label = "Noteworthy Items",
                sourceCategory = "openWorldInstances",
            },
        },
    },
}

local FARM_CATALOG_CATEGORY_BY_ID = {}
for _, category in ipairs(FARM_CATALOG_CATEGORIES) do
    FARM_CATALOG_CATEGORY_BY_ID[category.id] = category
end

local function CreatePanel(parent, bg, border)
    return Theme:CreatePanel(parent, bg, border)
end

local function CreateButton(parent, width, height, text, paletteKey)
    return Theme:CreateButton(parent, width, height, text, paletteKey)
end

local function GetDialogEditBox(dialog)
    if not dialog then
        return nil
    end
    if type(dialog.GetEditBox) == "function" then
        return dialog:GetEditBox()
    end
    return dialog.editBox or dialog.EditBox
end

local function FormatTimestamp(timestamp)
    local normalized = tonumber(timestamp)
    if not normalized or normalized <= 0 or type(date) ~= "function" then
        return "Unknown"
    end
    return date("%Y-%m-%d %H:%M", normalized)
end

local function Join(values, emptyText)
    if type(values) ~= "table" or #values == 0 then
        return emptyText or "None"
    end
    return table.concat(values, ", ")
end

local function SyncScrollContentWidth(scrollFrame, content)
    local width = scrollFrame and scrollFrame.GetWidth and scrollFrame:GetWidth() or 0
    if content and content.SetWidth then
        content:SetWidth(math.max(1, width - 2))
    end
end

local function FormatQuantity(value)
    value = tonumber(value) or 0
    if math.floor(value) == value then
        return tostring(math.floor(value))
    end
    return string.format("%.2f", value):gsub("0+$", ""):gsub("%.$", "")
end

local function FormatDuration(seconds)
    seconds = math.max(0, tonumber(seconds) or 0)
    if seconds >= 3600 then
        local hours = seconds / 3600
        return FormatQuantity(hours) .. " hour" .. (hours == 1 and "" or "s")
    end
    if seconds >= 60 then
        local minutes = math.max(1, math.floor((seconds / 60) + 0.5))
        return tostring(minutes) .. " minute" .. (minutes == 1 and "" or "s")
    end
    return "recorded sample"
end

local function GetFarmCatalog()
    return type(NS.FarmCatalog) == "table" and NS.FarmCatalog or { farms = {} }
end

local function GetFarmCatalogEntryByID(farmID)
    local catalog = GetFarmCatalog()
    local position = catalog.byID and tonumber(catalog.byID[farmID])
    if position and catalog.farms and catalog.farms[position] then
        return catalog.farms[position]
    end
    for _, farm in ipairs(catalog.farms or {}) do
        if farm.id == farmID then
            return farm
        end
    end
    return nil
end

local function NormalizeSearchText(value)
    return tostring(value or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function GetCatalogFarmSourceLabel(farm)
    if type(farm) ~= "table" then
        return "Catalog farm"
    end
    return farm.sourcePath or farm.sourceCategory or farm.activity or farm.sourceType or "Catalog farm"
end

local function GetCatalogMapName(farm, index)
    local mapNames = type(farm) == "table" and farm.mapNames or nil
    local label = type(mapNames) == "table" and mapNames[index] or nil
    local mapID = type(farm) == "table" and type(farm.mapIDs) == "table" and tonumber(farm.mapIDs[index]) or nil
    if (type(label) ~= "string" or label == "" or label:match("^Map%s+%d+$")) and mapID
        and C_Map and type(C_Map.GetMapInfo) == "function"
    then
        local mapInfo = C_Map.GetMapInfo(mapID)
        if type(mapInfo) == "table" and type(mapInfo.name) == "string" and mapInfo.name ~= "" then
            label = mapInfo.name
        end
    end
    if type(label) ~= "string" or label == "" or label:match("^Map%s+%d+$") then
        for _, option in ipairs(type(farm) == "table" and farm.mapOptions or {}) do
            if not mapID or tonumber(option.mapID) == mapID then
                local optionLabel = option.mapLabel or option.location
                if type(optionLabel) == "string" and optionLabel ~= "" and not optionLabel:match("^Map%s+%d+$") then
                    return optionLabel
                end
            end
        end
    end
    return type(label) == "string" and label ~= "" and label or nil
end

local function GetCatalogFarmLocationLabel(farm)
    local labels = {}
    local count = math.max(
        type(farm) == "table" and type(farm.mapNames) == "table" and #farm.mapNames or 0,
        type(farm) == "table" and type(farm.mapIDs) == "table" and #farm.mapIDs or 0
    )
    for index = 1, count do
        local label = GetCatalogMapName(farm, index)
        if label then
            labels[#labels + 1] = label
        end
    end
    return Join(labels, "No mapped location")
end

local function GetCatalogFarmLocationGroupLabel(farm)
    return GetCatalogMapName(farm, 1) or "No mapped location"
end

local function CatalogFarmMatchesSearch(farm, searchText)
    searchText = NormalizeSearchText(searchText)
    if searchText == "" then
        return true
    end
    local haystack = table.concat({
        farm and farm.name or "",
        farm and farm.sourcePath or "",
        farm and farm.sourceCategory or "",
        farm and farm.activity or "",
        farm and farm.expansion or "",
        GetCatalogFarmLocationLabel(farm),
    }, " "):lower()
    return haystack:find(searchText, 1, true) ~= nil
end

local function NormalizeFarmCatalogSelection(categoryID, subcategoryID)
    local category = FARM_CATALOG_CATEGORY_BY_ID[tostring(categoryID or "")]
        or FARM_CATALOG_CATEGORIES[1]
    local selectedSubcategory
    for _, option in ipairs(category.subcategories or {}) do
        if option.id == subcategoryID then
            selectedSubcategory = option
            break
        end
    end
    return category, selectedSubcategory or category.subcategories[1]
end

local function EnsureFarmCatalogSelection(addon)
    local category, subcategory = NormalizeFarmCatalogSelection(
        addon.farmCatalogCategoryID,
        addon.farmCatalogSubcategoryID
    )
    addon.farmCatalogCategoryID = category.id
    addon.farmCatalogSubcategoryID = subcategory.id
    return category, subcategory
end

function GoldTracker:GetFarmCatalogCategoryDefinitions()
    return FARM_CATALOG_CATEGORIES
end

function GoldTracker:GetFarmCatalogSubcategoryDefinitions(categoryID)
    local category = FARM_CATALOG_CATEGORY_BY_ID[tostring(categoryID or "")]
        or FARM_CATALOG_CATEGORIES[1]
    return category.subcategories
end

local function IsFarmInCatalogSelection(farm, categoryID, subcategoryID)
    if type(farm) ~= "table" then
        return false
    end

    local category = FARM_CATALOG_CATEGORY_BY_ID[tostring(categoryID or "")]
        or FARM_CATALOG_CATEGORIES[1]
    if category.id == "gathering" then
        if farm.sourceType ~= "gathering" then
            return false
        end
    elseif category.id == "instances" then
        if farm.sourceType ~= "drops" then
            return false
        end
    else
        return false
    end

    if not subcategoryID then
        for _, option in ipairs(category.subcategories or {}) do
            if farm.sourceCategory == (option.sourceCategory or option.id) then
                return true
            end
        end
        return false
    end

    for _, option in ipairs(category.subcategories or {}) do
        if option.id == subcategoryID then
            return farm.sourceCategory == (option.sourceCategory or option.id)
        end
    end
    return false
end

local FARM_CATALOG_EXPANSION_LABELS = {
    classic = "Classic",
    burningcrusade = "The Burning Crusade",
    wrath = "Wrath of the Lich King",
    cataclysm = "Cataclysm",
    mists = "Mists of Pandaria",
    warlords = "Warlords of Draenor",
    legion = "Legion",
    battleforazeroth = "Battle for Azeroth",
    shadowlands = "Shadowlands",
    dragonflight = "Dragonflight",
    warwithin = "The War Within",
    midnight = "Midnight",
    unknown = "Unknown",
}

local function GetFarmCatalogExpansionOptions()
    local options = { { id = "all", label = "All expansions" } }
    local seen = { all = true }
    for _, farm in ipairs(GetFarmCatalog().farms or {}) do
        local expansion = tostring(farm.expansion or "Unknown")
        local id = expansion:lower()
        if not seen[id] then
            seen[id] = true
            options[#options + 1] = { id = id, label = FARM_CATALOG_EXPANSION_LABELS[id] or expansion }
        end
    end
    table.sort(options, function(left, right)
        if left.id == "all" then return true end
        if right.id == "all" then return false end
        return left.label < right.label
    end)
    return options
end

local function NormalizeFarmCatalogExpansionFilter(expansionID)
    local normalized = tostring(expansionID or "all"):lower()
    for _, option in ipairs(GetFarmCatalogExpansionOptions()) do
        if option.id == normalized then
            return normalized
        end
    end
    return "all"
end

function GoldTracker:GetFarmCatalogExpansionOptions()
    return GetFarmCatalogExpansionOptions()
end

function GoldTracker:GetFarmCatalogEntries(searchText, categoryID, subcategoryID, expansionID)
    local entries = {}
    local normalizedExpansionID = NormalizeFarmCatalogExpansionFilter(expansionID)
    for _, farm in ipairs(GetFarmCatalog().farms or {}) do
        if IsFarmInCatalogSelection(farm, categoryID, subcategoryID)
            and (normalizedExpansionID == "all" or tostring(farm.expansion or "Unknown"):lower() == normalizedExpansionID)
            and CatalogFarmMatchesSearch(farm, searchText) then
            entries[#entries + 1] = farm
        end
    end
    table.sort(entries, function(left, right)
        local leftSource = GetCatalogFarmSourceLabel(left):lower()
        local rightSource = GetCatalogFarmSourceLabel(right):lower()
        if leftSource ~= rightSource then
            return leftSource < rightSource
        end
        local leftName = tostring(left.name or left.id or ""):lower()
        local rightName = tostring(right.name or right.id or ""):lower()
        if leftName ~= rightName then
            return leftName < rightName
        end
        return tostring(left.id or "") < tostring(right.id or "")
    end)
    return entries
end

local function GetTargetForItem(farm, itemID)
    for _, target in ipairs(type(farm) == "table" and farm.targets or {}) do
        if tonumber(target.itemID) == tonumber(itemID) then
            return target
        end
    end
    return nil
end

local function GetItemNameSafe(itemID)
    local name
    if type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" then
        name = C_Item.GetItemInfo(itemID)
    elseif type(GetItemInfo) == "function" then
        name = GetItemInfo(itemID)
    end
    if not name and type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function" then
        C_Item.RequestLoadItemDataByID(itemID)
    end
    return name or ("Item " .. tostring(itemID))
end

local function GetItemLinkSafe(itemID)
    local link
    if type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function" then
        local _, itemLink = C_Item.GetItemInfo(itemID)
        link = itemLink
    elseif type(GetItemInfo) == "function" then
        local _, itemLink = GetItemInfo(itemID)
        link = itemLink
    end
    return link
end

local function BuildMethodLabel(farm)
    if type(farm) ~= "table" then
        return "Item only"
    end
    local location = Join(farm.mapNames, nil)
    return location and string.format("%s — %s", farm.name or farm.id, location) or (farm.name or farm.id)
end

local function BuildMapSourceLabel(option)
    return (option.sourceType == "user" and "User discoveries: " or "Static: ")
        .. (option.label or option.mapLabel or ("Map " .. tostring(option.mapID)))
end

local function RefreshMethodDialog(frame)
    local payload = frame.payload
    if type(payload) ~= "table" then
        return
    end
    local entry = payload.entry or {}
    local activeFarm = payload.farmID and GoldTracker:GetCustomFarmByID(payload.farmID) or nil
    if payload.entryID then
        frame.promptText:SetText(string.format(
            "Choose how to farm %s in |cffffd24a%s|r.",
            entry.itemName or ("Item " .. tostring(entry.itemID)),
            activeFarm and activeFarm.name or "custom farm"
        ))
        frame.acceptButton:SetText("Save")
    else
        frame.promptText:SetText(activeFarm
            and string.format("Add %s to |cffffd24a%s|r?", entry.itemName or ("Item " .. tostring(entry.itemID)), activeFarm.name)
            or string.format("Create a new farm and add %s?", entry.itemName or ("Item " .. tostring(entry.itemID))))
        frame.acceptButton:SetText(activeFarm and "Add" or "Create & Add")
    end

    local isMap = frame.selectedDataType == "map"
    frame:SetSize(isMap and 760 or 640, isMap and 660 or 420)
    for dataType, button in pairs(frame.dataTypeButtons) do
        if button.SetSelected then
            button:SetSelected(frame.selectedDataType == dataType)
        end
    end
    frame.methodLabel:SetText("Map source")
    frame.methodDropdown:SetShown(frame.selectedDataType ~= "item")
    frame.methodLabel:SetShown(frame.selectedDataType ~= "item")
    frame.detailPanel:SetShown(not isMap)
    frame.mapPreview:SetShown(isMap)
    frame.acceptButton:SetEnabled(true)
    UIDropDownMenu_SetWidth(frame.methodDropdown, isMap and 684 or 564)
    if isMap then
        local selectedFarm
        if frame.selectedMethodKind == "catalog" then
            for _, farm in ipairs(payload.farms or {}) do
                if farm.id == frame.selectedCatalogFarmID then
                    selectedFarm = farm
                    break
                end
            end
        end
        local option = frame.selectedMethodKind == "map"
            and (payload.mapOptions or {})[frame.selectedMapOptionIndex or 1]
            or nil
        if selectedFarm and type(GoldTracker.BuildFarmDetailsMapOptions) == "function" then
            option = GoldTracker:BuildFarmDetailsMapOptions({ selectedFarm }, entry.itemID)[1]
        end
        local selectedValue = selectedFarm and ("catalog:" .. tostring(selectedFarm.id))
            or (option and ("map:" .. tostring(frame.selectedMapOptionIndex or 1)))
        UIDropDownMenu_SetSelectedValue(frame.methodDropdown, selectedValue)
        UIDropDownMenu_SetText(
            frame.methodDropdown,
            selectedFarm and ("Catalog: " .. BuildMethodLabel(selectedFarm))
                or (option and BuildMapSourceLabel(option) or "No map sources available")
        )
        frame.acceptButton:SetEnabled(selectedFarm ~= nil or option ~= nil)
        if option and frame.previewOption ~= option then
            frame.previewOption = option
            GoldTracker:RefreshFarmingMapPreview(frame.mapPreview, option)
        end
        return
    end
    if frame.selectedDataType == "item" then
        frame.detailText:SetText("This target will stay as an individual item without attached farm or map data.")
        return
    end

end

local function CreateMethodDialog()
    if GoldTracker.customFarmMethodDialog then
        return GoldTracker.customFarmMethodDialog
    end
    local frame = CreateFrame("Frame", "GoldTrackerCustomFarmMethodDialog", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(640, 420)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 60)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:SetScript("OnEvent", function(self)
        if self:IsShown() and self.selectedDataType == "map" then
            RefreshMethodDialog(self)
        end
    end)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Choose map data")
    frame.chrome = chrome
    Theme:RegisterSpecialFrame("GoldTrackerCustomFarmMethodDialog")

    local promptText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    promptText:SetPoint("TOPLEFT", chrome, "TOPLEFT", 20, -58)
    promptText:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -20, -58)
    promptText:SetJustifyH("LEFT")
    promptText:SetWordWrap(true)
    frame.promptText = promptText

    frame.dataTypeButtons = {}
    local previousButton
    for _, dataType in ipairs({ { "map", "Map data" }, { "item", "Item only" } }) do
        local key = dataType[1]
        local button = CreateButton(frame, 140, 26, dataType[2], "neutral")
        if previousButton then
            button:SetPoint("LEFT", previousButton, "RIGHT", 8, 0)
        else
            button:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -112)
        end
        button:SetScript("OnClick", function()
            frame.selectedDataType = key
            RefreshMethodDialog(frame)
        end)
        frame.dataTypeButtons[key] = button
        previousButton = button
    end

    local methodLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    methodLabel:SetPoint("TOPLEFT", frame.dataTypeButtons.map, "BOTTOMLEFT", 0, -14)
    methodLabel:SetText("Map source")
    frame.methodLabel = methodLabel
    local methodDropdown = CreateFrame("Frame", "GoldTrackerCustomFarmMethodDropdown", frame, "UIDropDownMenuTemplate")
    methodDropdown:SetPoint("TOPLEFT", methodLabel, "BOTTOMLEFT", -16, -3)
    UIDropDownMenu_SetWidth(methodDropdown, 480)
    UIDropDownMenu_Initialize(methodDropdown, function(_, level)
        if level ~= 1 or type(frame.payload) ~= "table" then
            return
        end
        if frame.selectedDataType == "map" then
            for _, farm in ipairs(frame.payload.farms or {}) do
                local selectedFarm = farm
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Catalog: " .. BuildMethodLabel(selectedFarm)
                info.value = "catalog:" .. tostring(selectedFarm.id)
                info.checked = frame.selectedMethodKind == "catalog"
                    and frame.selectedCatalogFarmID == selectedFarm.id
                info.func = function()
                    frame.selectedMethodKind = "catalog"
                    frame.selectedCatalogFarmID = selectedFarm.id
                    frame.previewOption = nil
                    RefreshMethodDialog(frame)
                end
                UIDropDownMenu_AddButton(info, level)
            end
            for index, option in ipairs(frame.payload.mapOptions or {}) do
                local optionIndex = index
                local info = UIDropDownMenu_CreateInfo()
                info.text = BuildMapSourceLabel(option)
                info.value = "map:" .. tostring(optionIndex)
                info.checked = frame.selectedMethodKind == "map" and frame.selectedMapOptionIndex == optionIndex
                info.func = function()
                    frame.selectedMethodKind = "map"
                    frame.selectedMapOptionIndex = optionIndex
                    frame.previewOption = nil
                    RefreshMethodDialog(frame)
                end
                UIDropDownMenu_AddButton(info, level)
            end
            return
        end
    end)
    frame.methodDropdown = methodDropdown

    local detailPanel = CreatePanel(frame, { 0.025, 0.03, 0.045, 0.96 }, { 1, 1, 1, 0.08 })
    frame.detailPanel = detailPanel
    detailPanel:SetPoint("TOPLEFT", methodDropdown, "BOTTOMLEFT", 16, -8)
    detailPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 54)
    local detailText = detailPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailText:SetPoint("TOPLEFT", detailPanel, "TOPLEFT", 12, -10)
    detailText:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT", -12, 10)
    detailText:SetJustifyH("LEFT")
    detailText:SetJustifyV("TOP")
    detailText:SetWordWrap(true)
    frame.detailText = detailText

    local mapPreview = GoldTracker:CreateFarmingMapPreview(frame)
    mapPreview:SetPoint("TOPLEFT", detailPanel, "TOPLEFT")
    mapPreview:SetPoint("BOTTOMRIGHT", detailPanel, "BOTTOMRIGHT")
    mapPreview:Hide()
    frame.mapPreview = mapPreview

    local cancelButton = CreateButton(frame, 86, 24, "Cancel", "neutral")
    cancelButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 18)
    cancelButton:SetScript("OnClick", function() frame:Hide() end)
    local acceptButton = CreateButton(frame, 112, 24, "Add", "primary")
    acceptButton:SetPoint("RIGHT", cancelButton, "LEFT", -8, 0)
    acceptButton:SetScript("OnClick", function()
        local payload = frame.payload
        local catalogFarmID = frame.selectedDataType == "map" and frame.selectedMethodKind == "catalog"
            and frame.selectedCatalogFarmID or nil
        local mapOption = frame.selectedDataType == "map" and frame.selectedMethodKind == "map"
            and payload.mapOptions[frame.selectedMapOptionIndex] or nil
        local committed
        local reason
        if payload and payload.entryID then
            committed, reason = GoldTracker:SetCustomFarmEntryMethod(payload.farmID, payload.entryID, catalogFarmID, mapOption)
        else
            committed, reason = GoldTracker:CommitCustomFarmEntry(payload, catalogFarmID, mapOption)
        end
        if not committed then
            GoldTracker:Print("Could not save this target in the custom farm (" .. tostring(reason or "unknown") .. ").")
        else
            frame:Hide()
        end
    end)
    frame.acceptButton = acceptButton
    GoldTracker.customFarmMethodDialog = frame
    return frame
end

function GoldTracker:ShowCustomFarmMethodDialog(payload)
    if type(payload) ~= "table" or type(payload.entry) ~= "table" then
        return false
    end
    payload.farms = payload.farms or {}
    payload.mapOptions = payload.mapOptions or self:GetCustomFarmMapOptions(payload.entry.itemID)
    local frame = CreateMethodDialog()
    frame.payload = payload
    frame.selectedCatalogFarmID = payload.selectedCatalogFarmID or (payload.farms[1] and payload.farms[1].id)
    frame.selectedMapOptionIndex = 1
    frame.selectedDataType = (#payload.farms > 0 or #payload.mapOptions > 0) and "map" or "item"
    frame.selectedMethodKind = #payload.farms > 0 and "catalog" or "map"
    if payload.entry.mapSource then
        frame.selectedDataType = "map"
        frame.selectedMethodKind = "map"
        local matched
        for index, option in ipairs(payload.mapOptions) do
            if self:GetCustomFarmMapSourceKey(option) == payload.entry.mapSource.key then
                frame.selectedMapOptionIndex = index
                matched = true
                break
            end
        end
        if not matched then
            payload.mapOptions[#payload.mapOptions + 1] = payload.entry.mapSource
            frame.selectedMapOptionIndex = #payload.mapOptions
        end
    elseif payload.preferItemOnly then
        frame.selectedDataType = "item"
    end
    frame.previewOption = nil
    frame.dataTypeButtons.map:SetEnabled(#payload.farms > 0 or #payload.mapOptions > 0)
    RefreshMethodDialog(frame)
    frame:Show()
    frame:Raise()
    return true
end

local function EnsureDialogs()
    if type(StaticPopupDialogs) ~= "table" then
        return
    end
    if not StaticPopupDialogs[NEW_DIALOG_KEY] then
        StaticPopupDialogs[NEW_DIALOG_KEY] = {
            text = "Name the new farm",
            button1 = "Create",
            button2 = "Cancel",
            hasEditBox = true,
            maxLetters = 80,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function(dialog)
                local editBox = GetDialogEditBox(dialog)
                if editBox then
                    editBox:SetText(GoldTracker:GetSuggestedCustomFarmName())
                    editBox:HighlightText()
                end
            end,
            OnAccept = function(dialog)
                local editBox = GetDialogEditBox(dialog)
                local farm = GoldTracker:CreateCustomFarm(editBox and editBox:GetText(), false)
                if farm and GoldTracker.myFarmsFrame then
                    GoldTracker.myFarmsFrame.selectedFarmID = farm.id
                    GoldTracker:RefreshMyFarmsWindow()
                end
            end,
            EditBoxOnEnterPressed = function(editBox)
                local dialog = editBox:GetParent()
                if dialog and dialog.button1 then
                    dialog.button1:Click()
                end
            end,
            EditBoxOnEscapePressed = function(editBox)
                editBox:GetParent():Hide()
            end,
        }
    end
    if not StaticPopupDialogs[RENAME_DIALOG_KEY] then
        StaticPopupDialogs[RENAME_DIALOG_KEY] = {
            text = "Rename farm",
            button1 = "Rename",
            button2 = "Cancel",
            hasEditBox = true,
            maxLetters = 80,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function(dialog)
                local editBox = GetDialogEditBox(dialog)
                local farm = GoldTracker:GetCustomFarmByID(dialog.data)
                if editBox then
                    editBox:SetText(farm and farm.name or "")
                    editBox:HighlightText()
                end
            end,
            OnAccept = function(dialog)
                local editBox = GetDialogEditBox(dialog)
                GoldTracker:RenameCustomFarm(dialog.data, editBox and editBox:GetText())
            end,
            EditBoxOnEnterPressed = function(editBox)
                local dialog = editBox:GetParent()
                if dialog and dialog.button1 then
                    dialog.button1:Click()
                end
            end,
            EditBoxOnEscapePressed = function(editBox)
                editBox:GetParent():Hide()
            end,
        }
    end
    if not StaticPopupDialogs[DELETE_DIALOG_KEY] then
        StaticPopupDialogs[DELETE_DIALOG_KEY] = {
            text = "Delete |cffffd24a%s|r and all of its entries?",
            button1 = "Delete",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(dialog)
                GoldTracker:DeleteCustomFarm(dialog.data)
                if GoldTracker.myFarmsFrame then
                    GoldTracker.myFarmsFrame.selectedFarmID = nil
                    GoldTracker:RefreshMyFarmsWindow()
                end
            end,
        }
    end
    if not StaticPopupDialogs[REMOVE_ENTRY_DIALOG_KEY] then
        StaticPopupDialogs[REMOVE_ENTRY_DIALOG_KEY] = {
            text = "Remove |cffffd24a%s|r from |cffffd24a%s|r?",
            button1 = "Remove",
            button2 = "Cancel",
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnAccept = function(dialog)
                local payload = dialog.data
                if type(payload) == "table" then
                    GoldTracker:RemoveEntryFromCustomFarm(payload.farmID, payload.entryID)
                end
            end,
        }
    end
end

local function SetFarmRowVisual(row, selected, active)
    if not row or not row.background then
        return
    end
    if selected then
        row.background:SetColorTexture(1.0, 0.82, 0.18, 0.16)
    elseif active then
        row.background:SetColorTexture(0.24, 0.78, 0.48, 0.14)
    else
        row.background:SetColorTexture(1, 1, 1, 0.035)
    end
end

local function GetOrCreateFarmRow(frame, index)
    frame.farmRows = frame.farmRows or {}
    local row = frame.farmRows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, frame.farmListContent)
    row:SetHeight(FARM_ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp")
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -9)
    row.nameText:SetPoint("TOPRIGHT", row, "TOPRIGHT", -10, -9)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.summaryText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.summaryText:SetPoint("TOPLEFT", row.nameText, "BOTTOMLEFT", 0, -5)
    row.summaryText:SetPoint("TOPRIGHT", row.nameText, "BOTTOMRIGHT", 0, -5)
    row.summaryText:SetJustifyH("LEFT")
    row.summaryText:SetWordWrap(false)
    row:SetScript("OnClick", function(self)
        frame.selectedFarmID = self.farmID
        GoldTracker:RefreshMyFarmsWindow()
    end)
    frame.farmRows[index] = row
    return row
end

local function SetCatalogColumnLayout(frame, row, isHeader, isItem)
    local rightInset = isHeader and 10 or 8
    local gap = 8
    local details = isHeader and row.detailsText or row.detailsButton
    details:ClearAllPoints()
    details:SetPoint("RIGHT", row, "RIGHT", -rightInset, 0)
    details:SetWidth(CATALOG_DETAILS_WIDTH)

    row.locationText:ClearAllPoints()
    row.locationText:SetPoint("RIGHT", details, "LEFT", -gap, 0)
    row.locationText:SetWidth(CATALOG_LOCATION_WIDTH)

    row.totalValueText:ClearAllPoints()
    row.totalValueText:SetPoint("RIGHT", row.locationText, "LEFT", -gap, 0)
    row.totalValueText:SetWidth(CATALOG_TOTAL_VALUE_WIDTH)

    row.unitValueText:ClearAllPoints()
    row.unitValueText:SetPoint("RIGHT", row.totalValueText, "LEFT", -gap, 0)
    row.unitValueText:SetWidth(CATALOG_UNIT_VALUE_WIDTH)

    row.quantityText:ClearAllPoints()
    row.quantityText:SetPoint("RIGHT", row.unitValueText, "LEFT", -gap, 0)
    row.quantityText:SetWidth(CATALOG_QUANTITY_WIDTH)

    row.nameText:ClearAllPoints()
    row.nameText:SetPoint("LEFT", row, "LEFT", isHeader and 10 or (isItem and 38 or 32), 0)
    row.nameText:SetPoint("RIGHT", row.quantityText, "LEFT", -gap, 0)
end

local function GetOrCreateCatalogRow(frame, index)
    frame.catalogRows = frame.catalogRows or {}
    local row = frame.catalogRows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, frame.catalogContent)
    row:SetHeight(CATALOG_ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp")
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.toggleText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.toggleText:SetPoint("LEFT", row, "LEFT", 10, 0)
    row.toggleText:SetWidth(14)
    row.toggleText:SetJustifyH("CENTER")
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.quantityText:SetJustifyH("RIGHT")
    row.unitValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.unitValueText:SetJustifyH("RIGHT")
    row.totalValueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.totalValueText:SetJustifyH("RIGHT")
    row.locationText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.locationText:SetJustifyH("LEFT")
    row.locationText:SetWordWrap(false)
    row.detailsButton = CreateButton(row, CATALOG_DETAILS_WIDTH, 20, "Details", "neutral")
    row.detailsButton:SetScript("OnClick", function(self)
        local owner = self:GetParent()
        if owner.catalogFarmID and type(GoldTracker.OpenFarmDetails) == "function" then
            GoldTracker:OpenFarmDetails(owner.catalogFarmID, {
                farms = { owner.catalogFarm },
                suppressFarmOptionNotice = true,
            })
        end
    end)
    row:SetScript("OnClick", function(self)
        if self.catalogFarmID then
            GoldTracker:ToggleFarmCatalogExpanded(self.catalogFarmID)
        end
    end)
    SetCatalogColumnLayout(frame, row, false, false)
    frame.catalogRows[index] = row
    return row
end

function GoldTracker:GetFarmCatalogLocationGroupLabel(farm)
    return GetCatalogFarmLocationGroupLabel(farm)
end

local RefreshAllFarmCatalogFrames

local function GetOrCreateCatalogGroupRow(frame, index)
    frame.catalogGroupRows = frame.catalogGroupRows or {}
    local row = frame.catalogGroupRows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, frame.catalogContent)
    row:SetHeight(CATALOG_GROUP_ROW_HEIGHT)
    row:RegisterForClicks("LeftButtonUp")
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.divider = row:CreateTexture(nil, "ARTWORK")
    row.divider:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 8, 0)
    row.divider:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -8, 0)
    row.divider:SetHeight(1)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.text:SetPoint("LEFT", row, "LEFT", 12, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -12, 0)
    row.text:SetJustifyH("LEFT")
    row:SetScript("OnClick", function(self)
        if not self.locationGroupKey then
            return
        end
        GoldTracker.farmCatalogCollapsedLocationGroups = GoldTracker.farmCatalogCollapsedLocationGroups or {}
        GoldTracker:ToggleLocationGroupCollapsed(
            GoldTracker.farmCatalogCollapsedLocationGroups,
            self.locationGroupKey,
            self.locationGroupCollapsed
        )
        RefreshAllFarmCatalogFrames(GoldTracker, false)
    end)
    frame.catalogGroupRows[index] = row
    return row
end

local function GetOrCreateCatalogItemRow(frame, index)
    frame.catalogItemRows = frame.catalogItemRows or {}
    local row = frame.catalogItemRows[index]
    if row then
        return row
    end
    row = CreateFrame("Button", nil, frame.catalogContent)
    row:SetHeight(CATALOG_ITEM_ROW_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.quantityText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.quantityText:SetJustifyH("RIGHT")
    row.unitValueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.unitValueText:SetJustifyH("RIGHT")
    row.totalValueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.totalValueText:SetJustifyH("RIGHT")
    row.locationText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.locationText:SetJustifyH("LEFT")
    row.detailsButton = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.detailsButton:SetText("")
    row:SetScript("OnEnter", function(self)
        if not GameTooltip or not self.itemID then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        if self.itemLink then
            GameTooltip:SetHyperlink(self.itemLink)
        elseif type(GameTooltip.SetItemByID) == "function" then
            GameTooltip:SetItemByID(self.itemID)
        end
        GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    SetCatalogColumnLayout(frame, row, false, true)
    frame.catalogItemRows[index] = row
    return row
end

local function GetCatalogValueText(addon, snapshot)
    if snapshot == nil then
        return "Not refreshed"
    end
    if (tonumber(snapshot.pricedTargets) or 0) <= 0 and (tonumber(snapshot.totalValue) or 0) <= 0 then
        return "Price unavailable"
    end
    return addon:FormatMoney(snapshot.estimatedHourlyValue or snapshot.hourlyValue or 0) .. "/hour"
end

local function GetCatalogRareBonusText(addon, snapshot)
    local bonus = type(snapshot) == "table" and snapshot.rareBonus or nil
    if not bonus or (tonumber(bonus.valuePerHour) or 0) <= 0 then
        return ""
    end
    return "+" .. addon:FormatMoney(bonus.valuePerHour) .. "/h rare"
end

local function GetCatalogItemValueText(addon, target, key)
    if target == nil then
        return "Not refreshed"
    end
    local value = math.max(0, tonumber(target[key]) or 0)
    if value <= 0 then
        return "Unavailable"
    end
    return addon:FormatMoney(math.floor(value + 0.5))
end

local function GetCatalogValueSource(addon)
    return type(addon.GetCraftingFarmingValueSource) == "function" and addon:GetCraftingFarmingValueSource() or nil
end

local function GetCatalogValueSourceKey(addon)
    local source = GetCatalogValueSource(addon)
    return tostring(source and (source.id or source.label) or "current")
end

local function GetCatalogSelectionKey(addon)
    local category, subcategory = EnsureFarmCatalogSelection(addon)
    return table.concat({ category.id, subcategory.id, GetCatalogValueSourceKey(addon) }, "|")
end

local function GetFarmCatalogSnapshotCache(addon)
    if type(addon.db) == "table" then
        if type(addon.db.farmCatalogValueCache) ~= "table" then
            addon.db.farmCatalogValueCache = {}
        end
        addon.farmCatalogViewSnapshots = addon.db.farmCatalogValueCache
    elseif type(addon.farmCatalogViewSnapshots) ~= "table" then
        addon.farmCatalogViewSnapshots = {}
    end
    return addon.farmCatalogViewSnapshots
end

local function UpdateCatalogMetaText(addon, frame, visibleCount)
    if not frame or not frame.catalogMetaText then
        return
    end
    local _, subcategory = EnsureFarmCatalogSelection(addon)
    local selectionKey = GetCatalogSelectionKey(addon)
    local isRefreshing = addon.farmCatalogRefreshSelectionKey == selectionKey
        and addon.farmCatalogRefreshInProgress == true
    local total = isRefreshing and math.max(0, tonumber(addon.farmCatalogViewTotal) or 0)
        or math.max(0, tonumber(visibleCount) or 0)
    local completed = isRefreshing and math.min(total, tonumber(addon.farmCatalogViewCompleted) or 0) or total
    local source = GetCatalogValueSource(addon)
    local parts = {
        string.format(
            "Showing %d %s farm%s (%d in selected group)",
            tonumber(visibleCount) or 0,
            subcategory.label,
            tonumber(visibleCount) == 1 and "" or "s",
            total
        ),
        "Selected source: " .. tostring(source and source.label or "current item values"),
    }
    if isRefreshing and completed < total then
        parts[#parts + 1] = string.format("Calculating %d/%d", completed, total)
    else
        parts[#parts + 1] = "Cached values; use Refresh values to recalculate"
    end
    frame.catalogMetaText:SetText(table.concat(parts, "  |  "))
end

local function GetSnapshotTarget(snapshot, target, targetIndex)
    if type(snapshot) ~= "table" or type(target) ~= "table" then
        return nil
    end
    local indexedTarget = snapshot.targets and snapshot.targets[targetIndex]
    if indexedTarget and tonumber(indexedTarget.itemID) == tonumber(target.itemID) then
        return indexedTarget
    end
    for _, pricedTarget in ipairs(snapshot.targets or {}) do
        if tonumber(pricedTarget.itemID) == tonumber(target.itemID) then
            return pricedTarget
        end
    end
    return nil
end

local function SortCatalogFarms(addon, farms)
    local cache = GetFarmCatalogSnapshotCache(addon)
    table.sort(farms, function(left, right)
        local leftLocation = string.lower(GetCatalogFarmLocationGroupLabel(left))
        local rightLocation = string.lower(GetCatalogFarmLocationGroupLabel(right))
        if leftLocation ~= rightLocation then
            return leftLocation < rightLocation
        end
        local leftSnapshot = cache[left.id]
        local rightSnapshot = cache[right.id]
        local leftValue = leftSnapshot
            and tonumber(leftSnapshot.estimatedHourlyValue or leftSnapshot.hourlyValue) or nil
        local rightValue = rightSnapshot
            and tonumber(rightSnapshot.estimatedHourlyValue or rightSnapshot.hourlyValue) or nil
        if leftValue ~= rightValue then
            if leftValue == nil then
                return false
            end
            if rightValue == nil then
                return true
            end
            return leftValue > rightValue
        end
        local leftName = tostring(left.name or left.id or ""):lower()
        local rightName = tostring(right.name or right.id or ""):lower()
        if leftName ~= rightName then
            return leftName < rightName
        end
        return tostring(left.id or "") < tostring(right.id or "")
    end)
end

local function ConfigureCatalogItemRow(addon, row, target, snapshotTarget, stripeIndex)
    local itemID = tonumber(target and target.itemID)
    local itemLink = itemID and GetItemLinkSafe(itemID) or nil
    row.itemID = itemID
    row.itemLink = itemLink
    row.nameText:SetText(itemLink or (itemID and GetItemNameSafe(itemID)) or "Unknown item")
    row.quantityText:SetText("x " .. FormatQuantity(target and target.quantity))
    row.unitValueText:SetText(GetCatalogItemValueText(addon, snapshotTarget, "unitValue"))
    row.totalValueText:SetText(GetCatalogItemValueText(addon, snapshotTarget, "sampleValue"))
    row.locationText:SetText(snapshotTarget and snapshotTarget.isRareBonus and "Rare value bonus" or "")
    row.background:SetColorTexture(0.18, 0.24, 0.34, stripeIndex % 2 == 0 and 0.16 or 0.10)
end

local function SyncFarmCatalogControls(addon, frame)
    local category, subcategory = EnsureFarmCatalogSelection(addon)
    if frame.catalogCategoryDropdown then
        UIDropDownMenu_SetSelectedValue(frame.catalogCategoryDropdown, category.id)
        UIDropDownMenu_SetText(frame.catalogCategoryDropdown, category.label)
    end
    if frame.catalogSubcategoryDropdown then
        UIDropDownMenu_SetSelectedValue(frame.catalogSubcategoryDropdown, subcategory.id)
        UIDropDownMenu_SetText(frame.catalogSubcategoryDropdown, subcategory.label)
    end
    addon.farmCatalogExpansionFilter = NormalizeFarmCatalogExpansionFilter(addon.farmCatalogExpansionFilter)
    if frame.catalogExpansionDropdown then
        UIDropDownMenu_SetSelectedValue(frame.catalogExpansionDropdown, addon.farmCatalogExpansionFilter)
        local label = "All expansions"
        for _, option in ipairs(GetFarmCatalogExpansionOptions()) do
            if option.id == addon.farmCatalogExpansionFilter then
                label = option.label
                break
            end
        end
        UIDropDownMenu_SetText(frame.catalogExpansionDropdown, label)
    end
    if frame.catalogTitle then
        frame.catalogTitle:SetText(category.label .. " farms")
    end
    if frame.catalogEmptyText then
        frame.catalogEmptyText:SetText(string.format(
            "No %s - %s farms match this search.",
            category.label,
            subcategory.label
        ))
    end
end

local function RefreshFarmCatalogFrame(addon, frame, scrollToTop)
    if not frame or not frame.catalogContent then
        return
    end
    SyncScrollContentWidth(frame.catalogScrollFrame, frame.catalogContent)
    local category, subcategory = EnsureFarmCatalogSelection(addon)
    SyncFarmCatalogControls(addon, frame)
    local farms = addon:GetFarmCatalogEntries(
        addon.farmCatalogSearchText,
        category.id,
        subcategory.id,
        addon.farmCatalogExpansionFilter
    )
    local cache = GetFarmCatalogSnapshotCache(addon)
    SortCatalogFarms(addon, farms)
    addon.farmCatalogCollapsedLocationGroups = addon.farmCatalogCollapsedLocationGroups or {}
    local displayRows = addon:BuildLocationGroupedDisplayRows(
        farms,
        GetCatalogFarmLocationGroupLabel,
        addon.farmCatalogCollapsedLocationGroups,
        true
    )
    frame.catalogRowByFarmID = {}
    frame.catalogItemRowsByFarmID = {}
    local yOffset = 0
    local farmRowCount = 0
    local groupRowCount = 0
    local itemRowCount = 0
    for displayIndex, displayRow in ipairs(displayRows) do
        if displayRow.isLocationGroupHeader then
            groupRowCount = groupRowCount + 1
            local groupRow = GetOrCreateCatalogGroupRow(frame, groupRowCount)
            groupRow.locationGroupKey = displayRow.locationGroupKey
            groupRow.locationGroupCollapsed = displayRow.collapsed == true
            groupRow.text:SetText(string.format(
                "%s %s (%d)",
                displayRow.collapsed and "+" or "-",
                displayRow.locationGroupLabel or "No mapped location",
                tonumber(displayRow.itemCount) or 0
            ))
            groupRow.background:SetColorTexture(1.0, 0.82, 0.18, 0.10)
            groupRow.divider:SetColorTexture(1.0, 0.82, 0.18, 0.42)
            groupRow:ClearAllPoints()
            groupRow:SetPoint("TOPLEFT", frame.catalogContent, "TOPLEFT", 0, -yOffset)
            groupRow:SetPoint("TOPRIGHT", frame.catalogContent, "TOPRIGHT", 0, -yOffset)
            groupRow:Show()
            yOffset = yOffset + CATALOG_GROUP_ROW_HEIGHT + CATALOG_ROW_GAP
        else
            local farm = displayRow
            farmRowCount = farmRowCount + 1
            local row = GetOrCreateCatalogRow(frame, farmRowCount)
            local snapshot = cache[farm.id]
            row.catalogFarmID = farm.id
            row.catalogFarm = farm
            frame.catalogRowByFarmID[farm.id] = row
            local isExpanded = addon.farmCatalogExpandedFarmIDs
                and addon.farmCatalogExpandedFarmIDs[farm.id] == true
            row.toggleText:SetText(isExpanded and "-" or "+")
            row.nameText:SetText(farm.name or farm.id or "Unknown farm")
            row.quantityText:SetText("")
            row.unitValueText:SetText(GetCatalogRareBonusText(addon, snapshot))
            row.locationText:SetText(GetCatalogFarmLocationLabel(farm))
            row.totalValueText:SetText(GetCatalogValueText(addon, snapshot))
            row.background:SetColorTexture(1, 1, 1, displayIndex % 2 == 0 and 0.045 or 0.022)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", frame.catalogContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("TOPRIGHT", frame.catalogContent, "TOPRIGHT", 0, -yOffset)
            SetCatalogColumnLayout(frame, row, false, false)
            row:Show()
            yOffset = yOffset + CATALOG_ROW_HEIGHT + CATALOG_ROW_GAP
            if isExpanded then
                local farmItemRows = {}
                frame.catalogItemRowsByFarmID[farm.id] = farmItemRows
                for targetIndex, target in ipairs(farm.targets or {}) do
                    itemRowCount = itemRowCount + 1
                    local itemRow = GetOrCreateCatalogItemRow(frame, itemRowCount)
                    ConfigureCatalogItemRow(
                        addon,
                        itemRow,
                        target,
                        GetSnapshotTarget(snapshot, target, targetIndex),
                        targetIndex
                    )
                    itemRow:ClearAllPoints()
                    itemRow:SetPoint("TOPLEFT", frame.catalogContent, "TOPLEFT", 0, -yOffset)
                    itemRow:SetPoint("TOPRIGHT", frame.catalogContent, "TOPRIGHT", 0, -yOffset)
                    SetCatalogColumnLayout(frame, itemRow, false, true)
                    itemRow:Show()
                    farmItemRows[#farmItemRows + 1] = itemRow
                    yOffset = yOffset + CATALOG_ITEM_ROW_HEIGHT + CATALOG_ITEM_ROW_GAP
                end
            end
        end
    end
    for index = farmRowCount + 1, #(frame.catalogRows or {}) do
        frame.catalogRows[index]:Hide()
    end
    for index = groupRowCount + 1, #(frame.catalogGroupRows or {}) do
        frame.catalogGroupRows[index]:Hide()
    end
    for index = itemRowCount + 1, #(frame.catalogItemRows or {}) do
        frame.catalogItemRows[index]:Hide()
    end
    frame.catalogContent:SetHeight(math.max(1, yOffset))
    frame.catalogVisibleCount = #farms
    frame.catalogEmptyText:SetShown(#farms == 0)
    UpdateCatalogMetaText(addon, frame, #farms)
    if scrollToTop and frame.catalogScrollFrame.SetVerticalScroll then
        frame.catalogScrollFrame:SetVerticalScroll(0)
    end
end

RefreshAllFarmCatalogFrames = function(addon, scrollToTop)
    local primary = addon.myFarmsFrame
    if primary and primary.IsShown and primary:IsShown()
        and primary.catalogPanel and primary.catalogPanel:IsShown()
    then
        RefreshFarmCatalogFrame(addon, primary, scrollToTop)
    end
    local expanded = addon.farmCatalogExpandedFrame
    if expanded and expanded.IsShown and expanded:IsShown() then
        RefreshFarmCatalogFrame(addon, expanded, scrollToTop)
    end
end

function GoldTracker:ToggleFarmCatalogExpanded(farmID)
    if not farmID then
        return
    end
    self.farmCatalogExpandedFarmIDs = self.farmCatalogExpandedFarmIDs or {}
    local expanded = self.farmCatalogExpandedFarmIDs[farmID] ~= true
    self.farmCatalogExpandedFarmIDs[farmID] = expanded

    local cache = GetFarmCatalogSnapshotCache(self)
    local farm = GetFarmCatalogEntryByID(farmID)
    if expanded and farm and type(self.BuildFarmValuationSnapshot) == "function" then
        cache[farmID] = self:BuildFarmValuationSnapshot(farm, {
            includeTargets = true,
        })
    elseif not expanded then
        local snapshot = cache[farmID]
        if snapshot then
            snapshot.targets = nil
        end
    end
    RefreshAllFarmCatalogFrames(self, false)
end

local function UpdateFarmCatalogFrameValues(addon, frame, farmIDs)
    if not frame or not frame.catalogRowByFarmID then
        return
    end
    for _, farmID in ipairs(farmIDs or {}) do
        local row = frame.catalogRowByFarmID[farmID]
        if row then
            local snapshot = addon.farmCatalogViewSnapshots[row.catalogFarmID]
            row.totalValueText:SetText(GetCatalogValueText(addon, snapshot))
            row.unitValueText:SetText(GetCatalogRareBonusText(addon, snapshot))
            for targetIndex, itemRow in ipairs(frame.catalogItemRowsByFarmID[farmID] or {}) do
                local target = row.catalogFarm and row.catalogFarm.targets and row.catalogFarm.targets[targetIndex]
                if target then
                    ConfigureCatalogItemRow(
                        addon,
                        itemRow,
                        target,
                        GetSnapshotTarget(snapshot, target, targetIndex),
                        targetIndex
                    )
                end
            end
        end
    end
    UpdateCatalogMetaText(addon, frame, frame.catalogVisibleCount)
end

local function UpdateAllFarmCatalogFrameValues(addon, farmIDs)
    local primary = addon.myFarmsFrame
    if primary and primary.IsShown and primary:IsShown()
        and primary.catalogPanel and primary.catalogPanel:IsShown()
    then
        UpdateFarmCatalogFrameValues(addon, primary, farmIDs)
    end
    local expanded = addon.farmCatalogExpandedFrame
    if expanded and expanded.IsShown and expanded:IsShown() then
        UpdateFarmCatalogFrameValues(addon, expanded, farmIDs)
    end
end

function GoldTracker:RefreshFarmCatalogValues()
    self.farmCatalogValuationGeneration = (tonumber(self.farmCatalogValuationGeneration) or 0) + 1
    local generation = self.farmCatalogValuationGeneration
    local category, subcategory = EnsureFarmCatalogSelection(self)
    local farms = self:GetFarmCatalogEntries(nil, category.id, subcategory.id, self.farmCatalogExpansionFilter)
    local cache = GetFarmCatalogSnapshotCache(self)
    self.farmCatalogRefreshSelectionKey = GetCatalogSelectionKey(self)
    self.farmCatalogRefreshInProgress = true
    self.farmCatalogViewCompleted = 0
    self.farmCatalogViewTotal = #farms
    RefreshAllFarmCatalogFrames(self, false)

    local function finishFarm(farm)
        local snapshot
        local isExpanded = self.farmCatalogExpandedFarmIDs ~= nil
            and self.farmCatalogExpandedFarmIDs[farm.id] == true
        if type(self.BuildFarmValuationSnapshot) == "function" then
            snapshot = self:BuildFarmValuationSnapshot(farm, {
                includeTargets = isExpanded,
            })
        else
            snapshot = { totalValue = 0, hourlyValue = 0, pricedTargets = 0 }
        end
        cache[farm.id] = snapshot
        self.farmCatalogViewCompleted = self.farmCatalogViewCompleted + 1
    end

    if not C_Timer or type(C_Timer.After) ~= "function" then
        for _, farm in ipairs(farms) do
            finishFarm(farm)
        end
        self.farmCatalogRefreshInProgress = false
        RefreshAllFarmCatalogFrames(self, false)
        return
    end

    local farmIndex = 1
    local function processBatch()
        if self.farmCatalogValuationGeneration ~= generation then
            return
        end
        local startedAt = type(debugprofilestop) == "function" and debugprofilestop() or nil
        local processed = 0
        local updatedFarmIDs = {}
        while farmIndex <= #farms do
            local farm = farms[farmIndex]
            finishFarm(farm)
            updatedFarmIDs[#updatedFarmIDs + 1] = farm.id
            farmIndex = farmIndex + 1
            processed = processed + 1
            if startedAt then
                if (debugprofilestop() - startedAt) >= CATALOG_REFRESH_BUDGET_MS then
                    break
                end
            elseif processed >= CATALOG_REFRESH_FALLBACK_BATCH_SIZE then
                break
            end
        end
        UpdateAllFarmCatalogFrameValues(self, updatedFarmIDs)
        if farmIndex <= #farms then
            C_Timer.After(0, processBatch)
        else
            self.farmCatalogRefreshInProgress = false
            RefreshAllFarmCatalogFrames(self, false)
        end
    end
    C_Timer.After(0, processBatch)
end


function GoldTracker:IsFarmCatalogValuationCurrent()
    local cache = GetFarmCatalogSnapshotCache(self)
    local category, subcategory = EnsureFarmCatalogSelection(self)
    local farms = self:GetFarmCatalogEntries(nil, category.id, subcategory.id, self.farmCatalogExpansionFilter)
    for _, farm in ipairs(farms) do
        if type(cache[farm.id]) ~= "table" then
            return false
        end
    end
    return #farms > 0
end

function GoldTracker:RefreshFarmCatalogWindow(scrollToTop)
    RefreshAllFarmCatalogFrames(self, scrollToTop == true)
    if scrollToTop and self.myFarmsFrame and self.myFarmsFrame.catalogScrollFrame
        and self.myFarmsFrame.catalogScrollFrame.SetVerticalScroll then
        self.myFarmsFrame.catalogScrollFrame:SetVerticalScroll(0)
    end
end

local function SetEntryTooltip(row, target)
    if not GameTooltip or not row.itemID then
        return
    end
    GameTooltip:SetOwner(target, "ANCHOR_CURSOR")
    if type(row.itemLink) == "string" and row.itemLink ~= "" then
        GameTooltip:SetHyperlink(row.itemLink)
    elseif type(GameTooltip.SetItemByID) == "function" then
        GameTooltip:SetItemByID(row.itemID)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Added from", row.sourceLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
    if row.locationLabel then
        GameTooltip:AddDoubleLine("Location", row.locationLabel, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    if row.catalogFarmName then
        GameTooltip:AddDoubleLine("Farming method", row.catalogFarmName, 0.72, 0.86, 1.0, 1, 1, 1)
    end
    GameTooltip:Show()
end

local function SetSuggestionTooltip(row, target)
    if not GameTooltip or not row.itemID then
        return
    end
    GameTooltip:SetOwner(target, "ANCHOR_CURSOR")
    if type(row.itemLink) == "string" and row.itemLink ~= "" then
        GameTooltip:SetHyperlink(row.itemLink)
    elseif type(GameTooltip.SetItemByID) == "function" then
        GameTooltip:SetItemByID(row.itemID)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Farm catalog", row.farmName or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:AddDoubleLine(
        "Current unit value",
        GoldTracker:FormatMoney(row.unitValue or 0),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine(
        "Recorded",
        string.format("%s per %s", FormatQuantity(row.quantity), FormatDuration(row.recordedSeconds)),
        0.72,
        0.86,
        1.0,
        1,
        1,
        1
    )
    GameTooltip:AddDoubleLine("Price source", row.valueSourceLabel or "Unknown", 0.72, 0.86, 1.0, 1, 1, 1)
    GameTooltip:Show()
end

local function GetOrCreateStepRow(frame, index)
    frame.stepRows = frame.stepRows or {}
    local row = frame.stepRows[index]
    if row then
        return row
    end
    row = CreateFrame("Frame", nil, frame.entryContent)
    row:SetHeight(STEP_ROW_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.nameText:SetPoint("TOPLEFT", row, "TOPLEFT", 10, -8)
    row.nameText:SetPoint("RIGHT", row, "RIGHT", -70, 0)
    row.nameText:SetJustifyH("LEFT")
    row.nameText:SetWordWrap(false)
    row.metaText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.metaText:SetPoint("TOPLEFT", row.nameText, "BOTTOMLEFT", 0, -5)
    row.metaText:SetPoint("RIGHT", row.nameText, "RIGHT", 0, 0)
    row.metaText:SetJustifyH("LEFT")
    row.metaText:SetWordWrap(false)
    row.mapButton = CreateButton(row, 52, 20, "Map", "primary")
    row.mapButton:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.mapButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        if parent.catalogFarmID and type(GoldTracker.OpenFarmDetails) == "function" then
            GoldTracker:OpenFarmDetails(parent.catalogFarmID, {
                itemID = parent.firstItemID,
                suppressFarmOptionNotice = true,
            })
        end
    end)
    frame.stepRows[index] = row
    return row
end

local function GetOrCreateEntryRow(frame, index)
    frame.entryRows = frame.entryRows or {}
    local row = frame.entryRows[index]
    if row then
        return row
    end
    row = CreateFrame("Frame", nil, frame.entryContent)
    row:SetHeight(ENTRY_ROW_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(20, 20)
    row.icon:SetPoint("LEFT", row, "LEFT", 8, 0)
    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -1)
    row.itemText:SetPoint("RIGHT", row, "RIGHT", -150, 0)
    row.itemText:SetJustifyH("LEFT")
    row.itemText:SetWordWrap(false)
    row.sourceText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.sourceText:SetPoint("TOPLEFT", row.itemText, "BOTTOMLEFT", 0, -3)
    row.sourceText:SetPoint("RIGHT", row.itemText, "RIGHT", 0, 0)
    row.sourceText:SetJustifyH("LEFT")
    row.sourceText:SetWordWrap(false)
    row.removeButton = CreateButton(row, 64, 20, "Remove", "danger")
    row.removeButton:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.removeButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        local farm = GoldTracker:GetCustomFarmByID(frame.selectedFarmID)
        EnsureDialogs()
        if farm and type(StaticPopup_Show) == "function" then
            StaticPopup_Show(
                REMOVE_ENTRY_DIALOG_KEY,
                parent.itemName or ("Item " .. tostring(parent.itemID)),
                farm.name,
                { farmID = farm.id, entryID = parent.entryID }
            )
        elseif farm then
            GoldTracker:RemoveEntryFromCustomFarm(farm.id, parent.entryID)
        end
    end)
    row.methodButton = CreateButton(row, 62, 20, "Method", "neutral")
    row.methodButton:SetPoint("RIGHT", row.removeButton, "LEFT", -6, 0)
    row.methodButton:SetScript("OnClick", function(self)
        local parent = self:GetParent()
        local farm = GoldTracker:GetCustomFarmByID(frame.selectedFarmID)
        local entry
        for _, candidate in ipairs(farm and farm.entries or {}) do
            if candidate.id == parent.entryID then
                entry = candidate
                break
            end
        end
        local farms = entry and type(GoldTracker.GetFarmsForItem) == "function" and GoldTracker:GetFarmsForItem(entry.itemID) or {}
        if entry then
            GoldTracker:ShowCustomFarmMethodDialog({
                farmID = frame.selectedFarmID,
                entryID = entry.id,
                entry = entry,
                farms = farms,
                selectedCatalogFarmID = entry.catalogFarmID,
                preferItemOnly = entry.catalogFarmID == nil and entry.mapSource == nil,
            })
        end
    end)
    row.mapButton = CreateButton(row, 42, 20, "Map", "neutral")
    row.mapButton:SetPoint("RIGHT", row.methodButton, "LEFT", -6, 0)
    row.mapButton:SetScript("OnClick", function(self)
        GoldTracker:OpenCustomFarmEntryMap(self:GetParent().entry)
    end)
    row.tooltipTarget = GoldTracker:CreateItemTooltipTarget(row, row.itemText, row.icon, SetEntryTooltip)
    frame.entryRows[index] = row
    return row
end

local function GetOrCreateSuggestionHeader(frame, index)
    frame.suggestionHeaders = frame.suggestionHeaders or {}
    local row = frame.suggestionHeaders[index]
    if row then
        return row
    end
    row = CreateFrame("Frame", nil, frame.entryContent)
    row:SetHeight(SUGGESTION_HEADER_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.text:SetPoint("LEFT", row, "LEFT", 26, 0)
    row.text:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.text:SetJustifyH("LEFT")
    row.text:SetTextColor(0.45, 0.92, 1.0)
    frame.suggestionHeaders[index] = row
    return row
end

local function GetOrCreateSuggestionRow(frame, index)
    frame.suggestionRows = frame.suggestionRows or {}
    local row = frame.suggestionRows[index]
    if row then
        return row
    end
    row = CreateFrame("Frame", nil, frame.entryContent)
    row:SetHeight(SUGGESTION_ROW_HEIGHT)
    row.background = row:CreateTexture(nil, "BACKGROUND")
    row.background:SetAllPoints(row)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(20, 20)
    row.icon:SetPoint("LEFT", row, "LEFT", 40, 0)
    row.itemText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.itemText:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -1)
    row.itemText:SetPoint("RIGHT", row, "RIGHT", -150, 0)
    row.itemText:SetJustifyH("LEFT")
    row.itemText:SetWordWrap(false)
    row.detailText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.detailText:SetPoint("TOPLEFT", row.itemText, "BOTTOMLEFT", 0, -3)
    row.detailText:SetPoint("RIGHT", row.itemText, "RIGHT", 0, 0)
    row.detailText:SetJustifyH("LEFT")
    row.detailText:SetWordWrap(false)
    row.valueText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.valueText:SetPoint("RIGHT", row, "RIGHT", -8, 0)
    row.valueText:SetWidth(132)
    row.valueText:SetJustifyH("RIGHT")
    row.tooltipTarget = GoldTracker:CreateItemTooltipTarget(row, row.itemText, row.icon, SetSuggestionTooltip)
    frame.suggestionRows[index] = row
    return row
end

local function ConfigureSuggestionRow(frame, row, suggestion, farm, yOffset, striped)
    local itemID = suggestion.itemID
    local itemName = GetItemNameSafe(itemID)
    local itemLink = GetItemLinkSafe(itemID)
    row.itemID = itemID
    row.itemLink = itemLink
    row.farmName = farm.name or farm.id
    row.unitValue = suggestion.unitValue
    row.quantity = suggestion.quantity
    row.recordedSeconds = farm.recordedSeconds
    row.valueSourceLabel = suggestion.valueSourceLabel
    row.itemText:SetText(itemLink or itemName)
    row.detailText:SetText(string.format(
        "Suggested drop | Recorded %s per %s",
        FormatQuantity(suggestion.quantity),
        FormatDuration(farm.recordedSeconds)
    ))
    row.valueText:SetText(GoldTracker:FormatMoney(suggestion.unitValue) .. " each")
    local icon = type(GetItemIcon) == "function" and GetItemIcon(itemID) or nil
    row.icon:SetTexture(icon)
    row.icon:SetShown(icon ~= nil)
    row.background:SetColorTexture(0.22, 0.55, 0.72, striped and 0.08 or 0.045)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", frame.entryContent, "TOPLEFT", 0, -yOffset)
    row:SetPoint("TOPRIGHT", frame.entryContent, "TOPRIGHT", 0, -yOffset)
    row:Show()
end


local function ConfigureEntryRow(frame, row, entry, yOffset, striped, grouped)
    row.entry = entry
    row.entryID = entry.id
    row.itemID = entry.itemID
    row.itemName = entry.itemName
    row.itemLink = entry.itemLink
    row.sourceLabel = entry.sourceLabel
    row.locationLabel = entry.locationLabel
    row.catalogFarmName = entry.catalogFarmName
    row.itemText:SetText(entry.itemLink or entry.itemName or ("Item " .. tostring(entry.itemID)))
    local context = grouped and ("Selected target | Added from " .. (entry.sourceLabel or "Unknown source")) or (entry.sourceLabel or "Unknown source")
    if grouped and entry.catalogFarmID and type(GoldTracker.GetFarmByID) == "function" then
        local catalogFarm = GoldTracker:GetFarmByID(entry.catalogFarmID)
        local target = GetTargetForItem(catalogFarm, entry.itemID)
        if target then
            local duration = tonumber(catalogFarm.recordedSeconds) or 0
            context = string.format(
                "Expected %s per %s | Added from %s",
                FormatQuantity(target.quantity),
                FormatDuration(duration),
                entry.sourceLabel or "Unknown source"
            )
        end
    end
    if entry.mapSource then
        context = "Map data | " .. BuildMapSourceLabel(entry.mapSource)
    elseif not grouped and entry.targetName then
        context = context .. " | " .. entry.targetName
    end
    if not grouped and not entry.mapSource and entry.locationLabel then
        context = context .. " | " .. entry.locationLabel
    end
    row.sourceText:SetText(context)
    row.methodButton:Show()
    row.mapButton:SetShown(entry.mapSource ~= nil)
    if entry.icon then
        row.icon:SetTexture(entry.icon)
        row.icon:Show()
    elseif type(GetItemIcon) == "function" then
        local icon = GetItemIcon(entry.itemID)
        row.icon:SetTexture(icon)
        row.icon:SetShown(icon ~= nil)
    else
        row.icon:Hide()
    end
    row.icon:ClearAllPoints()
    row.icon:SetPoint("LEFT", row, "LEFT", grouped and 26 or 8, 0)
    row.itemText:ClearAllPoints()
    row.itemText:SetPoint("TOPLEFT", row.icon, "TOPRIGHT", 7, -1)
    row.itemText:SetPoint("RIGHT", entry.mapSource and row.mapButton or row.methodButton, "LEFT", -6, 0)
    row.background:SetColorTexture(1, 1, 1, striped and 0.045 or 0.022)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", frame.entryContent, "TOPLEFT", 0, -yOffset)
    row:SetPoint("TOPRIGHT", frame.entryContent, "TOPRIGHT", 0, -yOffset)
    row:Show()
end

function GoldTracker:RefreshMyFarmsWindow()
    local frame = self.myFarmsFrame
    if not frame then
        return
    end
    if frame.farmsWorkspaceView == "catalog" then
        RefreshFarmCatalogFrame(self, frame, false)
        return
    end
    local farms = self:GetCustomFarms()
    local activeFarm = self:GetActiveCustomFarm()
    SyncScrollContentWidth(frame.farmScrollFrame, frame.farmListContent)
    SyncScrollContentWidth(frame.entryScrollFrame, frame.entryContent)
    if not frame.selectedFarmID or not self:GetCustomFarmByID(frame.selectedFarmID) then
        frame.selectedFarmID = farms[1] and farms[1].id or nil
    end

    local yOffset = 0
    for index, farm in ipairs(farms) do
        local row = GetOrCreateFarmRow(frame, index)
        local steps = self:GetCustomFarmSteps(farm)
        row.farmID = farm.id
        row.nameText:SetText(farm.name)
        row.summaryText:SetText(string.format(
            "%d step%s / %d target%s | %d character%s%s",
            #steps,
            #steps == 1 and "" or "s",
            #(farm.entries or {}),
            #(farm.entries or {}) == 1 and "" or "s",
            farm.assignedCharacter and 1 or 0,
            farm.assignedCharacter and "" or "s",
            activeFarm and activeFarm.id == farm.id and " | BUILDING" or ""
        ))
        row.summaryText:SetTextColor(activeFarm and activeFarm.id == farm.id and 0.42 or 0.72, activeFarm and activeFarm.id == farm.id and 0.95 or 0.76, activeFarm and activeFarm.id == farm.id and 0.62 or 0.84)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", frame.farmListContent, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", frame.farmListContent, "TOPRIGHT", 0, -yOffset)
        SetFarmRowVisual(row, frame.selectedFarmID == farm.id, activeFarm and activeFarm.id == farm.id)
        row:Show()
        yOffset = yOffset + FARM_ROW_HEIGHT + FARM_ROW_GAP
    end
    for index = #farms + 1, #(frame.farmRows or {}) do
        frame.farmRows[index]:Hide()
    end
    frame.farmListContent:SetHeight(math.max(1, yOffset))
    frame.emptyFarmText:SetShown(#farms == 0)

    local farm = self:GetCustomFarmByID(frame.selectedFarmID)
    for _, widget in ipairs(frame.detailsWidgets or {}) do
        widget:SetShown(farm ~= nil)
    end
    frame.emptyDetailsText:SetShown(farm == nil)
    if not farm then
        frame.activeStatusText:SetText(activeFarm and ("Building: " .. activeFarm.name) or "No farm is currently being built.")
        return
    end

    local isActive = activeFarm and activeFarm.id == farm.id
    frame.activeStatusText:SetText(activeFarm and ("Building: " .. activeFarm.name) or "No farm is currently being built.")
    frame.farmTitleText:SetText(farm.name)
    frame.farmMetaText:SetText(string.format("Created %s | Updated %s", FormatTimestamp(farm.createdAt), FormatTimestamp(farm.updatedAt)))
    frame.buildButton:SetText(isActive and "Finish Build" or "Build")
    frame.buildButton.tooltipText = isActive
        and "Stop adding list entries to this farm. The farm remains saved."
        or (activeFarm and ("Make this the active build farm instead of " .. activeFarm.name .. ".") or "Make this the active build farm.")
    if frame.buildButton.SetSelected then
        frame.buildButton:SetSelected(isActive)
    end
    local hasRoutePlan = type(self.HasCustomFarmRoutePlan) == "function" and self:HasCustomFarmRoutePlan(farm.id)
    frame.planButton:SetText(hasRoutePlan and "Replan Route" or "Plan Route")
    frame.openPlanButton:SetShown(hasRoutePlan)
    local characters = self:GetKnownCustomFarmCharacters()
    UIDropDownMenu_SetText(frame.characterDropdown, farm.assignedCharacter or "Select a character")
    if #characters == 0 and type(UIDropDownMenu_DisableDropDown) == "function" then
        UIDropDownMenu_DisableDropDown(frame.characterDropdown)
    elseif #characters > 0 and type(UIDropDownMenu_EnableDropDown) == "function" then
        UIDropDownMenu_EnableDropDown(frame.characterDropdown)
    end
    frame.noCharactersText:SetShown(#characters == 0)

    local entries = farm.entries or {}
    local steps = self:GetCustomFarmSteps(farm)
    local entryYOffset = 0
    local stepRowCount = 0
    local entryRowCount = 0
    local suggestionHeaderCount = 0
    local suggestionRowCount = 0
    for stepIndex, step in ipairs(steps) do
        local catalogFarm
        if step.catalogFarmID then
            catalogFarm = type(self.GetFarmByID) == "function" and self:GetFarmByID(step.catalogFarmID) or nil
            stepRowCount = stepRowCount + 1
            local stepRow = GetOrCreateStepRow(frame, stepRowCount)
            stepRow.catalogFarmID = step.catalogFarmID
            stepRow.firstItemID = step.entries[1] and step.entries[1].itemID or nil
            stepRow.nameText:SetText(step.name or step.catalogFarmID)
            local meta = step.sourcePath or step.activity or "Catalog farm"
            if #(step.mapNames or {}) > 0 then
                meta = meta .. " | " .. Join(step.mapNames, "")
            end
            meta = meta .. string.format(" | %d target%s", #(step.entries or {}), #(step.entries or {}) == 1 and "" or "s")
            if (tonumber(step.routeCount) or 0) > 0 then
                meta = meta .. string.format(" | %d route%s", step.routeCount, step.routeCount == 1 and "" or "s")
            end
            stepRow.metaText:SetText(meta)
            stepRow.background:SetColorTexture(1.0, 0.82, 0.18, stepIndex % 2 == 0 and 0.10 or 0.075)
            stepRow:ClearAllPoints()
            stepRow:SetPoint("TOPLEFT", frame.entryContent, "TOPLEFT", 0, -entryYOffset)
            stepRow:SetPoint("TOPRIGHT", frame.entryContent, "TOPRIGHT", 0, -entryYOffset)
            stepRow:Show()
            entryYOffset = entryYOffset + STEP_ROW_HEIGHT + STEP_ROW_GAP
        end
        for _, entry in ipairs(step.entries or {}) do
            entryRowCount = entryRowCount + 1
            local row = GetOrCreateEntryRow(frame, entryRowCount)
            ConfigureEntryRow(frame, row, entry, entryYOffset, entryRowCount % 2 == 0, step.catalogFarmID ~= nil)
            entryYOffset = entryYOffset + ENTRY_ROW_HEIGHT + ENTRY_ROW_GAP
        end
        if catalogFarm and type(self.GetFarmHighValueDropSuggestions) == "function" then
            local excludedItemIDs = {}
            for _, entry in ipairs(step.entries or {}) do
                excludedItemIDs[tonumber(entry.itemID)] = true
            end
            local suggestions, valueSourceLabel = self:GetFarmHighValueDropSuggestions(
                catalogFarm,
                excludedItemIDs,
                SUGGESTION_LIMIT
            )
            if #suggestions > 0 then
                suggestionHeaderCount = suggestionHeaderCount + 1
                local header = GetOrCreateSuggestionHeader(frame, suggestionHeaderCount)
                header.text:SetText(string.format(
                    "Other valuable drops from this dungeon (%s)",
                    valueSourceLabel or "current value source"
                ))
                header.background:SetColorTexture(0.22, 0.55, 0.72, 0.06)
                header:ClearAllPoints()
                header:SetPoint("TOPLEFT", frame.entryContent, "TOPLEFT", 0, -entryYOffset)
                header:SetPoint("TOPRIGHT", frame.entryContent, "TOPRIGHT", 0, -entryYOffset)
                header:Show()
                entryYOffset = entryYOffset + SUGGESTION_HEADER_HEIGHT
                for _, suggestion in ipairs(suggestions) do
                    suggestionRowCount = suggestionRowCount + 1
                    local row = GetOrCreateSuggestionRow(frame, suggestionRowCount)
                    ConfigureSuggestionRow(
                        frame,
                        row,
                        suggestion,
                        catalogFarm,
                        entryYOffset,
                        suggestionRowCount % 2 == 0
                    )
                    entryYOffset = entryYOffset + SUGGESTION_ROW_HEIGHT + ENTRY_ROW_GAP
                end
            end
        end
    end
    for index = entryRowCount + 1, #(frame.entryRows or {}) do
        frame.entryRows[index]:Hide()
    end
    for index = stepRowCount + 1, #(frame.stepRows or {}) do
        frame.stepRows[index]:Hide()
    end
    for index = suggestionHeaderCount + 1, #(frame.suggestionHeaders or {}) do
        frame.suggestionHeaders[index]:Hide()
    end
    for index = suggestionRowCount + 1, #(frame.suggestionRows or {}) do
        frame.suggestionRows[index]:Hide()
    end
    frame.entryContent:SetHeight(math.max(1, entryYOffset))
    frame.emptyEntriesText:SetShown(#entries == 0)
end

local function CreateFarmCatalogPanel(addon, frame, chrome, topOffset, includeMaximize)
    local panel = CreatePanel(frame, { 0.04, 0.05, 0.07, 0.96 }, { 1.0, 0.82, 0.18, 0.12 })
    panel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, topOffset)
    panel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 58)
    frame.catalogPanel = panel

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -13)
    title:SetText("Gathering farms")
    frame.catalogTitle = title

    local refreshButton = CreateButton(panel, 112, 22, "Refresh values", "neutral")
    refreshButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -11)
    refreshButton:SetScript("OnClick", function()
        addon:RefreshFarmCatalogValues()
    end)
    refreshButton.tooltipText = "Recalculate the selected category and type using the current item-value source."
    frame.catalogRefreshButton = refreshButton

    local maximizeButton
    if includeMaximize then
        maximizeButton = CreateButton(panel, 116, 22, "Maximize list", "neutral")
        maximizeButton:SetPoint("RIGHT", refreshButton, "LEFT", -8, 0)
        maximizeButton:SetScript("OnClick", function()
            addon:OpenFarmCatalogExpandedWindow()
        end)
        maximizeButton.tooltipText = "Open a larger window that mirrors the current farm catalog results."
        frame.catalogMaximizeButton = maximizeButton
    end

    local categoryLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    categoryLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -46)
    categoryLabel:SetText("Category")
    local dropdownSuffix = includeMaximize and "" or "Expanded"
    local categoryDropdown = CreateFrame(
        "Frame",
        "GoldTrackerFarmCatalogCategoryDropdown" .. dropdownSuffix,
        panel,
        "UIDropDownMenuTemplate"
    )
    categoryDropdown:SetPoint("LEFT", categoryLabel, "RIGHT", -8, -1)
    UIDropDownMenu_SetWidth(categoryDropdown, 120)
    UIDropDownMenu_Initialize(categoryDropdown, function(_, level)
        if level ~= 1 then
            return
        end
        for _, option in ipairs(FARM_CATALOG_CATEGORIES) do
            local category = option
            local info = UIDropDownMenu_CreateInfo()
            info.text = category.label
            info.value = category.id
            info.checked = addon.farmCatalogCategoryID == category.id
            info.func = function()
                addon.farmCatalogCategoryID = category.id
                addon.farmCatalogSubcategoryID = category.subcategories[1].id
                addon.farmCatalogExpandedFarmIDs = {}
                RefreshAllFarmCatalogFrames(addon, true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.catalogCategoryDropdown = categoryDropdown

    local subcategoryLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subcategoryLabel:SetPoint("LEFT", categoryDropdown, "RIGHT", -2, 1)
    subcategoryLabel:SetText("Type")
    local subcategoryDropdown = CreateFrame(
        "Frame",
        "GoldTrackerFarmCatalogSubcategoryDropdown" .. dropdownSuffix,
        panel,
        "UIDropDownMenuTemplate"
    )
    subcategoryDropdown:SetPoint("LEFT", subcategoryLabel, "RIGHT", -8, -1)
    UIDropDownMenu_SetWidth(subcategoryDropdown, 145)
    UIDropDownMenu_Initialize(subcategoryDropdown, function(_, level)
        if level ~= 1 then
            return
        end
        local category = FARM_CATALOG_CATEGORY_BY_ID[addon.farmCatalogCategoryID]
            or FARM_CATALOG_CATEGORIES[1]
        for _, option in ipairs(category.subcategories or {}) do
            local subcategory = option
            local info = UIDropDownMenu_CreateInfo()
            info.text = subcategory.label
            info.value = subcategory.id
            info.checked = addon.farmCatalogSubcategoryID == subcategory.id
            info.func = function()
                addon.farmCatalogSubcategoryID = subcategory.id
                addon.farmCatalogExpandedFarmIDs = {}
                RefreshAllFarmCatalogFrames(addon, true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.catalogSubcategoryDropdown = subcategoryDropdown

    local expansionLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    expansionLabel:SetPoint("LEFT", subcategoryDropdown, "RIGHT", -2, 1)
    expansionLabel:SetText("Expansion")
    local expansionDropdown = CreateFrame(
        "Frame",
        "GoldTrackerFarmCatalogExpansionDropdown" .. dropdownSuffix,
        panel,
        "UIDropDownMenuTemplate"
    )
    expansionDropdown:SetPoint("LEFT", expansionLabel, "RIGHT", -8, -1)
    UIDropDownMenu_SetWidth(expansionDropdown, 130)
    UIDropDownMenu_Initialize(expansionDropdown, function(_, level)
        if level ~= 1 then
            return
        end
        for _, option in ipairs(GetFarmCatalogExpansionOptions()) do
            local expansion = option
            local info = UIDropDownMenu_CreateInfo()
            info.text = expansion.label
            info.value = expansion.id
            info.checked = NormalizeFarmCatalogExpansionFilter(addon.farmCatalogExpansionFilter) == expansion.id
            info.func = function()
                addon.farmCatalogExpansionFilter = expansion.id
                addon.farmCatalogExpandedFarmIDs = {}
                RefreshAllFarmCatalogFrames(addon, true)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.catalogExpansionDropdown = expansionDropdown

    local searchInput = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    searchInput:SetSize(230, 22)
    searchInput:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -14, -35)
    searchInput:SetAutoFocus(false)
    searchInput:SetMaxLetters(80)
    searchInput:SetText(addon.farmCatalogSearchText or "")
    searchInput:SetScript("OnTextChanged", function(editBox)
        local value = editBox:GetText() or ""
        if value == (addon.farmCatalogSearchText or "") then
            return
        end
        addon.farmCatalogSearchText = value
        local otherFrames = {}
        if addon.myFarmsFrame then
            otherFrames[#otherFrames + 1] = addon.myFarmsFrame
        end
        if addon.farmCatalogExpandedFrame then
            otherFrames[#otherFrames + 1] = addon.farmCatalogExpandedFrame
        end
        for _, otherFrame in ipairs(otherFrames) do
            local otherInput = otherFrame and otherFrame.catalogSearchInput
            if otherInput and otherInput ~= editBox and otherInput:GetText() ~= value then
                otherInput:SetText(value)
            end
        end
        RefreshAllFarmCatalogFrames(addon, true)
    end)
    searchInput:SetScript("OnEnterPressed", function(editBox)
        editBox:ClearFocus()
    end)
    searchInput:SetScript("OnEscapePressed", function(editBox)
        if editBox:GetText() ~= "" then
            editBox:SetText("")
        else
            editBox:ClearFocus()
        end
    end)
    frame.catalogSearchInput = searchInput

    local searchLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    searchLabel:SetPoint("RIGHT", searchInput, "LEFT", -8, 0)
    searchLabel:SetText("Search")

    local header = CreateFrame("Frame", nil, panel)
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -76)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -76)
    header.nameText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.nameText:SetText("Farm / recorded item")
    header.nameText:SetJustifyH("LEFT")
    header.quantityText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.quantityText:SetText("Quantity")
    header.quantityText:SetJustifyH("RIGHT")
    header.unitValueText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.unitValueText:SetText("Unit / rare bonus")
    header.unitValueText:SetJustifyH("RIGHT")
    header.totalValueText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.totalValueText:SetText("Estimate / hour")
    header.totalValueText:SetJustifyH("RIGHT")
    header.locationText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.locationText:SetText("Location")
    header.locationText:SetJustifyH("LEFT")
    header.detailsText = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    header.detailsText:SetText("")
    SetCatalogColumnLayout(frame, header, true, false)
    frame.catalogHeader = header

    local underline = panel:CreateTexture(nil, "ARTWORK")
    underline:SetColorTexture(1, 0.82, 0.18, 0.18)
    underline:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -100)
    underline:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -100)
    underline:SetHeight(1)

    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -106)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 10)
    frame.catalogScrollFrame = scrollFrame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    frame.catalogContent = content

    local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 12, -12)
    emptyText:SetText("No farms match this category and search.")
    emptyText:SetJustifyH("LEFT")
    emptyText:Hide()
    frame.catalogEmptyText = emptyText

    local metaText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    metaText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 16, 42)
    metaText:SetPoint("RIGHT", frame, "RIGHT", -36, 42)
    metaText:SetJustifyH("LEFT")
    metaText:SetTextColor(0.72, 0.76, 0.84)
    frame.catalogMetaText = metaText
end

function GoldTracker:SetFarmsWorkspaceView(view)
    local frame = self.myFarmsFrame
    if not frame then
        return
    end
    view = view == "catalog" and "catalog" or "my"
    frame.farmsWorkspaceView = view
    local showMyFarms = view == "my"
    for _, widget in ipairs(frame.myFarmsViewWidgets or {}) do
        widget:SetShown(showMyFarms)
    end
    frame.catalogPanel:SetShown(not showMyFarms)
    frame.catalogMetaText:SetShown(not showMyFarms)
    if frame.myFarmsTabButton.SetSelected then
        frame.myFarmsTabButton:SetSelected(showMyFarms)
    end
    if frame.farmsTabButton.SetSelected then
        frame.farmsTabButton:SetSelected(not showMyFarms)
    end
    if showMyFarms then
        self:RefreshMyFarmsWindow()
    else
        self:RefreshFarmCatalogWindow(true)
    end
end

function GoldTracker:CreateFarmCatalogExpandedWindow()
    if self.farmCatalogExpandedFrame then
        return self.farmCatalogExpandedFrame
    end
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerFarmCatalogExpandedFrame", UIParent, "BasicFrameTemplateWithInset")
    local width = CATALOG_EXPANDED_WIDTH
    local height = CATALOG_EXPANDED_HEIGHT
    if UIParent and type(UIParent.GetWidth) == "function" then
        width = math.min(width, math.max(CATALOG_EXPANDED_MIN_WIDTH, (tonumber(UIParent:GetWidth()) or width) - 60))
    end
    if UIParent and type(UIParent.GetHeight) == "function" then
        height = math.min(height, math.max(CATALOG_EXPANDED_MIN_HEIGHT, (tonumber(UIParent:GetHeight()) or height) - 80))
    end
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetFrameStrata("DIALOG")
    if frame.SetToplevel then
        frame:SetToplevel(true)
    end
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(
            CATALOG_EXPANDED_MIN_WIDTH,
            CATALOG_EXPANDED_MIN_HEIGHT,
            CATALOG_EXPANDED_MAX_WIDTH,
            CATALOG_EXPANDED_MAX_HEIGHT
        )
    end
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:Raise()
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    local chrome = Theme:ApplyWindowChrome(frame, "Gathering Farms")
    frame.chrome = chrome
    Theme:RegisterSpecialFrame("GoldTrackerFarmCatalogExpandedFrame")
    CreateFarmCatalogPanel(addon, frame, chrome, -54, false)
    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = CATALOG_EXPANDED_MIN_WIDTH,
        minHeight = CATALOG_EXPANDED_MIN_HEIGHT,
        maxWidth = CATALOG_EXPANDED_MAX_WIDTH,
        maxHeight = CATALOG_EXPANDED_MAX_HEIGHT,
        onResizeStop = function()
            RefreshFarmCatalogFrame(addon, frame, false)
        end,
    })
    frame:SetScript("OnShow", function()
        RefreshFarmCatalogFrame(addon, frame, true)
    end)
    frame:SetScript("OnHide", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
    self.farmCatalogExpandedFrame = frame
    return frame
end

function GoldTracker:OpenFarmCatalogExpandedWindow()
    local frame = self:CreateFarmCatalogExpandedWindow()
    local wasShown = frame:IsShown()
    frame:Show()
    frame:Raise()
    if wasShown then
        RefreshFarmCatalogFrame(self, frame, true)
    end
end

function GoldTracker:CreateMyFarmsWindow()
    if self.myFarmsFrame then
        return self.myFarmsFrame
    end
    EnsureDialogs()
    local addon = self
    local frame = CreateFrame("Frame", "GoldTrackerMyFarmsFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(WINDOW_WIDTH, WINDOW_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:SetResizable(true)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(WINDOW_MIN_WIDTH, WINDOW_MIN_HEIGHT, WINDOW_MAX_WIDTH, WINDOW_MAX_HEIGHT)
    end
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    frame:SetScript("OnEvent", function(self)
        if self:IsShown() then
            addon:RefreshMyFarmsWindow()
        end
    end)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    frame.farmsWorkspaceView = "my"

    local chrome = Theme:ApplyWindowChrome(frame, "Farms")
    frame.chrome = chrome
    Theme:RegisterSpecialFrame("GoldTrackerMyFarmsFrame")

    local myFarmsTabButton = CreateButton(frame, 104, 24, "My Farms", "primary")
    myFarmsTabButton:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
    myFarmsTabButton:SetScript("OnClick", function()
        addon:SetFarmsWorkspaceView("my")
    end)
    if myFarmsTabButton.SetSelected then
        myFarmsTabButton:SetSelected(true)
    end
    frame.myFarmsTabButton = myFarmsTabButton

    local farmsTabButton = CreateButton(frame, 104, 24, "Farms", "primary")
    farmsTabButton:SetPoint("LEFT", myFarmsTabButton, "RIGHT", 8, 0)
    farmsTabButton:SetScript("OnClick", function()
        addon:SetFarmsWorkspaceView("catalog")
    end)
    if farmsTabButton.SetSelected then
        farmsTabButton:SetSelected(false)
    end
    frame.farmsTabButton = farmsTabButton
    Theme:LayoutExplorerTabs(chrome, { myFarmsTabButton, farmsTabButton })

    local newFarmButton = CreateButton(frame, 104, 24, "New Farm", "primary")
    newFarmButton:SetPoint("TOPRIGHT", chrome, "TOPRIGHT", -12, -54)
    newFarmButton:SetScript("OnClick", function()
        EnsureDialogs()
        if type(StaticPopup_Show) == "function" then
            StaticPopup_Show(NEW_DIALOG_KEY)
        end
    end)
    frame.newFarmButton = newFarmButton

    local activeStatusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    activeStatusText:SetPoint("RIGHT", newFarmButton, "LEFT", -12, 0)
    activeStatusText:SetPoint("LEFT", farmsTabButton, "RIGHT", 12, 0)
    activeStatusText:SetJustifyH("RIGHT")
    activeStatusText:SetTextColor(0.72, 0.86, 1.0)
    frame.activeStatusText = activeStatusText

    local listPanel = CreatePanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.12 })
    listPanel:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -86)
    listPanel:SetPoint("BOTTOMLEFT", chrome, "BOTTOMLEFT", 12, 38)
    listPanel:SetWidth(FARM_LIST_WIDTH)
    frame.listPanel = listPanel

    local listTitle = listPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    listTitle:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 12, -12)
    listTitle:SetText("Saved farms")

    local farmScrollFrame = CreateFrame("ScrollFrame", nil, listPanel, "UIPanelScrollFrameTemplate")
    farmScrollFrame:SetPoint("TOPLEFT", listPanel, "TOPLEFT", 10, -36)
    farmScrollFrame:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -28, 10)
    frame.farmScrollFrame = farmScrollFrame
    local farmListContent = CreateFrame("Frame", nil, farmScrollFrame)
    farmListContent:SetSize(1, 1)
    farmScrollFrame:SetScrollChild(farmListContent)
    frame.farmListContent = farmListContent
    frame.content = farmListContent
    local emptyFarmText = farmListContent:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyFarmText:SetPoint("TOPLEFT", farmListContent, "TOPLEFT", 8, -10)
    emptyFarmText:SetText("No custom farms yet.\nCreate one with New Farm.")
    emptyFarmText:SetJustifyH("LEFT")
    frame.emptyFarmText = emptyFarmText

    local bodyPanel = CreatePanel(frame, { 0.04, 0.05, 0.07, 0.92 }, { 1.0, 0.82, 0.18, 0.12 })
    bodyPanel:SetPoint("TOPLEFT", listPanel, "TOPRIGHT", 10, 0)
    bodyPanel:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 38)
    frame.bodyPanel = bodyPanel
    frame.detailsPanel = bodyPanel

    local emptyDetailsText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyDetailsText:SetPoint("CENTER", bodyPanel, "CENTER", 0, 0)
    emptyDetailsText:SetText("Select a farm or create a new one.")
    frame.emptyDetailsText = emptyDetailsText

    local farmTitleText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    farmTitleText:SetPoint("TOPLEFT", bodyPanel, "TOPLEFT", 14, -14)
    farmTitleText:SetPoint("RIGHT", bodyPanel, "RIGHT", -430, 0)
    farmTitleText:SetJustifyH("LEFT")
    farmTitleText:SetWordWrap(false)
    frame.farmTitleText = farmTitleText

    local buildButton = CreateButton(bodyPanel, 100, 24, "Build", "primary")
    buildButton:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -14, -10)
    buildButton:SetScript("OnClick", function(self)
        local activeFarm = addon:GetActiveCustomFarm()
        if activeFarm and activeFarm.id == frame.selectedFarmID then
            addon:FinishCustomFarmBuild(frame.selectedFarmID)
        else
            addon:SetActiveCustomFarm(frame.selectedFarmID)
        end
    end)
    frame.buildButton = buildButton

    local renameButton = CreateButton(bodyPanel, 76, 24, "Rename", "neutral")
    renameButton:SetPoint("RIGHT", buildButton, "LEFT", -8, 0)
    renameButton:SetScript("OnClick", function()
        if type(StaticPopup_Show) == "function" then
            StaticPopup_Show(RENAME_DIALOG_KEY, nil, nil, frame.selectedFarmID)
        end
    end)
    frame.renameButton = renameButton

    local deleteButton = CreateButton(bodyPanel, 70, 24, "Delete", "danger")
    deleteButton:SetPoint("RIGHT", renameButton, "LEFT", -8, 0)
    deleteButton:SetScript("OnClick", function()
        local farm = addon:GetCustomFarmByID(frame.selectedFarmID)
        if farm and type(StaticPopup_Show) == "function" then
            StaticPopup_Show(DELETE_DIALOG_KEY, farm.name, nil, farm.id)
        end
    end)
    frame.deleteButton = deleteButton

    local planButton = CreateButton(bodyPanel, 96, 24, "Plan Route", "primary")
    planButton:SetPoint("RIGHT", deleteButton, "LEFT", -8, 0)
    planButton:SetScript("OnClick", function()
        if type(addon.BuildCustomFarmRoutePlan) == "function" then
            addon:BuildCustomFarmRoutePlan(frame.selectedFarmID, true)
            addon:RefreshMyFarmsWindow()
        end
    end)
    frame.planButton = planButton

    local openPlanButton = CreateButton(bodyPanel, 88, 24, "Open Plan", "neutral")
    openPlanButton:SetPoint("RIGHT", planButton, "LEFT", -8, 0)
    openPlanButton:SetScript("OnClick", function()
        if type(addon.OpenFarmRoutePlanWindow) == "function" then
            addon:OpenFarmRoutePlanWindow(frame.selectedFarmID)
        end
    end)
    openPlanButton:Hide()
    frame.openPlanButton = openPlanButton

    local farmMetaText = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    farmMetaText:SetPoint("TOPLEFT", farmTitleText, "BOTTOMLEFT", 0, -5)
    farmMetaText:SetPoint("RIGHT", bodyPanel, "RIGHT", -14, 0)
    farmMetaText:SetJustifyH("LEFT")
    frame.farmMetaText = farmMetaText

    local characterPanel = CreatePanel(bodyPanel, { 0.025, 0.03, 0.045, 0.92 }, { 1, 1, 1, 0.08 })
    characterPanel:SetPoint("TOPLEFT", farmMetaText, "BOTTOMLEFT", 0, -12)
    characterPanel:SetPoint("TOPRIGHT", bodyPanel, "TOPRIGHT", -14, -64)
    characterPanel:SetHeight(72)
    frame.characterPanel = characterPanel
    local assignedTitle = characterPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    assignedTitle:SetPoint("TOPLEFT", characterPanel, "TOPLEFT", 10, -9)
    assignedTitle:SetText("Assigned character")
    local characterDropdown = CreateFrame("Frame", "GoldTrackerMyFarmsCharacterDropdown", characterPanel, "UIDropDownMenuTemplate")
    characterDropdown:SetPoint("TOPLEFT", assignedTitle, "BOTTOMLEFT", -16, -2)
    UIDropDownMenu_SetWidth(characterDropdown, 360)
    UIDropDownMenu_Initialize(characterDropdown, function(_, level)
        if level ~= 1 then
            return
        end
        local farm = addon:GetCustomFarmByID(frame.selectedFarmID)
        local noneInfo = UIDropDownMenu_CreateInfo()
        noneInfo.text = "None"
        noneInfo.value = "__NONE__"
        noneInfo.checked = farm and farm.assignedCharacter == nil
        noneInfo.func = function()
            addon:SetCustomFarmAssignedCharacter(frame.selectedFarmID, nil)
        end
        UIDropDownMenu_AddButton(noneInfo, level)
        for _, label in ipairs(addon:GetKnownCustomFarmCharacters()) do
            local characterLabel = label
            local info = UIDropDownMenu_CreateInfo()
            info.text = characterLabel
            info.value = characterLabel
            info.checked = farm and farm.assignedCharacter == characterLabel
            info.func = function()
                addon:SetCustomFarmAssignedCharacter(frame.selectedFarmID, characterLabel)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    frame.characterDropdown = characterDropdown
    local noCharactersText = characterPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    noCharactersText:SetPoint("LEFT", characterDropdown, "RIGHT", -4, 2)
    noCharactersText:SetPoint("RIGHT", characterPanel, "RIGHT", -10, 2)
    noCharactersText:SetJustifyH("LEFT")
    noCharactersText:SetText("Log into a character once to make it available here.")
    frame.noCharactersText = noCharactersText

    local entriesTitle = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    entriesTitle:SetPoint("TOPLEFT", characterPanel, "BOTTOMLEFT", 0, -12)
    entriesTitle:SetText("Farm steps and targets")
    local entriesHint = bodyPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    entriesHint:SetPoint("LEFT", entriesTitle, "RIGHT", 8, 0)
    entriesHint:SetText("Changes save immediately. Use Add in other Explorer lists while this farm is being built.")
    local entryPanel = CreatePanel(bodyPanel, { 0.025, 0.03, 0.045, 0.92 }, { 1, 1, 1, 0.08 })
    entryPanel:SetPoint("TOPLEFT", entriesTitle, "BOTTOMLEFT", 0, -8)
    entryPanel:SetPoint("BOTTOMRIGHT", bodyPanel, "BOTTOMRIGHT", -14, 12)
    frame.entryPanel = entryPanel
    local entryScrollFrame = CreateFrame("ScrollFrame", nil, entryPanel, "UIPanelScrollFrameTemplate")
    entryScrollFrame:SetPoint("TOPLEFT", entryPanel, "TOPLEFT", 6, -6)
    entryScrollFrame:SetPoint("BOTTOMRIGHT", entryPanel, "BOTTOMRIGHT", -28, 6)
    local entryContent = CreateFrame("Frame", nil, entryScrollFrame)
    entryContent:SetSize(1, 1)
    entryScrollFrame:SetScrollChild(entryContent)
    frame.entryScrollFrame = entryScrollFrame
    frame.entryContent = entryContent
    local emptyEntriesText = entryContent:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    emptyEntriesText:SetPoint("TOPLEFT", entryContent, "TOPLEFT", 8, -10)
    emptyEntriesText:SetText("This farm is empty. Start Build, then use Add on list entries.")
    frame.emptyEntriesText = emptyEntriesText
    frame.detailsWidgets = {
        farmTitleText,
        buildButton,
        renameButton,
        deleteButton,
        planButton,
        openPlanButton,
        farmMetaText,
        characterPanel,
        entriesTitle,
        entriesHint,
        entryPanel,
    }
    frame.myFarmsViewWidgets = {
        newFarmButton,
        activeStatusText,
        listPanel,
        bodyPanel,
    }

    CreateFarmCatalogPanel(addon, frame, chrome, -86, true)
    frame.catalogPanel:Hide()
    frame.catalogMetaText:Hide()

    Theme:CreateResizeButton(frame, {
        maximize = true,
        minWidth = WINDOW_MIN_WIDTH,
        minHeight = WINDOW_MIN_HEIGHT,
        maxWidth = WINDOW_MAX_WIDTH,
        maxHeight = WINDOW_MAX_HEIGHT,
        onResizeStop = function()
            addon:RefreshMyFarmsWindow()
        end,
    })
    frame:SetScript("OnShow", function()
        if not frame.suppressExplorerOnShow then
            if frame.farmsWorkspaceView == "catalog" then
                addon:RefreshFarmCatalogWindow(false)
            else
                addon:RefreshMyFarmsWindow()
            end
        end
    end)
    self.myFarmsFrame = frame
    self:RefreshMyFarmsWindow()
    return frame
end

function GoldTracker:OpenMyFarmsWindow()
    if type(self.OpenExplorerWindow) == "function" then
        self:OpenExplorerWindow("farms")
        return
    end
    local frame = self:CreateMyFarmsWindow()
    frame:Show()
    frame:Raise()
    self:RefreshMyFarmsWindow()
end
