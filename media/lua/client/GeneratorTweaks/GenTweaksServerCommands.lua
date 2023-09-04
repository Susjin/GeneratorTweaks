
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
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"

GenTweaksServerCommands.onServerCommand = function(module, command, args)
    if isClient() then
        if module == "GenTweaks" then
            local branches = ModData.getOrCreate("GenTweaksBranches")
            if command == "startGenerator" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos(args)
                if generator then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                    ISGenTweaksUtils.saveGeneratorToModData(generator)
                    ISGenTweaksPowerShare.createAllBranches()
                end
            elseif command == "branchSetting" then
                local generator = ISGenTweaksUtils.getGeneratorFromPos({args.x, args.y, args.z})
                if generator then
                    ISGenTweaksUtils.setBranchSetting(generator, branches, args.share)
                end
            end
        end
    end
end
Events.OnServerCommand.Add(GenTweaksServerCommands.onServerCommand)


------------------ Returning file for 'require' ------------------
return GenTweaksServerCommands