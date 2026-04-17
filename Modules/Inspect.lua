local _, UI = ...
local F = CreateFrame("Frame")

F:RegisterEvent("ADDON_LOADED")
F:RegisterEvent("INSPECT_READY")
F:RegisterEvent("PLAYER_TARGET_CHANGED")

local standardClasses = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true
}

local function InjectTargetPortrait()
    local f = AscensionInspectFrame or InspectFrame
    if not (f and f:IsVisible()) then return end

    if not f.CleanUI_PlayerIcon then
        f.CleanUI_PlayerIcon = CreateFrame("Frame", nil, f)
        f.CleanUI_PlayerIcon:SetSize(60, 60)
        f.CleanUI_PlayerIcon:SetPoint("TOPLEFT", f, "TOPLEFT", -6, 6) 
        f.CleanUI_PlayerIcon:SetFrameLevel(f:GetFrameLevel() + 1)
        
        local border = AscensionInspectFrameNineSlice or InspectFrameNineSlice
        if border then border:SetFrameLevel(f.CleanUI_PlayerIcon:GetFrameLevel() + 2) end

        local tex = f.CleanUI_PlayerIcon:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        f.CleanUI_PlayerIcon.tex = tex
    end

    local fName = f:GetName() or ""
    local model = _G[fName .. "PortraitModel"] or _G[fName .. "ModelFrame"] or _G["InspectModelFrame"]
    local defaultPortrait = _G[fName .. "Portrait"]

    local u = f.unit or "target"
    local _, class = UnitClass(u)
    
    if class and standardClasses[class] then
        f.CleanUI_PlayerIcon.tex:SetTexture(UI.ClassPath .. class)
        f.CleanUI_PlayerIcon.tex:SetTexCoord(0, 1, 0, 1)
        f.CleanUI_PlayerIcon:SetAlpha(1)

        if model then model:SetAlpha(0) end
        if defaultPortrait then defaultPortrait:SetAlpha(0) end
    else
        f.CleanUI_PlayerIcon:SetAlpha(0)

        if model then model:SetAlpha(1) end
        if defaultPortrait then defaultPortrait:SetAlpha(1) end
    end
end

F:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and (arg1 == "Blizzard_InspectUI" or arg1 == "Ascension_InspectUI") then
        local f = AscensionInspectFrame or InspectFrame
        if f then f:HookScript("OnShow", InjectTargetPortrait) end
    elseif event == "INSPECT_READY" or event == "PLAYER_TARGET_CHANGED" then
        InjectTargetPortrait()
    end
end)