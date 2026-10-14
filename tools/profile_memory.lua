-- Standalone approximation, NOT WoW addon memory accounting or native frames.
-- Usage: lua5.1 tools/profile_memory.lua [SavedVariables.lua] [--baseline]
-- The saved file is read into this process only; it is never written back.
local baselineMode = arg[2] == "--baseline"
local function readGit(path)
    local pipe = assert(io.popen("git show HEAD:" .. path, "r"))
    local source = pipe:read("*a")
    pipe:close()
    return source
end
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
local loaded = {}
local relocated = {}
for _, module in ipairs({ "Rares", "Instances", "Drops", "Materials", "Farms" }) do
    local name = "General-Gold-Tracker_" .. module
    local root = "Data/" .. name .. "/"
    for line in io.lines(root .. name .. ".toc") do
        line = line:gsub("\r", "")
        if line:match("%.lua$") and line ~= "Namespace.lua" then
            relocated["Data/" .. line] = root .. line
        end
    end
end
C_AddOns = { LoadAddOn = function(name)
    if loaded[name] then return true end
    local root = "Data/" .. name .. "/"
    local private = {}
    for line in io.lines(root .. name .. ".toc") do
        line = line:gsub("\r", "")
        if line:match("%.lua$") then assert(loadfile(root .. line))(name, private) end
    end
    loaded[name] = true
    return true
end }
local toc = baselineMode and readGit("General-Gold-Tracker.toc") or readFile("General-Gold-Tracker.toc")
collectgarbage("collect")
local initial = collectgarbage("count")
local function report(label)
    collectgarbage("collect")
    print(string.format("%s: %.3f MiB", label, (collectgarbage("count") - initial) / 1024))
end
for line in toc:gmatch("[^\r\n]+") do
    if line:match("^[^#].*%.lua$") then
        if baselineMode and not line:match("^Data/") then
            assert((loadstring or load)(readGit(line), "@" .. line))("General-Gold-Tracker", ns)
        else
            assert(loadfile(relocated[line] or line))("General-Gold-Tracker", ns)
        end
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
local moduleCount, knownCount, samples, histories = 0, 0, 0, 0
for _ in pairs(loaded) do moduleCount = moduleCount + 1 end
for _ in pairs(ns.GoldTracker.db.knownPriceHistory.items) do knownCount = knownCount + 1 end
for _, history in pairs(ns.GoldTracker.db.marketHistory.items) do
    histories = histories + 1
    samples = samples + #history.snapshots
end
print(string.format("Loaded data modules: %d; known-price entries: %d; detailed histories: %d; samples: %d",
    moduleCount, knownCount, histories, samples))
