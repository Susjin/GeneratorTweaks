
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- All the methods related to the every minute update
--- @class ISGenTweaksUpdate
local ISGenTweaksUpdate = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"

---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUpdate.updateEveryMinute()
    --Gets all tables from Global ModData
    ---@type Generator[]
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    ---@type Branch[]
    local branches = ModData.getOrCreate("GenTweaksBranches")
    --Checks if they have any value within
    if not ISGenTweaksUtils.checkModData(totalGenerators) then return end
    if not ISGenTweaksUtils.checkModData(branches) then return end

    --Corrects the weird consumption value
    ISGenTweaksPowerSet.correctAllGenerators(totalGenerators)
    --Activates PowerShare if wanted
    ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
end
Events.EveryOneMinute.Add(ISGenTweaksUpdate.updateEveryMinute)

------------------ Returning file for 'require' ------------------
return ISGenTweaksUpdate