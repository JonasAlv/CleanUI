local _, UI = ...

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    -- fixed world tooltips position, dont touch
    tooltip:SetOwner(parent, "ANCHOR_NONE")
    tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -25, 25)
end)

local function StyleTooltip(self)
    local hasItem = self:GetItem()
    local hasSpell = self:GetSpell()
    
    local owner = self:GetOwner()
    local ownerName = owner and owner:GetName() or ""
    local isAura = ownerName:find("Buff") or ownerName:find("Debuff")

    if InCombatLockdown() and not (hasItem or hasSpell or isAura) then 
        self:Hide() 
        return 
    end
    
    if not self:IsShown() then return end

    if hasItem or hasSpell then
        self:ClearAllPoints()
        local x, y = GetCursorPosition()
        local scale = self:GetEffectiveScale()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (x / scale) + 15, (y / scale) + 15)
    end
    
    self:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    self:SetBackdropBorderColor(0.15, 0.15, 0.15)
    
    if GameTooltipStatusBar then
        local _, unit = self:GetUnit()
        if unit and UnitIsPlayer(unit) then
            local _, class = UnitClass(unit)
            local color = RAID_CLASS_COLORS[class]
            if color then
                GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end
end

GameTooltip:HookScript("OnShow", StyleTooltip)
GameTooltip:HookScript("OnUpdate", StyleTooltip)

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
local ErrorGatekeeper = CreateFrame("Frame")
ErrorGatekeeper:RegisterEvent("UI_ERROR_MESSAGE")

ErrorGatekeeper:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end
    
    if InCombatLockdown() then return end
    
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
end)

local CombatWatch = CreateFrame("Frame")
CombatWatch:RegisterEvent("PLAYER_REGEN_DISABLED")
CombatWatch:SetScript("OnEvent", function()
    if GameTooltip:IsShown() then 
        local hasItem = GameTooltip:GetItem()
        local hasSpell = GameTooltip:GetSpell()
        
        local owner = GameTooltip:GetOwner()
        local ownerName = owner and owner:GetName() or ""
        local isAura = ownerName:find("Buff") or ownerName:find("Debuff")

        if not (hasItem or hasSpell or isAura) then
            GameTooltip:Hide() 
        end
    end
end)