local _, hmc_ns = ...
local hmc_sounds = hmc_ns.hmc_sounds
hmc_ns.hmc_CD = 0
hmc_ns.hmc_muted = false;

hmc_ns.UIConfig = CreateFrame("Frame", "HMC_UI_Frame", UIParent, "BasicFrameTemplateWithInset")

-- Set size and position
hmc_ns.UIConfig:SetSize(700, 400)
hmc_ns.UIConfig:SetPoint("CENTER", UIParent, "CENTER")
hmc_ns.UIConfig.title = hmc_ns.UIConfig:CreateFontString(nil, "OVERLAY")
hmc_ns.UIConfig.title:SetFontObject("GameFontHighlight")
hmc_ns.UIConfig.title:SetPoint("CENTER", hmc_ns.UIConfig.TitleBg, "CENTER", 5, 0)
hmc_ns.UIConfig.title:SetText("Hungarian Meme Caller")

-- Make the frame movable
hmc_ns.UIConfig:SetMovable(true)               -- Make the frame movable
hmc_ns.UIConfig:EnableMouse(true)              -- Enable mouse input
hmc_ns.UIConfig:RegisterForDrag("LeftButton")  -- Register the left mouse button for dragging
hmc_ns.UIConfig:SetScript("OnDragStart", hmc_ns.UIConfig.StartMoving)  -- Start dragging
hmc_ns.UIConfig:SetScript("OnDragStop", hmc_ns.UIConfig.StopMovingOrSizing)  -- Stop dragging

-- Hide the frame by default
hmc_ns.UIConfig:Hide()

-- Escape key handling
hmc_ns.UIConfig:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" and hmc_ns.UIConfig:IsShown() then
        hmc_ns.UIConfig:Hide()
        return
    end
end)

-- Enable mouse input
hmc_ns.UIConfig:EnableMouse(true)

-- Override the Escape key when the frame is shown
hmc_ns.UIConfig:SetScript("OnShow", function()
    hmc_ns.UIConfig:SetPropagateKeyboardInput(true)
end)

hmc_ns.UIConfig:SetScript("OnHide", function()
    hmc_ns.UIConfig:SetPropagateKeyboardInput(false)
end)

-- Calculate the number of categories in hmc_sounds
local itemCount = 0
for _ in pairs(hmc_sounds) do
    itemCount = itemCount + 1  -- Count the number of categories
end

-- Create the first scrollable section (left side)
local scrollFrame1 = CreateFrame("ScrollFrame", "HMC_ScrollFrame1", hmc_ns.UIConfig, "UIPanelScrollFrameTemplate")
scrollFrame1:SetSize(180, 362)  -- Adjust size for the left side
scrollFrame1:SetPoint("TOPLEFT", hmc_ns.UIConfig, "TOPLEFT", 10, -30)  -- Position relative to the main frame

local content1 = CreateFrame("Frame", nil, scrollFrame1)  -- Content frame
content1:SetSize(160, itemCount * 40)  -- Content size can be larger than the scroll frame
scrollFrame1:SetScrollChild(content1)  -- Set the scrollable content

-- Create the second scrollable section (right side)
local scrollFrame2 = CreateFrame("ScrollFrame", "HMC_ScrollFrame2", hmc_ns.UIConfig, "UIPanelScrollFrameTemplate")
scrollFrame2:SetSize(430, 362)  -- Adjust size for the right side
scrollFrame2:SetPoint("TOPRIGHT", hmc_ns.UIConfig, "TOPRIGHT", -30, -30)  -- Position relative to the main frame

local content2 = CreateFrame("Frame", nil, scrollFrame2)  -- Content frame
content2:SetSize(410, 362)  -- Content size can be larger than the scroll frame
scrollFrame2:SetScrollChild(content2)  -- Set the scrollable content

-- Declare sounds table outside the loop to keep it persistent
local sounds = {}

local offsetY = 0
for category, data in pairs(hmc_sounds) do
    -- Create an example item in the left scroll frame
    local exampleItem1 = CreateFrame("Frame", nil, content1)
    exampleItem1:SetSize(160, 50)  -- Set size for the item
    exampleItem1:SetPoint("TOPLEFT", content1, "TOPLEFT", 0, -offsetY)  -- Correct position with negative offset

    -- Create an image for the left item
    local itemImage1 = exampleItem1:CreateTexture(nil, "OVERLAY")
    itemImage1:SetSize(50, 50)  -- Size of the image
    itemImage1:SetPoint("LEFT", exampleItem1, "LEFT", 0, 0)
    itemImage1:SetTexture(data.image_path or "Interface\\Icons\\INV_Misc_QuestionMark")  -- Use the image path from the data

    -- Create text for the left item
    local itemText1 = exampleItem1:CreateFontString(nil, "OVERLAY")
    itemText1:SetFontObject("GameFontNormal")
    itemText1:SetPoint("LEFT", itemImage1, "RIGHT", 10, 5)  -- Position next to the image
    itemText1:SetText(data.display)  -- Set the text to the category name

    -- Create text for the left item
    local itemText1 = exampleItem1:CreateFontString(nil, "OVERLAY")
    itemText1:SetFontObject("ChatFontSmall")
    itemText1:SetPoint("LEFT", itemImage1, "RIGHT", 10, -5)  -- Position next to the image
    itemText1:SetText("/hmc list " .. category)  -- Set the text to the category name

    -- Click handler to update the right panel
    exampleItem1:SetScript("OnMouseUp", function()
        -- Clear existing text in the right panel
        for _, soundText in ipairs(sounds) do
            soundText:Hide()  -- Hide the previous text elements
        end
        table.wipe(sounds)  -- Clear the sounds table

        local soundOffsetY = 0

        -- Loop through the sound data of the selected category
        for key, soundData in pairs(data) do
            if key ~= "image_path" and key ~= "display" then
                -- Create an example item for the sound data
                local soundDataItem = CreateFrame("Frame", nil, content2)
                soundDataItem:SetSize(410, 60)  -- Set size for the item
                soundDataItem:SetPoint("TOPLEFT", content2, "TOPLEFT", 0, -soundOffsetY)

                -- Create display text for the sound
                local soundDisplay = soundDataItem:CreateFontString(nil, "OVERLAY")
                soundDisplay:SetFontObject("ChatFontNormal")
                soundDisplay:SetPoint("TOPLEFT", soundDataItem, "TOPLEFT", 0, -2)
                soundDisplay:SetText(soundData.display)

                -- Create display text for the sound
                local soundCommand = soundDataItem:CreateFontString(nil, "OVERLAY")
                soundCommand:SetFontObject("ChatFontNormal")
                soundCommand:SetPoint("TOPLEFT", soundDataItem, "TOPLEFT", 0, -17)
                soundCommand:SetText("/hmc " .. key)

                -- Create description text for the sound
                local soundDescription = soundDataItem:CreateFontString(nil, "OVERLAY")
                soundDescription:SetFontObject("ChatFontSmall")
                soundDescription:SetPoint("TOPLEFT", soundDataItem, "TOPLEFT", 0, -32)  -- Adjusted to position below display text
                soundDescription:SetText(soundData.description)

                -- Store the text elements in the sounds table for later clearing
                table.insert(sounds, soundDataItem)
                table.insert(sounds, soundDisplay)
                table.insert(sounds, soundDescription)

                soundDataItem:SetScript("OnMouseUp", function()
                    if hmc_ns.hmc_muted ~= true and GetTime() > hmc_ns.hmc_CD then
                        PlaySoundFile(soundData.path, "Master")
                        hmc_ns.hmc_CD = GetTime() + 3
                    end
                end)

                -- Increment the offset for the next sound
                soundOffsetY = soundOffsetY + 60  -- Adjust this value if you want more spacing
            end
        end
    end)

    offsetY = offsetY + 50  -- Update the offset for the next item
end