function string.interpolate(s, ...)
    local arr = {...}
    local ret = string.gsub(
        s,
        '{%d}',
        function(c)
            return arr[tonumber(string.match(c, '%d'))]
        end
    )
    return ret
end
