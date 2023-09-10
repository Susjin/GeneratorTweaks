
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
            if command == "startGenerator" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                    ISGenTweaksUtils.saveGeneratorToModData(generator)
                    ISGenTweaksPowerShare.createAllBranches()
                    ModData.transmit("GenTweaksGenerators")
                    ModData.transmit("GenTweaksBranches")
                end
            elseif command == "plugGenerator" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksUtils.saveGeneratorToModData(generator)
                    ISGenTweaksPowerShare.createAllBranches()
                    ModData.transmit("GenTweaksGenerators")
                    ModData.transmit("GenTweaksBranches")
                end
            elseif command == "branchSetting" then
                ISGenTweaksUtils.setBranchSetting(args.genID, args.share)
                ModData.transmit("GenTweaksBranches")
            elseif command == "addToSystem" then
                ISGenTweaksUtils.setIsOnBranchSystem(args.genID, true)
                ISGenTweaksPowerShare.createAllBranches()
                ModData.transmit("GenTweaksGenerators")
                ModData.transmit("GenTweaksBranches")
            elseif command == "removeFromSystem" then
                ISGenTweaksUtils.setIsOnBranchSystem(args.genID, false)
                ISGenTweaksPowerShare.createAllBranches()
                ModData.transmit("GenTweaksGenerators")
                ModData.transmit("GenTweaksBranches")
            end
            sendServerCommand(module, command, args)
            print("GENTWEAKS: Command: '" .. command .. "' received from client player: " .. tostring(player:getUsername()))
        end
    end
end

--Add functions to events
Events.OnClientCommand.Add(GenTweaksClientCommands.onClientCommand)

------------------ Returning file for 'require' ------------------
return GenTweaksClientCommands