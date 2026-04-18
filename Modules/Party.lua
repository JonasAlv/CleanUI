local _, UI = ...

UI.NativePartyAnchors = {}

for i = 1, 4 do
    local pf = _G["PartyMemberFrame"..i]
    local pet = _G["PartyMemberFrame"..i.."PetFrame"]
    
    if pf then
        local p, rT, rP, x, y = pf:GetPoint()
        UI.NativePartyAnchors[i] = { pt = p, rel = rT, relP = rP, x = x, y = y }

        --pf:SetScale(0.85)

        UI.MakeMovableAndSave(pf, "Party"..i)
        UI.ProtectFrame(_G["PartyMemberFrame"..i.."HealthBar"])
        
        if pet then 
            UI.ProtectFrame(_G["PartyMemberFrame"..i.."PetFrameHealthBar"]) 
        end
    end
end

local F = CreateFrame("Frame")
F:RegisterEvent("PARTY_MEMBERS_CHANGED")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:RegisterEvent("UNIT_PET")
F:RegisterEvent("PLAYER_REGEN_ENABLED")
F:RegisterEvent("PLAYER_ROLES_ASSIGNED") 
F:RegisterEvent("LFG_ROLE_UPDATE")       

-- party update function
local needsUpdate = false

function UI.UpdatePartyLayout()
    if InCombatLockdown() then 
        needsUpdate = true
        return 
    end
    
    for i = 1, 4 do
        local pf = _G["PartyMemberFrame"..i]
        local pet = _G["PartyMemberFrame"..i.."PetFrame"]
        
        if pf then
            if CleanUI_TestActive then 
                pf:Show()
                pf:SetAlpha(1)
                if pet then pet:Show(); pet:SetAlpha(1) end 
                -- test mode
                local testClass = (i == 1 and "PALADIN") or (i == 2 and "WARRIOR") or (i == 3 and "HUNTER") or "PRIEST"
                
                UI.ApplyClassTheme("party"..i, testClass)
                
                if pet then 
                    UI.ApplyClassTheme("partypet"..i, "WARLOCK") 
                end
            else
                -- live mode
                if UnitExists("party"..i) then pf:SetAlpha(1) else pf:SetAlpha(0) end
                if pet then 
                    if UnitExists("partypet"..i) then pet:SetAlpha(1) else pet:SetAlpha(0) end
                end

                UI.ApplyClassTheme("party"..i)
                if pet then UI.ApplyClassTheme("partypet"..i) end
            end

            local savedPos = CleanUIPositions and CleanUIPositions["Party"..i]
            
            pf:ClearAllPoints()
            
            if savedPos then
                pf:SetPoint(savedPos.pt, UIParent, savedPos.rel, savedPos.x, savedPos.y)
            else
                local def = UI.NativePartyAnchors[i]
                if def and def.pt then
                    pf:SetPoint(def.pt, def.rel, def.relP, def.x, def.y)
                end
            end
        end
    end
    needsUpdate = false
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" then
        if needsUpdate then UI.UpdatePartyLayout() end
    else
        UI.UpdatePartyLayout()
    end
end)