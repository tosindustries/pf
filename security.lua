local TOSIndustries_Security = {
    _VERIFIED = true,
    _KEY = "TOS"..string.char(95,73,110,100,117,115,116,114,105,101,115),
    _SALT = string.char(84,79,83,95,73,78,68),
    _CHECK = function(self) 
        return self._VERIFIED and 
               self._KEY:find("TOS") and 
               self._SALT:find("TOS") and
               debug.info(2, "s"):find("TOS")
    end,
    _VALIDATE = function(self, module)
        if not self:_CHECK() then return false end
        return module and module._SEC == self._KEY
    end
}

return TOSIndustries_Security 