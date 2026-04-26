local _, UI = ...

local MAX_LEVEL = MAX_PLAYER_LEVEL or 80
local F = CreateFrame("Frame")
local bar

local function FormatNum(val)
    if val >= 1e6 then return string.format("%.1fm", val / 1e6):gsub("%.0m", "m")
    elseif val >= 1e3 then return string.format("%.1fk", val / 1e3):gsub("%.0k", "k")
    else return tostring(val) end
end

local function LobotomizeDefaultBars()
    local framesToKill = {
        MainMenuExpBar, MainMenuBarMaxLevelBar,
        ReputationWatchBar, ReputationWatchStatusBar,
        ExhaustionTick, ExhaustionLevelIndicator
    }
    for _, frame in ipairs(framesToKill) do
        if frame then
            frame:UnregisterAllEvents()
            frame:Hide()
            if CleanUIHider then frame:SetParent(CleanUIHider) end 
            if frame.EnableMouse then frame:EnableMouse(false) end
        end
    end
end

local function UpdateBar()
    if not bar or UI.HaltModules then return end
    
    local repName, repStanding, repMin, repMax, repValue = GetWatchedFactionInfo()
    local playerLevel = UnitLevel("player")
    local isMaxLevel = (playerLevel >= MAX_LEVEL)

    if repName and (isMaxLevel or IsShiftKeyDown()) then
        bar:Show()
        bar.isRep = true
        
        local color = FACTION_BAR_COLORS[repStanding]
        local curRep, maxRep = repValue - repMin, repMax - repMin
        
        if maxRep <= 0 then maxRep = 1 curRep = 1 end

        bar:SetMinMaxValues(0, maxRep)
        bar:SetValue(curRep)
        bar:SetStatusBarColor(color.r, color.g, color.b)
        bar.text:SetText(format("%s: %s / %s (%d%%)", repName, FormatNum(curRep), FormatNum(maxRep), math.floor((curRep / maxRep) * 100)))

    elseif not isMaxLevel then
        bar:Show()
        bar.isRep = false
        
        local curXP, maxXP = UnitXP("player"), UnitXPMax("player")
        if maxXP <= 0 then maxXP = 1 end

        bar:SetMinMaxValues(0, maxXP)
        bar:SetValue(curXP)
        
        if GetXPExhaustion() then 
            bar:SetStatusBarColor(0.0, 0.39, 0.88)
        else 
            bar:SetStatusBarColor(0.58, 0.0, 0.55)
        end
        bar.text:SetText(format("%s / %s (%d%%)", FormatNum(curXP), FormatNum(maxXP), math.floor((curXP / maxXP) * 100)))

    else 
        bar:Hide() 
    end
end

local function CreateBar()
    bar = CreateFrame("StatusBar", "CleanUIExpBar", UIParent)
    bar:SetHeight(10)
    
    local anchorFrame = ActionButton1 or MainMenuBar
    bar:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4)
    bar:SetPoint("TOPRIGHT", _G["ActionButton12"] or anchorFrame, "BOTTOMRIGHT", 0, -4)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1); bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetTexture(0, 0, 0, 1) 

    local innerBg = bar:CreateTexture(nil, "BORDER")
    innerBg:SetAllPoints()
    innerBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    innerBg:SetVertexColor(0, 0, 0, 0.35) 

    local barWidth = bar:GetWidth()
    for i = 1, 9 do
        local t = bar:CreateTexture(nil, "OVERLAY")
        t:SetTexture(0, 0, 0, 1) 
        t:SetWidth(1)
        t:SetHeight(10)
        t:SetPoint("LEFT", bar, "LEFT", (i * (490 / 10)), 0)
    end

    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.text:SetTextColor(1, 1, 0)
    bar.text:SetAlpha(0)

    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        self.text:SetAlpha(1)
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
    bar:SetScript("OnLeave", function(self)
        self.text:SetAlpha(0)
        GameTooltip:Hide()
    end)
end

F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PLAYER_XP_UPDATE")
F:RegisterEvent("PLAYER_LEVEL_UP")
F:RegisterEvent("UPDATE_EXHAUSTION")
F:RegisterEvent("UPDATE_FACTION")

F:SetScript("OnEvent", function(self, event)
    if UI.HaltModules then return end

    if event == "PLAYER_ENTERING_WORLD" then
        LobotomizeDefaultBars()
        if not bar then CreateBar() end
    end
    UpdateBar()
end)