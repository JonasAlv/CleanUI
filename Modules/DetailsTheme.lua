local _, UI = ...

local function GetClassColor(class)
    return RAID_CLASS_COLORS[class] or {r = 1, g = 1, b = 1}
end

-- Character/Inspect Frame Name Coloring
local function UpdateCharacterNameColor()
    if CharacterNameText then
        local _, pClass = UnitClass("player")
        local pColor = GetClassColor(pClass)
        if pColor then
            CharacterNameText:SetTextColor(pColor.r, pColor.g, pColor.b)
        end
    end
end

if CharacterFrame then
    CharacterFrame:HookScript("OnShow", UpdateCharacterNameColor)
end

local InspectHooker = CreateFrame("Frame")
InspectHooker:RegisterEvent("ADDON_LOADED")
InspectHooker:SetScript("OnEvent", function(self, event, addon)
    if addon == "Blizzard_InspectUI" then
        hooksecurefunc("InspectPaperDollFrame_OnShow", function()
            local unit = InspectFrame and InspectFrame.unit
            if unit and InspectNameText then
                local _, tClass = UnitClass(unit)
                local tColor = GetClassColor(tClass)
                if tColor then
                    InspectNameText:SetTextColor(tColor.r, tColor.g, tColor.b)
                end
            end
        end)
        self:UnregisterEvent(event)
    end
end)

-- Durability Indicators with colors
local function ColorizeDurability(self)
    local name = self:GetName()
    for i = 1, self:NumLines() do
        local line = _G[name .. "TextLeft" .. i]
        if line then
            local text = line:GetText()
            if text and text:find(DURABILITY) then
                local current, max = text:match("(%d+) / (%d+)")
                if current and max then
                    local percent = tonumber(current) / tonumber(max)
                    local hex = "39ff14" -- Green
                    if percent <= 0.3 then
                        hex = "ff2a2a" -- Red
                    elseif percent <= 0.7 then
                        hex = "ffea00" -- Yellow
                    end
                    local newText = text:gsub("(%d+) / (%d+)", "|cff" .. hex .. "%1 / %2|r")
                    line:SetText(newText)
                end
            end
        end
    end
end

local Tooltips = { GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2 }
for _, tt in ipairs(Tooltips) do
    tt:HookScript("OnTooltipSetItem", ColorizeDurability)
end