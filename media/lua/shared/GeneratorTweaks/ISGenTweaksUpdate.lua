
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- Main file with all functions
--- @class ISGenTweaksUpdate
local ISGenTweaksUpdate = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"

---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUpdate.updateEveryMinute()
    --Gets all tables from Global ModData
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if #totalGenerators == 0 then return end
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if #branches == 0 then return end

    --Corrects the weird consumption value
    ISGenTweaksPowerSet.correctAllGenerators(totalGenerators)
    --Activates PowerShare if wanted
    ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
end
Events.EveryOneMinute.Add(ISGenTweaksUpdate.updateEveryMinute)

------------------ Returning file for 'require' ------------------
return ISGenTweaksUpdate