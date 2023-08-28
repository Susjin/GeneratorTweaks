----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksPowerShare
--- @return ISGenTweaksPowerShare
local ISGenTweaksPowerShare = {}
----------------------------------------------------------------------------------------------
--Setting locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local pairs = pairs

---checkRadius
---@param generator IsoGenerator
function ISGenTweaksPowerShare.checkRadius(generator)
    local totalGenerators = ModData.getOrCreate("GenTweaks")
    if not totalGenerators then return end
    local cell = getCell()
    local currentGeneratorSquare = generator:getSquare()
    local currentGeneratorAdjacent = {}
    for _, data in pairs(totalGenerators) do
        local generatorModDataSquare = cell:getGridSquare(data.x, data.y, data.z)
        if generatorModDataSquare and (generatorModDataSquare ~= currentGeneratorSquare) and (currentGeneratorSquare:DistToProper(generatorModDataSquare) <= 20) then
            table.insert(currentGeneratorAdjacent, data)
        end
    end
    ISGenTweaksUtils.printAdjacent(currentGeneratorAdjacent)
    return currentGeneratorAdjacent
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare