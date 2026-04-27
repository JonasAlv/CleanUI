local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIPetHider", UIParent)
Hider:Hide()

local function GetTargetAnchor(self)
    local parent = self:GetParent()
    while parent do
        if parent == CleanUIPetBarAnchor then return parent end
        parent = parent:GetParent()
    end
    return nil
end

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = GetTargetAnchor(self)
        if anchor and anchor:GetScript("OnMouseDown") then
            anchor:GetScript("OnMouseDown")(anchor, button)
        end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = GetTargetAnchor(self)
    if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function SkinButton(btn)
    if not btn then return end
    local name = btn:GetName()
    local icon = _G[name.."Icon"]
    if icon then icon:SetTexCoord(0, 1, 0, 1) end
    if btn:GetNormalTexture() then btn:GetNormalTexture():SetAlpha(1) end

    if not btn.cleanUIHooked then
        btn:HookScript("OnMouseDown", RedirectClickToAnchor)
        btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
        btn.cleanUIHooked = true
    end
end

local function ApplyPetBarSkin()
    local petAnchor = _G["CleanUIPetBarAnchor"] or CreateFrame("Frame", "CleanUIPetBarAnchor", UIParent, "SecureHandlerStateTemplate")
    petAnchor:SetSize(350, 35)

    petAnchor:ClearAllPoints()
    petAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    petAnchor:SetClampedToScreen(true)

    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(petAnchor, "PetBarAnchor")
    end

    if PetActionBarFrame then
        PetActionBarFrame:SetAlpha(0)
        PetActionBarFrame:EnableMouse(false)
        PetActionBarFrame:SetSize(1, 1)
    end

    local artFrames = {SlidingActionBarTexture0, SlidingActionBarTexture1}
    for _, frame in ipairs(artFrames) do
        if frame then frame:SetParent(Hider) end
    end

    for i = 1, 10 do
        local btn = _G["PetActionButton"..i]
        if btn then
            btn:SetParent(petAnchor)
            btn:SetFrameLevel(5)
            btn:ClearAllPoints()

            if i == 1 then
                btn:SetPoint("BOTTOMLEFT", petAnchor, "BOTTOMLEFT", 0, 0)
            else
                btn:SetPoint("LEFT", _G["PetActionButton"..(i-1)], "RIGHT", 6, 0)
            end

            SkinButton(btn)
        end
    end

    RegisterStateDriver(petAnchor, "visibility", "[pet] show; hide")
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if UI.HaltModules then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            return
        end

        ApplyPetBarSkin()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)