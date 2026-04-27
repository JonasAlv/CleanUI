local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = _G["CleanUIBagBarAnchor"]
        if anchor and anchor:GetScript("OnMouseDown") then
            anchor:GetScript("OnMouseDown")(anchor, button)
        end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = _G["CleanUIBagBarAnchor"]
    if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function ApplyBagBarSkin()
    if not CleanUIPositions or CleanUIPositions.MinimalistMode then return end

    local bagsAnchor = _G["CleanUIBagBarAnchor"] or CreateFrame("Frame", "CleanUIBagBarAnchor", UIParent)
    bagsAnchor:SetSize(220, 35)
    bagsAnchor:SetClampedToScreen(true)
    bagsAnchor:SetMovable(true)

    if not CleanUIPositions["BagBarAnchor"] then
        bagsAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 36)
    end

    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(bagsAnchor, "BagBarAnchor")
    end

    local bagButtons = {
        MainMenuBarBackpackButton,
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot,
        KeyRingButton
    }

    local function PositionBags()
        if InCombatLockdown() then return end

        local prev = nil
        local spacing = -1

        for _, btn in ipairs(bagButtons) do
            if btn then
                btn:SetParent(bagsAnchor)
                btn:SetFrameLevel(2)
                btn:ClearAllPoints()

                if not prev then
                    btn:SetPoint("BOTTOMRIGHT", bagsAnchor, "BOTTOMRIGHT", 0, 0)
                else
                    btn:SetPoint("RIGHT", prev, "LEFT", spacing, 0)
                end

                if not btn.cleanUIHooked then
                    btn:HookScript("OnMouseDown", RedirectClickToAnchor)
                    btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
                    btn.cleanUIHooked = true
                end

                prev = btn
            end
        end
    end

    hooksecurefunc("UIParent_ManageFramePositions", PositionBags)
    PositionBags()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyBagBarSkin()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)