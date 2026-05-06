local _, UI = ...

local UnitExists = UnitExists
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local InCombatLockdown = InCombatLockdown
local _G = _G

local anchor = CreateFrame("Frame", "CleanUIPartyAnchor", UIParent)
anchor:SetSize(130, 250)
anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -150)
anchor:SetFrameStrata("BACKGROUND")

if UI.MakeMovableAndSave then
    UI.MakeMovableAndSave(anchor, "PartyAnchor")
end

for i = 1, 4 do
    local pf = _G["PartyMemberFrame"..i]
    if pf then
        UI.ProtectFrame(_G["PartyMemberFrame"..i.."HealthBar"])
        local petH = _G["PartyMemberFrame"..i.."PetFrameHealthBar"]
        if petH then UI.ProtectFrame(petH) end
    end
end

-- 3. Party Update Logic
local needsUpdate = false

function UI.UpdatePartyLayout()
    if InCombatLockdown() then
        needsUpdate = true
        return
    end

    for i = 1, 4 do
        local pf = _G["PartyMemberFrame"..i]
        local pet = _G["PartyMemberFrame"..i.."PetFrame"]
        local unit = "party"..i

        if pf then
            local exists = UnitExists(unit)
            local isTest = CleanUI_TestActive --

            if isTest or exists then
                pf:Show() 
                pf:SetAlpha(1)

                pf:ClearAllPoints()
                if i == 1 then
                    pf:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
                else
                    local prev = _G["PartyMemberFrame"..(i-1)]
                    pf:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
                end

                if isTest then
                    local testClass = (i == 1 and "PALADIN") or (i == 2 and "WARRIOR") or (i == 3 and "HUNTER") or "PRIEST"
                    UI.ApplyClassTheme(unit, testClass)
                    if pet then 
                        pet:Show()
                        pet:SetAlpha(1)
                        UI.ApplyClassTheme("partypet"..i, "WARLOCK") 
                    end
                else
                    UI.ApplyClassTheme(unit)
                    if pet then
                        if UnitExists("partypet"..i) then
                            pet:Show()
                            pet:SetAlpha(1)
                            UI.ApplyClassTheme("partypet"..i)
                        else
                            pet:Hide()
                        end
                    end
                end
            else
                pf:Hide()
                pf:SetAlpha(0)
            end
        end
    end
    needsUpdate = false
end

local F = CreateFrame("Frame")
F:RegisterEvent("PARTY_MEMBERS_CHANGED")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("UNIT_PET")
F:RegisterEvent("PLAYER_REGEN_ENABLED")
F:RegisterEvent("PLAYER_ROLES_ASSIGNED")
F:RegisterEvent("LFG_ROLE_UPDATE")

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        if needsUpdate then UI.UpdatePartyLayout() end
    else
        UI.UpdatePartyLayout()
    end
end)
