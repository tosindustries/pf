-- TOS Industries v1 Loader
local function main()
    local success, script = pcall(function()
        return game:HttpGet('https://raw.githubusercontent.com/tosind/loader/main/script.lua')
    end)
    
    if success then
        return loadstring(script)()
    else
        warn("Failed to load script")
        return false
    end
end

return main()