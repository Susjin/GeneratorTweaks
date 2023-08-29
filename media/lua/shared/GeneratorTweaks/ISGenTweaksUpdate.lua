----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksUpdate
local ISGenTweaksUpdate = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
--local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"

---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUpdate.updateEveryMinute()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not totalGenerators then return end
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if not branches then return end
    --Corrects the weird consumption value
    ISGenTweaksPowerSet.correctAllGenerators(totalGenerators)
    --Activates PowerShare if wanted
    ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
end
Events.EveryOneMinute.Add(ISGenTweaksUpdate.updateEveryMinute)

------------------ Returning file for 'require' ------------------
return ISGenTweaksUpdate