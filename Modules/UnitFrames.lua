local _, UI = ...

-- Focus Frame Module
UI.MakeMovableAndSave(FocusFrame, "FocusFrame")
UI.ProtectFrame(FocusFrameHealthBar)
UI.ProtectFrame(FocusFrameToTHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_FOCUS_CHANGED")
F:SetScript("OnEvent", function()
    UI.ApplyClassTheme("focus")
end)

-- Target Frame Module
UI.MakeMovableAndSave(TargetFrame, "TargetFrame")
UI.ProtectFrame(TargetFrameHealthBar)
UI.ProtectFrame(TargetFrameToTHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_TARGET_CHANGED")
F:SetScript("OnEvent", function()
    UI.ApplyClassTheme("target")
end)

-- Player Frame Module
UI.MakeMovableAndSave(PlayerFrame, "PlayerFrame")
UI.ProtectFrame(PlayerFrameHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:SetScript("OnEvent", function(self)
    UI.ApplyClassTheme("player")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)