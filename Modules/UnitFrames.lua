local _, UI = ...

UI.Modules["UnitFrames"] = function()
    UI.MakeMovableAndSave(FocusFrame, "FocusFrame")
    UI.ProtectFrame(FocusFrameHealthBar)
    UI.ProtectFrame(FocusFrameToTHealthBar)

    local F1 = CreateFrame("Frame")
    F1:RegisterEvent("PLAYER_FOCUS_CHANGED")
    F1:SetScript("OnEvent", function()
        UI.ApplyClassTheme("focus")
    end)

    UI.MakeMovableAndSave(TargetFrame, "TargetFrame")
    UI.ProtectFrame(TargetFrameHealthBar)
    UI.ProtectFrame(TargetFrameToTHealthBar)

    local F2 = CreateFrame("Frame")
    F2:RegisterEvent("PLAYER_TARGET_CHANGED")
    F2:SetScript("OnEvent", function()
        UI.ApplyClassTheme("target")
    end)

    UI.MakeMovableAndSave(PlayerFrame, "PlayerFrame")
    UI.ProtectFrame(PlayerFrameHealthBar)

    local F3 = CreateFrame("Frame")
    F3:RegisterEvent("PLAYER_ENTERING_WORLD")
    F3:SetScript("OnEvent", function(self)
        UI.ApplyClassTheme("player")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end)
end