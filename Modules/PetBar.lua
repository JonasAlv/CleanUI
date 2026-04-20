local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PET_BAR_UPDATE")
F:RegisterEvent("PET_BAR_UPDATE_STATE")
F:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
F:RegisterEvent("UNIT_PET")

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

local function UpdatePetButtons()
    for i = 1, 10 do
        local btn = _G["PetActionButton"..i]
        if btn then
            local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
            
            local icon = _G[btn:GetName().."Icon"]
            if icon then
                if texture then
                    icon:SetTexture(texture)
                    icon:SetTexCoord(0, 1, 0, 1) 
                    icon:Show()
                else
                    icon:Hide()
                end
            end

            local cd = _G[btn:GetName().."Cooldown"]
            if cd then
                local start, duration, enable = GetPetActionCooldown(i)
                CooldownFrame_SetTimer(cd, start, duration, enable)
            end

            btn:SetChecked(isActive)

            local shine = _G[btn:GetName().."Shine"]
            if shine then
                if autoCastEnabled then
                    AutoCastShine_AutoCastStart(shine)
                else
                    AutoCastShine_AutoCastStop(shine)
                end
            end

            local nt = btn:GetNormalTexture()
            if nt then 
                nt:SetAlpha(1)
            end
        end
    end
end


local function ApplyPetBarSkin()
    local petAnchor = _G["CleanUIPetBarAnchor"] or CreateFrame("Frame", "CleanUIPetBarAnchor", UIParent, "SecureHandlerStateTemplate")
    petAnchor:SetSize(350, 35) 
    
    if not petAnchor:GetPoint() then
        petAnchor:ClearAllPoints()
        petAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 10)
    end
    petAnchor:SetClampedToScreen(true)
    
    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(petAnchor, "PetBarAnchor") 
    end

    if PetActionBarFrame then
        PetActionBarFrame:UnregisterAllEvents()
        PetActionBarFrame:SetParent(Hider)
        PetActionBarFrame.ignoreFramePositionManager = true
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

            -- Movement Hooks
            if not btn.cleanUIHooked then
                btn:HookScript("OnMouseDown", RedirectClickToAnchor)
                btn:HookScript("OnMouseUp", RedirectReleaseToAnchor)
                btn.cleanUIHooked = true
            end
        end
    end

    RegisterStateDriver(petAnchor, "visibility", "[pet] show; hide")
    UpdatePetButtons()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        ApplyPetBarSkin()
    end
    UpdatePetButtons()
end)

hooksecurefunc("PetActionBar_Update", UpdatePetButtons)