local _, UI = ...

local Config = {
    MainBarOffset = 255,   
    VerticalPadding = 15,  
    BarGap = 2,            
}

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIHider", UIParent):Hide()
local isLocking = false

local function Kill(f)
    if not f or f.isDead then return end
    f:Hide()
    if f.SetAlpha then f:SetAlpha(0) end
    if f.SetParent and f.GetObjectType and f:GetObjectType() == "Frame" then
        f:SetParent(Hider)
    end
    if f.Show then f.Show = function() end end
    f.isDead = true
end

local function ApplySelectiveLockdown()
    if CleanUIPositions.MinimalistMode or InCombatLockdown() or isLocking then return end
    isLocking = true

    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", Config.MainBarOffset, Config.VerticalPadding)
    
    if not MainMenuBar.isLobotomized then
        MainMenuBar.ClearAllPoints = function() end
        MainMenuBar.SetPoint = function() end
        MainMenuBar.isLobotomized = true
    end

    if MultiBarBottomLeft then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, Config.BarGap)
        if not MultiBarBottomLeft.isLobotomized then
            MultiBarBottomLeft.ClearAllPoints = function() end
            MultiBarBottomLeft.SetPoint = function() end
            MultiBarBottomLeft.isLobotomized = true
        end
    end
    
    if MultiBarBottomRight then
        local bar2Visible = MultiBarBottomLeft and MultiBarBottomLeft:IsShown()
        local anchor = bar2Visible and MultiBarBottomLeft or ActionButton1
        
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, Config.BarGap)
    end

    if MainMenuBarPageNumber then
        MainMenuBarPageNumber:SetParent(MainMenuBar)
        MainMenuBarPageNumber:ClearAllPoints()
        MainMenuBarPageNumber:SetPoint("LEFT", ActionButton12, "RIGHT", 12, 0)
        MainMenuBarPageNumber:Show()
    end

    if ActionBarUpButton then
        ActionBarUpButton:SetParent(MainMenuBar)
        ActionBarUpButton:ClearAllPoints()
        ActionBarUpButton:SetPoint("BOTTOM", MainMenuBarPageNumber, "TOP", 0, 2)
        ActionBarUpButton:Show()
    end

    if ActionBarDownButton then
        ActionBarDownButton:SetParent(MainMenuBar)
        ActionBarDownButton:ClearAllPoints()
        ActionBarDownButton:SetPoint("TOP", MainMenuBarPageNumber, "BOTTOM", 0, -2)
        ActionBarDownButton:Show()
    end

    isLocking = false
end

local function ApplyCleanSkin()
    if CleanUIPositions.MinimalistMode then
        UI.HaltModules = true
        Kill(MainMenuBarLeftEndCap)
        Kill(MainMenuBarRightEndCap)
        return 
    end

    local framesToDisable = {
        MainMenuBarOverlayFrame, MainMenuBarMaxLevelBar, MainMenuExpBar, 
        ReputationWatchBar, MainMenuBarPerformanceBarFrame, ExhaustionTick, 
        MainMenuBarArtFrame, BonusActionBarFrame,
        CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, 
        SocialsMicroButton, WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
        MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot, KeyRingButton
    }
    for _, f in ipairs(framesToDisable) do Kill(f) end

    local texturesToHide = {
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        BonusActionBarTexture0, BonusActionBarTexture1,
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap
    }
    for _, tex in ipairs(texturesToHide) do Kill(tex) end

    ApplySelectiveLockdown()
end

F:SetScript("OnEvent", function(self, event)
    ApplyCleanSkin()
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplySelectiveLockdown)
hooksecurefunc("MultiActionBar_Update", ApplySelectiveLockdown)