local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
F:RegisterEvent("UPDATE_SHAPESHIFT_STATE")
F:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")

local Hider = CreateFrame("Frame", "CleanUIStanceHider", UIParent); Hider:Hide()

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
        end
    end
end

local function UpdateStanceButtons()
    local numForms = GetNumShapeshiftForms()
    for i = 1, 10 do
        local btn = _G["ShapeshiftButton"..i]
        local icon = _G["ShapeshiftButton"..i.."Icon"]
        local nt = _G["ShapeshiftButton"..i.."NormalTexture2"] or btn:GetNormalTexture()
        if btn then
            if i <= numForms then
                local texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
                if icon then 
                    icon:SetTexture(texture)
                    icon:SetTexCoord(0, 1, 0, 1) 
                end
                if nt then nt:SetAlpha(1) end 
                btn:SetChecked(isActive)
                if isCastable then 
                    if icon then icon:SetVertexColor(1, 1, 1) end
                else 
                    if icon then icon:SetVertexColor(0.4, 0.4, 0.4) end
                end
                btn:Show()
            else
                btn:Hide()
            end
        end
    end
end

local function ApplyStanceBarSkin()
    local stanceAnchor = _G["CleanUIStanceBarAnchor"] or CreateFrame("Frame", "CleanUIStanceBarAnchor", UIParent, "SecureHandlerStateTemplate")
    stanceAnchor:SetSize(300, 35) 
    stanceAnchor:SetClampedToScreen(true)
    if UI.MakeMovableAndSave then UI.MakeMovableAndSave(stanceAnchor, "StanceBarAnchor") end
    if ShapeshiftBarFrame then ShapeshiftBarFrame:SetParent(Hider) end
    for i = 1, 10 do
        local btn = _G["ShapeshiftButton"..i]
        if btn then
            btn:SetParent(stanceAnchor)
            btn:SetFrameLevel(5) 
            btn:ClearAllPoints()
            if _G[btn:GetName().."Border"] then _G[btn:GetName().."Border"]:SetAlpha(1) end
            if _G[btn:GetName().."Flash"] then _G[btn:GetName().."Flash"]:SetAlpha(1) end
            if i == 1 then
                btn:SetPoint("BOTTOMLEFT", stanceAnchor, "BOTTOMLEFT", 0, 0)
            else
                btn:SetPoint("LEFT", _G["ShapeshiftButton"..(i-1)], "RIGHT", 6, 0)
            end
            if not btn.cleanUIHooked then
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
                btn:HookScript("OnClick", function() C_Timer.After(0.05, UpdateStanceButtons) end)
                btn.cleanUIHooked = true
            end
        end
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
hooksecurefunc("ShapeshiftBar_Update", UpdateStanceButtons)