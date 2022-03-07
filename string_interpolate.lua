function string.interpolate(fmt, keys)
    local ret =
        string.gsub(
        fmt,
        '{%w+}',
        function(c)
            local key = string.match(c, "(%w+)")
            -- 添加数字索引支持
            key = tonumber(key) or key
            local val = keys[key]
            -- 转化为字符串
            val = tostring（val == nil and '' or val）
            return val
        end
    )
    return ret
end
