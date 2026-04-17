local _, UI = ...

function UI.MakeMovableAndSave(frame, name)
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

    frame:SetScript("OnMouseDown", function(self, btn)
        if IsShiftKeyDown() and IsControlKeyDown() and btn == "LeftButton" then 
            self:StartMoving() 
            self.isCleanUIMoving = true
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self)
        if self.isCleanUIMoving then
            self:StopMovingOrSizing()
            self.isCleanUIMoving = false
            
            local pt, _, rel, x, y = self:GetPoint()
            CleanUIPositions[name] = {pt = pt, rel = rel, x = x, y = y}
            self:SetUserPlaced(true)
            
            print("|cff00ff00CleanUI:|r " .. name .. " position saved.")
        end
    end)
    
    frame.isMovableSet = true
end