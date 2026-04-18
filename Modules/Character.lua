local _, UI = ...
local F = CreateFrame("Frame")

F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("PLAYER_TALENT_UPDATE")
F:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
F:RegisterEvent("SPELLS_CHANGED")
F:RegisterEvent("UNIT_PORTRAIT_UPDATE")

local standardClasses = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true
}

local function InjectPlayerPortrait()
    local f = AscensionCharacterFrame or CharacterFrame
    if not (f and f:IsVisible()) then return end

    if not f.CleanUI_PlayerIcon then
        f.CleanUI_PlayerIcon = CreateFrame("Frame", nil, f)
        f.CleanUI_PlayerIcon:SetSize(60, 60)
        f.CleanUI_PlayerIcon:SetPoint("TOPLEFT", f, "TOPLEFT", -6, 6) 
        f.CleanUI_PlayerIcon:SetFrameLevel(f:GetFrameLevel() + 1)
        
        -- fix char panel(C) class icon(our icon), forcing the borders to crop it
        local border = AscensionCharacterFrameNineSlice or CharacterFrameNineSlice
        if border then border:SetFrameLevel(f.CleanUI_PlayerIcon:GetFrameLevel() + 2) end

        local tex = f.CleanUI_PlayerIcon:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        f.CleanUI_PlayerIcon.tex = tex
    end

    local fName = f:GetName() or ""
    local model = _G[fName .. "PortraitModel"] or _G[fName .. "ModelFrame"] or CharacterModelFrame
    local defaultPortrait = _G[fName .. "Portrait"]

    local _, class = UnitClass("player")
    
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

F:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_PORTRAIT_UPDATE" and unit ~= "player" then return end
    InjectPlayerPortrait()
end)

local f = AscensionCharacterFrame or CharacterFrame
if f then
    f:HookScript("OnShow", InjectPlayerPortrait)
end