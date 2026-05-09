local _, UI = ...

local MAX_LEVEL = MAX_PLAYER_LEVEL
local F = CreateFrame("Frame")
local bar, restBar

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
            if _G["CleanUIHider"] then frame:SetParent(_G["CleanUIHider"]) end
        end
    end
end

local function UpdateBar()
    if not bar or (CleanUIPositions and CleanUIPositions.MinimalistMode) then return end

    local repName, repStanding, repMin, repMax, repValue = GetWatchedFactionInfo()
    local playerLevel = UnitLevel("player")
    local isMaxLevel = (playerLevel >= MAX_LEVEL)

    if repName and (isMaxLevel or IsShiftKeyDown()) then
        bar:Show()
        restBar:Hide() 
        bar.isRep = true

        local color = FACTION_BAR_COLORS[repStanding]
        local curRep, maxRep = repValue - repMin, repMax - repMin
        if maxRep <= 0 then maxRep = 1 end

        bar:SetMinMaxValues(0, maxRep)
        bar:SetValue(curRep)
        bar:SetStatusBarColor(color.r, color.g, color.b)
        
        local standingLabel = _G["FACTION_STANDING_LABEL"..repStanding] or ""
        bar.text:SetText(format("%s (%s): %s / %s", repName, standingLabel, FormatNum(curRep), FormatNum(maxRep)))

    elseif not isMaxLevel then
        bar:Show()
        bar.isRep = false

        local curXP, maxXP = UnitXP("player"), UnitXPMax("player")
        local restedXP = GetXPExhaustion()
        if maxXP <= 0 then maxXP = 1 end

        bar:SetMinMaxValues(0, maxXP)
        bar:SetValue(curXP)

        if restedXP and restedXP > 0 then
            restBar:Show()
            restBar:SetMinMaxValues(0, maxXP)
            restBar:SetValue(curXP + restedXP)
            bar:SetStatusBarColor(0.0, 0.39, 0.88) -- Blue (Rested)
            bar.text:SetText(format("%s / %s (+%s) [%d%%]", FormatNum(curXP), FormatNum(maxXP), FormatNum(restedXP), math.floor((curXP / maxXP) * 100)))
        else
            restBar:Hide()
            bar:SetStatusBarColor(0.58, 0.0, 0.55) -- Purple (Normal)
            bar.text:SetText(format("%s / %s [%d%%]", FormatNum(curXP), FormatNum(maxXP), math.floor((curXP / maxXP) * 100)))
        end

    else
        bar:Hide()
        restBar:Hide()
    end
end

local function CreateBar()
    bar = CreateFrame("StatusBar", "CleanUIExpBar", UIParent)
    bar:SetHeight(12)
    
    local anchor = _G["ActionButton1"] or MainMenuBar
    bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -4)
    bar:SetPoint("TOPRIGHT", _G["ActionButton12"] or anchor, "BOTTOMRIGHT", 0, -4)
    bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bar:SetFrameStrata("LOW")

    restBar = CreateFrame("StatusBar", nil, bar)
    restBar:SetAllPoints(bar)
    restBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    restBar:SetStatusBarColor(0, 0.4, 0.8, 0.5) 
    restBar:SetFrameLevel(bar:GetFrameLevel() - 1)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1); bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetTexture(0, 0, 0, 0.8)

    for i = 1, 9 do
        local t = bar:CreateTexture(nil, "OVERLAY")
        t:SetTexture(0, 0, 0, 0.5)
        t:SetWidth(1)
        t:SetHeight(bar:GetHeight())
        t:SetPoint("LEFT", bar, "LEFT", (i * (498 / 10)), 0) 
    end

    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    bar.text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.text:SetTextColor(1, 1, 1)
    bar.text:SetAlpha(0)

    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self) self.text:SetAlpha(1) end)
    bar:SetScript("OnLeave", function(self) self.text:SetAlpha(0) end)
end

F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PLAYER_XP_UPDATE")
F:RegisterEvent("PLAYER_LEVEL_UP")
F:RegisterEvent("UPDATE_EXHAUSTION")
F:RegisterEvent("UPDATE_FACTION")

F:SetScript("OnEvent", function(self, event)
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end

    if event == "PLAYER_ENTERING_WORLD" then
        LobotomizeDefaultBars()
        if not bar then CreateBar() end
    end
    UpdateBar()
end)