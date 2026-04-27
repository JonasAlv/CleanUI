local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = _G["CleanUIHider"] or CreateFrame("Frame", "CleanUITotemHider", UIParent):Hide()
local isLocking = false

local function EnforceTotemPosition()
    if not CleanUIPositions or CleanUIPositions.MinimalistMode or InCombatLockdown() or isLocking then return end
    isLocking = true

    local anchor = _G["CleanUITotemBarAnchor"]
    if not anchor then isLocking = false; return end

    if not CleanUIPositions["TotemBarAnchor"] then
        anchor:ClearAllPoints()

        local floorFrame
        if CleanUIStanceBarAnchor and CleanUIStanceBarAnchor:IsShown() then
            floorFrame = ShapeshiftButton1
        elseif CleanUIPetBarAnchor and CleanUIPetBarAnchor:IsShown() then
             floorFrame = PetActionButton1
        elseif MultiBarBottomRight and MultiBarBottomRight:IsShown() then
            floorFrame = MultiBarBottomRightButton1
        elseif MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
            floorFrame = MultiBarBottomLeftButton1
        else
            floorFrame = ActionButton1
        end

        if floorFrame then
            anchor:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 10)
        else
            anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 180)
        end
    end
    
    isLocking = false
end

local function ApplyTotemBarSkin()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return end

    if CleanUIPositions.MinimalistMode then return end

    local totemAnchor = _G["CleanUITotemBarAnchor"] or CreateFrame("Frame", "CleanUITotemBarAnchor", UIParent)
    totemAnchor:SetSize(220, 40)
    
    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(totemAnchor, "TotemBarAnchor")
    end

    if MultiCastActionBarFrame then
        MultiCastActionBarFrame:SetParent(Hider)
        MultiCastActionBarFrame.ignoreFramePositionManager = true
    end

    local buttons = {
        MultiCastSummonSpellButton,
        MultiCastActionButton1,
        MultiCastActionButton2,
        MultiCastActionButton3,
        MultiCastActionButton4,
        MultiCastRecallSpellButton,
    }

    local prev
    for _, btn in ipairs(buttons) do
        if btn then
            btn:SetParent(totemAnchor)
            btn:ClearAllPoints()
            if not prev then
                btn:SetPoint("BOTTOMLEFT", totemAnchor, "BOTTOMLEFT", 0, 0)
            else
                btn:SetPoint("LEFT", prev, "RIGHT", 4, 0)
            end
            prev = btn
        end
    end

    if MultiCastFlyoutFrame then
        MultiCastFlyoutFrame:SetParent(totemAnchor)
    end

    EnforceTotemPosition()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyTotemBarSkin()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

if MultiBarBottomLeft then
    MultiBarBottomLeft:HookScript("OnShow", EnforceTotemPosition)
    MultiBarBottomLeft:HookScript("OnHide", EnforceTotemPosition)
end
if MultiBarBottomRight then
    MultiBarBottomRight:HookScript("OnShow", EnforceTotemPosition)
    MultiBarBottomRight:HookScript("OnHide", EnforceTotemPosition)
end

hooksecurefunc("MultiActionBar_Update", EnforceTotemPosition)
hooksecurefunc("UIParent_ManageFramePositions", EnforceTotemPosition)
hooksecurefunc("ShapeshiftBar_Update", EnforceTotemPosition)