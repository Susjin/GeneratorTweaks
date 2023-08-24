GenTweaks = {}

---Returns the given number rounded with the number of decimal places in param2 (0 by default)
---@param number number Number to be rounded
---@param numberDecimalPlaces number Amount of decimal places
---@return number Rounded number
local function roundNumber(number, numberDecimalPlaces)
	local decimal = 10^(numberDecimalPlaces or 0)
	return math.floor(number * decimal + 0.5) / decimal
end




function GenTweaks.updateEveryMinute()
	local totalGenerators = ModData.getOrCreate("GenTweaks")
	if totalGenerators then
		for i = 1, #totalGenerators do
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
Events.EveryOneMinute.Add(GenTweaks.updateEveryMinute)

---setPower
---@param generator IsoGenerator
---@param power number
function GenTweaks.setPower(generator, power)
	generator:setTotalPowerUsing(power)
	generator:getModData().TweakTotalPower = power

	---Saving Generator on GlobalModData
	local generatorSquare = generator:getSquare()
	local generatorPos = {x = generatorSquare:getX(), y = generatorSquare:getY(), z = generatorSquare:getZ()}
	local genModData = ModData.getOrCreate("GenTweaks")
	for i = 1, #genModData do
		if genModData[i].x == generatorPos.x and genModData[i].y == generatorPos.y and genModData[i].z == generatorPos.z then
			return
		end
	end
	genModData[#genModData+1] = generatorPos
end

---getAllPowered
---@param generator IsoGenerator
function GenTweaks.getAllPowered(generator)
	local list = generator:getItemsPowered()
	local items = {}
	local itemsFormatted = ""
	for i=0, list:size()-1 do
		itemsFormatted = list:get(i):gsub(" L/h%)","")
		itemsFormatted = itemsFormatted:gsub("%(","-")
		itemsFormatted = itemsFormatted:gsub("x","-")
		itemsFormatted = itemsFormatted:gsub(",",".")
		itemsFormatted = luautils.split(itemsFormatted, "-")
		--print(itemsFormatted)
		table.insert(items, itemsFormatted)
	end
	--[[
	for i=1, #items do
		for j=1, #items[i] do
			print(items[i][j])
		end
	end
	--]]
	return items
end

function GenTweaks.sumPowerCost(table)
	local sum = 0
	for i=1, #table do
		sum = sum + tonumber(table[i][3])
	end
	return sum
end

---correctGenerator
---@param generator IsoGenerator
function GenTweaks.correctGenerator(generator)
	local itemList = GenTweaks.getAllPowered(generator)
	local totalNewPower = GenTweaks.sumPowerCost(itemList)
	if not (roundNumber(generator:getTotalPowerUsing(), 2) == totalNewPower) then
		print(roundNumber(generator:getTotalPowerUsing(), 2))
		print(totalNewPower)
		GenTweaks.setPower(generator, totalNewPower)
	end
end

function GenTweaks.onContextMenu(_player, context, worldObjects)
	local player = getSpecificPlayer(_player)
	local generator
	for i=1, #worldObjects do
		print(worldObjects[i])
		if instanceof(worldObjects[i], "IsoGenerator") then
			generator = worldObjects[i]
		end
	end
	
	if generator then
		context:addOption("Correct Generator cost", generator, GenTweaks.correctGenerator)
		
		
		--print("GENERATORTEST: " .. tostring(generator))
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