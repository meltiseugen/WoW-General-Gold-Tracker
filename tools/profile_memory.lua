-- Standalone approximation, NOT WoW addon memory accounting or native frames.
-- Usage: lua5.1 tools/profile_memory.lua [SavedVariables.lua]
-- The saved file is read into this process only; it is never written back.
local function readFile(path)
    local file = assert(io.open(path, "rb"))
    local source = file:read("*a")
    file:close()
    return source
end
local noop = function() end
local ns = { GoldTracker = { SetScript = noop, RegisterEvent = noop } }
SlashCmdList = {}
WOW_PROJECT_MAINLINE = 1
time, date = os.time, os.date
CreateFrame = function() return { SetScript = noop, RegisterEvent = noop } end
C_AddOns = { LoadAddOn = function(name) error("Unexpected addon load: " .. name) end }
local toc = readFile("General-Gold-Tracker.toc")
collectgarbage("collect")
local initial = collectgarbage("count")
local function report(label)
    collectgarbage("collect")
    print(string.format("%s: %.3f MiB", label, (collectgarbage("count") - initial) / 1024))
end
for line in toc:gmatch("[^\r\n]+") do
    if line:match("^[^#].*%.lua$") then
        assert(loadfile(line))("General-Gold-Tracker", ns)
    end
end
report("Runtime definitions and startup data")
if arg[1] then assert(loadfile(arg[1]))() end
ns.GoldTracker:InitializeDatabase()
if ns.GoldTracker.InitializeMemoryStorage then ns.GoldTracker:InitializeMemoryStorage() end
report("Normalized startup with saved data")
local candidates = ns.GoldTracker:BuildKnownPriceScanCandidates()
print("Price candidates: " .. #candidates)
report("During candidate scan")
candidates = nil
report("After candidate release")
local knownCount, samples, histories = 0, 0, 0
for _ in pairs(ns.GoldTracker.db.knownPriceHistory.items) do knownCount = knownCount + 1 end
for _, history in pairs(ns.GoldTracker.db.marketHistory.items) do
    histories = histories + 1
    samples = samples + #history.snapshots
end
print(string.format("Bundled catalogs; known-price entries: %d; detailed histories: %d; samples: %d",
    knownCount, histories, samples))
