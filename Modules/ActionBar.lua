local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local function ApplyCleanSkin()

    _G["SHOW_MULTI_ACTIONBAR_1"] = nil   
    _G["SHOW_MULTI_ACTIONBAR_2"] = nil 
    _G["SHOW_MULTI_ACTIONBAR_3"] = nil 
    _G["SHOW_MULTI_ACTIONBAR_4"] = nil 
    
--     SetCVar("lockActionBars", "1")
--     MultiActionBar_Update()

    local artToHide = {
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap,
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuExpBar, ReputationWatchBar, MainMenuBarMaxLevelBar,
        MainMenuBarPageNumber, ActionBarUpButton, ActionBarDownButton, ExhaustionTick
    }
    
    for _, frame in ipairs(artToHide) do
        if frame then
            frame:Hide()
            frame.Show = function() end 
        end
    end

    local anchor = CreateFrame("Frame", "CleanUIActionBarAnchor", UIParent)
    anchor:SetSize(498, 110)
    anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0) 
    anchor:SetFrameStrata("BACKGROUND") 
    
    if UI.MakeMovableAndSave then
        UI.MakeMovableAndSave(anchor, "ActionBarAnchor")
    end

    hooksecurefunc("UIParent_ManageFramePositions", function()
        
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 0)

        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 1)

        MultiBarBottomRight:ClearAllPoints()
        if MultiBarBottomLeft:IsShown() then
            MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeft, "TOPLEFT", 0, 1)
        else
            MultiBarBottomRight:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 1)
        end

        local topBar = ActionButton1 
        if MultiBarBottomLeft:IsShown() then topBar = MultiBarBottomLeft end
        if MultiBarBottomRight:IsShown() then topBar = MultiBarBottomRight end

        if PetActionBarFrame then
            PetActionBarFrame:ClearAllPoints()
            PetActionBarFrame:SetPoint("BOTTOMLEFT", topBar, "TOPLEFT", 30, 1)
        end
        if ShapeshiftBarFrame then
            ShapeshiftBarFrame:ClearAllPoints()
            ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", topBar, "TOPLEFT", 10, 1)
        end

        CharacterMicroButton:ClearAllPoints()
        CharacterMicroButton:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMRIGHT", -265, 0)
        
        MainMenuBarBackpackButton:ClearAllPoints()
        MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 36)
        
    end)
    
    UIParent_ManageFramePositions()
end

F:SetScript("OnEvent", ApplyCleanSkin)