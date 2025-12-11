local original_setfflag = clonefunction(setfflag)

local hooked_setfflag = function(flag, value)
    print("[+] setfflag called with: " .. tostring(flag) .. ", " .. tostring(value))
    return original_setfflag(flag, value)
end

hookfunction(setfflag, hooked_setfflag)
