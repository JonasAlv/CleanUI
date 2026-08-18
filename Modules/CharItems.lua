local _, UI = ...

UI.Modules["CharItems"] = function()
    local SimpleRarity = {
        [2] = {0.12, 0.80, 0.00},
        [3] = {0.00, 0.50, 0.90},
        [4] = {0.65, 0.20, 0.90},
        [5] = {1.00, 0.45, 0.00},
    }

    local GearEquipLocs = {
        INVTYPE_HEAD = true, INVTYPE_NECK = true, INVTYPE_SHOULDER = true,
        INVTYPE_CHEST = true, INVTYPE_ROBE = true, INVTYPE_WAIST = true,
        INVTYPE_LEGS = true, INVTYPE_FEET = true, INVTYPE_WRIST = true,
        INVTYPE_HAND = true, INVTYPE_FINGER = true, INVTYPE_TRINKET = true,
        INVTYPE_CLOAK = true, INVTYPE_WEAPON = true, INVTYPE_SHIELD = true,
        INVTYPE_2HWEAPON = true, INVTYPE_WEAPONMAINHAND = true,
        INVTYPE_WEAPONOFFHAND = true, INVTYPE_HOLDABLE = true,
        INVTYPE_RANGED = true, INVTYPE_THROWN = true,
        INVTYPE_RANGEDRIGHT = true, INVTYPE_RELIC = true,
    }

    local function StyleItemIcon(button, link)
        if not button then return end

        if not button.CleanUIGlow then
            local glow = button:CreateTexture(nil, "OVERLAY")
            glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            glow:SetBlendMode("ADD")
            glow:SetPoint("CENTER")
            button.CleanUIGlow = glow

            local extraGlow = button:CreateTexture(nil, "OVERLAY")
            extraGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            extraGlow:SetBlendMode("ADD")
            extraGlow:SetPoint("CENTER")
            button.CleanUIExtraGlow = extraGlow

            local ag = extraGlow:CreateAnimationGroup()
            
            local a1 = ag:CreateAnimation("Alpha")
            a1:SetOrder(1)
            a1:SetSmoothing("IN_OUT")
            
            local a2 = ag:CreateAnimation("Alpha")
            a2:SetOrder(2)
            a2:SetSmoothing("IN_OUT")
            
            ag:SetLooping("REPEAT")
            
            extraGlow.Anim = ag
            extraGlow.FadeOut = a1
            extraGlow.FadeIn = a2

            local ilvlText = button:CreateFontString(nil, "OVERLAY")
            ilvlText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
            ilvlText:SetPoint("CENTER", 1, 0)
            button.CleanUI_ILvl = ilvlText
        end

        button.CleanUIGlow:Hide()
        button.CleanUIExtraGlow:Hide()
        button.CleanUIExtraGlow.Anim:Stop()
        button.CleanUI_ILvl:SetText("")
        button.CleanUI_ILvl:SetTextColor(1, 1, 1)
        button.CleanUIGlow:SetAlpha(0.6)
        button.CleanUIExtraGlow:SetAlpha(0.8)

        if link then
            local _, _, quality, ilvl, _, _, _, _, equipLoc = GetItemInfo(link)
            
            if equipLoc and GearEquipLocs[equipLoc] then
                if quality and quality > 1 then
                    local r, g, b
                    if SimpleRarity[quality] then
                        r, g, b = SimpleRarity[quality][1], SimpleRarity[quality][2], SimpleRarity[quality][3]
                    else
                        r, g, b = GetItemQualityColor(quality)
                    end
                    
                    local scale = 1.8
                    local extraScale = 1.8
                    local speed = 1.0
                    local drop = -0.3
                    
                    if quality == 2 then
                        scale = 1.8
                    elseif quality == 3 then
                        extraScale = 1.95
                        speed = 1.2
                        drop = -0.4
                    elseif quality == 4 then
                        extraScale = 2.05
                        speed = 0.8
                        drop = -0.5
                    elseif quality >= 5 then
                        extraScale = 2.2
                        speed = 0.4
                        drop = -0.7
                    end

                    local w, h = button:GetWidth(), button:GetHeight()
                    
                    button.CleanUIGlow:SetSize(w * scale, h * scale)
                    button.CleanUIGlow:SetVertexColor(r, g, b, 0.6)
                    button.CleanUIGlow:Show()

                    if quality >= 3 then
                        button.CleanUIExtraGlow:SetSize(w * extraScale, h * extraScale)
                        button.CleanUIExtraGlow:SetVertexColor(r, g, b, 0.8)
                        
                        button.CleanUIExtraGlow.FadeOut:SetChange(drop)
                        button.CleanUIExtraGlow.FadeOut:SetDuration(speed)
                        
                        button.CleanUIExtraGlow.FadeIn:SetChange(math.abs(drop))
                        button.CleanUIExtraGlow.FadeIn:SetDuration(speed)
                        
                        button.CleanUIExtraGlow.Anim:Play()
                        button.CleanUIExtraGlow:Show()
                    end
                    
                    button.CleanUI_ILvl:SetTextColor(r, g, b)
                end

                if ilvl and ilvl > 1 then
                    button.CleanUI_ILvl:SetText(ilvl)
                end
            end
        end
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        if not button then return end
        local id = button:GetID()
        local link = GetInventoryItemLink("player", id)
        StyleItemIcon(button, link)
    end)

    local function HookInspect()
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
            if not button then return end
            local id = button:GetID()
            local unit = InspectFrame and InspectFrame.unit or "target"
            local link = GetInventoryItemLink(unit, id)
            StyleItemIcon(button, link)
        end)
    end

    if IsAddOnLoaded("Blizzard_InspectUI") then
        HookInspect()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, addon)
            if addon == "Blizzard_InspectUI" then
                HookInspect()
                self:UnregisterEvent(event)
            end
        end)
    end

    local inspectWatcher = CreateFrame("Frame")
    inspectWatcher:RegisterEvent("INSPECT_READY")
    inspectWatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    inspectWatcher:SetScript("OnEvent", function(self, event, arg1)
        if InspectFrame and InspectFrame:IsShown() then
            if event == "INSPECT_READY" and arg1 == InspectFrame.unit then
                if InspectPaperDollFrame_Update then
                    InspectPaperDollFrame_Update()
                end
            elseif event == "GET_ITEM_INFO_RECEIVED" then
                if InspectPaperDollFrame_Update then
                    InspectPaperDollFrame_Update()
                end
            end
        end
    end)

    local equipmentSlotButtons = {
        [1] = CharacterHeadSlot,
        [2] = CharacterNeckSlot,
        [3] = CharacterShoulderSlot,
        [4] = CharacterShirtSlot,
        [5] = CharacterChestSlot,
        [6] = CharacterWaistSlot,
        [7] = CharacterLegsSlot,
        [8] = CharacterFeetSlot,
        [9] = CharacterWristSlot,
        [10] = CharacterHandsSlot,
        [11] = CharacterFinger0Slot,
        [12] = CharacterFinger1Slot,
        [13] = CharacterTrinket0Slot,
        [14] = CharacterTrinket1Slot,
        [15] = CharacterBackSlot,
        [16] = CharacterMainHandSlot,
        [17] = CharacterSecondaryHandSlot,
        [18] = CharacterRangedSlot,
        [19] = CharacterTabardSlot,
    }

    local equipEventWatcher = CreateFrame("Frame")
    equipEventWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    equipEventWatcher:SetScript("OnEvent", function(self, event, slotId, hasItem)
        local button = equipmentSlotButtons[slotId]
        if button and PaperDollItemSlotButton_Update then
            PaperDollItemSlotButton_Update(button)
        end
    end)
end