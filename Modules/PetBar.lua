local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIPetHider", UIParent):Hide()
local isLocking = false

local function GetAnchorFloor()
    if CleanUIStanceBarAnchor and CleanUIStanceBarAnchor:IsShown() then
        return _G["ShapeshiftButton1"]
    elseif MultiBarBottomRight and MultiBarBottomRight:IsShown() then
        return _G["MultiBarBottomRightButton1"]
    elseif MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
        return _G["MultiBarBottomLeftButton1"]
    end
    return _G["ActionButton1"]
end

local function ApplyPetBarLockdown()
    if not CleanUIPositions or CleanUIPositions.MinimalistMode or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local anchor = _G["CleanUIPetBarAnchor"]
    if not anchor then isLocking = false; return end

    if not CleanUIPositions["PetBarAnchor"] then
        anchor:ClearAllPoints()
        local floorFrame = GetAnchorFloor()
        if floorFrame then
            anchor:SetPoint("BOTTOMLEFT", floorFrame, "TOPLEFT", 0, 4)
        else
            anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 150)
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
    if CleanUIPositions.MinimalistMode then 
        if _G["CleanUIPetBarAnchor"] then UnregisterStateDriver(_G["CleanUIPetBarAnchor"], "visibility") end
        return 
    end

    local petAnchor = _G["CleanUIPetBarAnchor"] or CreateFrame("Frame", "CleanUIPetBarAnchor", UIParent, "SecureHandlerStateTemplate")
    petAnchor:SetSize(350, 35)

    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(petAnchor, "PetBarAnchor")
    end

    if PetActionBarFrame then
        PetActionBarFrame:SetParent(Hider)
    end

    local artFrames = {SlidingActionBarTexture0, SlidingActionBarTexture1}
    for _, frame in ipairs(artFrames) do
        if frame then frame:Hide(); frame:SetAlpha(0) end
    end

    for i = 1, 10 do
        local btn = _G["PetActionButton"..i]
        if btn then
            btn:SetParent(petAnchor)
            btn:SetFrameLevel(5)
        end
    end

    RegisterStateDriver(petAnchor, "visibility", "[pet] show; hide")
    ApplyPetBarLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        InitPetBar()
    end
end)

if MultiBarBottomLeft then
    MultiBarBottomLeft:HookScript("OnShow", ApplyPetBarLockdown)
    MultiBarBottomLeft:HookScript("OnHide", ApplyPetBarLockdown)
end
if MultiBarBottomRight then
    MultiBarBottomRight:HookScript("OnShow", ApplyPetBarLockdown)
    MultiBarBottomRight:HookScript("OnHide", ApplyPetBarLockdown)
end

hooksecurefunc("UIParent_ManageFramePositions", ApplyPetBarLockdown)
hooksecurefunc("ShapeshiftBar_Update", ApplyPetBarLockdown)