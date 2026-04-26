local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = CleanUIMicroMenuAnchor
        if anchor and anchor:GetScript("OnMouseDown") then
            anchor:GetScript("OnMouseDown")(anchor, button)
        end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = CleanUIMicroMenuAnchor
    if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function ApplyMicroMenuSkin()
    local menuAnchor = CreateFrame("Frame", "CleanUIMicroMenuAnchor", UIParent)
    menuAnchor:SetSize(300, 35) 
    menuAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    menuAnchor:SetClampedToScreen(true)
    menuAnchor:SetMovable(true)

    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(menuAnchor, "MicroMenuAnchor") 
    end

    local buttonNames = {
        "CharacterMicroButton",
        "SpellbookMicroButton",
        "TalentMicroButton",
        "AchievementMicroButton",
        "QuestLogMicroButton",
        "SocialsMicroButton",         
        "LFDMicroButton",
        "PVPMicroButton",
        "PathToAscensionMicroButton",
        "ChallengesMicroButton",
        "MainMenuMicroButton",
        "HelpMicroButton"
    }

    local function PositionButtons()
        if InCombatLockdown() then return end
        
        local prev = nil
        local totalWidth = 0
        local spacing = -3

        for _, name in ipairs(buttonNames) do
            local btn = _G[name]
            
            if btn and btn:IsShown() then
                btn:SetParent(menuAnchor)
                btn:ClearAllPoints()
                
                if not prev then
                    btn:SetPoint("BOTTOMLEFT", menuAnchor, "BOTTOMLEFT", 0, 0)
                    totalWidth = btn:GetWidth()
                else
                    btn:SetPoint("LEFT", prev, "RIGHT", spacing, 0)
                    totalWidth = totalWidth + (btn:GetWidth() + spacing)
                end
                
                if not btn.cleanUIHooked then
                    btn:HookScript("OnMouseDown", RedirectClickToAnchor)
                    btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
                    btn.cleanUIHooked = true
                end
                
                if btn.Flash then btn.Flash:Hide() end
                
                prev = btn
            end
        end

        if totalWidth > 0 then
            menuAnchor:SetWidth(totalWidth)
        end
    end

    hooksecurefunc("UpdateMicroButtons", PositionButtons)
    hooksecurefunc("UIParent_ManageFramePositions", PositionButtons)
    
    PositionButtons()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if UI.HaltModules then 
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            return 
        end

        ApplyMicroMenuSkin()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)