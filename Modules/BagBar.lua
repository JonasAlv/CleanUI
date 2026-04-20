local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = self:GetParent()
        if anchor:GetScript("OnMouseDown") then anchor:GetScript("OnMouseDown")(anchor, button) end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = self:GetParent()
    if anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function ApplyBagBarSkin()
    local bagsAnchor = CreateFrame("Frame", "CleanUIBagBarAnchor", UIParent)
    bagsAnchor:SetSize(220, 35)
    bagsAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 36) 
    bagsAnchor:SetClampedToScreen(true)

    if UI.MakeMovableAndSave then UI.MakeMovableAndSave(bagsAnchor, "BagBarAnchor") end

    local bagButtons = {
        MainMenuBarBackpackButton,
        CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot,
        KeyRingButton 
    }

    local function PositionBags()
        if InCombatLockdown() then return end

        for i, btn in ipairs(bagButtons) do
            if btn then
                btn:SetParent(bagsAnchor)
                btn:SetFrameLevel(2)
                btn:ClearAllPoints()
                
                if btn == MainMenuBarBackpackButton then
                    btn:SetPoint("BOTTOMRIGHT", bagsAnchor, "BOTTOMRIGHT", 0, 0)
                elseif btn == KeyRingButton then
                    btn:SetPoint("RIGHT", _G["CharacterBag3Slot"], "LEFT", -4, 0)
                else
                    local slotID = i - 2 
                    if slotID == 0 then
                        btn:SetPoint("RIGHT", MainMenuBarBackpackButton, "LEFT", -4, 0)
                    else
                        btn:SetPoint("RIGHT", _G["CharacterBag"..(slotID-1).."Slot"], "LEFT", -4, 0)
                    end
                end

                if not btn.cleanUIHooked then
                    btn:HookScript("OnMouseDown", RedirectClickToAnchor)
                    btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
                    btn.cleanUIHooked = true
                end
            end
        end
    end

    hooksecurefunc("UIParent_ManageFramePositions", PositionBags)
    PositionBags()
end

F:SetScript("OnEvent", ApplyBagBarSkin)