local _, UI = ...
local F = CreateFrame("Frame")

F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
F:RegisterEvent("UPDATE_SHAPESHIFT_FORM") 
F:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
F:RegisterEvent("SPELL_UPDATE_COOLDOWN")
F:RegisterEvent("PLAYER_AURAS_CHANGED")

local Hider = CreateFrame("Frame", "CleanUIStanceHider", UIParent)
Hider:Hide()

local CustomStanceButtons = {}

local function SkinButton(btn)
    if not btn then return end
    
    local icon = _G[btn:GetName().."Icon"]
    if icon then 
        icon:ClearAllPoints()
        icon:SetAllPoints(btn)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) 
    end
    
    local nt = btn:GetNormalTexture()
    if nt then nt:SetAlpha(0) end
    if _G[btn:GetName().."Border"] then _G[btn:GetName().."Border"]:SetAlpha(0) end
    
    if not btn.cleanUIBorder then
        local border = btn:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", btn, "TOPLEFT", -1, 2)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 1, -1)
        border:SetTexture(0, 0, 0, 1) 
        btn.cleanUIBorder = border
    end
    
    local ct = btn:GetCheckedTexture()
    if ct then 
        ct:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        ct:SetBlendMode("ADD")
        ct:ClearAllPoints()
        ct:SetAllPoints(btn)
    end
    
    local ht = btn:GetHighlightTexture()
    if ht then
        ht:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        ht:SetBlendMode("ADD")
        ht:ClearAllPoints()
        ht:SetAllPoints(btn)
    end
end

local function EnforceStancePosition()
    local anchor = CleanUIStanceBarAnchor
    if not anchor or InCombatLockdown() then return end
    
    if not CleanUIPositions or not CleanUIPositions["StanceBarAnchor"] then
        anchor:ClearAllPoints()
        local floorButton
        if MultiBarBottomRight:IsShown() then
            floorButton = MultiBarBottomRightButton1
        elseif MultiBarBottomLeft:IsShown() then
            floorButton = MultiBarBottomLeftButton1
        else
            floorButton = ActionButton1
        end
        
        if floorButton then
            anchor:SetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 10)
        else
            anchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 10, 110)
        end
    end
end

local function UpdateStanceButtons()
    if InCombatLockdown() then return end 
    
    local numForms = GetNumShapeshiftForms()
    
    for i = 1, 10 do
        local btn = CustomStanceButtons[i]
        if not btn then break end
        
        if i <= numForms then
            local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
            local icon = _G[btn:GetName().."Icon"]
            local cooldown = _G[btn:GetName().."Cooldown"]
            
            if icon then 
                icon:SetTexture(texture)
                if isCastable then 
                    icon:SetVertexColor(1, 1, 1) 
                else 
                    icon:SetVertexColor(0.4, 0.4, 0.4) 
                end
            end
            
            btn:SetChecked(isActive and true or false)
            
            if cooldown then
                local start, duration, enable = GetShapeshiftFormCooldown(i)
                CooldownFrame_SetTimer(cooldown, start, duration, enable)
            end
            
            btn:Show()
        else
            btn:Hide()
        end
    end
end

local function ApplyStanceBarSkin()
    local stanceAnchor = _G["CleanUIStanceBarAnchor"] or CreateFrame("Frame", "CleanUIStanceBarAnchor", UIParent, "SecureHandlerStateTemplate")
    stanceAnchor:SetSize(300, 35) 
    stanceAnchor:SetClampedToScreen(true)
    
    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(stanceAnchor, "StanceBarAnchor") 
    end
    
    if ShapeshiftBarFrame then 
        ShapeshiftBarFrame:UnregisterAllEvents()
        ShapeshiftBarFrame:SetParent(Hider) 
    end

    for i = 1, 10 do
        local btn = CreateFrame("CheckButton", "CleanUIStanceButton"..i, stanceAnchor, "ShapeshiftButtonTemplate")
        btn:SetID(i) 
        btn:SetFrameLevel(5) 
        
        if i == 1 then
            btn:SetPoint("BOTTOMLEFT", stanceAnchor, "BOTTOMLEFT", 0, 0)
        else
            btn:SetPoint("LEFT", CustomStanceButtons[i-1], "RIGHT", 6, 0)
        end
        
        SkinButton(btn)
        
        btn:HookScript("OnMouseDown", function(self, button)
            if IsShiftKeyDown() and IsControlKeyDown() then
                local script = stanceAnchor:GetScript("OnMouseDown")
                if script then script(stanceAnchor, button) end
            end
        end)
        btn:HookScript("OnMouseUp", function(self, button)
            if stanceAnchor.isCleanUIMoving then
                local script = stanceAnchor:GetScript("OnMouseUp")
                if script then script(stanceAnchor, button) end
            end
        end)
        
        CustomStanceButtons[i] = btn
    end
    
    RegisterStateDriver(stanceAnchor, "visibility", "[bonusbar:5] hide; show")
    EnforceStancePosition()
    UpdateStanceButtons()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then 
        ApplyStanceBarSkin() 
    else
        UpdateStanceButtons()
    end
end)

hooksecurefunc("MultiActionBar_Update", EnforceStancePosition)
hooksecurefunc("UIParent_ManageFramePositions", EnforceStancePosition)