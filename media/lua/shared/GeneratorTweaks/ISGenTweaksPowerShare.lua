
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
            --ISGenTweaksUtils.printPosFromData(data)
        end
    end
    return currentGeneratorAdjacent
end

function ISGenTweaksPowerShare.getAllAdjacentGenerators()
    local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
    if not totalGenerators then return end
    local adjacentGenerators = { }

    for i, data in pairs(totalGenerators) do
        local generator = ISGenTweaksUtils.getGeneratorFromPos(data)
        if generator then
            adjacentGenerators[i] = ISGenTweaksPowerShare.getAdjacentGenerators(generator)
        end
    end
    return adjacentGenerators
end

---Return all the connections of a given generator
---@param generatorID number Generator ID to be checked on the ModData table
---@param alreadyChecked table Table containing all Generator IDs already checked
---@param totalGenerators KahluaTable ModData table containing all Generator IDs
function ISGenTweaksPowerShare.checkConnections(generatorID, alreadyChecked, totalGenerators)
    if not alreadyChecked[generatorID] then
        alreadyChecked[generatorID] = true
        local connections = { generatorID }

        for _, adjacent in pairs(totalGenerators[generatorID]) do
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
function ISGenTweaksPowerShare.checkAllConnections()
    local adjacentTable = ISGenTweaksPowerShare.getAllAdjacentGenerators()
    local alreadyChecked = {}
    local oldShareSettings = {}

    --Clears old branches table
    local oldBranches = ModData.get("GenTweaksBranches")
    if oldBranches then
        for i, data in pairs(oldBranches) do
            oldShareSettings[i] = data.share
        end
        ModData.remove("GenTweaksBranches")
    end
    --Creates new branches table
    local branches = ModData.getOrCreate("GenTweaksBranches")

    for i, _ in pairs(adjacentTable) do
        local connections = ISGenTweaksPowerShare.checkConnections(i, alreadyChecked, adjacentTable)
        if connections[1] then
            if (oldShareSettings[i]) and (oldShareSettings[i] > -1) then
                connections.share = oldShareSettings[i] else connections.share = -1
            end
            table.insert(branches, i,connections)
        end
    end
    ISGenTweaksUtils.printConnections(branches)
end

---Gets a sum of power using on generators in the same branch, and split it between all
---@param totalGenerators KahluaTable ModData table containing all the generators in the world
---@param branches KahluaTable ModData table containing all generators 'branches' in the world
function ISGenTweaksPowerShare.splitPowerBranch(totalGenerators, branches)
    if not totalGenerators then return end
    if not branches then return end

    local branchPower = {}
    --First we get the sum of all generators and make a average
    for i, data in pairs(branches) do
        if not ((data.share == -1) or (data.share == nil)) then
            local shareSetting = ISGenTweaksUtils.checkFocusGenerator(totalGenerators, data.share)

            branchPower[i] = {}
            branchPower[i].sum = 0
            branchPower[i].count = 0
            for j = 1, #data do
                local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[data[j]])
                if generator and generator:isActivated() then
                    branchPower[i].sum = branchPower[i].sum + generator:getTotalPowerUsing()
                    branchPower[i].count = branchPower[i].count + 1
                    ISGenTweaksUtils.debugMessage(string.format("Branch %d current: sum: %.2f | count: %d", i, branchPower[i].sum, branchPower[i].count))
                end
            end
            if shareSetting == 1 then
                local average = (branchPower[i].sum / branchPower[i].count)
                if branchPower[i].count == 0 then average = 0 end
                branchPower[i] = ISGenTweaksUtils.roundNumber(average, 2)
            elseif shareSetting == 2 then
                branchPower[i] = ISGenTweaksUtils.roundNumber(branchPower[i].sum, 2)
            end
            ISGenTweaksUtils.debugMessage(string.format("Branch %d | current total power: %.2f", i, branchPower[i]))
        end
    end
    --Split all power between generators
    for i, data in pairs(branches) do
        if not ((data.share == -1) or (data.share == nil)) then
            local shareSetting = ISGenTweaksUtils.checkFocusGenerator(totalGenerators, data.share)
            for j = 1, #data do
                local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[data[j]])
                if generator and generator:isActivated() then
                    if shareSetting == 1 then
                        generator:setTotalPowerUsing(branchPower[i])
                    elseif shareSetting == 2 then
                        if data[j] ~= data.share then
                            generator:setTotalPowerUsing(0)
                        else
                            generator:setTotalPowerUsing(branchPower[i])
                        end
                    end
                    ISGenTweaksUtils.debugMessage(string.format("Power %.2f set to branch %d", branchPower[i], i))
                end
            end
        end
    end
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerShare