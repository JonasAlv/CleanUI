local _, UI = ...

UI.MakeMovableAndSave(FocusFrame, "FocusFrame")
UI.ProtectFrame(FocusFrameHealthBar)
UI.ProtectFrame(FocusFrameToTHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_FOCUS_CHANGED")
F:SetScript("OnEvent", function()
    UI.ApplyClassTheme("focus")
end)