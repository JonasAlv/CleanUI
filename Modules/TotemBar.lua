local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local isLocking = false

local function GetTotemFloor()
    if PetActionBarFrame and PetActionBarFrame:IsVisible() then
        return _G["PetActionButton1"]
    elseif ShapeshiftBarFrame and ShapeshiftBarFrame:IsVisible() then
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

    local frame = MultiCastActionBarFrame
    local floorFrame = GetTotemFloor()

    if frame and floorFrame then
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 10)
    end
    
    isLocking = false
end

local function ApplyTotemBarSkin()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return end
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

    if MultiCastActionBarFrame then
        MultiCastActionBarFrame.ignoreFramePositionManager = true
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