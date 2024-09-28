local _, hmc_ns = ...

local LDB = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local hmcLDB = LDB:NewDataObject("HungarianMemeCaller", {
    type = "data source",
    text = "Hungarian Meme Caller",
    icon = "Interface\\Icons\\spell_misc_emotionhappy",
    OnClick = function(_, button)
        if button == "LeftButton" then
            if hmc_ns.UIConfig:IsShown() then
                hmc_ns.UIConfig:Hide()
            else
                hmc_ns.UIConfig:Show()
                hmc_ns.UIConfig:SetFocus()  -- Optional: Set focus to the frame
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Hungarian Meme Caller")
        tooltip:AddLine("Left-click to show or hide the meme panel.")
    end,
})

-- Register the minimap icon
hmc_ns.minimapIcon = hmc_ns.minimapIcon or { hide = false }
icon:Register("HungarianMemeCaller", hmcLDB, hmc_ns.minimapIcon)
icon:Show("HungarianMemeCaller")