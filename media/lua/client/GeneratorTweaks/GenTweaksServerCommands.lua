
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/AutomaticGateMotors

---	All the methods related to the ClientCommands are listed in this file
--- @class GenTweaksServerCommands
--- @return GenTweaksServerCommands
local GenTweaksServerCommands = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local pairs = pairs


--Update ModData to every player connecting on the server
GenTweaksServerCommands.onCreatePlayer = function(playerIndex, player)
    if isClient() then
        ModData.request("GenTweaksGenerators")
        ModData.request("GenTweaksBranches")
        print(string.format("GENTWEAKS: Requesting ModData to player with index: %d | username: %s", playerIndex, player:getUsername()))
    end
end

--Sync Global ModData from the server
GenTweaksServerCommands.onReceiveGlobalModData = function(ModDataKey, ModDataTable)
    if isClient() then
        if ModDataTable and (ModDataKey == "GenTweaksGenerators" or ModDataKey == "GenTweaksBranches") then
            print("GENTWEAKS: Received ModData Table: " .. ModDataKey)
            local table = ModData.getOrCreate(ModDataKey)
            for i, data in pairs(ModDataTable) do
                table[i] = data
            end
        end
    end
end

--Handler of Server Commands
GenTweaksServerCommands.onServerCommand = function(module, command, args)
    if isClient() then
        if module == "GenTweaks" then
            if command == "startGenerator" then
                ModData.request("GenTweaksGenerators")
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                end
            elseif command == "branchSetting" then
                ModData.request("GenTweaksBranches")
            elseif command == "addToSystem" then
                ModData.request("GenTweaksGenerators")
            elseif command == "removeFromSystem" then
                ModData.request("GenTweaksGenerators")
            end
        end
    end
end
--Adding functions to events
Events.OnServerCommand.Add(GenTweaksServerCommands.onServerCommand)
Events.OnReceiveGlobalModData.Add(GenTweaksServerCommands.onReceiveGlobalModData)
Events.OnCreatePlayer.Add(GenTweaksServerCommands.onCreatePlayer)


------------------ Returning file for 'require' ------------------
return GenTweaksServerCommands