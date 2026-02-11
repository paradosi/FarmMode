local farming = false

SLASH_FARMMODE1 = "/farm"
SlashCmdList["FARMMODE"] = function()
    if farming then
        Minimap:ClearAllPoints()
        Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
        Minimap:SetScale(1)
        farming = false
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6600FarmMode:|r Off")
    else
        Minimap:ClearAllPoints()
        Minimap:SetPoint("CENTER", UIParent, "CENTER", 0, 300)
        Minimap:SetScale(1.5)
        farming = true
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FarmMode:|r On - Minimap centered and enlarged")
    end
end
