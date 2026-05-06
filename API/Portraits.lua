local _, UI = ...

UI.ClassPath = "Interface\\Glues\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES-ROUND"

local isAscension = false
local testTex = UIParent:CreateTexture(nil, "OVERLAY")
testTex:SetTexture(UI.ClassPath)
if testTex:GetWidth() > 0 then
    isAscension = true
end
testTex:Hide()

local classCoords = {
    -- Ascension Round Icons
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


    BARBARIAN    = { 0.0, 0.125, 0, 0.25 },
    REAPER       = { 0.25, 0.375, 0.5, 0.75 },
    CHRONOMANCER = { 0.125, 0.25, 0, 0.25 },
    CULTIST      = { 0.25, 0.375, 0, 0.25 },
    DEMONHUNTER  = { 0.5, 0.625, 0, 0.25 },
    FLESHWARDEN  = { 0.75, 0.875, 0, 0.25 },
    GUARDIAN     = { 0.875, 1, 0, 0.25 },
    HERO         = { 0, 0.125, 0.25, 0.5 },
    MONK         = { 0.375, 0.5, 0.25, 0.5 },
    NECROMANCER  = { 0.5, 0.625, 0.25, 0.5 },
    PROPHET      = { 0.875, 1, 0.25, 0.5 },
    PYROMANCER   = { 0, 0.125, 0.5, 0.75 },
    RANGER       = { 0.125, 0.25, 0.5, 0.75 },
    SONOFARUGAL  = { 0.625, 0.75, 0.5, 0.75 },
    SPIRITMAGE   = { 0.75, 0.875, 0.5, 0.75 },
    STARCALLER   = { 0.875, 1, 0.5, 0.75 },
    STORMBRINGER = { 0, 0.125, 0.75, 1 },
    SUNCLERIC    = { 0.125, 0.25, 0.75, 1 },
    TINKER       = { 0.25, 0.375, 0.75, 1 },
    WILDWALKER   = { 0.625, 0.75, 0.75, 1 },
    WITCHDOCTOR  = { 0.75, 0.875, 0.75, 1 },
    WITCHHUNTER  = { 0.875, 1, 0.75, 1 },
}

local fallbackCoords = {
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

local defaultClassPath = "Interface\\AddOns\\CleanUI\\Media\\classes.blp"
local texturePathCache = {}

local function GetClassTextureData(class)
    if texturePathCache[class] then
        return texturePathCache[class].path, texturePathCache[class].coords
    end
    
    if isAscension and classCoords[class] then
        texturePathCache[class] = { path = UI.ClassPath, coords = classCoords[class] }
        return UI.ClassPath, classCoords[class]
    end
    
    if fallbackCoords[class] then
        texturePathCache[class] = { path = defaultClassPath, coords = fallbackCoords[class] }
        return defaultClassPath, fallbackCoords[class]
    end
end

local bypassSetPortrait = false

function UI.SetClassPortrait(portrait, unit, forceClass)
    if type(portrait) == "string" then portrait = _G[portrait] end
    if not portrait then return false end

    if CleanUI_UseClassPortraits == false then
        if not bypassSetPortrait and unit then
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

    local safeUnit = unit
    if unit then
        if UnitIsUnit(unit, "player") then safeUnit = "player"
        elseif UnitIsUnit(unit, "target") then safeUnit = "target"
        elseif UnitIsUnit(unit, "focus") then safeUnit = "focus" end
    end

    local isPet = (safeUnit and safeUnit:find("pet")) or name:find("Pet")
    local isPlayer = safeUnit and UnitIsPlayer(safeUnit) and not isPet
    
    if not isPlayer then
        portrait:SetTexCoord(0, 1, 0, 1)
        return true
    end

    local class = forceClass or select(2, UnitClass(safeUnit))
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
    if PlayerPortrait then UI.SetClassPortrait(PlayerPortrait, "player") end
    if TargetFramePortrait then UI.SetClassPortrait(TargetFramePortrait, "target") end
    if FocusFramePortrait then UI.SetClassPortrait(FocusFramePortrait, "focus") end
    if TargetFrameToTPortrait then UI.SetClassPortrait(TargetFrameToTPortrait, "targettarget") end
    if FocusFrameToTPortrait then UI.SetClassPortrait(FocusFrameToTPortrait, "focustarget") end
    
    if CharacterFramePortrait then UI.SetClassPortrait(CharacterFramePortrait, "player") end
    if InspectFramePortrait and InspectFrame.unit then 
        UI.SetClassPortrait(InspectFramePortrait, InspectFrame.unit) 
    end

    for i = 1, 4 do
        local p = _G["PartyMemberFrame"..i.."Portrait"]
        if p and UnitExists("party"..i) then UI.SetClassPortrait(p, "party"..i) end
    end
end