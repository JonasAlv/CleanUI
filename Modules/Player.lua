local _, UI = ...

UI.MakeMovableAndSave(PlayerFrame, "PlayerFrame")
UI.ProtectFrame(PlayerFrameHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:SetScript("OnEvent", function(self)
    UI.ApplyClassTheme("player")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD") 
end)