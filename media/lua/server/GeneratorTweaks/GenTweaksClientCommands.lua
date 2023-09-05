
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/AutomaticGateMotors

---	All the methods related to the ClientCommands are listed in this file
--- @class GenTweaksClientCommands
--- @return GenTweaksClientCommands
local GenTweaksClientCommands = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"

--Handler of Client Commands
GenTweaksClientCommands.onClientCommand = function(module, command, player, args)
    if isServer() then
        if module == "GenTweaks" then
            local branches = ModData.getOrCreate("GenTweaksBranches")
            if command == "startGenerator" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                    ISGenTweaksUtils.saveGeneratorToModData(generator)
                    ISGenTweaksPowerShare.createAllBranches()
                    ModData.transmit("GenTweaksGenerators")
                    ModData.transmit("GenTweaksBranches")
                end
            elseif command == "branchSetting" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksUtils.setBranchSetting(generator, branches, args.share)
                end
            end
            sendServerCommand(module, command, args)
            print("GENTWEAKS: Client command '" .. command .. "' received from player: " .. tostring(player:getUsername()))
        end
    end
end

--Add functions to events
Events.OnClientCommand.Add(GenTweaksClientCommands.onClientCommand)
--Handler for connecting players
Events.SendCustomModData.Add(function() ModData.transmit("GenTweaksGenerators"); ModData.transmit("GenTweaksBranches"); print("GENTWEAKS: Sent ModData!"); end)

------------------ Returning file for 'require' ------------------
return GenTweaksClientCommands