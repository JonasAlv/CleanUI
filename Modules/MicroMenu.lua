local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function GetTargetAnchor(self)
    local parent = self:GetParent()
    while parent do
        if parent == CleanUIMicroMenuAnchor then return parent end
        parent = parent:GetParent()
    end
    return nil
end

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = GetTargetAnchor(self)
        if anchor and anchor:GetScript("OnMouseDown") then
            anchor:GetScript("OnMouseDown")(anchor, button)
        end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = GetTargetAnchor(self)
    if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function ApplyMicroMenuSkin()
    local menuAnchor = CreateFrame("Frame", "CleanUIMicroMenuAnchor", UIParent)
    menuAnchor:SetSize(32, 35)
    menuAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0) 
    menuAnchor:SetClampedToScreen(true)

    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(menuAnchor, "MicroMenuAnchor") 
    end

    local microButtons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        AchievementMicroButton,
        QuestLogMicroButton,
        _G["SocialsMicroButton"],         -- Ascension specific
        LFDMicroButton,
        _G["PathToAscensionMicroButton"], -- Ascension specific
        _G["ChallengesMicroButton"],      -- Ascension specific
        MainMenuMicroButton,
        HelpMicroButton
    }

    local function PositionButtons()
        if InCombatLockdown() then return end
        
        local prev = nil
        local totalWidth = 0
        local buttonSpacing = -3 

        for _, btn in ipairs(microButtons) do
            if btn and btn:IsShown() then
                btn:SetParent(menuAnchor)
                btn:ClearAllPoints()
                btn:SetFrameLevel(2)
                
                if not prev then
                    btn:SetPoint("BOTTOMLEFT", menuAnchor, "BOTTOMLEFT", 0, 0)
                    totalWidth = btn:GetWidth()
                else
                    btn:SetPoint("LEFT", prev, "RIGHT", buttonSpacing, 0)
                    totalWidth = totalWidth + (btn:GetWidth() + buttonSpacing)
                end
                
                if not btn.cleanUIHooked then
                    btn:HookScript("OnMouseDown", RedirectClickToAnchor)
                    btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
                    btn.cleanUIHooked = true
                end
                prev = btn
            end
        end

        if totalWidth > 0 then
            menuAnchor:SetWidth(totalWidth)
        end
    end

    hooksecurefunc("UIParent_ManageFramePositions", PositionButtons)
    PositionButtons()
end

F:SetScript("OnEvent", ApplyMicroMenuSkin)