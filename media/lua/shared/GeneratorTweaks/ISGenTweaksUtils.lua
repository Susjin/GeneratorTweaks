
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksUtils
local ISGenTweaksUtils = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local pairs = pairs
local print = print

------------------ Miscellaneous Functions ------------------

---Prints a message in the log only if in debug mode
---@param message string Message to be printed
function ISGenTweaksUtils.debugMessage(message)
	if getDebug() then
		print(message)
	end
end

---Returns the given number rounded with the number of decimal places in param2 (0 by default)
---@param number number Number to be rounded
---@param numberDecimalPlaces number Amount of decimal places
---@return number Rounded number
function ISGenTweaksUtils.roundNumber(number, numberDecimalPlaces)
	if number == 0 then return 0 end
	local decimal = 10^(numberDecimalPlaces or 0)
	return math.floor(number * decimal + 0.5) / decimal
end

---Prints the coordinates of a IsoGridSquare
---@param table table Contains a x, y and z index for the position of a IsoGridSquare
function ISGenTweaksUtils.printPosFromData(table)
	--for _, data in pairs(table) do
	ISGenTweaksUtils.debugMessage(string.format("X: %d, Y: %d, Z: %d", table.x, table.y, table.z))
	--end
end

---Prints all the generator connection branches
---@param branches KahluaTable Contains all the branches of generator connections
function ISGenTweaksUtils.printConnections(branches)
	for i, data in pairs(branches) do
		ISGenTweaksUtils.debugMessage(string.format("Connections in branch %d are:", i))
		for j=1, #data do
			ISGenTweaksUtils.debugMessage(j .. "o: " .. data[j])
		end
		ISGenTweaksUtils.debugMessage("")
	end
end

------------------ Functions related to general Generator interactions ------------------

function ISGenTweaksUtils.checkFocusGenerator(totalGenerators, shareValue)
	if shareValue == 0 then return 1 end
	if shareValue > 0 then
		local genTest = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[shareValue])
		if genTest and genTest:isActivated() then
			return 2
		else
			return 1
		end
	end
end

---Gets a generator from a XYZ coordinates
---@param genXYZ table Contains the coordinates of a grid square
---@return IsoGenerator Generator is that grid square
function ISGenTweaksUtils.getGeneratorFromPos(genXYZ)
	if genXYZ then
		local square = getCell():getGridSquare(genXYZ.x, genXYZ.y, genXYZ.z)
		if square then
			local generator = square:getGenerator()
			if generator then
				return generator
			end
		end
	end
	return nil
end

---Gets the Generator ID in ModData table by a generator object
---@param generator IsoGenerator
---@return number Generator ID in ModData table (-1 if non-existent)
function ISGenTweaksUtils.getIDFromGenerator(generator)
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	if not totalGenerators then return end

	local square = generator:getSquare()
	local squarePos = {x = square:getX(), y = square:getY(), z = square:getZ()}
	for i, data in pairs(totalGenerators) do
		if (data.x == squarePos.x) and (data.y == squarePos.y) and (data.y == squarePos.y) then
			return i
		end
	end
	return -1
end

---Gets in what branch a specific generator is located from it's ID
---@param branches KahluaTable ModData table containing all generators 'branches' in the world
---@param id number Generator ID in ModData table
---@return number The branch index that the generator is located (-1 if non-existent)
function ISGenTweaksUtils.getBranchFromID(branches, id)
	for i, data in pairs(branches) do
		for j = 1, #data do
			if branches[i][j] == id then
				return i
			end
		end
	end
	return -1
end

---Saves the given generator coordinates to the ModData
---@param generator IsoGenerator Generator to be stored
function ISGenTweaksUtils.saveGeneratorToModData(generator)
	--Storing Generator on GlobalModData
	local exists = false
	local genID = 0
	local generatorSquare = generator:getSquare()
	local generatorData = {x = generatorSquare:getX(), y = generatorSquare:getY(), z = generatorSquare:getZ()}
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	for _, data in pairs(totalGenerators) do
		if data.x == generatorData.x and data.y == generatorData.y and data.z == generatorData.z then
			exists = true
		end
	end
	if not exists then
		repeat
			local sameID = false
			genID = ZombRand(9999) + 1
			for i,_ in pairs(totalGenerators) do
				if i == genID then
					sameID = true
				end
			end
		until (sameID == false)
		totalGenerators[genID] = generatorData
	end
end



------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

