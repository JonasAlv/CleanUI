local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIHider", UIParent)
Hider:Hide()

local function SkinButton(btn)
    if not btn then return end
    
    local icon = _G[btn:GetName().."Icon"]
    if icon then 
        icon:ClearAllPoints()
        icon:SetAllPoints(btn)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    end
    
    local nt = btn:GetNormalTexture()
    if nt then nt:SetAlpha(0) end
    if _G[btn:GetName().."Border"] then _G[btn:GetName().."Border"]:SetAlpha(0) end
    
    if not btn.cleanUIBorder then
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
        border:SetTexture(0, 0, 0, 1) 
        btn.cleanUIBorder = border
    end
    
    local ct = btn:GetCheckedTexture()
    if ct then 
        ct:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        ct:SetBlendMode("ADD")
        ct:ClearAllPoints()
        ct:SetAllPoints(btn)
    end
    
    local ht = btn:GetHighlightTexture()
    if ht then
        ht:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        ht:SetBlendMode("ADD")
        ht:ClearAllPoints()
        ht:SetAllPoints(btn)
    end
end

local function EnforceBarPositions()
    if InCombatLockdown() then return end
    
    if MultiBarBottomLeftButton1 and ActionButton1 then
        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 2)
    end
    
    if MultiBarBottomRightButton1 and MultiBarBottomLeftButton1 then
        MultiBarBottomRightButton1:ClearAllPoints()
        MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0, 2)
    end
    
end

local function ApplyCleanSkin()
    MainMenuBar.ignoreFramePositionManager = true
    MainMenuBar:ClearAllPoints()
    MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 230, 15) 
    
    local framesToDisable = {
        MainMenuBarOverlayFrame, MainMenuBarMaxLevelBar,
        MainMenuExpBar, ReputationWatchBar, MainMenuBarPerformanceBarFrame,
        CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton, 
        SocialsMicroButton, WorldMapMicroButton, MainMenuMicroButton, HelpMicroButton,
        MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot, KeyRingButton
    }
    
    for _, frame in ipairs(framesToDisable) do
        if frame then 
            frame:SetParent(Hider) 
            frame:SetAlpha(0)
            if frame.EnableMouse then frame:EnableMouse(false) end 
        end
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
        SkinButton(_G["BonusActionButton"..i])
        SkinButton(_G["MultiBarBottomLeftButton"..i])
        SkinButton(_G["MultiBarBottomRightButton"..i])
    end

    EnforceBarPositions()
end

F:SetScript("OnEvent", function(self, event) 
    if event == "PLAYER_ENTERING_WORLD" then 
        ApplyCleanSkin() 
    end 
end)

hooksecurefunc("UIParent_ManageFramePositions", EnforceBarPositions)
hooksecurefunc("MultiActionBar_Update", EnforceBarPositions)