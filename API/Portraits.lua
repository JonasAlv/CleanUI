local _, UI = ...

local standardClasses = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true
}

function UI.SetClassPortrait(portrait, unit, forceClass)
    if type(portrait) == "string" then portrait = _G[portrait] end
    if not portrait then return false end

    if CleanUI_UseClassPortraits == false then return true end

    local name = portrait:GetName() or ""
    local parentName = portrait:GetParent() and portrait:GetParent():GetName() or ""

    if parentName:find("MicroButton") or name:find("SideTab") or parentName:find("SideTab") then
        return false
    end

    local safeUnit = unit
    if unit then
        if UnitIsUnit(unit, "player") then safeUnit = "player"
        elseif UnitIsUnit(unit, "target") then safeUnit = "target"
        elseif UnitIsUnit(unit, "focus") then safeUnit = "focus" end
    end

    local isPet = (safeUnit and safeUnit:find("pet")) or name:find("Pet")
    local isPlayer = safeUnit and UnitIsPlayer(safeUnit) and not isPet
    local class = forceClass or (isPlayer and select(2, UnitClass(safeUnit)))

    if isPlayer and class and standardClasses[class] then
        portrait:SetTexture(UI.ClassPath .. class)
        portrait:SetTexCoord(0, 1, 0, 1)
    end

    return true
end

hooksecurefunc("SetPortraitTexture", function(portrait, unit)
    UI.SetClassPortrait(portrait, unit)
end)

function UI.RefreshPortraits()

    if PlayerPortrait then SetPortraitTexture(PlayerPortrait, "player") end

    if TargetFramePortrait and UnitExists("target") then SetPortraitTexture(TargetFramePortrait, "target") end
    if FocusFramePortrait and UnitExists("focus") then SetPortraitTexture(FocusFramePortrait, "focus") end
    if TargetFrameToTPortrait and UnitExists("targettarget") then SetPortraitTexture(TargetFrameToTPortrait, "targettarget") end
    if FocusFrameToTPortrait and UnitExists("focustarget") then SetPortraitTexture(FocusFrameToTPortrait, "focustarget") end

    for i = 1, 4 do
        local p = _G["PartyMemberFrame"..i.."Portrait"]
        if p and UnitExists("party"..i) then SetPortraitTexture(p, "party"..i) end
    end
end