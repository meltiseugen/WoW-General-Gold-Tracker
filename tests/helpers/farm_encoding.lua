-- Deterministic stand-ins for Blizzard's native codec APIs. These test the
-- sharing logic and data preservation; they do not implement the native CBOR wire format.
local M = {}

local function serialize(value)
    local kind = type(value)
    if kind == "boolean" then return value and "b1" or "b0" end
    if kind == "string" or kind == "number" then
        local text = kind == "number" and string.format("%.17g", value) or value
        return (kind == "string" and "s" or "n") .. #text .. ":" .. text
    end
    assert(kind == "table", "unsupported test value")
    local parts, count = {}, 0
    for key, child in pairs(value) do
        parts[#parts + 1], parts[#parts + 2] = serialize(key), serialize(child)
        count = count + 1
    end
    return "t" .. count .. ":" .. table.concat(parts)
end

local function deserialize(text)
    local position = 1
    local function read()
        local kind = text:sub(position, position)
        position = position + 1
        if kind == "b" then
            local value = text:sub(position, position)
            position = position + 1
            assert(value == "0" or value == "1")
            return value == "1"
        end
        local finish = assert(text:find(":", position, true))
        local length = assert(tonumber(text:sub(position, finish - 1)))
        position = finish + 1
        if kind == "t" then
            local result = {}
            for _ = 1, length do local key = read(); result[key] = read() end
            return result
        end
        assert(kind == "s" or kind == "n")
        local value = text:sub(position, position + length - 1)
        assert(#value == length)
        position = position + length
        return kind == "n" and assert(tonumber(value)) or value
    end
    local value = read()
    assert(position == #text + 1, "trailing data")
    return value
end

M.codec = {
    SerializeCBOR = serialize,
    DeserializeCBOR = deserialize,
    CompressString = function(text) return text end,
    DecompressString = function(text) return text end,
    EncodeBase64 = function(text) return (text:gsub(".", function(char) return string.format("%02x", char:byte()) end)) end,
    DecodeBase64 = function(text)
        assert(#text % 2 == 0 and not text:find("[^%x]"))
        return (text:gsub("..", function(pair) return string.char(tonumber(pair, 16)) end))
    end,
}

function M.wrap(package)
    local data, a, b = serialize(package), 1, 0
    for index = 1, #data do a = (a + data:byte(index)) % 65521; b = (b + a) % 65521 end
    return "GGT-FARMS:1:" .. #data .. ":" .. string.format("%08x", b * 65536 + a) .. ":"
        .. M.codec.EncodeBase64(M.codec.CompressString(data))
end

function M.unwrap(text)
    return deserialize(M.codec.DecompressString(M.codec.DecodeBase64(assert(text:match("^GGT%-FARMS:1:%d+:%x+:(.+)$")))))
end

return M
