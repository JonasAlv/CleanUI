local _, UI = ...

local button = CreateFrame("Button", "CleanUIMinimapButton", Minimap)
button:SetSize(34, 34) 
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)

local bg = button:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
bg:SetSize(21, 21); bg:SetPoint("CENTER"); bg:SetVertexColor(0, 0, 0, 1) 

local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(52, 52); border:SetPoint("TOPLEFT")

local text = button:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE"); text:SetPoint("CENTER")
text:SetText("CUI"); text:SetTextColor(1, 0.82, 0) 

button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
button:RegisterForDrag("LeftButton"); button:RegisterForClicks("RightButtonUp")
button:SetMovable(true)

local function UpdateMinimapButtonPos()
    CleanUIPositions = CleanUIPositions or {}
    local angle = CleanUIPositions["MinimapButton"] or 45
    local x = math.cos(math.rad(angle)) * 80
    local y = math.sin(math.rad(angle)) * 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

button:SetScript("OnDragStart", function(self)
    self:LockHighlight()
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        local angle = math.deg(math.atan2(py/scale - my, px/scale - mx))
        CleanUIPositions["MinimapButton"] = angle % 360
        UpdateMinimapButtonPos()
    end)
end)

button:SetScript("OnDragStop", function(self)
    self:UnlockHighlight(); self:SetScript("OnUpdate", nil)
end)

local function ToggleBar3()
    CleanUIPositions = CleanUIPositions or {}
    
    if CleanUIPositions["ShowBar3"] then
        CleanUIPositions["ShowBar3"] = false
        _G["SHOW_MULTI_ACTIONBAR_2"] = nil
    else
        CleanUIPositions["ShowBar3"] = true
        _G["SHOW_MULTI_ACTIONBAR_2"] = 1
    end
    
    SetActionBarToggles(1, _G["SHOW_MULTI_ACTIONBAR_2"], nil, nil, 1)
    MultiActionBar_Update()
end

local DropdownMenu = CreateFrame("Frame", "CleanUIDropdownMenu", UIParent, "UIDropDownMenuTemplate")

local function InitializeMenu(self, level)
    CleanUIPositions = CleanUIPositions or {}
    
    local info = UIDropDownMenu_CreateInfo()
    info.isTitle = true; info.text = "CleanUI Options"; info.notCheckable = true; UIDropDownMenu_AddButton(info)

    local items = {
        {t="Toggle Portraits", c="portrait"}, 
        {t="Loot Test Mode", c="loot test"}, 
        {t="Party Test Mode", c="party test"}
    }
    for _, v in ipairs(items) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v.t; info.notCheckable = true
        info.func = function() SlashCmdList["CLEANUI"](v.c) end
        UIDropDownMenu_AddButton(info)
    end

    info = UIDropDownMenu_CreateInfo(); info.isTitle = true; info.text = "Bars"; info.notCheckable = true; UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Show Bar 3 (Bottom Right)"
    info.func = ToggleBar3
    info.checked = CleanUIPositions["ShowBar3"] or false
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo(); info.text = "|cffff0000Reset UI & Reload|r"; info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("reset") end; UIDropDownMenu_AddButton(info)
end

button:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" then
        UIDropDownMenu_Initialize(DropdownMenu, InitializeMenu, "MENU")
        ToggleDropDownMenu(1, nil, DropdownMenu, "cursor", 3, -3)
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("CleanUI", 1, 0.82, 0)
    GameTooltip:AddLine("Right Click: Options", 1, 1, 1)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function() GameTooltip:Hide() end)

local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_LOGIN")
Init:SetScript("OnEvent", function() UpdateMinimapButtonPos() end)