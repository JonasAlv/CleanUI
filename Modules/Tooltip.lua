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

local ExactBlacklist = {}

local function SafeAdd(constant)
    if constant then
        ExactBlacklist[constant] = true
    end
end

SafeAdd(ERR_OUT_OF_ENERGY)
SafeAdd(ERR_OUT_OF_MANA)
SafeAdd(ERR_OUT_OF_RAGE)
SafeAdd(ERR_NO_ATTACK_TARGET)
SafeAdd(ERR_INVALID_TARGET)
SafeAdd(ERR_OUT_OF_RANGE)
SafeAdd(ERR_SPELL_COOLDOWN)
SafeAdd(ERR_ABILITY_COOLDOWN)
SafeAdd(ERR_BADATTACKFACING)
SafeAdd(ERR_BADATTACKPOS)
SafeAdd(SPELL_FAILED_NOT_READY)
SafeAdd(SPELL_FAILED_OUT_OF_RANGE)

local FallbackKeywords = {
    "moving", "interrupted", "silenced", "stunned", "dead", "reagents", "focus"
}

ErrorGatekeeper:SetScript("OnEvent", function(self, event, msg)
    if not msg then return end

    if ExactBlacklist[msg] then return end

    local lowerMsg = msg:lower()
    for _, pattern in ipairs(FallbackKeywords) do
        if lowerMsg:find(pattern) then
            return
        end
    end

    UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
end)

local CombatWatch = CreateFrame("Frame")
CombatWatch:RegisterEvent("PLAYER_REGEN_DISABLED")
CombatWatch:SetScript("OnEvent", function()
    if GameTooltip:IsShown() then
        local hasItem, hasSpell = GameTooltip:GetItem(), GameTooltip:GetSpell()
        local owner = GameTooltip:GetOwner()
        local ownerName = owner and owner:GetName() or ""
        local isAura = ownerName:find("Buff") or ownerName:find("Debuff")

        if not (hasItem or hasSpell or isAura) then 
            GameTooltip:Hide() 
        end
    end
end)