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
local pairs = pairs

---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUpdate.updateEveryMinute()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if totalGenerators then
        for i, data in pairs(totalGenerators) do
            if data then
                local generatorSquare = getCell():getGridSquare(data.x, data.y, data.z)
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