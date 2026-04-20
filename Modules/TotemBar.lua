local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUITotemHider", UIParent); Hider:Hide()

local function EnforceTotemPosition()
    local anchor = CleanUITotemBarAnchor
    if not anchor or InCombatLockdown() then return end

    if not CleanUIPositions or not CleanUIPositions["TotemBarAnchor"] then
        anchor:ClearAllPoints()
        
        local floorButton
        if CleanUIStanceBarAnchor and CleanUIStanceBarAnchor:IsShown() then
            floorButton = ShapeshiftButton1
        elseif MultiBarBottomRight and MultiBarBottomRight:IsShown() then
            floorButton = MultiBarBottomRightButton1
        elseif MultiBarBottomLeft and MultiBarBottomLeft:IsShown() then
            floorButton = MultiBarBottomLeftButton1
        else
            floorButton = ActionButton1
        end

        if floorButton then
            anchor:SetPoint("BOTTOMLEFT", floorButton, "TOPLEFT", 0, 10)
        end
    end
end

local function SkinTotemButton(btn)
    if not btn then return end
    local name = btn:GetName()
    local icon = _G[name.."Icon"] or _G[name.."Texture"]
    local nt = btn:GetNormalTexture()

    if icon then icon:SetTexCoord(0, 1, 0, 1) end
    if nt then nt:SetAlpha(1) end
    
    if not btn.cleanUIHooked then
        btn:HookScript("OnMouseDown", function(self, button)
            if IsShiftKeyDown() and IsControlKeyDown() and button == "LeftButton" then
                local parent = CleanUITotemBarAnchor
                local script = parent:GetScript("OnMouseDown")
                if script then script(parent, button) end
            end
        end)
        btn:HookScript("OnMouseUp", function(self, button)
            local parent = CleanUITotemBarAnchor
            if parent.isCleanUIMoving then
                local script = parent:GetScript("OnMouseUp")
                if script then script(parent, button) end
            end
        end)
        btn.cleanUIHooked = true
    end
end

local function ApplyTotemBarSkin()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" then return end

    local totemAnchor = _G["CleanUITotemBarAnchor"] or CreateFrame("Frame", "CleanUITotemBarAnchor", UIParent)
    totemAnchor:SetSize(220, 40)
    totemAnchor:SetClampedToScreen(true)
    
    if UI.MakeMovableAndSave then 
        UI.MakeMovableAndSave(totemAnchor, "TotemBarAnchor") 
    end

    if MultiCastActionBarFrame then
        MultiCastActionBarFrame:SetParent(Hider)
        MultiCastActionBarFrame.ignoreFramePositionManager = true
    end

    local buttons = {
        MultiCastSummonSpellButton,
        MultiCastActionButton1,
        MultiCastActionButton2,
        MultiCastActionButton3,
        MultiCastActionButton4,
        MultiCastRecallSpellButton,
    }

    local prev
    for i, btn in ipairs(buttons) do
        if btn then
            btn:SetParent(totemAnchor)
            btn:ClearAllPoints()
            if i == 1 then
                btn:SetPoint("BOTTOMLEFT", totemAnchor, "BOTTOMLEFT", 0, 0)
            else
                btn:SetPoint("LEFT", prev, "RIGHT", 4, 0)
            end
            SkinTotemButton(btn)
            prev = btn
        end
    end

    if MultiCastFlyoutFrame then
        MultiCastFlyoutFrame:SetParent(totemAnchor)
    end

    EnforceTotemPosition()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then ApplyTotemBarSkin() end
end)

hooksecurefunc("MultiActionBar_Update", EnforceTotemPosition)
hooksecurefunc("UIParent_ManageFramePositions", EnforceTotemPosition)
hooksecurefunc("ShapeshiftBar_Update", EnforceTotemPosition)