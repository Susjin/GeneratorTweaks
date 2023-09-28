
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- All the methods related to correcting power consumption on generators
--- @class ISGenTweaksPowerSet
--- @return ISGenTweaksPowerSet
local ISGenTweaksPowerSet = {}
----------------------------------------------------------------------------------------------
--Setting locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"

local pairs = pairs

local powerGeneratorConstant = 0.02


---Gets all the powered items from the generator and splits then into a table
---@param generator IsoGenerator Generator which we're getting the items from
---@return table Containing all the items powered by the given generator (formatted)
function ISGenTweaksPowerSet.getAllItemsPowered(generator)
    local poweredList = generator:getItemsPowered()
    local itemsPowered = {}
    local itemsFormatted = ""
    for i=0, poweredList:size()-1 do --( device x4 (0,26L/h) ) Original string text
        itemsFormatted = poweredList:get(i):gsub(" L/h%)","") --( device x4 (0,26 ) Change the ' L/h)' to ''
        itemsFormatted = itemsFormatted:gsub("%(","-") --( device x4 -0,26 ) Change the '(' to '-'
        itemsFormatted = itemsFormatted:gsub("x","-") --( device -4 -0,26 ) Change the 'x' to '-'
        itemsFormatted = itemsFormatted:gsub(",",".") --( device -4 -0.26 ) Change the ',' to '.'
        itemsFormatted = luautils.split(itemsFormatted, "-") --( device |4 |0.26 ) Each bar is a different table pos
        table.insert(itemsPowered, itemsFormatted)
    end
    return itemsPowered
end

---Get the REAL total power a generator is consuming
---@param generator IsoGenerator Generator which we're calculating the real total power
---@return number The real power consumption of a specific generator (5 decimals)
function ISGenTweaksPowerSet.calculateTotalPower(generator)
    local itemsPowered = ISGenTweaksPowerSet.getAllItemsPowered(generator)
    local sum = 0
    for i=1, #itemsPowered do
        sum = sum + tonumber(itemsPowered[i][3]) --Only the power consumption value from each item got from the earlier function
    end
    sum = (sum + powerGeneratorConstant) * SandboxVars.GeneratorFuelConsumption
    return ISGenTweaksUtils.roundNumber(sum, 5)
end

---Adjust the generator consumption to the REAL total power cost
---@param generator IsoGenerator Generator to be corrected
function ISGenTweaksPowerSet.correctGenerator(generator)
    if not generator then return end
    local totalNewPower = ISGenTweaksPowerSet.calculateTotalPower(generator)
    generator:setTotalPowerUsing(totalNewPower)
end

---Correct all generators that are in the ModData table
---@param totalGenerators Generator[] ModData table containing all generators IDs and pos
function ISGenTweaksPowerSet.correctAllGenerators(totalGenerators)
    for i, data in pairs(totalGenerators) do
        if data then
            local generator = ISGenTweaksUtils.getGeneratorFromPos(data)
            if generator == "notFound" then
                --If the square is loaded, but a generator is not found, remove it from the global table (sync data if MP)
                totalGenerators[i] = nil
                ISGenTweaksPowerShare.createAllBranches()
                if isServer() then
                    ModData.transmit("GenTweaksGenerators")
                    ModData.transmit("GenTweaksBranches")
                end
            else
                --Just a double-check to avoid issues with the function square:getGenerator()
                if instanceof(generator, "IsoGenerator") and generator:isActivated() then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                end
            end
        end
    end
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerSet