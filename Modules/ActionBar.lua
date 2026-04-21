local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIHider", UIParent)
Hider:Hide()

local function SkinButton(btn)
    if not btn then return end
    local name = btn:GetName()
    local icon = _G[name.."Icon"]
    local nt = btn:GetNormalTexture()
    local flash = _G[name.."Flash"]
    local hotkey = _G[name.."HotKey"]

    if icon then 
        icon:ClearAllPoints()
        icon:SetAllPoints(btn)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    end
    if nt then nt:SetAlpha(1) end
    if flash then flash:SetTexture(nil) end
    if btn.SetPushedTexture then btn:SetPushedTexture(nil) end
    if hotkey then hotkey:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE") end
    if _G[name.."Border"] then _G[name.."Border"]:SetAlpha(0) end 
end

local isLocking = false

local function ApplySelectiveLockdown()
    if InCombatLockdown() or isLocking then return end
    isLocking = true

    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 255, 15)
    
    if not MainMenuBar.isLobotomized then
        MainMenuBar.ClearAllPoints = function() end
        MainMenuBar.SetPoint = function() end
        MainMenuBar.isLobotomized = true
    end

    if MultiBarBottomLeft then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 2)
        
        if not MultiBarBottomLeft.isLobotomized then
            MultiBarBottomLeft.ClearAllPoints = function() end
            MultiBarBottomLeft.SetPoint = function() end
            MultiBarBottomLeft.isLobotomized = true
        end
    end
    
    if MultiBarBottomRight then
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, 2)
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
        ActionBarUpButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", 0, 18)
        ActionBarUpButton:Show()
    end

    if ActionBarDownButton then
        ActionBarDownButton:SetParent(MainMenuBar)
        ActionBarDownButton:ClearAllPoints()
        ActionBarDownButton:SetPoint("CENTER", MainMenuBarPageNumber, "CENTER", 0, -18)
        ActionBarDownButton:Show()
    end

    isLocking = false
end

local function ApplyCleanSkin()
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

    for i = 1, 12 do
        SkinButton(_G["ActionButton"..i])
        SkinButton(_G["MultiBarBottomLeftButton"..i])
        SkinButton(_G["MultiBarBottomRightButton"..i])
    end
    
    ApplySelectiveLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyCleanSkin()
    end
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplySelectiveLockdown)
hooksecurefunc("MultiActionBar_Update", ApplySelectiveLockdown)