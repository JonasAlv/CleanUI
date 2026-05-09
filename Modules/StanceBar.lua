local _, UI = ...

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local isLocking = false

local function GetStanceFloor()
    if MultiBarBottomRight and MultiBarBottomRight:IsVisible() then
        return MultiBarBottomRightButton1
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsVisible() then
        return MultiBarBottomLeftButton1
    end
    return ActionButton1
end

local function ApplyStanceBarLockdown()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local frame = ShapeshiftBarFrame
    local floorFrame = GetStanceFloor()

    if frame and floorFrame then
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 4)
    end

    isLocking = false
end

local function InitStanceBar()
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

    if ShapeshiftBarFrame then
        ShapeshiftBarFrame.ignoreFramePositionManager = true
        
        local texturesToHide = { 
            ShapeshiftBarLeft, 
            ShapeshiftBarMiddle, 
            ShapeshiftBarRight 
        }
        for _, tex in ipairs(texturesToHide) do
            if tex then 
                tex:Hide()
                tex:SetAlpha(0) 
            end
        end
    end

    ApplyStanceBarLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then 
        InitStanceBar() 
    end
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplyStanceBarLockdown)
hooksecurefunc("MultiActionBar_Update", ApplyStanceBarLockdown)
hooksecurefunc("ShapeshiftBar_Update", ApplyStanceBarLockdown)