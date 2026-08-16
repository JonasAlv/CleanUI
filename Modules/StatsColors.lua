local _, UI = ...

local StatColorsHex = {
    [SPELL_STAT1_NAME] = "ff2a2a",
    [SPELL_STAT2_NAME] = "39ff14",
    [SPELL_STAT3_NAME] = "ff9500",
    [SPELL_STAT4_NAME] = "00e5ff",
    [SPELL_STAT5_NAME] = "e040ff",
    ["All Stats"] = "ffea00",
}

local StatColorsRGB = {
    [SPELL_STAT1_NAME] = {1.00, 0.16, 0.16},
    [SPELL_STAT2_NAME] = {0.22, 1.00, 0.08},
    [SPELL_STAT3_NAME] = {1.00, 0.58, 0.00},
    [SPELL_STAT4_NAME] = {0.00, 0.90, 1.00},
    [SPELL_STAT5_NAME] = {0.88, 0.25, 1.00},
}

local function ColorizeTooltipStats(self)
    local name = self:GetName()
    for i = 1, self:NumLines() do
        local line = _G[name .. "TextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                local modified = false
                for stat, hex in pairs(StatColorsHex) do
                    if text:find(stat) and not text:find("|cff" .. hex) then
                        local newText = text:gsub("(%+?%-?%d+)(%s+)("..stat..")", "%1%2|cff"..hex.."%3|r")
                        if newText ~= text then
                            text = newText
                            modified = true
                        end
                    end
                end
                if modified then
                    line:SetText(text)
                end
            end
        end
    end
end

local Tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2 }
for _, tt in ipairs(Tooltips) do
    tt:HookScript("OnTooltipSetItem", ColorizeTooltipStats)
end

local StatMonitor = CreateFrame("Frame", nil, PaperDollFrame)
local timer = 0

StatMonitor:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer >= 0.1 then
        timer = 0
        local sides = {"Left", "Right"}
        for _, side in ipairs(sides) do
            for i = 1, 6 do
                local label = _G["PlayerStatFrame" .. side .. i .. "Label"] or _G["PlayerStat" .. side .. i .. "Label"]
                if label then
                    local text = label:GetText()
                    if text then
                        local matched = false
                        for statName, color in pairs(StatColorsRGB) do
                            if text:find(statName) then
                                label:SetTextColor(color[1], color[2], color[3])
                                matched = true
                                break
                            end
                        end
                        if not matched then
                            label:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
                        end
                    end
                end
            end
        end
    end
end)