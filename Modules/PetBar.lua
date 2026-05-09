local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = _G["CleanUIHider"] or CreateFrame("Frame", "CleanUIPetHider", UIParent):Hide()
local isLocking = false

local function Lobotomize(f)
    if not f or f.isLobotomized then return end
    f.OrigSetPoint = f.SetPoint
    f.OrigClearAllPoints = f.ClearAllPoints
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.isLobotomized = true
end

local function GetAnchorFloor()
    if CleanUIStanceBarAnchor and CleanUIStanceBarAnchor:IsVisible() then
        return _G["ShapeshiftButton1"]
    elseif MultiBarBottomRight and MultiBarBottomRight:IsVisible() then
        return _G["MultiBarBottomRightButton1"]
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsVisible() then
        return _G["MultiBarBottomLeftButton1"]
    end
    return _G["ActionButton1"]
end

local function ApplyPetBarLockdown()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local anchor = _G["CleanUIPetBarAnchor"]
    if not anchor then isLocking = false; return end

    local floorFrame = GetAnchorFloor()
    
    if anchor and floorFrame then
        if anchor.isLobotomized then
            anchor:OrigClearAllPoints()
            anchor:OrigSetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 4)
        else
            anchor:ClearAllPoints()
            anchor:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 4)
            Lobotomize(anchor)
        end
    end

    for i = 1, 10 do
        local btn = _G["PetActionButton"..i]
        if btn then
            btn:ClearAllPoints()
            if i == 1 then
                btn:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", 0, 0)
            else
                btn:SetPoint("LEFT", _G["PetActionButton"..(i-1)], "RIGHT", 6, 0)
            end
        end
    end
    isLocking = false
end

local function InitPetBar()
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

    local petAnchor = _G["CleanUIPetBarAnchor"] or CreateFrame("Frame", "CleanUIPetBarAnchor", UIParent, "SecureHandlerStateTemplate")
    petAnchor:SetSize(350, 35)

    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(petAnchor, "PetBarAnchor")
    end

    if PetActionBarFrame then
        PetActionBarFrame:SetParent(Hider)
        PetActionBarFrame.ignoreFramePositionManager = true 
    end

    local artFrames = {SlidingActionBarTexture0, SlidingActionBarTexture1}
    for _, frame in ipairs(artFrames) do
        if frame then frame:Hide(); frame:SetAlpha(0) end
    end

    for i = 1, 10 do
        local btn = _G["PetActionButton"..i]
        if btn then btn:SetParent(petAnchor) end
    end

    RegisterStateDriver(petAnchor, "visibility", "[pet] show; hide")
    ApplyPetBarLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then InitPetBar() end
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplyPetBarLockdown)
hooksecurefunc("ShapeshiftBar_Update", ApplyPetBarLockdown)