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
    if f.UnregisterAllEvents then f:UnregisterAllEvents() end -- Stop logic without taint
    if f.SetAlpha then f:SetAlpha(0) end
    
    if f.SetParent and f:GetObjectType() == "Frame" then
        f:SetParent(Hider)
    end
    
    f.isDead = true
end

local function ApplySelectiveLockdown()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true

    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", Config.MainBarOffset, Config.VerticalPadding)
    
    if not MainMenuBar.isLobotomized then
        MainMenuBar.ClearAllPoints = function() end
        MainMenuBar.SetPoint = function() end
        MainMenuBar.isLobotomized = true
    end

    if BonusActionBarFrame then
        BonusActionBarFrame:ClearAllPoints()
        BonusActionBarFrame:SetPoint("BOTTOM", MainMenuBar, "BOTTOM", 0, 0)
    end

    for i = 1, 12 do
        local mainBtn = _G["ActionButton"..i]
        local bonusBtn = _G["BonusActionButton"..i]
        
        if mainBtn then
            mainBtn:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(mainBtn)
        end
        
        if bonusBtn then
            bonusBtn:SetAttribute("showgrid", 1)
            ActionButton_ShowGrid(bonusBtn)
            -- Position bonus buttons to match main buttons
            bonusBtn:ClearAllPoints()
            bonusBtn:SetPoint("CENTER", mainBtn, "CENTER", 0, 0)
        end
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
        local anchor = bar2Visible and MultiBarBottomLeftButton1 or ActionButton1
        
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, Config.BarGap)
    end

    isLocking = false
end

local function ApplyCleanSkin()
    if CleanUIPositions and CleanUIPositions.MinimalistMode then
        UI.HaltModules = true
        Kill(MainMenuBarLeftEndCap)
        Kill(MainMenuBarRightEndCap)
        return 
    end

    local framesToDisable = {
        MainMenuBarOverlayFrame, MainMenuBarMaxLevelBar, MainMenuExpBar, 
        ReputationWatchBar, MainMenuBarPerformanceBarFrame, ExhaustionTick, 
        MainMenuBarArtFrame, 
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

hooksecurefunc("ShowBonusActionBar", function()
    for i = 1, 12 do
        local btn = _G["ActionButton"..i]
        if btn then btn:SetAlpha(0) end -- Use Alpha to avoid potential secure header taint
    end
end)

hooksecurefunc("HideBonusActionBar", function()
    for i = 1, 12 do
        local btn = _G["ActionButton"..i]
        if btn then btn:SetAlpha(1) end
    end
end)

F:SetScript("OnEvent", function(self, event)
    ApplyCleanSkin()
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplySelectiveLockdown)
hooksecurefunc("MultiActionBar_Update", ApplySelectiveLockdown)