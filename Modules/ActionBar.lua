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
    
    if nt then 
        nt:SetAlpha(1) 
    end

    if flash then flash:SetTexture(nil) end
    if btn.SetPushedTexture then btn:SetPushedTexture(nil) end
    
    if hotkey then
        hotkey:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    end

    local border = _G[name.."Border"]
    if border then border:SetAlpha(0) end 
end

local isLocking = false

local function ApplySelectiveLockdown()
    if InCombatLockdown() or isLocking then return end
    isLocking = true

    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 255, 15)
    
    if MainMenuBar.SetPoint ~= (function() end) then
        MainMenuBar.ClearAllPoints = function() end
        MainMenuBar.SetPoint = function() end
    end

    if MultiBarBottomLeft then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 2)
    end
    
    if MultiBarBottomRight then
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, 2)
    end

    isLocking = false
end

local function ApplyCleanSkin()
    local framesToHide = {
        MainMenuBarOverlayFrame, MainMenuBarMaxLevelBar,
        MainMenuExpBar, ReputationWatchBar, MainMenuBarPerformanceBarFrame,
        CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, 
        SocialsMicroButton, WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
        MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot, KeyRingButton
    }
    for _, f in ipairs(framesToHide) do
        if f then f:SetParent(Hider) end
    end

    local texturesToHide = {
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        BonusActionBarTexture0, BonusActionBarTexture1,
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap
    }
    for _, tex in ipairs(texturesToHide) do
        if tex then tex:SetAlpha(0) end
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