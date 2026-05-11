local _, UI = ...
local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")

local isLocking = false

local function Lobotomize(f)
    if not f or f.isLobotomized then return end
    f.OrigSetPoint = f.SetPoint
    f.OrigClearAllPoints = f.ClearAllPoints
    f.SetPoint = function() end
    f.ClearAllPoints = function() end
    f.isLobotomized = true
end

local function ApplyPetBarLockdown()
    if (CleanUIPositions and CleanUIPositions.MinimalistMode) or InCombatLockdown() or isLocking then return end
    isLocking = true
    
    local frame = PetActionBarFrame
    if frame then
        if frame.isLobotomized then
            local p = CleanUIPositions["PetBar"]
            frame:OrigClearAllPoints()
            if p then
                frame:OrigSetPoint(p.pt, UIParent, p.rel, p.x, p.y)
            else
                frame:OrigSetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
            end
        end
    end
    isLocking = false
end

local function InitPetBar()
    if CleanUIPositions and CleanUIPositions.MinimalistMode then return end
    if not PetActionBarFrame then return end

    PetActionBarFrame.ignoreFramePositionManager = true
    local art = {SlidingActionBarTexture0, SlidingActionBarTexture1}
    for _, tex in ipairs(art) do if tex then tex:Hide(); tex:SetAlpha(0) end end

    UI.MakeMovableAndSave(PetActionBarFrame, "PetBar")

    if not CleanUIPositions["PetBar"] then
        PetActionBarFrame:ClearAllPoints()
        PetActionBarFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 5)
    end

    Lobotomize(PetActionBarFrame)
    ApplyPetBarLockdown()
end

F:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then InitPetBar() end
end)

hooksecurefunc("UIParent_ManageFramePositions", ApplyPetBarLockdown)