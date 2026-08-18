local _, UI = ...
UI.Modules = {}

local Setup = CreateFrame("Frame")
Setup:RegisterEvent("PLAYER_LOGIN")
Setup:RegisterEvent("PLAYER_ENTERING_WORLD")

Setup:SetScript("OnEvent", function(self, event)
    CleanUIPositions = CleanUIPositions or {}
    
    if CleanUIClassPortraits == nil then 
        CleanUIClassPortraits = true 
    end
    
    if CleanUIPositions.HideBarBg == nil then 
        CleanUIPositions.HideBarBg = true 
    end

    if event == "PLAYER_LOGIN" then
        if CleanUIPositions.EnableCharItems == nil then CleanUIPositions.EnableCharItems = true end
        if CleanUIPositions.EnableStatsColors == nil then CleanUIPositions.EnableStatsColors = true end
        if CleanUIPositions.EnableTooltipsTheming == nil then CleanUIPositions.EnableTooltipsTheming = true end
        if CleanUIPositions.EnableParty == nil then CleanUIPositions.EnableParty = true end
        if CleanUIPositions.EnableTooltip == nil then CleanUIPositions.EnableTooltip = true end
        if CleanUIPositions.EnableUnitFrames == nil then CleanUIPositions.EnableUnitFrames = true end

        if CleanUIPositions.EnableCharItems and UI.Modules["CharItems"] then UI.Modules["CharItems"]() end
        if CleanUIPositions.EnableStatsColors and UI.Modules["StatsColors"] then UI.Modules["StatsColors"]() end
        if CleanUIPositions.EnableTooltipsTheming and UI.Modules["TooltipsTheming"] then UI.Modules["TooltipsTheming"]() end
        if CleanUIPositions.EnableParty and UI.Modules["Party"] then UI.Modules["Party"]() end
        if CleanUIPositions.EnableTooltip and UI.Modules["Tooltip"] then UI.Modules["Tooltip"]() end
        if CleanUIPositions.EnableUnitFrames and UI.Modules["UnitFrames"] then UI.Modules["UnitFrames"]() end
    end

    if TargetFrameToTHealthBar then UI.ProtectFrame(TargetFrameToTHealthBar) end
    if FocusFrameToTHealthBar then UI.ProtectFrame(FocusFrameToTHealthBar) end
    
    if UI.RefreshPortraits then 
        UI.RefreshPortraits() 
    end
end)

SLASH_CLEANUI1 = "/cleanui"
SlashCmdList["CLEANUI"] = function(msg)
    msg = (msg or ""):lower()
    
    if msg == "reset" then
        CleanUIPositions = {} 
        CleanUIPositions.HideBarBg = true 
        CleanUIPositions.MinimapIcon = { hide = false }
        CleanUIClassPortraits = true

        local frames = {
            PlayerFrame, TargetFrame, FocusFrame, PetFrame, 
            TargetFrameToT, FocusFrameToT, 
            CleanUIPartyAnchor, CleanUIPetBarAnchor, 
            CleanUIStanceBarAnchor, CleanUIMicroMenuAnchor, CleanUIBagBarAnchor,
        }
        
        for i = 1, 4 do
            table.insert(frames, _G["PartyMemberFrame"..i])
            table.insert(frames, _G["PartyMemberFrame"..i.."PetFrame"])
        end

        for _, f in pairs(frames) do 
            if f then 
                if f.SetMovable then f:SetMovable(true) end
                f:SetUserPlaced(false) 
                f:ClearAllPoints()     
            end 
        end

        print("|cff00ff00CleanUI:|r UI reset to defaults. Reloading...")
        ReloadUI()

    elseif msg == "portrait" then
        CleanUIClassPortraits = not CleanUIClassPortraits
        if UI.RefreshPortraits then UI.RefreshPortraits() end
        print("|cff00ff00CleanUI:|r Portraits set to " .. (CleanUIClassPortraits and "|cff00ff00Class Icons|r" or "|cffff00003D Faces|r"))
    
    else
        InterfaceOptionsFrame_OpenToCategory("CleanUI")
        InterfaceOptionsFrame_OpenToCategory("CleanUI")
    end
end

hooksecurefunc("TargetofTarget_Update", function(self)
    if InCombatLockdown() then return end
    local name = (self == TargetFrameToT) and "TargetFrameToT" or "FocusFrameToT"
    local parent = (self == TargetFrameToT) and TargetFrame or FocusFrame

    if not CleanUIPositions or not CleanUIPositions[name] then
        self:ClearAllPoints()
        self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, -10)
    end
end)