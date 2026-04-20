local _, UI = ...

local MAX_PLAYER_LEVEL_TABLE = { [0] = 60, [1] = 70, [2] = 80 }

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PLAYER_XP_UPDATE")
F:RegisterEvent("PLAYER_LEVEL_UP")
F:RegisterEvent("UPDATE_EXHAUSTION")
F:RegisterEvent("UPDATE_FACTION")

local Hider = CreateFrame("Frame", nil, UIParent)
Hider:Hide()

local bar

local function FormatNum(val)
    if val >= 1e6 then
        return string.format("%.1fm", val / 1e6):gsub("%.0m", "m")
    elseif val >= 1e3 then
        return string.format("%.1fk", val / 1e3):gsub("%.0k", "k")
    else
        return tostring(val)
    end
end

local function UpdateBar()
    if not bar then return end
    
    local name, standing, min, max, value = GetWatchedFactionInfo()
    local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()] or 80
    local isMaxLevel = UnitLevel("player") == maxLevel

    if name and (isMaxLevel or IsShiftKeyDown()) then
        bar:Show()
        local color = FACTION_BAR_COLORS[standing]
        local curRep, maxRep = value - min, max - min
        bar:SetMinMaxValues(0, maxRep)
        bar:SetValue(curRep)
        bar:SetStatusBarColor(color.r, color.g, color.b)
        
        bar.text:SetText(format("%s: %s / %s (%d%%)", name, FormatNum(curRep), FormatNum(maxRep), math.floor((curRep / maxRep) * 100)))
        bar.isRep = true
    elseif not isMaxLevel then
        bar:Show()
        local currXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local restedXP = GetXPExhaustion()
        
        bar:SetMinMaxValues(0, maxXP)
        bar:SetValue(currXP)
        
        if restedXP and restedXP > 0 then
            bar:SetStatusBarColor(0.0, 0.39, 0.88)
        else
            bar:SetStatusBarColor(0.58, 0.0, 0.55)
        end

        bar.text:SetText(format("%s / %s (%d%%)", FormatNum(currXP), FormatNum(maxXP), math.floor((currXP / maxXP) * 100)))
        bar.isRep = false
    else
        bar:Hide()
    end
end

local function CreateBar()
    bar = CreateFrame("StatusBar", "CleanUIExpBar", UIParent)
    bar:SetHeight(10) 
    
    bar:SetPoint("TOPLEFT", ActionButton1, "BOTTOMLEFT", 0, -4)
    bar:SetPoint("TOPRIGHT", ActionButton12, "BOTTOMRIGHT", 0, -4)
    
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1)
    bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetTexture(0, 0, 0, 1)

    local innerBg = bar:CreateTexture(nil, "BORDER")
    innerBg:SetAllPoints()
    innerBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    innerBg:SetVertexColor(0.1, 0.1, 0.1, 0.9)

    for i = 1, 9 do
        local tick = bar:CreateTexture(nil, "OVERLAY")
        tick:SetTexture(0, 0, 0, 0.6) 
        tick:SetWidth(1)
        tick:SetHeight(bar:GetHeight())
        tick:SetPoint("LEFT", bar, "LEFT", (i * (bar:GetWidth() / 10)), 0)
        
        local highlight = bar:CreateTexture(nil, "OVERLAY")
        highlight:SetTexture(1, 1, 1, 0.1)
        highlight:SetWidth(1)
        highlight:SetHeight(bar:GetHeight())
        highlight:SetPoint("LEFT", tick, "RIGHT", 0, 0)
    end

    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE") 
    bar.text:SetPoint("CENTER", bar, "CENTER", 0, 1)
    
    bar.text:SetTextColor(1, 1, 0)

    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        if self.isRep then
            local name, standing, min, max, value = GetWatchedFactionInfo()
            GameTooltip:AddLine(name, 1, 1, 1)
            GameTooltip:AddLine(string.format("Standing: %s", _G["FACTION_STANDING_LABEL"..standing]), 1, 0.82, 0)
            GameTooltip:AddLine(string.format("%s / %s (%d%%)", BreakUpLargeNumbers(value-min), BreakUpLargeNumbers(max-min), math.floor(((value-min)/(max-min))*100)), 1, 1, 1)
        else
            local curr, max = UnitXP("player"), UnitXPMax("player")
            local rested = GetXPExhaustion()
            GameTooltip:AddLine("Experience", 1, 1, 1)
            GameTooltip:AddLine(string.format("%s / %s (%d%%)", BreakUpLargeNumbers(curr), BreakUpLargeNumbers(max), math.floor((curr/max)*100)), 1, 0.82, 0)
            if rested and rested > 0 then
                GameTooltip:AddLine(string.format("%s Rested", BreakUpLargeNumbers(rested)), 0, 0.5, 1)
            end
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdateBar()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if ActionButton1 then CreateBar() else C_Timer.After(0.1, CreateBar) end
    else
        UpdateBar()
    end
end)