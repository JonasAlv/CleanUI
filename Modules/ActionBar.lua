local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local Hider = CreateFrame("Frame", "CleanUIHider", UIParent)
Hider:Hide()

local function SkinButton(btn)
    if not btn then return end
    local name = btn:GetName()
    local icon = _G[name.."Icon"]
    if icon then icon:SetTexCoord(0, 1, 0, 1) end
    if btn:GetNormalTexture() then btn:GetNormalTexture():SetAlpha(1) end
    
    if not btn.cleanUIHooked then
        btn:HookScript("OnMouseDown", function(self, button)
            if IsShiftKeyDown() and IsControlKeyDown() and button == "LeftButton" then
                local anchor = CleanUIActionBarAnchor
                if anchor and anchor:GetScript("OnMouseDown") then anchor:GetScript("OnMouseDown")(anchor, button) end
            end
        end)
        btn:HookScript("OnMouseUp", function(self, button)
            local anchor = CleanUIActionBarAnchor
            if anchor and anchor.isCleanUIMoving and anchor:GetScript("OnMouseUp") then anchor:GetScript("OnMouseUp")(anchor, button) end
        end)
        btn.cleanUIHooked = true
    end
end

local function EnforceBarPositions()
    if InCombatLockdown() or not CleanUIActionBarAnchor then return end
    
    local mainBar = _G["CleanUIMainBar"]
    if mainBar then
        mainBar:ClearAllPoints()
        mainBar:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 12)
    end
    
    local bonusBar = _G["CleanUIBonusBar"]
    if bonusBar then
        bonusBar:ClearAllPoints()
        bonusBar:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 12)
    end
    
    local possessBar = _G["CleanUIPossessBar"]
    if possessBar then
        possessBar:ClearAllPoints()
        possessBar:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 12)
    end
    
    if MultiBarBottomLeftButton1 then
        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 50)
    end
    
    if MultiBarBottomRightButton1 then
        MultiBarBottomRightButton1:ClearAllPoints()
        if MultiBarBottomLeft:IsShown() then
            MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 88)
        else
            MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", CleanUIActionBarAnchor, "BOTTOMLEFT", 0, 50)
        end
    end
end

local function SyncBarState()
    if _G["SHOW_MULTI_ACTIONBAR_2"] then
        MultiBarBottomRight:Show()
    else
        MultiBarBottomRight:Hide()
    end
    EnforceBarPositions()
end

function UI.ForceTwoBarLayout(isReset)
    if isReset then
        CleanUIPositions = CleanUIPositions or {}
        CleanUIPositions["ShowBar3"] = false 
        
        _G["SHOW_MULTI_ACTIONBAR_1"] = 1
        _G["SHOW_MULTI_ACTIONBAR_2"] = nil
        _G["SHOW_MULTI_ACTIONBAR_3"] = nil
        _G["SHOW_MULTI_ACTIONBAR_4"] = nil
        
        SetActionBarToggles(1, nil, nil, nil, 1)
        MultiActionBar_Update()
    end
    SyncBarState()
end

local function ApplyCleanSkin()
    CleanUIPositions = CleanUIPositions or {}
    
    _G["SHOW_MULTI_ACTIONBAR_1"] = 1
    _G["SHOW_MULTI_ACTIONBAR_2"] = CleanUIPositions["ShowBar3"] and 1 or nil
    _G["SHOW_MULTI_ACTIONBAR_3"] = nil
    _G["SHOW_MULTI_ACTIONBAR_4"] = nil
    SetActionBarToggles(1, _G["SHOW_MULTI_ACTIONBAR_2"], nil, nil, 1)

    local mainAnchor = _G["CleanUIActionBarAnchor"] or CreateFrame("Frame", "CleanUIActionBarAnchor", UIParent)
    mainAnchor:SetSize(500, 100); mainAnchor:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    if UI.MakeMovableAndSave then UI.MakeMovableAndSave(mainAnchor, "ActionBarAnchor") end

    local logicFrames = {MainMenuBar, BonusActionBarFrame, PossessBarFrame, PetActionBarFrame, ShapeshiftBarFrame}
    for _, f in ipairs(logicFrames) do
        if f then
            f:SetAlpha(0)
            f:EnableMouse(false)
            f:SetSize(1, 1)
        end
    end

    local artFrames = {
        MainMenuBarArtFrame, MainMenuBarOverlayFrame, MainMenuBarMaxLevelBar,
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuMaxLevelBar2, MainMenuMaxLevelBar3,
        BonusActionBarTexture0, BonusActionBarTexture1
    }
    for _, frame in ipairs(artFrames) do
        if frame then frame:SetParent(Hider) end
    end

    local barContainer = CreateFrame("Frame", "CleanUIMainBar", mainAnchor, "SecureHandlerStateTemplate")
    barContainer:SetSize(400, 40)
    
    local bonusContainer = CreateFrame("Frame", "CleanUIBonusBar", mainAnchor, "SecureHandlerStateTemplate")
    bonusContainer:SetSize(400, 40)

    local possessContainer = CreateFrame("Frame", "CleanUIPossessBar", mainAnchor, "SecureHandlerStateTemplate")
    possessContainer:SetSize(400, 40)

    local bars = {MultiBarBottomLeft, MultiBarBottomRight}
    for _, bar in ipairs(bars) do
        if bar then
            bar:SetParent(mainAnchor)
            for i = 1, 12 do SkinButton(_G[bar:GetName().."Button"..i]) end
        end
    end

    for i = 1, 12 do
        local btn = _G["ActionButton"..i]
        if btn then 
            btn:SetParent(barContainer)
            btn:ClearAllPoints()
            if i == 1 then btn:SetPoint("BOTTOMLEFT", barContainer, "BOTTOMLEFT", 0, 0)
            else btn:SetPoint("LEFT", _G["ActionButton"..(i-1)], "RIGHT", 6, 0) end
            SkinButton(btn) 
        end
        
        local bonus = _G["BonusActionButton"..i]
        if bonus then 
            bonus:SetParent(bonusContainer)
            bonus:ClearAllPoints()
            if i == 1 then bonus:SetPoint("BOTTOMLEFT", bonusContainer, "BOTTOMLEFT", 0, 0)
            else bonus:SetPoint("LEFT", _G["BonusActionButton"..(i-1)], "RIGHT", 6, 0) end
            SkinButton(bonus) 
        end
        
        local possess = _G["PossessButton"..i]
        if possess then 
            possess:SetParent(possessContainer)
            possess:ClearAllPoints()
            if i == 1 then possess:SetPoint("BOTTOMLEFT", possessContainer, "BOTTOMLEFT", 0, 0)
            else possess:SetPoint("LEFT", _G["PossessButton"..(i-1)], "RIGHT", 6, 0) end
            SkinButton(possess) 
        end
    end

    RegisterStateDriver(barContainer, "visibility", "[bonusbar:1/2/3/4/5] hide; show")
    RegisterStateDriver(bonusContainer, "visibility", "[bonusbar:1/2/3/4] show; hide")
    RegisterStateDriver(possessContainer, "visibility", "[bonusbar:5] show; hide")

    hooksecurefunc("MultiActionBar_Update", SyncBarState)
    hooksecurefunc("UIParent_ManageFramePositions", EnforceBarPositions)
    
    SyncBarState()
end

F:SetScript("OnEvent", function(self, event) 
    if event == "PLAYER_ENTERING_WORLD" then 
        ApplyCleanSkin() 
    end 
end)