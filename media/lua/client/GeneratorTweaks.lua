
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class GenTweaks
local GenTweaks = {}
----------------------------------------------------------------------------------------------

---Returns the given number rounded with the number of decimal places in param2 (0 by default)
---@param number number Number to be rounded
---@param numberDecimalPlaces number Amount of decimal places
---@return number Rounded number
local function roundNumber(number, numberDecimalPlaces)
	local decimal = 10^(numberDecimalPlaces or 0)
	return math.floor(number * decimal + 0.5) / decimal
end

local function printAdjacent(table)
	for i = 1, #table do
		local square = getCell():getGridSquare(table[i].x, table[i].y, table[i].z)
		if square then
			print(string.format("X: %d, Y: %d, Z: %d", square:getX(), square:getY(), square:getZ()))
		end
	end
end




---Updates the current generator power to a new one and saves that generator to the GlobalModData it doesn't exist there.
---@param generator IsoGenerator Generator to get updated
---@param power number New power to be set
function GenTweaks.setPower(generator, power)
	generator:setTotalPowerUsing(power)
	generator:getModData().TweakTotalPower = power

	---Saving Generator on GlobalModData
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

---Gets all the powered items from the generator and splits then into a table
---@param generator IsoGenerator Generator which we're getting the items from
function GenTweaks.getAllPowered(generator)
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
function GenTweaks.sumPowerCost(itemsPowered)
	local sum = 0
	for i=1, #itemsPowered do
		sum = sum + tonumber(itemsPowered[i][3])
	end
	return sum
end

---Adjust the generator consumption to the REAL total power cost, only if needed
---@param generator IsoGenerator Generator to be updated
function GenTweaks.correctGenerator(generator)
	local itemList = GenTweaks.getAllPowered(generator)
	local totalNewPower = GenTweaks.sumPowerCost(itemList)
	if not (roundNumber(generator:getTotalPowerUsing(), 2) == totalNewPower) then
		GenTweaks.setPower(generator, totalNewPower)
	end
end

---Updates all generators on the Global ModData per in-game minute
function GenTweaks.updateEveryMinute()
	local totalGenerators = ModData.getOrCreate("GenTweaks")
	if totalGenerators then
		for i = 1, #totalGenerators do
			if totalGenerators[i] then
				local generatorSquare = getCell():getGridSquare(totalGenerators[i].x, totalGenerators[i].y, totalGenerators[i].z)
				if not generatorSquare then return end
				local generator = generatorSquare:getGenerator()
				if not generator then
					table.remove(totalGenerators, i)
				else
					if instanceof(generator, "IsoGenerator") and generator:isActivated() then
						GenTweaks.correctGenerator(generator)
					end
				end
			end
		end
	end
end
Events.EveryOneMinute.Add(GenTweaks.updateEveryMinute)

---checkRadius
---@param generator IsoGenerator
function GenTweaks.checkRadius(generator)
	local totalGenerators = ModData.getOrCreate("GenTweaks")
	if not totalGenerators then return end
	local cell = getCell()
	local currentGeneratorSquare = generator:getSquare()
	local currentGeneratorAdjacent = {}
	for i = 1, #totalGenerators do
		local generatorModDataSquare = cell:getGridSquare(totalGenerators[i].x, totalGenerators[i].y, totalGenerators[i].z)
		if generatorModDataSquare and (generatorModDataSquare ~= currentGeneratorSquare) and (currentGeneratorSquare:DistToProper(generatorModDataSquare) <= 20) then
			table.insert(currentGeneratorAdjacent, totalGenerators[i])
		end
	end
	printAdjacent(currentGeneratorAdjacent)
	return currentGeneratorAdjacent
end


---Creates the ContextMenu option when clicking a generator
---@param _player number Player index number
---@param context ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function GenTweaks.onContextMenu(_player, context, worldObjects)
	local player = getSpecificPlayer(_player)
	local generator
	for i=1, #worldObjects do
		if instanceof(worldObjects[i], "IsoGenerator") then
			generator = worldObjects[i]
		end
	end
	
	if generator then
		context:addOption("Check Radius", generator, GenTweaks.checkRadius)
	end
end
Events.OnFillWorldObjectContextMenu.Add(GenTweaks.onContextMenu)

local oldActivatePerform = ISActivateGenerator.perform
function ISActivateGenerator:perform()
	oldActivatePerform(self)
	if self.generator:isActivated() then
		GenTweaks.correctGenerator(self.generator)
	end
end