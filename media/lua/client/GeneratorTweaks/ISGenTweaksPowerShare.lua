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

function ISGenTweaksPowerShare.getAdjacentGenerators()
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

---Return all the connections of a given generator
---@param generatorID number Generator ID to be checked on the ModData table
---@param alreadyChecked table Table containing all Generator IDs already checked
---@param totalGenerators table ModData table containing all Generator IDs
function ISGenTweaksPowerShare.findAllConnections(generatorID, alreadyChecked, totalGenerators)
    if not alreadyChecked[generatorID] then
        alreadyChecked[generatorID] = true
        local connections = { generatorID }

        for _, adjacent in pairs(totalGenerators[generatorID]) do
            local subConnections = ISGenTweaksPowerShare.findAllConnections(adjacent, alreadyChecked, totalGenerators)
            for _, subConnection in pairs(subConnections) do
                table.insert(connections, subConnection)
            end
        end

        return connections
    end
    return {}
end

---Checks all adjacent generators in ModData table and organize them in branches
function ISGenTweaksPowerShare.checkAllConnections()
    local oldBranches = ModData.get("GenTweaksBranches")        --Clears old branches table
    if oldBranches then ModData.remove("GenTweaksBranches") end --Clears old branches table
    local branches = ModData.getOrCreate("GenTweaksBranches")

    local adjacentTable = ModData.getOrCreate("GenTweaksAdjacent")
    local alreadyChecked = {}

    for i, _ in pairs(adjacentTable) do
        local connections = ISGenTweaksPowerShare.findAllConnections(i, alreadyChecked, adjacentTable)
        if connections[1] then table.insert(branches, connections) end
    end
    ISGenTweaksUtils.printConnections(branches)
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare