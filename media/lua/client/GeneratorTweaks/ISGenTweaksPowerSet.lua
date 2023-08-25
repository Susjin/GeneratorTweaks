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
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"


---Gets all the powered items from the generator and splits then into a table
---@param generator IsoGenerator Generator which we're getting the items from
function ISGenTweaksPowerSet.getAllPowered(generator)
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
---@param itemsPowered table Contains all the items getting powered by a generator
function ISGenTweaksPowerSet.sumPowerCost(itemsPowered)
    local sum = 0
    for i=1, #itemsPowered do
        sum = sum + tonumber(itemsPowered[i][3])
    end
    return sum
end

---Updates the current generator power to a new one and saves that generator to the GlobalModData it doesn't exist there.
---@param generator IsoGenerator Generator to get updated
---@param power number New power to be set
function ISGenTweaksPowerSet.setPower(generator, power)
    generator:setTotalPowerUsing(power)

    --Storing Generator on GlobalModData
    local exists = false
    local generatorSquare = generator:getSquare()
    local genID = ZombRand(9999)
    local generatorData = { x = generatorSquare:getX(), y = generatorSquare:getY(), z = generatorSquare:getZ(), id = genID}
    local genModData = ModData.getOrCreate("GenTweaks")
    for i = 1, #genModData do
        if genModData[i].x == generatorData.x and genModData[i].y == generatorData.y and genModData[i].z == generatorData.z then
            exists = true
        end
    end
    if not exists then genModData[#genModData+1] = generatorData
    end
end

---Adjust the generator consumption to the REAL total power cost, only if needed
---@param generator IsoGenerator Generator to be updated
function ISGenTweaksPowerSet.correctGenerator(generator)
    local itemList = ISGenTweaksPowerSet.getAllPowered(generator)
    local totalNewPower = ISGenTweaksPowerSet.sumPowerCost(itemList)
    if not (ISGenTweaksUtils.roundNumber(generator:getTotalPowerUsing(), 2) == totalNewPower) then
        ISGenTweaksPowerSet.setPower(generator, totalNewPower)
    end
end

---Overwrite default vanilla behaviour to fix generator consumption
local oldActivatePerform = ISActivateGenerator.perform
function ISActivateGenerator:perform()
    oldActivatePerform(self)
    if self.generator:isActivated() then
        ISGenTweaksPowerSet.correctGenerator(self.generator)
    end
end


------------------ Returning file for 'require' ------------------
return ISGenTweaksPowerSet