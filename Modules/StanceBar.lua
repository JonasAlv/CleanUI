local _, UI = ...

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIStanceHider", UIParent):Hide()
local isLocking = false

local function ApplyStanceBarLockdown()
    if not CleanUIPositions or CleanUIPositions.MinimalistMode or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local anchor = _G["CleanUIStanceBarAnchor"]
    if not anchor then isLocking = false; return end

    if not CleanUIPositions["StanceBarAnchor"] then
        anchor:ClearAllPoints()
        
        local floorButton
        if MultiBarBottomRight and MultiBarBottomRight:IsShown() then
            floorButton = MultiBarBottomRightButton1
        elseif MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
            floorButton = MultiBarBottomLeftButton1
        else
            floorButton = ActionButton1
        end
        
        if floorButton then
            anchor:SetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 4)
        else
            anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 110)
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
    if CleanUIPositions.MinimalistMode then return end

    local anchor = _G["CleanUIStanceBarAnchor"] or CreateFrame("Frame", "CleanUIStanceBarAnchor", UIParent)
    anchor:SetSize(30, 30)
    
    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(anchor, "StanceBarAnchor") 
    end

    for i = 1, 10 do
        local btn = _G["ShapeshiftButton"..i]
        if btn then
            btn:SetParent(anchor) 
        end
    end

    if ShapeshiftBarFrame then
        ShapeshiftBarFrame:SetParent(Hider)
    end
    
    local texturesToHide = {
        ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight
    }
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

if MultiBarBottomLeft then
    MultiBarBottomLeft:HookScript("OnShow", ApplyStanceBarLockdown)
    MultiBarBottomLeft:HookScript("OnHide", ApplyStanceBarLockdown)
end
if MultiBarBottomRight then
    MultiBarBottomRight:HookScript("OnShow", ApplyStanceBarLockdown)
    MultiBarBottomRight:HookScript("OnHide", ApplyStanceBarLockdown)
end

hooksecurefunc("UIParent_ManageFramePositions", ApplyStanceBarLockdown)
hooksecurefunc("ShapeshiftBar_Update", ApplyStanceBarLockdown)