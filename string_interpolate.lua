function string.interpolate(fmt, keys)
    keys = type(keys) == "table" and keys or {}
    local ret =
        string.gsub(
        fmt,
        '{%w+}',
        function(c)
            local key = string.match(c, "(%w+)")
            // 添加数字索引支持
            key = tonumber(key) or key
            return keys[key] or ''
        end
    )
    return ret
end
