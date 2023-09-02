
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksPowerSet
--- @return ISGenTweaksPowerSet
local ISGenTweaksPowerSet = {}
----------------------------------------------------------------------------------------------
--Setting locals
--local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local pairs = pairs
local powerGeneratorConstant = 0.02


---Gets all the powered items from the generator and splits then into a table
---@param generator IsoGenerator Generator which we're getting the items from
function ISGenTweaksPowerSet.getAllItemsPowered(generator)
    local poweredList = generator:getItemsPowered()
    local itemsPowered = {}
    local itemsFormatted = ""
    for i=0, poweredList:size()-1 do
        itemsFormatted = poweredList:get(i):gsub(" L/h%)","")
        itemsFormatted = itemsFormatted:gsub("%(","-")
        itemsFormatted = itemsFormatted:gsub("x","-")
        itemsFormatted = itemsFormatted:gsub(",",".")
        itemsFormatted = luautils.split(itemsFormatted, "-")
        table.insert(itemsPowered, itemsFormatted)
    end
    return itemsPowered
end

---Get the REAL total power a generator is outputting from a table
---@param generator IsoGenerator Generator which we're calculating the real total power
function ISGenTweaksPowerSet.calculateTotalPower(generator)
    local itemsPowered = ISGenTweaksPowerSet.getAllItemsPowered(generator)
    local sum = 0
    for i=1, #itemsPowered do
        sum = sum + tonumber(itemsPowered[i][3])
    end
    sum = (sum + powerGeneratorConstant) * SandboxVars.GeneratorFuelConsumption
    return ISGenTweaksUtils.roundNumber(sum, 5)
end

---Adjust the generator consumption to the REAL total power cost
---@param generator IsoGenerator Generator to be updated
function ISGenTweaksPowerSet.correctGenerator(generator)
    if not generator then return end
    local totalNewPower = ISGenTweaksPowerSet.calculateTotalPower(generator)
    generator:setTotalPowerUsing(totalNewPower)
end

---Correct all generators that are in the ModData
---@param totalGenerators KahluaTable ModData table containing all generators IDs and pos
function ISGenTweaksPowerSet.correctAllGenerators(totalGenerators)
    for i, data in pairs(totalGenerators) do
        if data then
            local generator = ISGenTweaksUtils.getGeneratorFromPos(data)
            if not instanceof(generator, "IsoGenerator") then
                totalGenerators[i] = nil
                ISGenTweaksPowerShare.checkAllConnections()
            else
                if generator:isActivated() then
                    ISGenTweaksPowerSet.correctGenerator(generator)
                end
            end
        end
    end
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerSet