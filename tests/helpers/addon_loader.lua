local M = {}
local unpack_values = table.unpack or unpack

function M.load_module(relative_path, addon, ns_overrides)
    local ns = {
        GoldTracker = addon or {},
    }
    for key, value in pairs(ns_overrides or {}) do
        ns[key] = value
    end
    local chunk, err = loadfile(relative_path)
    assert(chunk, err)
    chunk("General-Gold-Tracker", ns)
    return ns.GoldTracker, ns
end

function M.with_globals(values, callback)
    local previous = {}
    for key, value in pairs(values or {}) do
        previous[key] = _G[key]
        _G[key] = value
    end

    local results = table.pack and table.pack(pcall(callback)) or { pcall(callback) }
    if not results.n then
        results.n = #results
    end
    for key in pairs(values or {}) do
        _G[key] = previous[key]
    end
    if not results[1] then
        error(results[2], 0)
    end
    return unpack_values(results, 2, results.n)
end

return M
