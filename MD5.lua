local md5 = {}

local function leftrotate(x, c)
    return (x << c) | (x >> (32 - c))
end

function md5.sumhexa(msg)
    local s = {
        7, 12, 17, 22,  5,  9, 14, 20,
        4, 11, 16, 23,  6, 10, 15, 21
    }
    local K = {}
    for i = 0, 63 do
        K[i + 1] = math.floor(math.abs(math.sin(i + 1)) * 2^32)
    end

    local a0, b0, c0, d0 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476

    local original_len_in_bits = #msg * 8
    msg = msg .. "\128" .. string.rep("\0", 63 - ((#msg + 8) % 64))
    msg = msg .. string.pack("<I8", original_len_in_bits)

    local chunks = {}
    for i = 1, #msg, 64 do
        chunks[#chunks + 1] = msg:sub(i, i + 63)
    end

    for _, chunk in ipairs(chunks) do
        local M = { string.unpack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", chunk) }
        local A, B, C, D = a0, b0, c0, d0

        for i = 0, 63 do
            local F, g
            if i < 16 then
                F = (B & C) | (~B & D)
                g = i
            elseif i < 32 then
                F = (D & B) | (~D & C)
                g = (5 * i + 1) % 16
            elseif i < 48 then
                F = B ~ C ~ D
                g = (3 * i + 5) % 16
            else
                F = C ~ (B | ~D)
                g = (7 * i) % 16
            end
            F = F + A + K[i + 1] + M[g + 1]
            A, D, C, B = D, C, B, B + leftrotate(F, s[(i // 16) * 4 + (i % 4) + 1])
        end

        a0 = a0 + A
        b0 = b0 + B
        c0 = c0 + C
        d0 = d0 + D
    end

    return string.format("%08x%08x%08x%08x", a0, b0, c0, d0)
end

-- Example usage:
local input = "Hello, World!"
local hash = md5.sumhexa(input)
print("MD5 hash of '" .. input .. "' is: " .. hash)
