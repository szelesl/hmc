local _, hmc_ns = ...
local hmc_sounds = hmc_ns.hmc_sounds
hmc_ns.hmc_CD = 0
hmc_ns.hmc_muted = false;

local function listCategories()
    for category in pairs(hmc_sounds) do
        print("/hmc list " .. category)
    end
end

local function listTracks(category)
    print("debug")
    for command, data in pairs(hmc_sounds[category]) do
        if command ~= "image_path" and command ~= "display" then
            print("/hmc " .. command .. " - Description: " .. data.description)
        end
    end
end

-- Function to play the sound based on command
local function playTrack(soundKey)
    for category, categoryData in pairs(hmc_sounds) do
        for soundName, soundData in pairs(categoryData) do
            if soundName == soundKey then
                PlaySoundFile(soundData.path, "Master")
                hmc_ns.hmc_CD = GetTime() + 3
                return
            end
        end
    end
    print("Sound not found for key: " .. soundKey)
end

-- Slash command handler
local function slashCmdHandler(cmd)
    local arg1, arg2 = string.match(cmd, "(%S+)%s*(.*)")

    if not arg1 and not arg2 then
        listCategories()
    elseif arg1 and string.len(arg1) > 0 then
        if arg1 == "list" then
            if arg2 and string.len(arg2) > 0 then
                listTracks(arg2)
            end
        else
            playTrack(arg1)
        end
    elseif arg1 == "mute" then
        hmc_muted = true
        print("HMC muted.")
    elseif arg1 == "unmute" then
        hmc_muted = false
        print("HMC unmuted.")
    else
        listCategories()
    end
end

local function OnEvent(self, event, prefix, msg, ...)
    if event == "CHAT_MSG_ADDON" then
        slashCmdHandler(msg)
    elseif event == "ADDON_LOADED" and prefix == "HungarianMemeCaller" then
        hmc_muted = HMCMutedVar
        SLASH_HMC_SOUND1 = '/hmc';
        SlashCmdList['HMC_SOUND'] = slashCmdHandler
    elseif event == "PLAYER_LOGOUT" then
        HMCMutedVar = hmc_muted
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", OnEvent)