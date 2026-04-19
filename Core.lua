local _, UI = ...

UI.ClassPath = "Interface\\AddOns\\CleanUI\\Media\\classes\\"

local Setup = CreateFrame("Frame")
Setup:RegisterEvent("PLAYER_LOGIN")
Setup:SetScript("OnEvent", function()
    if CleanUI_UseClassPortraits == nil then CleanUI_UseClassPortraits = true end

    if TargetFrameToTHealthBar then UI.ProtectFrame(TargetFrameToTHealthBar) end
    if FocusFrameToTHealthBar then UI.ProtectFrame(FocusFrameToTHealthBar) end
end)

SLASH_CLEANUI1 = "/cui"
SlashCmdList["CLEANUI"] = function(msg)
    msg = msg:lower()
    
    if msg == "reset" then
        CleanUIPositions = {}
        
        local frames = {
            PlayerFrame, TargetFrame, FocusFrame, PetFrame, 
            TargetFrameToT, FocusFrameToT, 
            CleanUILootAnchor,      
            CleanUIActionBarAnchor, 
            CleanUIPartyAnchor      
        }
        
        for i = 1, 4 do
            table.insert(frames, _G["PartyMemberFrame"..i])
            table.insert(frames, _G["PartyMemberFrame"..i.."PetFrame"])
        end

        for _, f in pairs(frames) do 
            if f then 
                f:SetMovable(true)
                f:SetUserPlaced(false) 
                f:ClearAllPoints()     
            end 
        end

        print("|cff00ff00CleanUI:|r Positions reset to defaults. Reloading...")
        ReloadUI()

    elseif msg:find("loot") and msg:find("test") then
        CleanUI_LootTestActive = not CleanUI_LootTestActive
        if UI.UpdateLootTest then UI.UpdateLootTest() end
        local state = CleanUI_LootTestActive and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"
        print("|cff00ff00CleanUI:|r Loot Test Mode " .. state)

    elseif msg:find("party") and msg:find("test") then
        CleanUI_TestActive = not CleanUI_TestActive
        if UI.UpdatePartyLayout then UI.UpdatePartyLayout() end
        local state = CleanUI_TestActive and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r"
        print("|cff00ff00CleanUI:|r Party Test Mode " .. state)

    elseif msg == "portrait" then
        CleanUI_UseClassPortraits = not CleanUI_UseClassPortraits
        if UI.RefreshPortraits then UI.RefreshPortraits() end
        
        local state = CleanUI_UseClassPortraits and "|cff00ff00Class Icons|r" or "|cffff0000Default 3D Faces|r"
        print("|cff00ff00CleanUI:|r Portraits are now using " .. state)
    end
end

hooksecurefunc("TargetofTarget_Update", function(self)
    if InCombatLockdown() then return end

    if self == TargetFrameToT then
        if not CleanUIPositions or not CleanUIPositions["TargetFrameToT"] then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMRIGHT", TargetFrame, "BOTTOMRIGHT", -10, -10)
        end
    elseif self == FocusFrameToT then
        if not CleanUIPositions or not CleanUIPositions["FocusFrameToT"] then
            self:ClearAllPoints()
            self:SetPoint("BOTTOMRIGHT", FocusFrame, "BOTTOMRIGHT", -10, -10)
        end
    end
end)