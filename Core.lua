local _, UI = ...
UI.Modules = {}

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

local Setup = CreateFrame("Frame")
Setup:RegisterEvent("PLAYER_LOGIN")
Setup:RegisterEvent("PLAYER_ENTERING_WORLD")

Setup:SetScript("OnEvent", function(self, event)
    CleanUIPositions = CleanUIPositions or {}
    
    if CleanUIClassPortraits == nil then 
        CleanUIClassPortraits = true 
    end
    
    if CleanUIPositions.HideBarBg == nil then 
        CleanUIPositions.HideBarBg = true 
    end

    if event == "PLAYER_LOGIN" then
        if CleanUIPositions.EnableCharItems == nil then CleanUIPositions.EnableCharItems = true end
        if CleanUIPositions.EnableStatsColors == nil then CleanUIPositions.EnableStatsColors = true end
        if CleanUIPositions.EnableTooltipsTheming == nil then CleanUIPositions.EnableTooltipsTheming = true end
        if CleanUIPositions.EnableParty == nil then CleanUIPositions.EnableParty = true end
        if CleanUIPositions.EnableTooltip == nil then CleanUIPositions.EnableTooltip = true end
        if CleanUIPositions.EnableUnitFrames == nil then CleanUIPositions.EnableUnitFrames = true end

        if CleanUIPositions.EnableCharItems and UI.Modules["CharItems"] then UI.Modules["CharItems"]() end
        if CleanUIPositions.EnableStatsColors and UI.Modules["StatsColors"] then UI.Modules["StatsColors"]() end
        if CleanUIPositions.EnableTooltipsTheming and UI.Modules["TooltipsTheming"] then UI.Modules["TooltipsTheming"]() end
        if CleanUIPositions.EnableParty and UI.Modules["Party"] then UI.Modules["Party"]() end
        if CleanUIPositions.EnableTooltip and UI.Modules["Tooltip"] then UI.Modules["Tooltip"]() end
        if CleanUIPositions.EnableUnitFrames and UI.Modules["UnitFrames"] then UI.Modules["UnitFrames"]() end
        
        -- Portraits always load as a core utility tool when UI is active
        if UI.Modules["Portraits"] then UI.Modules["Portraits"]() end
    end

    if TargetFrameToTHealthBar then UI.ProtectFrame(TargetFrameToTHealthBar) end
    if FocusFrameToTHealthBar then UI.ProtectFrame(FocusFrameToTHealthBar) end
    
    if UI.RefreshPortraits then 
        UI.RefreshPortraits() 
    end
end)

SLASH_CLEANUI1 = "/cleanui"
SlashCmdList["CLEANUI"] = function(msg)
    msg = (msg or ""):lower()
    
    if msg == "reset" then
        CleanUIPositions = {} 
        CleanUIPositions.HideBarBg = true 
        CleanUIPositions.MinimapIcon = { hide = false }
        CleanUIClassPortraits = true

        local frames = {
            PlayerFrame, TargetFrame, FocusFrame, PetFrame, 
            TargetFrameToT, FocusFrameToT, 
            CleanUIPartyAnchor, CleanUIPetBarAnchor, 
            CleanUIStanceBarAnchor, CleanUIMicroMenuAnchor, CleanUIBagBarAnchor,
        }
        
        for i = 1, 4 do
            table.insert(frames, _G["PartyMemberFrame"..i])
            table.insert(frames, _G["PartyMemberFrame"..i.."PetFrame"])
        end

        for _, f in pairs(frames) do 
            if f then 
                if f.SetMovable then f:SetMovable(true) end
                f:SetUserPlaced(false) 
                f:ClearAllPoints()     
            end 
        end

        print("|cff00ff00CleanUI:|r UI reset to defaults. Reloading...")
        ReloadUI()

    elseif msg == "portrait" then
        CleanUIClassPortraits = not CleanUIClassPortraits
        if UI.RefreshPortraits then UI.RefreshPortraits() end
        print("|cff00ff00CleanUI:|r Portraits set to " .. (CleanUIClassPortraits and "|cff00ff00Class Icons|r" or "|cffff00003D Faces|r"))
    
    else
        InterfaceOptionsFrame_OpenToCategory("CleanUI")
        InterfaceOptionsFrame_OpenToCategory("CleanUI")
    end
end

hooksecurefunc("TargetofTarget_Update", function(self)
    if InCombatLockdown() then return end
    local name = (self == TargetFrameToT) and "TargetFrameToT" or "FocusFrameToT"
    local parent = (self == TargetFrameToT) and TargetFrame or FocusFrame

    if not CleanUIPositions or not CleanUIPositions[name] then
        self:ClearAllPoints()
        self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -10, -10)
    end
end)