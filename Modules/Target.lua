local _, UI = ...

UI.MakeMovableAndSave(TargetFrame, "TargetFrame")
UI.ProtectFrame(TargetFrameHealthBar)
UI.ProtectFrame(TargetFrameToTHealthBar)

local F = CreateFrame("Frame")
F:RegisterEvent("PLAYER_TARGET_CHANGED")
F:SetScript("OnEvent", function()
    UI.ApplyClassTheme("target")
end)