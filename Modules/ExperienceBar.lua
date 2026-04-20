local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PLAYER_XP_UPDATE")
F:RegisterEvent("PLAYER_LEVEL_UP")
F:RegisterEvent("UPDATE_EXHAUSTION")

local Hider = CreateFrame("Frame", nil, UIParent)
Hider:Hide()

local xpBar

local function RedirectClickToAnchor(self, button)
    if button == "LeftButton" and IsShiftKeyDown() and IsControlKeyDown() then
        local anchor = CleanUIActionBarAnchor
        if anchor and anchor:GetScript("OnMouseDown") then
            anchor:GetScript("OnMouseDown")(anchor, button)
        end
    end
end

local function RedirectReleaseToAnchor(self, button)
    local anchor = CleanUIActionBarAnchor
    if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then
        anchor:GetScript("OnMouseUp")(anchor, button)
    end
end

local function UpdateXP()
    if not xpBar then return end
    
    local currXP = UnitXP("player") or 0
    local maxXP = UnitXPMax("player") or 1
    local isMaxLevel = UnitLevel("player") == 80

    if isMaxLevel then
        xpBar:Hide()
        return
    else
        xpBar:Show()
    end

    xpBar:SetMinMaxValues(0, maxXP)
    xpBar:SetValue(currXP)

    local restedXP = GetXPExhaustion()
    if restedXP and restedXP > 0 then
        xpBar:SetStatusBarColor(0.0, 0.39, 0.88)
    else
        xpBar:SetStatusBarColor(0.58, 0.0, 0.55)
    end
    
    xpBar.text:SetText(math.floor((currXP / maxXP) * 100) .. "%")
end

local function CreateXPBar()
    if not CleanUIActionBarAnchor then return end

    xpBar = CreateFrame("StatusBar", "CleanUIExperienceBar", CleanUIActionBarAnchor)
    xpBar:SetHeight(8)
    xpBar:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 2)
    xpBar:SetPoint("BOTTOMRIGHT", CleanUIActionBarAnchor, "BOTTOMRIGHT", 0, 2)
    xpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    
    local bg = xpBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetVertexColor(0, 0, 0, 0.6)

    local t = xpBar:CreateTexture(nil, "OVERLAY"); t:SetTexture(0, 0, 0, 1); t:SetPoint("TOPLEFT", -1, 1); t:SetPoint("TOPRIGHT", 1, 1); t:SetHeight(1)
    local b = xpBar:CreateTexture(nil, "OVERLAY"); b:SetTexture(0, 0, 0, 1); b:SetPoint("BOTTOMLEFT", -1, -1); b:SetPoint("BOTTOMRIGHT", 1, -1); b:SetHeight(1)
    local l = xpBar:CreateTexture(nil, "OVERLAY"); l:SetTexture(0, 0, 0, 1); l:SetPoint("TOPLEFT", -1, 1); l:SetPoint("BOTTOMLEFT", -1, -1); l:SetWidth(1)
    local r = xpBar:CreateTexture(nil, "OVERLAY"); r:SetTexture(0, 0, 0, 1); r:SetPoint("TOPRIGHT", 1, 1); r:SetPoint("BOTTOMRIGHT", 1, -1); r:SetWidth(1)

    xpBar.text = xpBar:CreateFontString(nil, "OVERLAY")
    xpBar.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    xpBar.text:SetPoint("CENTER", xpBar, "CENTER", 0, 0)

    xpBar:EnableMouse(true)
    xpBar:HookScript("OnMouseDown", RedirectClickToAnchor)
    xpBar:HookScript("OnMouseUp", RedirectReleaseToAnchor)

    xpBar:SetScript("OnEnter", function(self)
        local curr, max = UnitXP("player"), UnitXPMax("player")
        local rested = GetXPExhaustion()
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("Experience", 1, 1, 1)
        GameTooltip:AddLine(string.format("%s / %s (%d%%)", curr, max, math.floor((curr/max)*100)), 1, 0.82, 0)
        if rested and rested > 0 then
            GameTooltip:AddLine(string.format("%s Rested", rested), 0.0, 0.39, 0.88)
        end
        GameTooltip:Show()
    end)
    xpBar:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local blizzXP = {MainMenuExpBar, ExhaustionTick}
    for _, frame in ipairs(blizzXP) do
        if frame then
            frame:UnregisterAllEvents()
            frame:SetParent(Hider)
        end
    end

    UpdateXP()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        CreateXPBar()
    else
        UpdateXP()
    end
end)