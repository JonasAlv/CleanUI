local _, UI = ...

local Config = {
    ForceThreeBars = true,
    MainBarOffset = 255,
    VerticalPadding = 15,
    BarGap = 2,
}

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_LOGIN")

local Hider = CreateFrame("Frame", "CleanUIHider", UIParent)
Hider:Hide()

local isLocking = false

local function Kill(f)
    if not f or f.isDead then return end
    f:Hide()
    f:SetParent(Hider)
    f.Show = function() end
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
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, Config.BarGap)

        if not MultiBarBottomRight.isLobotomized then
            MultiBarBottomRight.ClearAllPoints = function() end
            MultiBarBottomRight.SetPoint = function() end
            MultiBarBottomRight.isLobotomized = true
        end
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
        ActionBarUpButton:SetPoint("BOTTOM", MainMenuBarPageNumber, "TOP", 0, 0)
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
    CleanUIPositions = CleanUIPositions or {}
    if CleanUIPositions.MinimalistMode == nil then CleanUIPositions.MinimalistMode = false end

    if Config.ForceThreeBars then
        _G["SHOW_MULTI_ACTIONBAR_1"] = 1
        _G["SHOW_MULTI_ACTIONBAR_2"] = 1
        InterfaceOptions_UpdateMultiActionBars()
    end

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

    for _, f in ipairs(framesToDisable) do
        if f then
            f:UnregisterAllEvents()
            f:Hide()
            f:SetParent(Hider)
        end
    end

    local texturesToHide = {
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        BonusActionBarTexture0, BonusActionBarTexture1,
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap
    }
    for _, tex in ipairs(texturesToHide) do
        if tex then tex:Hide(); tex:SetAlpha(0) end
    end

    ApplySelectiveLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        ApplyCleanSkin()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplySelectiveLockdown)
hooksecurefunc("MultiActionBar_Update", ApplySelectiveLockdown)