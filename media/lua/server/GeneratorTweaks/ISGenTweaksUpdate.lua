----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksUpdate
local ISGenTweaksUpdate = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"

---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUpdate.updateEveryMinute()
    local totalGenerators = ModData.getOrCreate("GenTweaks")
    if totalGenerators then
        for i = 1, #totalGenerators do
            if totalGenerators[i] then
                local generatorSquare = getCell():getGridSquare(totalGenerators[i].x, totalGenerators[i].y, totalGenerators[i].z)
                if not generatorSquare then return end
                local generator = generatorSquare:getGenerator()
                if not generator then
                    table.remove(totalGenerators, i)
                else
                    if instanceof(generator, "IsoGenerator") and generator:isActivated() then
                        ISGenTweaksPowerSet.correctGenerator(generator)
                    end
                end
            end
        end
    end
end
Events.EveryOneMinute.Add(ISGenTweaksUpdate.updateEveryMinute)

------------------ Returning file for 'require' ------------------
return ISGenTweaksUpdate