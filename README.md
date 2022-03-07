# Lua 字符串插值

Lua 的格式化字符串又臭又长，不仅需要输入格式化模式，还存在参数冗余，比如：

```lua
print(string.format('Hi! %s am %s, %s am from %s', 'I', 'DoooReyn', 'I', 'China'))
-- output: Hi! I am DoooReyn, I am from China
```

于是就想到，在 Python 中，格式化字符串可以使用多种形式，其中一种是**字符串插值**，就解决了这个问题，如下：

```python
name = "DoooReyn"
 "I am {name}".format(name=name)
# output
# I am DoooReyn，我来自中国
```

于是就想 Lua 可不可以这么搞。那么就来尝试一下吧：

- 首先，定义下提取变量的规范：`{var}`，模式匹配为：`{%w+}`
- 接下来，准备解析格式化字符串，可以使用 Lua 的 `string.gsub`
- 最后，提取到变量名之后，进行替换操作即可

于是得到：

```lua
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
```

测试一下：

```lua
print(string.interpolate('Hi! {who} am {name}, {who} am from {from}', {who = 'I', name = 'DoooReyn', from = 'China'}))
-- output: Hi! I am DoooReyn, I am from China
print(string.interpolate('Hi! {1} am {2}, {1} am from {3}', {'I', 'DoooReyn', 'China'}))
-- output: Hi! I am DoooReyn, I am from China
```

完美！


## 后记

本来还想到另外一种做法，使用 `debug.getlocal` 获取调用 `string.interpolate` 之前的局部变量映射表来代替 `keys`:

```lua
local function getLocals(level)
    local i = 1
    local locals = {}
    while true do
        local name, value = debug.getlocal(level, i)
        if not name then
            break
        end
        locals[name] = value
        i = i + 1
        print('locals: ', name, value)
    end
    return locals
end

function string.interpolate(fmt)
    local locals = getLocals(3)
    local ret =
        string.gsub(
        fmt,
        '{%w+}',
        function(c)
            local key = string.match(c, "(%w+)")
            local val = locals[key]
            -- 去全局中查找
            val = val == nil and or _G[key] or val
            -- 转化为字符串
            val = tostring（val == nil and '' or val）
            return val
        end
    )
    return ret
end
```

这样一来，就可以省略 `keys`，使用起来也更灵活：

```lua
-- test
local who = "I"
local name = "DoooReyn"
local from = "China"
print(string.interpolate('Hi! {who} am {name}, {who} am from {from}'))
```

但是这样存在一些问题：

- 一是，如果局部变量很多，缓存的局部变量表就会很大，很浪费内存；如果改为每提取一个变量就去查询一次，额外的操作又会很多；
- 二是，如果变量是全局的，`getlocal` 是找不到的，于是就要增加去全局中查找的操作。

目前没有想到很好的解决方法，还是推荐使用第一种方式，毕竟它目的足够清楚，也不会有额外的损耗。

---

🤠 如果你喜欢这篇文章，请给我一个[Star⭐](https://github.com/DoooReyn/lua-string-interpolate)吧! 
