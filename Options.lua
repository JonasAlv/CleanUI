local _, UI = ...

local function UpdateBarBackground()
    CleanUIPositions = CleanUIPositions or {}
    local hide = CleanUIPositions.HideBarBg
    
    local textures = {
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuMaxLevelBar0, MainMenuMaxLevelBar1, MainMenuBarLeftEndCap, MainMenuBarRightEndCap,
        ReputationWatchBarTexture0, ReputationWatchBarTexture1, MainMenuExpBarTexture0, MainMenuExpBarTexture1,
    }
    
    for _, tex in ipairs(textures) do
        if tex then
            if hide then tex:Hide() else tex:Show() end
        end
    end
end

local CleanUILDB = LibStub("LibDataBroker-1.1"):NewDataObject("CleanUI", {
    type = "launcher",
    text = "CleanUI",
    icon = "Interface\\Icons\\INV_Misc_EngGizmos_17",
    OnClick = function(self, button)
        InterfaceOptionsFrame_OpenToCategory("CleanUI")
        InterfaceOptionsFrame_OpenToCategory("CleanUI") 
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("CleanUI", 1, 0.82, 0)
        tooltip:AddLine("Click to open Options", 1, 1, 1)
    end,
})

local options = {
    name = "CleanUI",
    type = "group",
    args = {
        general = {
            name = "General Settings",
            type = "group",
            inline = true,
            order = 1,
            args = {
                hideBarBg = {
                    type = "toggle",
                    name = "Hide Action Bar Background",
                    desc = "Hides the native Blizzard background art plates.",
                    order = 1,
                    set = function(info, val) CleanUIPositions.HideBarBg = val; UpdateBarBackground() end,
                    get = function(info) return CleanUIPositions.HideBarBg end,
                },
                classPortraits = {
                    type = "toggle",
                    name = "Use Class Icon Portraits",
                    desc = "Enable to show class icons instead of 3D animated faces.",
                    order = 2,
                    set = function(info, val) CleanUIClassPortraits = val; if UI.RefreshPortraits then UI.RefreshPortraits() end end,
                    get = function(info) return CleanUIClassPortraits end,
                },
            },
        },
        modules = {
            name = "Module Toggles (Requires Reload)",
            type = "group",
            inline = true,
            order = 2,
            args = {
                charItems = {
                    type = "toggle",
                    name = "Character Items Info",
                    desc = "Enable Item Level and Durability text on the character panel.",
                    order = 1,
                    set = function(info, val) CleanUIPositions.EnableCharItems = val end,
                    get = function(info) return CleanUIPositions.EnableCharItems end,
                },
                statsColors = {
                    type = "toggle",
                    name = "Character Stats Colors",
                    desc = "Enable custom coloring for the character stats panel.",
                    order = 2,
                    set = function(info, val) CleanUIPositions.EnableStatsColors = val end,
                    get = function(info) return CleanUIPositions.EnableStatsColors end,
                },
                tooltipsTheming = {
                    type = "toggle",
                    name = "Tooltips Theming",
                    desc = "Enable custom styling and background darkening for tooltips.",
                    order = 3,
                    set = function(info, val) CleanUIPositions.EnableTooltipsTheming = val end,
                    get = function(info) return CleanUIPositions.EnableTooltipsTheming end,
                },
                partyFrames = {
                    type = "toggle",
                    name = "Party Frames",
                    desc = "Enable custom CleanUI party frames and positioning.",
                    order = 4,
                    set = function(info, val) CleanUIPositions.EnableParty = val end,
                    get = function(info) return CleanUIPositions.EnableParty end,
                },
                tooltipSettings = {
                    type = "toggle",
                    name = "Core Tooltip Hooks",
                    desc = "Enable CleanUI core tooltip anchoring and error filtering.",
                    order = 5,
                    set = function(info, val) CleanUIPositions.EnableTooltip = val end,
                    get = function(info) return CleanUIPositions.EnableTooltip end,
                },
                unitFrames = {
                    type = "toggle",
                    name = "Unit Frames",
                    desc = "Enable custom CleanUI player, target, and focus frame behavior.",
                    order = 6,
                    set = function(info, val) CleanUIPositions.EnableUnitFrames = val end,
                    get = function(info) return CleanUIPositions.EnableUnitFrames end,
                },
            },
        },
        minimap = {
            name = "Minimap Button",
            type = "group",
            inline = true,
            order = 3,
            args = {
                hideMinimap = {
                    type = "toggle",
                    name = "Hide Minimap Button",
                    desc = "Hides the CleanUI minimap button.",
                    order = 1,
                    set = function(info, val)
                        CleanUIPositions.MinimapIcon.hide = val
                        if val then LibStub("LibDBIcon-1.0"):Hide("CleanUI") else LibStub("LibDBIcon-1.0"):Show("CleanUI") end
                    end,
                    get = function(info) return CleanUIPositions.MinimapIcon.hide end,
                }
            }
        },
        dangerZone = {
            name = "Danger Zone",
            type = "group",
            inline = true,
            order = 4,
            args = {
                resetUI = {
                    type = "execute",
                    name = "Reset UI & Reload",
                    desc = "Restores all frames to default positions and reloads the interface.",
                    order = 1,
                    confirm = true,
                    func = function() SlashCmdList["CLEANUI"]("reset") end,
                },
            }
        }
    }
}

local Init = CreateFrame("Frame")
Init:RegisterEvent("PLAYER_LOGIN")
Init:SetScript("OnEvent", function()
    CleanUIPositions = CleanUIPositions or {}
    CleanUIPositions.MinimapIcon = CleanUIPositions.MinimapIcon or { hide = false }
    
    LibStub("LibDBIcon-1.0"):Register("CleanUI", CleanUILDB, CleanUIPositions.MinimapIcon)
    
    local mmButton = _G["LibDBIcon10_CleanUI"]
    if mmButton then
        if mmButton.icon then
            mmButton.icon:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        end
        mmButton.cuText = mmButton.cuText or mmButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mmButton.cuText:SetPoint("CENTER", mmButton, "CENTER", 1, 1)
        mmButton.cuText:SetText("CU")
        mmButton.cuText:SetTextColor(1, 0.82, 0)
    end
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("CleanUI", options, {"cui"})
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CleanUI", "CleanUI")
    
    UpdateBarBackground()
end)