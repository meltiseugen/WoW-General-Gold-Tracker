local _, NS = ...

local JanisTheme = _G.JanisTheme
if type(JanisTheme) ~= "table" or type(JanisTheme.New) ~= "function" then
    error("General Gold Tracker requires JanisTheme-1.0. Check General-Gold-Tracker.toc load order.")
end

NS.JanisThemeClass = JanisTheme
NS.JanisTheme = NS.JanisTheme or JanisTheme:New({
    addon = NS.GoldTracker,
    assetRoot = "Interface\\AddOns\\General-Gold-Tracker\\Libs\\JanisTheme-1.0\\Assets\\",
})
