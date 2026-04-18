local _, UI = ...

UI.MakeMovableAndSave(PlayerFrame, "PlayerFrame")
UI.ProtectFrame(PlayerFrameHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_ENTERING_WORLD")
F:SetScript("OnEvent", function(self)
    UI.ApplyClassTheme("player")
    -- player frame doesnt need constant updates(get class color and icon only once on login)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD") 
end)