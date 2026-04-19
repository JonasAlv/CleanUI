local _, UI = ...

local button = CreateFrame("Button", "CleanUIMinimapButton", Minimap)
button:SetSize(34, 34) 
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)

local bg = button:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
bg:SetSize(21, 21) 
bg:SetPoint("CENTER", 0, 0)
bg:SetVertexColor(0, 0, 0, 1) 

local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(52, 52) 
border:SetPoint("TOPLEFT", 0, 0)

local text = button:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
text:SetPoint("CENTER", 0, 0)
text:SetText("CUI")
text:SetTextColor(1, 0.82, 0) 

button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
button:RegisterForDrag("LeftButton")
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:SetMovable(true)

local function UpdatePosition()
    if not CleanUIPositions then CleanUIPositions = {} end
    local angle = CleanUIPositions["MinimapButton"] or 45
    local radius = 80
    
    local rad = math.rad(angle)
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius
    
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

button:SetScript("OnDragStart", function(self)
    self:LockHighlight()
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        local angle = math.deg(math.atan2(py - my, px - mx))
        if angle < 0 then angle = angle + 360 end
        
        CleanUIPositions["MinimapButton"] = angle
        UpdatePosition()
    end)
end)

button:SetScript("OnDragStop", function(self)
    self:UnlockHighlight()
    self:SetScript("OnUpdate", nil)
end)

local DropdownMenu = CreateFrame("Frame", "CleanUIDropdownMenu", UIParent, "UIDropDownMenuTemplate")

local function InitializeMenu(self, level)
    local info = UIDropDownMenu_CreateInfo()

    -- HEADER
    info.isTitle = true; info.text = "CleanUI Options"; info.notCheckable = true
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Toggle Portraits (Class/3D)"; info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("portrait") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Loot Test Mode"; info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("loot test") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Party Test Mode"; info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("party test") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.isTitle = true; info.text = "Bottom Bar Settings"; info.notCheckable = true
    UIDropDownMenu_AddButton(info, level)

    local function ToggleActionBar(barID)
        local varName = "SHOW_MULTI_ACTIONBAR_" .. barID
        
        _G[varName] = not _G[varName] and 1 or nil
        
        SetActionBarToggles(
            SHOW_MULTI_ACTIONBAR_1, 
            SHOW_MULTI_ACTIONBAR_2, 
            SHOW_MULTI_ACTIONBAR_3, 
            SHOW_MULTI_ACTIONBAR_4, 
            tonumber(GetCVar("alwaysShowActionBars"))
        )
        
        MultiActionBar_Update()
        if UIParent_ManageFramePositions then UIParent_ManageFramePositions() end
    end

    for i = 1, 2 do
        local label = (i == 1 and "Show Bar 2 (Bottom Left)") or ("Show Bar 3 (Bottom Right)")
        info = UIDropDownMenu_CreateInfo()
        info.text = label
        info.func = function() ToggleActionBar(i) end
        info.checked = _G["SHOW_MULTI_ACTIONBAR_" .. i]
        UIDropDownMenu_AddButton(info, level)
    end

    info = UIDropDownMenu_CreateInfo()
    info.text = "|cffff0000Reset UI & Reload|r"; info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("reset") end
    UIDropDownMenu_AddButton(info, level)
end

button:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
        print("|cff00ff00CleanUI:|r Right-click CUI button for settings.")
    elseif btn == "RightButton" then
        ToggleDropDownMenu(1, nil, DropdownMenu, "cursor", 3, -3)
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("CleanUI", 1, 0.82, 0)
    GameTooltip:AddLine("Left Click: Info", 1, 1, 1)
    GameTooltip:AddLine("Right Click: Options", 1, 1, 1)
    GameTooltip:AddLine("Drag: Move Button", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_LOGIN")
Init:RegisterEvent("CVAR_UPDATE") 

Init:SetScript("OnEvent", function(self, event)
    UpdatePosition()
    
    if event == "PLAYER_LOGIN" then
        UIDropDownMenu_Initialize(DropdownMenu, InitializeMenu, "MENU")
    end
end)