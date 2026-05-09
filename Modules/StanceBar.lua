local _, UI = ...

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIStanceHider", UIParent):Hide()
local isLocking = false

local function Kill(f)
    if not f or f.isDead then return end
    f:Hide()
    if f.UnregisterAllEvents then f:UnregisterAllEvents() end 
    if f.SetAlpha then f:SetAlpha(0) end
    if f.SetParent and f:GetObjectType() == "Frame" then
        f:SetParent(Hider)
    end
    f.isDead = true
end

local function Lobotomize(f)
    if not f or f.isLobotomized then return end
    f.OrigSetPoint = f.SetPoint
    f.OrigClearAllPoints = f.ClearAllPoints
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.isLobotomized = true
end

local function ApplyStanceBarLockdown()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local anchor = _G["CleanUIStanceBarAnchor"]
    if not anchor then isLocking = false; return end

    local floorButton
    if MultiBarBottomRight and MultiBarBottomRight:IsVisible() then
        floorButton = MultiBarBottomRightButton1
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsVisible() then
        floorButton = MultiBarBottomLeftButton1
    else
        floorButton = ActionButton1
    end

    if anchor and floorButton then
        if anchor.isLobotomized then
            anchor:OrigClearAllPoints()
            anchor:OrigSetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 4)
        else
            anchor:ClearAllPoints()
            anchor:SetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 4)
            Lobotomize(anchor)
        end
    end

    if ShapeshiftButton1 then
        ShapeshiftButton1:ClearAllPoints()
        ShapeshiftButton1:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
    end
    
    for i = 2, 10 do
        local btn = _G["ShapeshiftButton"..i]
        if btn then
            btn:ClearAllPoints()
            btn:SetPoint("LEFT", _G["ShapeshiftButton"..(i-1)], "RIGHT", 4, 0)
        end
    end

    isLocking = false
end

local function InitStanceBar()
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

    local anchor = _G["CleanUIStanceBarAnchor"] or CreateFrame("Frame", "CleanUIStanceBarAnchor", UIParent)
    anchor:SetSize(30, 30)
    
    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(anchor, "StanceBarAnchor") 
    end

    if ShapeshiftBarFrame then
        ShapeshiftBarFrame.ignoreFramePositionManager = true
        Kill(ShapeshiftBarFrame)
    end

    for i = 1, 10 do
        local btn = _G["ShapeshiftButton"..i]
        if btn then btn:SetParent(anchor) end
    end

    local texturesToHide = { ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight }
    for _, tex in ipairs(texturesToHide) do
        if tex then tex:Hide(); tex:SetAlpha(0) end
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