local _, hmc_ns = ...
local hmc_sounds = hmc_ns.hmc_sounds
local prefix = "hmemecaller"
C_ChatInfo.RegisterAddonMessagePrefix(prefix)
hmc_ns.hmc_CD = 0
hmc_ns.hmc_muted = false

function sendAddonMessage(sound) 
    if hmc_ns.hmc_muted ~= true and GetTime() > hmc_ns.hmc_CD then
        local chatType, target = "WHISPER", UnitName("player")

        if IsInGroup(LE_PARTY_CATEGORY_HOME) then
            chatType = "RAID"
            table = nil
        elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            chatType = "INSTANCE_CHAT"
            target = nil
        elseif IsInGroup() then
            chatType = "PARTY"
            target = nil
        end

        if target then
            C_ChatInfo.SendAddonMessage(prefix, sound, chatType, target)
        else
            C_ChatInfo.SendAddonMessage(prefix, sound, chatType)
        end

        hmc_ns.hmc_CD = GetTime() + 3
    end
end

local function listCategories()
    for category in pairs(hmc_sounds) do
        print("/hmc list " .. category)
    end
end

local function listTracks(category)
    for command, data in pairs(hmc_sounds[category]) do
        if command ~= "image_path" and command ~= "display" then
            print("/hmc " .. command .. " - Description: " .. data.description)
        end
    end
end

-- Function to play the sound based on command
local function playTrack(soundKey)
    if not hmc_ns.hmc_muted then
        for category, category_sounds in pairs(hmc_sounds) do
            local sound = category_sounds[soundKey] -- changed 'track' to 'soundKey'
            if sound then
                PlaySoundFile(sound.path, "Master")
                break -- Exit after playing the first matched sound
            end
        end
    end
end

local function slashCmdHandler(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end

    if #args == 0 then
        listCategories()
    elseif #args == 1 then
        sendAddonMessage(args[1])
    elseif #args == 2 and args[1] == "list" then
        listTracks(args[2])
    else
        print("Invalid command. Use /hmc to list categories or /hmc list [category_name] to list sounds.")
    end
end

local function OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg = ...
        if prefix == "hmemecaller" then
            playTrack(msg)
        end
    elseif event == "ADDON_LOADED" then
        hmc_ns.hmc_muted = HMCMutedVar
    elseif event == "PLAYER_LOGOUT" then
        HMCMutedVar = hmc_ns.hmc_muted
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", OnEvent)

SLASH_HMC1 = '/hmc' -- Correctly set the first slash command
SlashCmdList['HMC'] = function(msg)
    slashCmdHandler(msg)
end