local _, UI = ...

local button = CreateFrame("Button", "CleanUIMinimapButton", Minimap)
button:SetSize(34, 34) 
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)

local bg = button:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
bg:SetSize(21, 21)
bg:SetPoint("CENTER")
bg:SetVertexColor(0, 0, 0, 1) 

local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(52, 52)
border:SetPoint("TOPLEFT")

local text = button:CreateFontString(nil, "OVERLAY")
text:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
text:SetPoint("CENTER")
text:SetText("CUI")
text:SetTextColor(1, 0.82, 0) 

button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
button:RegisterForDrag("LeftButton")
button:RegisterForClicks("RightButtonUp")
button:SetMovable(true)

local function UpdateMinimapButtonPos()
    CleanUIPositions = CleanUIPositions or {}
    local angle = CleanUIPositions["MinimapButton"] or 45
    local x = math.cos(math.rad(angle)) * 80
    local y = math.sin(math.rad(angle)) * 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function ToggleMinimalistMode()
    CleanUIPositions = CleanUIPositions or {}
    
    CleanUIPositions.MinimalistMode = not CleanUIPositions.MinimalistMode
    
    print("|cff00ff00CleanUI:|r Minimalist Mode (Hide Gryphons Only) " .. 
        (CleanUIPositions.MinimalistMode and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r") .. 
        ". Reloading UI...")
        
    ReloadUI()
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
    self:UnlockHighlight()
    self:SetScript("OnUpdate", nil)
end)

local DropdownMenu = CreateFrame("Frame", "CleanUIDropdownMenu", UIParent, "UIDropDownMenuTemplate")

local function InitializeMenu(self, level)
    local info = UIDropDownMenu_CreateInfo()
    
    info.isTitle = true
    info.text = "CleanUI Options"
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    local items = {
        {t="Toggle Portraits", c="portrait"}, 
        {t="Loot Test Mode", c="loot test"}, 
        {t="Party Test Mode", c="party test"}
    }
    
    for _, v in ipairs(items) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v.t
        info.notCheckable = true
        info.func = function() SlashCmdList["CLEANUI"](v.c) end
        UIDropDownMenu_AddButton(info)
    end

    info = UIDropDownMenu_CreateInfo()
    info.text = "Minimalist Mode (Hide Gryphons Only)"
    info.func = ToggleMinimalistMode
    info.checked = CleanUIPositions and CleanUIPositions.MinimalistMode
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = ""
    info.disabled = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "|cffff0000Reset UI & Reload|r"
    info.notCheckable = true
    info.func = function() SlashCmdList["CLEANUI"]("reset") end
    UIDropDownMenu_AddButton(info)
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