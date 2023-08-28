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
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not totalGenerators then return end
    local currentGeneratorSquare = generator:getSquare()
    local currentGeneratorAdjacent = {}
    for i, data in pairs(totalGenerators) do
        local generatorModDataSquare = getCell():getGridSquare(data.x, data.y, data.z)
        if generatorModDataSquare and (generatorModDataSquare ~= currentGeneratorSquare) and (currentGeneratorSquare:DistToProper(generatorModDataSquare) <= 20) then
            table.insert(currentGeneratorAdjacent, i)
            ISGenTweaksUtils.printPosFromData(data)
        end
    end
    return currentGeneratorAdjacent
end

function ISGenTweaksPowerShare.saveAdjacentModData()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not totalGenerators then return end

    local oldAdjacent = ModData.get("GenTweaksAdjacent")        --Clears old adjacent table
    if oldAdjacent then ModData.remove("GenTweaksAdjacent") end --Clears old adjacent table

    local adjacentGenerators = ModData.getOrCreate("GenTweaksAdjacent")
    for i, data in pairs(totalGenerators) do
        local square = getCell():getGridSquare(data.x, data.y, data.z)
        if square then
            local generator = square:getGenerator()
            if generator then
                adjacentGenerators[i] = ISGenTweaksPowerShare.checkRadius(generator)
            end
        end
    end
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare