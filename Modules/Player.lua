local _, UI = ...

UI.MakeMovableAndSave(PlayerFrame, "PlayerFrame")
UI.ProtectFrame(PlayerFrameHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:SetScript("OnEvent", function(self)
    UI.ApplyClassTheme("player")
    -- player frame doesnt need dynamic update so i use this here.
    self:UnregisterEvent("PLAYER_ENTERING_WORLD") 
end)