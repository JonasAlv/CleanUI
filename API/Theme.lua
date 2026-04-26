local _, UI = ...

local standardClasses = {
    WARRIOR = true, PALADIN = true, HUNTER = true, ROGUE = true,
    PRIEST = true, DEATHKNIGHT = true, SHAMAN = true, MAGE = true,
    WARLOCK = true, DRUID = true
}

UI.PlayerNameBG = nil 
local function CreatePlayerNameBackground()
    if not UI.PlayerNameBG then
        UI.PlayerNameBG = PlayerFrame:CreateTexture(nil, "ARTWORK")
        UI.PlayerNameBG:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-LevelBackground")
        
        UI.PlayerNameBG:SetSize(114, 18)
        
        UI.PlayerNameBG:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 107, -22)
        UI.PlayerNameBG:SetTexCoord(1, 0, 0, 1)
        
        local _, class = UnitClass("player")
        
        if class and standardClasses[class] then
            local color = RAID_CLASS_COLORS[class]
            if color then
                UI.PlayerNameBG:SetVertexColor(color.r, color.g, color.b, 1)
            end
        else
            UI.PlayerNameBG:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        end
    end
end
CreatePlayerNameBackground()

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
        UI.ApplyClassTheme("targettarget")
    elseif event == "PLAYER_FOCUS_CHANGED" then 
        UI.ApplyClassTheme("focustarget")
    elseif event == "PARTY_MEMBERS_CHANGED" then
        for i = 1, 4 do UI.ApplyClassTheme("party"..i) end
        UI.ApplyClassTheme("player")
    end
end)

function UI.ProtectFrame(healthBar)
    if not healthBar or healthBar.hooked then return end
    
    hooksecurefunc(healthBar, "SetStatusBarColor", function(self, r, g, b)
        if self.isCleanUI_Updating then return end

        local parent = self:GetParent()
        local unit = parent.unit or (parent:GetParent() and parent:GetParent().unit)
        local pName = parent:GetName() or ""
        
        if not unit then
            if pName == "TargetFrameToT" then unit = "targettarget"
            elseif pName == "FocusFrameToT" then unit = "focustarget" end
        end
        
        if unit then
            local safeUnit = unit
            if UnitIsUnit(unit, "player") then safeUnit = "player"
            elseif UnitIsUnit(unit, "target") then safeUnit = "target"
            elseif UnitIsUnit(unit, "focus") then safeUnit = "focus" end

            local tClass = UnitIsPlayer(safeUnit) and select(2, UnitClass(safeUnit))

            if CleanUI_TestActive then
                if pName == "PartyMemberFrame1" then tClass = "PALADIN"
                elseif pName == "PartyMemberFrame2" then tClass = "WARRIOR"
                elseif pName == "PartyMemberFrame3" then tClass = "HUNTER"
                elseif pName == "PartyMemberFrame4" then tClass = "PRIEST"
                elseif pName:find("PetFrame") then tClass = "WARLOCK" end
            end

            if tClass and standardClasses[tClass] then
                local color = RAID_CLASS_COLORS[tClass]
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

function UI.ApplyClassTheme(unit, forceClass)
    if not (unit and (forceClass or UnitExists(unit))) then return end

    local safeUnit = unit
    if UnitIsUnit(unit, "player") then safeUnit = "player"
    elseif UnitIsUnit(unit, "target") then safeUnit = "target"
    elseif UnitIsUnit(unit, "focus") then safeUnit = "focus" end

    local main, h, p
    if unit == "player" then 
        main, h, p = PlayerFrame, PlayerFrameHealthBar, PlayerPortrait
    elseif unit == "target" then 
        main, h, p = TargetFrame, TargetFrameHealthBar, TargetFramePortrait
    elseif unit == "focus" then 
        main, h, p = FocusFrame, FocusFrameHealthBar, FocusFramePortrait
    elseif unit == "targettarget" then 
        main, h, p = TargetFrameToT, TargetFrameToTHealthBar, TargetFrameToTPortrait
    elseif unit == "focustarget" then 
        main, h, p = FocusFrameToT, FocusFrameToTHealthBar, FocusFrameToTPortrait
    elseif unit == "pet" then 
        main, h, p = PetFrame, PetFrameHealthBar, PetPortrait 
    else
        local partyId = string.match(unit, "^party(%d)$")
        local partyPetId = string.match(unit, "^partypet(%d)$")
        
        if partyId then
            main, h, p = _G["PartyMemberFrame"..partyId], _G["PartyMemberFrame"..partyId.."HealthBar"], _G["PartyMemberFrame"..partyId.."Portrait"]
        elseif partyPetId then
            main, h, p = _G["PartyMemberFrame"..partyPetId.."PetFrame"], _G["PartyMemberFrame"..partyPetId.."PetFrameHealthBar"], _G["PartyMemberFrame"..partyPetId.."PetFramePortrait"]
        end
    end

    if not (h and p) then return end

    local classToUse = forceClass or (UnitIsPlayer(safeUnit) and select(2, UnitClass(safeUnit)))
    if classToUse and standardClasses[classToUse] then
        local color = RAID_CLASS_COLORS[classToUse]
        if color then
            if unit == "player" and UI.PlayerNameBG then
                UI.PlayerNameBG:SetVertexColor(color.r, color.g, color.b, 1)
            elseif main and main.nameBackground then
                main.nameBackground:SetVertexColor(color.r, color.g, color.b, 1)
            end
        end
    else
        if unit == "player" and UI.PlayerNameBG then
            UI.PlayerNameBG:SetVertexColor(0.2, 0.2, 0.2, 0.8)
        end
    end

    if UI.SetClassPortrait then
        UI.SetClassPortrait(p, safeUnit, forceClass)
    end

    if unit ~= "focustarget" then
        h.isCleanUI_Updating = false
        h:SetStatusBarColor(0, 1, 0)
    end
end

if TargetFrame_CheckFaction then
    hooksecurefunc("TargetFrame_CheckFaction", function(self)
        if not self.unit or not self.nameBackground then return end
        
        local safeUnit = self.unit
        if UnitIsUnit(safeUnit, "player") then safeUnit = "player" end

        if UnitIsPlayer(safeUnit) then
            local _, classToUse = UnitClass(safeUnit)
            
            if classToUse and standardClasses[classToUse] then
                local color = RAID_CLASS_COLORS[classToUse]
                if color then
                    self.nameBackground:SetVertexColor(color.r, color.g, color.b, 1)
                end
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