local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function ApplyCleanSkin()

        _G["SHOW_MULTI_ACTIONBAR_1"] = 1   -- Bottom Left
        _G["SHOW_MULTI_ACTIONBAR_2"] = 1   -- Bottom Right
        _G["SHOW_MULTI_ACTIONBAR_3"] = nil -- Right Bar 1 (Hide)
        _G["SHOW_MULTI_ACTIONBAR_4"] = nil -- Right Bar 2 (Hide)
        _G["ALWAYS_SHOW_MULTIBARS"] = 1
        pcall(SetCVar, "lockActionBars", "1")
        pcall(SetCVar, "ALWAYS_SHOW_MULTIBARS", "1")
        MultiActionBar_Update()

        --MainMenuBar:SetScale(1.25)
        --MultiBarBottomLeft:SetScale(1.25)
        --MultiBarBottomRight:SetScale(1.25)
  
        MainMenuBarLeftEndCap:Hide()
        MainMenuBarRightEndCap:Hide()
    
end

F:SetScript("OnEvent", ApplyCleanSkin)