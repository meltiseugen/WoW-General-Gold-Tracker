local _, NS = ...
local GoldTracker = NS.GoldTracker

-- One definition list drives Explorer navigation, setup, and Options.
local MODULES = {
    { id = "favorites", label = "Favorites", description = "Keep saved farming targets together for quick access." },
    { id = "alts", label = "Alts", description = "Browse your characters, gold, roles, and recorded locations." },
    { id = "priceAlerts", label = "Market Watch", width = 108, description = "Compare recorded item prices and spot market changes." },
    { id = "rares", label = "Rares", description = "Find rare farming targets and manage saved scans." },
    { id = "instances", label = "Instances", description = "Explore dungeon and raid loot and save farming scans." },
    { id = "drops", label = "Drops", description = "Browse farmable drops, mounts, pets, toys, and more." },
    { id = "materials", label = "Materials", description = "Find gathering and crafting materials and their farming areas." },
    { id = "farms", label = "Farms", description = "Browse farm guides and build your own custom farms." },
    { id = "inventory", label = "Bags", description = "Value auctionable bag items and use the Auction House Sell shortcut." },
}
local BY_ID = {}
GoldTracker.DEFAULTS = GoldTracker.DEFAULTS or {}
GoldTracker.DEFAULTS.welcomeCompleted = false
for _, module in ipairs(MODULES) do
    module.key = "module_" .. module.id
    BY_ID[module.id] = module
    GoldTracker.DEFAULTS[module.key] = true
end

function GoldTracker:GetExplorerModuleDefinitions()
    return MODULES
end

function GoldTracker:IsModuleEnabled(moduleID)
    local module = BY_ID[moduleID]
    if not module then return false end
    -- Older installations and newly added modules keep the full experience.
    return not self.db or self.db[module.key] ~= false
end

function GoldTracker:ResolveEnabledExplorerTab(tabID)
    if self:IsModuleEnabled(tabID) then return tabID end
    for _, module in ipairs(MODULES) do
        if self:IsModuleEnabled(module.id) then return module.id end
    end
end

function GoldTracker:ApplyModuleSelection()
    local frame = self.explorerFrame
    if frame then
        if frame:IsShown() and not self:IsModuleEnabled(frame.activeTabID) then
            self:SetExplorerTab(frame.activeTabID or "favorites")
        else
            self:RefreshExplorerTabs()
        end
    end
    if type(self.RefreshOptionsControls) == "function" then self:RefreshOptionsControls() end
end

function GoldTracker:SetModuleEnabled(moduleID, enabled)
    local module = BY_ID[moduleID]
    if not module or not self.db then return end
    self.db[module.key] = enabled == true
    self:ApplyModuleSelection()
end

function GoldTracker:NeedsWelcomeSetup()
    return self.db and self.db.welcomeCompleted ~= true
end

function GoldTracker:CompleteWelcomeSetup(selection)
    if not self:NeedsWelcomeSetup() then return end
    for _, module in ipairs(MODULES) do
        -- Skip/close supplies no selection and always enables every module.
        self.db[module.key] = not selection or selection[module.id] ~= false
    end
    self.db.welcomeCompleted = true
    self:ApplyModuleSelection()
    if self.welcomeFrame then self.welcomeFrame:Hide() end
    self:OpenMainWindowFromSlash()
end
