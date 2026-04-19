local _, UI = ...

local GridFrame
local function ShowAlignmentGrid()
    if not GridFrame then
        GridFrame = CreateFrame("Frame", "CleanUIGrid", UIParent)
        GridFrame:SetAllPoints(UIParent)
        GridFrame:SetFrameStrata("BACKGROUND") 
        
        local size = 64 
        local width = GetScreenWidth()
        local height = GetScreenHeight()
        local centerX = width / 2
        local centerY = height / 2
        
        local vCenter = GridFrame:CreateTexture(nil, "ARTWORK")
        vCenter:SetColorTexture(0, 1, 0, 0.8)
        vCenter:SetWidth(1)
        vCenter:SetPoint("TOP", GridFrame, "TOP", 0, 0)
        vCenter:SetPoint("BOTTOM", GridFrame, "BOTTOM", 0, 0)

        local hCenter = GridFrame:CreateTexture(nil, "ARTWORK")
        hCenter:SetColorTexture(0, 1, 0, 0.8)
        hCenter:SetHeight(1)
        hCenter:SetPoint("LEFT", GridFrame, "LEFT", 0, 0)
        hCenter:SetPoint("RIGHT", GridFrame, "RIGHT", 0, 0)
        
        local numCols = math.ceil(centerX / size)
        for i = -numCols, numCols do
            if i ~= 0 then 
                local line = GridFrame:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(0, 0, 0, 0.6)
                line:SetWidth(1)
                line:SetPoint("TOPLEFT", GridFrame, "TOPLEFT", centerX + (i * size), 0)
                line:SetPoint("BOTTOMLEFT", GridFrame, "BOTTOMLEFT", centerX + (i * size), 0)
            end
        end
        
        local numRows = math.ceil(centerY / size)
        for i = -numRows, numRows do
            if i ~= 0 then
                local line = GridFrame:CreateTexture(nil, "BACKGROUND")
                line:SetColorTexture(0, 0, 0, 0.6)
                line:SetHeight(1)
                line:SetPoint("TOPLEFT", GridFrame, "TOPLEFT", 0, -(centerY + (i * size)))
                line:SetPoint("TOPRIGHT", GridFrame, "TOPRIGHT", 0, -(centerY + (i * size)))
            end
        end
    end
    GridFrame:Show()
end

local function HideAlignmentGrid()
    if GridFrame then GridFrame:Hide() end
end

function UI.MakeMovableAndSave(frame, name, showLabel)
    if not frame or frame.isMovableSet then return end
    CleanUIPositions = CleanUIPositions or {}
    
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    if not InCombatLockdown() then frame:EnableMouse(true) end
    frame:RegisterForDrag("LeftButton")

    if CleanUIPositions[name] then
        local p = CleanUIPositions[name]
        frame:ClearAllPoints()
        frame:SetPoint(p.pt, UIParent, p.rel, p.x, p.y)
        frame:SetUserPlaced(true)
    else
        frame:SetUserPlaced(false)
    end

    local originalStrata = frame:GetFrameStrata()

    if not frame.cleanUI_highlight then
        frame.cleanUI_highlight = frame:CreateTexture(nil, "OVERLAY")
        frame.cleanUI_highlight:SetAllPoints()
        frame.cleanUI_highlight:SetColorTexture(0, 1, 0, 0.2) 
        frame.cleanUI_highlight:Hide()

        if showLabel then
            frame.cleanUI_text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            frame.cleanUI_text:SetPoint("CENTER", frame, "CENTER", 0, 0)
            
            local displayName = string.upper(name:gsub("Anchor", ""))
            frame.cleanUI_text:SetText(displayName)
            
            frame.cleanUI_text:SetTextColor(1, 1, 1, 1)
            frame.cleanUI_text:SetShadowOffset(1, -1)
            frame.cleanUI_text:SetShadowColor(0, 0, 0, 1)
            frame.cleanUI_text:Hide()
        end
    end

    frame:HookScript("OnUpdate", function(self)
        if (IsShiftKeyDown() and IsControlKeyDown()) or self.isCleanUIMoving then
            if not InCombatLockdown() then
                self:SetFrameStrata("DIALOG") 
                self.cleanUI_highlight:Show()
                if self.cleanUI_text then self.cleanUI_text:Show() end
            end
        else
            if not self.isCleanUIMoving then
                self:SetFrameStrata(originalStrata) 
                self.cleanUI_highlight:Hide()
                if self.cleanUI_text then self.cleanUI_text:Hide() end
            end
        end
    end)

    frame:SetScript("OnMouseDown", function(self, btn)
        if IsShiftKeyDown() and IsControlKeyDown() and btn == "LeftButton" then 
            self:StartMoving() 
            self.isCleanUIMoving = true
            ShowAlignmentGrid()
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self)
        if self.isCleanUIMoving then
            self:StopMovingOrSizing()
            self.isCleanUIMoving = false
            HideAlignmentGrid()
            
            local pt, _, rel, x, y = self:GetPoint()
            CleanUIPositions[name] = {pt = pt, rel = rel, x = x, y = y}
            self:SetUserPlaced(true)
            
            print("|cff00ff00CleanUI:|r " .. name .. " position saved.")
        end
    end)
    
    frame.isMovableSet = true
end