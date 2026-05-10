local _, UI = ...

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
    local isMinimalist = CleanUIPositions and CleanUIPositions.MinimalistMode
    local yOffset = isMinimalist and 25 or 120

    tooltip:SetOwner(parent, "ANCHOR_NONE")
    tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -25, yOffset)
end)

local function StyleTooltip(self)
    local hasItem, hasSpell = self:GetItem(), self:GetSpell()
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
            if color then GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b) end
        end
    end
end

GameTooltip:HookScript("OnShow", StyleTooltip)
GameTooltip:HookScript("OnUpdate", StyleTooltip)

UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
local ErrorGatekeeper = CreateFrame("Frame")
ErrorGatekeeper:RegisterEvent("UI_ERROR_MESSAGE")

local BlacklistedErrors = {}
local function AddToBlacklist(constant)
    if constant and type(constant) == "string" then
        BlacklistedErrors[constant] = true
    end
end

AddToBlacklist(ERR_NO_ATTACK_TARGET)
AddToBlacklist(ERR_ATTACK_NONTARGET)
AddToBlacklist(ERR_INVALID_TARGET)
AddToBlacklist(ERR_OUT_OF_RANGE)
AddToBlacklist(ERR_SPELL_COOLDOWN)
AddToBlacklist(SPELL_FAILED_OUT_OF_RANGE)
AddToBlacklist(SPELL_FAILED_NOT_READY)
AddToBlacklist(ERR_ABILITY_COOLDOWN)

local BlacklistKeywords = {
    "target",      
    "moving",      
    "close",       
    "interrupted", 
    "range",       
    "ready",       
}

ErrorGatekeeper:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end
    
    local lowerMsg = msg:lower()

    for _, keyword in ipairs(BlacklistKeywords) do
        if lowerMsg:find(keyword) then
            return
        end
    end

    if BlacklistedErrors[msg] then return end
    
    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
end)

local CombatWatch = CreateFrame("Frame")
CombatWatch:RegisterEvent("PLAYER_REGEN_DISABLED")
CombatWatch:SetScript("OnEvent", function()
    if GameTooltip:IsShown() then
        local hasItem, hasSpell = GameTooltip:GetItem(), GameTooltip:GetSpell()
        local isAura = (GameTooltip:GetOwner() and GameTooltip:GetOwner():GetName() or ""):find("Buff")
        if not (hasItem or hasSpell or isAura) then GameTooltip:Hide() end
    end
end)