local _, UI = ...

local standardClasses = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true,
    BARBARIAN = true, REAPER = true, CHRONOMANCER = true, CULTIST = true, DEMONHUNTER = true,
    FLESHWARDEN = true, GUARDIAN = true, HERO = true, MONK = true, NECROMANCER = true, PROPHET = true, PYROMANCER = true,
    RANGER = true, SONOFARUGAL = true, SPIRITMAGE = true, STARCALLER = true, STORMBRINGER = true, SUNCLERIC = true, TINKER = true, WILDWALKER = true, WITCHDOCTOR = true, WITCHHUNTER = true
}

local function GetClassColor(class)
    return RAID_CLASS_COLORS[class]
end

local function CreatePlayerNameBackground()
    if not UI.PlayerNameBG then
        UI.PlayerNameBG = PlayerFrame:CreateTexture(nil, "ARTWORK", nil, -1)
        UI.PlayerNameBG:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        
        UI.PlayerNameBG:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 106, -22)
        UI.PlayerNameBG:SetPoint("BOTTOMRIGHT", PlayerFrameHealthBar, "TOPRIGHT", 0, 1)
        
        UI.PlayerNameBG:SetTexCoord(1, 0, 0, 1)
    end

    local _, class = UnitClass("player")
    local color = GetClassColor(class)
    
    if color then
        UI.PlayerNameBG:SetVertexColor(color.r, color.g, color.b, 1)
        UI.PlayerNameBG:Show()
    else
        UI.PlayerNameBG:Hide()
    end
end
CreatePlayerNameBackground()

function UI.ProtectFrame(healthBar)
    if not healthBar or healthBar.hooked then return end

    hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
        if self.isCleanUI_Updating then return end
        local parent = self:GetParent()
        local unit = parent.unit or (parent:GetParent() and parent:GetParent().unit)
        
        if unit and UnitIsPlayer(unit) then
            local _, tClass = UnitClass(unit)
            if tClass and standardClasses[tClass] then
                local color = GetClassColor(tClass)
                if color then
                    self.isCleanUI_Updating = true
                    self:SetStatusBarColor(color.r, color.g, color.b)
                    self.isCleanUI_Updating = false
                end
            end
        end
    end)
    healthBar.hooked = true
end

function UI.ApplyClassTheme(unit)
    if not (unit and UnitExists(unit)) then return end

    if not UnitIsPlayer(unit) then 
        local p = (unit == "player" and PlayerPortrait) or 
                  (unit == "target" and TargetFramePortrait) or 
                  (unit == "focus" and FocusFramePortrait)
        if p and UI.SetClassPortrait then UI.SetClassPortrait(p, unit) end
        return 
    end

    local main, p
    if unit == "player" then main, p = PlayerFrame, PlayerPortrait
    elseif unit == "target" then main, p = TargetFrame, TargetFramePortrait
    elseif unit == "focus" then main, p = FocusFrame, FocusFramePortrait
    elseif unit == "targettarget" then main, p = TargetFrameToT, TargetFrameToTPortrait
    elseif unit == "focustarget" then main, p = FocusFrameToT, FocusFrameToTPortrait
    elseif unit == "pet" then main, p = PetFrame, PetPortrait
    else
        local partyId = string.match(unit, "^party(%d)$")
        if partyId then
            main, p = _G["PartyMemberFrame"..partyId], _G["PartyMemberFrame"..partyId.."Portrait"]
        end
    end

    local _, classToUse = UnitClass(unit)
    if classToUse and standardClasses[classToUse] then
        local color = GetClassColor(classToUse)
        if color then
            if unit == "player" and UI.PlayerNameBG then
                UI.PlayerNameBG:SetVertexColor(color.r, color.g, color.b, 1)
            elseif main and main.nameBackground then
                main.nameBackground:SetVertexColor(color.r, color.g, color.b, 1)
            end
        end
    end

    if UI.SetClassPortrait then
        UI.SetClassPortrait(p, unit)
    end
end

if TargetFrame_CheckFaction then
    hooksecurefunc("TargetFrame_CheckFaction", function(self)
        if not self.unit or not self.nameBackground then return end
        if UnitIsPlayer(self.unit) then
            local _, class = UnitClass(self.unit)
            local color = GetClassColor(class)
            if color then
                self.nameBackground:SetVertexColor(color.r, color.g, color.b, 1)
            end
        end
    end)
end

local function ApplyTextOutline(fontString)
    if not fontString then return end
    local font, size = fontString:GetFont()
    if font and size then
        fontString:SetFont(font, size, "OUTLINE")
        fontString:SetShadowOffset(1, -1)
        fontString:SetShadowColor(0, 0, 0, 1)
    end
end

ApplyTextOutline(PlayerName)
ApplyTextOutline(TargetFrameTextureFrameName)
ApplyTextOutline(FocusFrameTextureFrameName)
ApplyTextOutline(TargetFrameToTTextureFrameName)
ApplyTextOutline(FocusFrameToTTextureFrameName)

local ThemeWatcher = CreateFrame("Frame")
ThemeWatcher:RegisterEvent("UNIT_TARGET")
ThemeWatcher:RegisterEvent("UNIT_PORTRAIT_UPDATE")
ThemeWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
ThemeWatcher:RegisterEvent("PLAYER_FOCUS_CHANGED")
ThemeWatcher:RegisterEvent("PARTY_MEMBERS_CHANGED")

ThemeWatcher:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_TARGET" or event == "UNIT_PORTRAIT_UPDATE" then
        if unit == "target" then UI.ApplyClassTheme("targettarget")
        elseif unit == "focus" then UI.ApplyClassTheme("focustarget")
        elseif unit and string.match(unit, "^party") then UI.ApplyClassTheme(unit) end
    elseif event == "PLAYER_TARGET_CHANGED" then
        UI.ApplyClassTheme("target")
        UI.ApplyClassTheme("targettarget")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        UI.ApplyClassTheme("focus")
        UI.ApplyClassTheme("focustarget")
    elseif event == "PARTY_MEMBERS_CHANGED" then
        for i = 1, 4 do UI.ApplyClassTheme("party"..i) end
        UI.ApplyClassTheme("player")
    end
end)