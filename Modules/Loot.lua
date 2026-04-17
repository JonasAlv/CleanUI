local _, UI = ...

local anchor = CreateFrame("Frame", "CleanUILootAnchor", UIParent)
anchor:SetSize(280, 72)
anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", 350, 150)

UI.MakeMovableAndSave(anchor, "LootStack")

if UIPARENT_MANAGED_FRAME_POSITIONS then
    UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootFrame1"] = nil
end

for i = 1, 4 do
    local f = _G["GroupLootFrame"..i]
    if f then
        f:SetScale(0.9)
    end
end

local function ApplyLootPosition(frame, id)
    frame:ClearAllPoints()
    local yOffset = (id - 1) * 100
    frame:SetPoint("BOTTOM", anchor, "BOTTOM", 0, yOffset)
end

local function ForceLootLayout()
    for i = 1, 4 do
        local frame = _G["GroupLootFrame"..i]
        if frame and frame:IsShown() then
            ApplyLootPosition(frame, i)
        end
    end
end

hooksecurefunc("AlertFrame_FixAnchors", ForceLootLayout)
hooksecurefunc("GroupLootFrame_OnShow", ForceLootLayout)

local testFrames = {}

function UI.UpdateLootTest()
    if CleanUI_LootTestActive and not InCombatLockdown() then
        anchor:EnableMouse(true)
    else
        anchor:EnableMouse(false)
    end

    for i = 1, 4 do
        if not testFrames[i] then
            local f = CreateFrame("Frame", "CleanUILootTest"..i, UIParent)
            f:SetSize(280, 72)
            f:SetScale(0.9) 
            
            local bg = f:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetTexture(0, 0, 0, 0.7)

            local txt = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            txt:SetPoint("CENTER")
            txt:SetText("LOOT " .. i)

            f:EnableMouse(false)
            testFrames[i] = f
        end

        local dummy = testFrames[i]
        if CleanUI_LootTestActive then
            dummy:Show()
            dummy:SetFrameStrata("DIALOG")
            ApplyLootPosition(dummy, i)
        else
            dummy:Hide()
        end
    end
end