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
function ISGenTweaksPowerShare.getAdjacentGenerators(generator)
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

function ISGenTweaksPowerShare.getAllAdjacentGenerators()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not totalGenerators then return end

    local oldAdjacent = ModData.get("GenTweaksAdjacent")        --Clears old adjacent table
    if oldAdjacent then ModData.remove("GenTweaksAdjacent") end --Clears old adjacent table
    local adjacentGenerators = ModData.getOrCreate("GenTweaksAdjacent")

    for i, data in pairs(totalGenerators) do
        local generator = ISGenTweaksUtils.getGeneratorFromPos(data)
        if generator then
            adjacentGenerators[i] = ISGenTweaksPowerShare.getAdjacentGenerators(generator)
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
    local adjacentTable = ModData.getOrCreate("GenTweaksAdjacent")
    if not adjacentTable then return end
    local alreadyChecked = {}

    local oldBranches = ModData.get("GenTweaksBranches")        --Clears old branches table
    if oldBranches then ModData.remove("GenTweaksBranches") end --Clears old branches table
    local branches = ModData.getOrCreate("GenTweaksBranches")   --Creates new branches table

    for i, _ in pairs(adjacentTable) do
        local connections = ISGenTweaksPowerShare.findAllConnections(i, alreadyChecked, adjacentTable)
        connections.split = -1
        if connections[1] then table.insert(branches, connections) end
    end
    ISGenTweaksUtils.printConnections(branches)
end

---Gets a sum of power using on generators in the same branch, and split it between all
---@param totalGenerators table ModData table containing all the generators in the world
---@param branches table ModData table containing all generators 'branches' in the world
function ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
    if not totalGenerators then return end
    if not branches then return end
    if branches.split == -1 then return end

    local branchPower = {}

    --First we get the sum of all generators and make a average
    for i = 1, #branches do
        branchPower[i] = {}
        branchPower[i].sum = 0
        branchPower[i].count = 0
        for j = 1, #branches[i] do
            local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[branches[i][j]])
            if generator and generator:isActivated() then
                branchPower[i].sum = branchPower[i].sum + generator:getTotalPowerUsing()
                branchPower[i].count = branchPower[i].count + 1
                print(string.format("Branch %d current: sum: %f | count: %d", i, branchPower[i].sum, branchPower[i].count))
            end
        end
        branchPower[i] = ISGenTweaksUtils.roundNumber((branchPower[i].sum / branchPower[i].count), 2)
        print(string.format("Branch %d current: average: %f", i, branchPower[i]))
    end
    --Split all power between generators
    for i = 1, #branches do
        for j = 1, #branches[i] do
            local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[branches[i][j]])
            if generator and generator:isActivated() then
                generator:setTotalPowerUsing(branchPower[i])
                print(string.format("Power set (%f) to generator %s in branch %d", branchPower[i], tostring(generator), i))
            end
        end
    end
end




------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare