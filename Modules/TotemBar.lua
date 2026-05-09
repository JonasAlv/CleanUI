local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = _G["CleanUIHider"] or CreateFrame("Frame", "CleanUITotemHider", UIParent):Hide()
local isLocking = false

local function Lobotomize(f)
    if not f or f.isLobotomized then return end
    f.OrigSetPoint = f.SetPoint
    f.OrigClearAllPoints = f.ClearAllPoints
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.isLobotomized = true
end

local function GetTotemFloor()
    if CleanUIPetBarAnchor and CleanUIPetBarAnchor:IsVisible() then
        return _G["PetActionButton1"]
    elseif CleanUIStanceBarAnchor and CleanUIStanceBarAnchor:IsVisible() then
        return _G["ShapeshiftButton1"]
    elseif MultiBarBottomRight and MultiBarBottomRight:IsVisible() then
        return _G["MultiBarBottomRightButton1"]
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsVisible() then
        return _G["MultiBarBottomLeftButton1"]
    end
    return _G["ActionButton1"]
end

local function EnforceTotemPosition()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true

    local anchor = _G["CleanUITotemBarAnchor"]
    if not anchor then isLocking = false; return end

    local floorFrame = GetTotemFloor()

    if anchor and floorFrame then
        if anchor.isLobotomized then
            anchor:OrigClearAllPoints()
            anchor:OrigSetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 10)
        else
            anchor:ClearAllPoints()
            anchor:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 10)
            Lobotomize(anchor)
        end
    end
    
    isLocking = false
end

local function ApplyTotemBarSkin()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return end
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

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
    end
end)

hooksecurefunc("MultiActionBar_Update", EnforceTotemPosition)
hooksecurefunc("UIParent_ManageFramePositions", EnforceTotemPosition)
hooksecurefunc("ShapeshiftBar_Update", EnforceTotemPosition)