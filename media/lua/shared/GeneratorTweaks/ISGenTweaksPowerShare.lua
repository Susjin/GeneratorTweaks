
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- All the methods related to creating branches and updating power distribution
--- @class ISGenTweaksPowerShare
--- @return ISGenTweaksPowerShare
local ISGenTweaksPowerShare = {}
----------------------------------------------------------------------------------------------
--Setting locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local pairs = pairs

---Gets all the generators considered adjacent to a specific generator
---@param generator IsoGenerator Generator to get the others adjacent
---@param totalGenerators Generator[] ModData table containing all Generator IDs
---@param isOnBranchSystem boolean If the generator currently in check is on the branch system
---@return table Contains a table with all the IDs of Generators adjacent to the given generator
function ISGenTweaksPowerShare.getAdjacentGenerators(generator, totalGenerators, isOnBranchSystem)
    local currentGeneratorSquare = generator:getSquare()
    local currentGeneratorAdjacent = {}
    for i, data in pairs(totalGenerators) do
        local generatorModDataSquare = getCell():getGridSquare(data.x, data.y, data.z)
        if generatorModDataSquare and isOnBranchSystem and (generatorModDataSquare ~= currentGeneratorSquare) --If: other is loaded|current is on branch system|If it's not itself
            and (currentGeneratorSquare:DistToProper(generatorModDataSquare) <= 20) and data.branch == true then --is inside each-other radius|other is on branch system
            table.insert(currentGeneratorAdjacent, i)
        end
    end
    return currentGeneratorAdjacent
end

---Checks the considered adjacent of all generators in the ModData table
---@return table Contains all generators in the ModData with their respective adjacency
function ISGenTweaksPowerShare.getAllAdjacentGenerators()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not ISGenTweaksUtils.checkModData(totalGenerators) then return {} end
    local adjacentGenerators = { }

    for i, data in pairs(totalGenerators) do
        local generator = ISGenTweaksUtils.getGeneratorFromPos(data)
        if generator then
            adjacentGenerators[i] = ISGenTweaksPowerShare.getAdjacentGenerators(generator, totalGenerators, data.branch)
        end
    end
    return adjacentGenerators
end

---Return all the connections of a given generator (For creating a branch)
---@param genID number Generator ID to be checked on the ModData table
---@param alreadyChecked table Table containing all Generator IDs already checked
---@param totalGenerators Generator[] ModData table containing all Generator IDs
function ISGenTweaksPowerShare.checkConnections(genID, alreadyChecked, totalGenerators)
    if not alreadyChecked[genID] then
        alreadyChecked[genID] = true
        local connections = { genID }

        for _, adjacent in pairs(totalGenerators[genID]) do
            local subConnections = ISGenTweaksPowerShare.checkConnections(adjacent, alreadyChecked, totalGenerators)
            for _, subConnection in pairs(subConnections) do
                table.insert(connections, subConnection)
            end
        end

        return connections
    end
    return {}
end

---Checks all adjacent generators and organize them in branches
function ISGenTweaksPowerShare.createAllBranches()
    local adjacentTable = ISGenTweaksPowerShare.getAllAdjacentGenerators()
    local alreadyChecked = {}
    local oldShareSettings = {}

    --Clears old branches table and saves settings
    local oldBranches = ModData.get("GenTweaksBranches")
    if oldBranches then
        for i, data in pairs(oldBranches) do
            oldShareSettings[i] = data.share
        end
        ModData.remove("GenTweaksBranches")
    end
    --Creates new branches table and reloads existing settings
    local branches = ModData.getOrCreate("GenTweaksBranches")

    for i, _ in pairs(adjacentTable) do
        local connections = ISGenTweaksPowerShare.checkConnections(i, alreadyChecked, adjacentTable)
        if connections[1] then
            if (oldShareSettings[i]) and (oldShareSettings[i] > -1) then
                connections.share = oldShareSettings[i] else connections.share = -1
            end
            table.insert(branches, i, connections)
        end
    end
end

---Gets a sum of power consuming on generators in the same branch, and split it between all according to the branch setting
---@param totalGenerators Generator[] ModData table containing all the generators in the world
---@param branches Branch[] ModData table containing all generators 'branches' in the world
function ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
    local branchPower = {}
    --First we get the sum of all generators and make a average
    for i, data in pairs(branches) do
        if not ((data.share == -1) or (data.share == nil)) then
            branchPower[i] = ISGenTweaksUtils.getBranchTotalPower(branches[i])
            branchPower[i].set = ISGenTweaksUtils.getBranchEachPower(branches[i])
        end
    end
    --Split all power between generators
    for i, data in pairs(branches) do
        --Skip if power distribution is disabled
        if not ((data.share == -1) or (data.share == nil)) then
            local shareSetting = ISGenTweaksUtils.getShareSetting(data.share)
            for j = 1, #data do
                local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[data[j]])
                if generator and generator:isActivated() then
                    if shareSetting == 1 then
                        --Split between generators
                        generator:setTotalPowerUsing(branchPower[i].set)
                    elseif shareSetting == 2 then
                        --Focus on one generator
                        if data[j] ~= data.share then
                            generator:setTotalPowerUsing(0)
                        else
                            generator:setTotalPowerUsing(branchPower[i].set)
                        end
                    end
                end
            end
        end
    end
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare