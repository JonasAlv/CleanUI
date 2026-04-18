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
    local angle = (CleanUIPositions and CleanUIPositions["MinimapButton"]) or 45
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
        
        if not CleanUIPositions then CleanUIPositions = {} end
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

    info.isTitle = true
    info.text = "CleanUI Options"
    info.notCheckable = true
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Toggle Class Icons / 3D Faces"
    info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("portrait") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Toggle Loot Test Mode"
    info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("loot test") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Toggle Party Test Mode"
    info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("party test") end
    UIDropDownMenu_AddButton(info, level)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Reset All Positions & Reload"
    info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("reset") end
    UIDropDownMenu_AddButton(info, level)
end

UIDropDownMenu_Initialize(DropdownMenu, InitializeMenu, "MENU")

button:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
        print("|cff00ff00CleanUI:|r Right-click the Minimap button for options!")
    elseif btn == "RightButton" then
        ToggleDropDownMenu(1, nil, DropdownMenu, "cursor", 3, -3)
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("CleanUI", 1, 0.82, 0)
    GameTooltip:AddLine("Left Click: Show Info", 1, 1, 1)
    GameTooltip:AddLine("Right Click: Open Options Menu", 1, 1, 1)
    GameTooltip:AddLine("Drag: Move Button", 0.5, 0.5, 0.5)
    GameTooltip:Show()
end)

button:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_LOGIN")
Init:SetScript("OnEvent", function()
    UpdatePosition()
end)