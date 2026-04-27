local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIPetHider", UIParent):Hide()
local isLocking = false

local function ApplyPetBarLockdown()
    if not CleanUIPositions or CleanUIPositions.MinimalistMode or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local anchor = _G["CleanUIPetBarAnchor"]
    if not anchor then isLocking = false; return end

    if not CleanUIPositions["PetBarAnchor"] then
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
            anchor:SetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 40)
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
    if CleanUIPositions.MinimalistMode then return end

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
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
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