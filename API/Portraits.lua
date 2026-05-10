local _, UI = ...

UI.ClassPath = "Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES-ROUND"
local defaultClassPath = "Interface\\AddOns\\CleanUI\\Media\\classes.blp"
local bypassSetPortrait = false

local classCoords = {
    DRUID        = { 0.625, 0.75, 0, 0.25 },
    WARRIOR      = { 0.5, 0.625, 0.75, 1 },
    PALADIN      = { 0.625, 0.75, 0.25, 0.5 },
    HUNTER       = { 0.125, 0.25, 0.25, 0.5 },
    ROGUE        = { 0.375, 0.5, 0.5, 0.75 },
    PRIEST       = { 0.75, 0.875, 0.25, 0.5 },
    DEATHKNIGHT  = { 0.375, 0.5, 0, 0.25 },
    SHAMAN       = { 0.5, 0.625, 0.5, 0.75 },
    MAGE         = { 0.25, 0.375, 0.25, 0.5 },
    WARLOCK      = { 0.375, 0.5, 0.75, 1 },
}

local customClassCoords = {
    BARBARIAN    = { 0.0, 0.125, 0, 0.25 }, REAPER       = { 0.25, 0.375, 0.5, 0.75 },
    CHRONOMANCER = { 0.125, 0.25, 0, 0.25 }, CULTIST      = { 0.25, 0.375, 0, 0.25 },
    DEMONHUNTER  = { 0.5, 0.625, 0, 0.25 }, FLESHWARDEN  = { 0.75, 0.875, 0, 0.25 },
    GUARDIAN     = { 0.875, 1, 0, 0.25 }, HERO         = { 0, 0.125, 0.25, 0.5 },
    MONK         = { 0.375, 0.5, 0.25, 0.5 }, NECROMANCER  = { 0.5, 0.625, 0.25, 0.5 },
    PROPHET      = { 0.875, 1, 0.25, 0.5 }, PYROMANCER   = { 0, 0.125, 0.5, 0.75 },
    RANGER       = { 0.125, 0.25, 0.5, 0.75 }, SONOFARUGAL  = { 0.625, 0.75, 0.5, 0.75 },
    SPIRITMAGE   = { 0.75, 0.875, 0.5, 0.75 }, STARCALLER   = { 0.875, 1, 0.5, 0.75 },
    STORMBRINGER = { 0, 0.125, 0.75, 1 }, SUNCLERIC    = { 0.125, 0.25, 0.75, 1 },
    TINKER       = { 0.25, 0.375, 0.75, 1 }, WILDWALKER   = { 0.625, 0.75, 0.75, 1 },
    WITCHDOCTOR  = { 0.75, 0.875, 0.75, 1 }, WITCHHUNTER  = { 0.875, 1, 0.75, 1 },
}

local function GetClassTextureData(class)
    if not class then return end
    if classCoords[class] then return defaultClassPath, classCoords[class] end
    if customClassCoords[class] then return UI.ClassPath, customClassCoords[class] end
end

function UI.SetClassPortrait(portrait, unit)
    if type(portrait) == "string" then portrait = _G[portrait] end
    if not portrait or not unit then return false end

    local isPet = UnitIsUnit(unit, "pet") or UnitIsUnit(unit, "partypet")
    if CleanUI_UseClassPortraits == false or not UnitIsPlayer(unit) or isPet then
        if not bypassSetPortrait then
            bypassSetPortrait = true
            SetPortraitTexture(portrait, unit)
            bypassSetPortrait = false
        end
        portrait:SetTexCoord(0, 1, 0, 1)
        return true
    end

    local name = portrait:GetName() or ""
    local parent = portrait:GetParent()
    local parentName = parent and parent:GetName() or ""
    if parentName:find("MicroButton") or name:find("SideTab") or parentName:find("SideTab") then
        return false
    end

    local _, class = UnitClass(unit)
    if class then
        local texturePath, texCoords = GetClassTextureData(class)
        if texturePath and texCoords then
            portrait:SetTexture(texturePath)
            portrait:SetTexCoord(unpack(texCoords))
        end
    end

    return true
end

hooksecurefunc("SetPortraitTexture", function(portrait, unit)
    UI.SetClassPortrait(portrait, unit)
end)

function UI.RefreshPortraits()
    local portraits = {
        ["player"] = PlayerPortrait,
        ["target"] = TargetFramePortrait,
        ["focus"] = FocusFramePortrait,
        ["targettarget"] = TargetFrameToTPortrait,
        ["focustarget"] = FocusFrameToTPortrait,
        ["player_frame"] = CharacterFramePortrait,
    }

    for unit, portrait in pairs(portraits) do
        if portrait then 
            local safeUnit = (unit == "player_frame") and "player" or unit
            UI.SetClassPortrait(portrait, safeUnit) 
        end
    end

    if InspectFramePortrait and InspectFrame.unit then 
        UI.SetClassPortrait(InspectFramePortrait, InspectFrame.unit) 
    end

    for i = 1, 4 do
        local p = _G["PartyMemberFrame"..i.."Portrait"]
        if p and UnitExists("party"..i) then UI.SetClassPortrait(p, "party"..i) end
    end
end