
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


---Returns the given number rounded with the number of decimal places in param2 (0 by default)
---@param number number Number to be rounded
---@param numberDecimalPlaces number Amount of decimal places
---@return number Rounded number
function ISGenTweaksUtils.roundNumber(number, numberDecimalPlaces)
	local decimal = 10^(numberDecimalPlaces or 0)
	return math.floor(number * decimal + 0.5) / decimal
end

---Prints the coordinates of a IsoGridSquare
---@param table table Contains a x, y and z index for the position of a IsoGridSquare
function ISGenTweaksUtils.printPosFromData(table)
	--for _, data in pairs(table) do
		print(string.format("X: %d, Y: %d, Z: %d", table.x, table.y, table.z))
	--end
end

---Prints all the generator connection branches
---@param branches table Contains all the branches of generator connections
function ISGenTweaksUtils.printConnections(branches)
	for i = 1, #branches do
		print(string.format("Connections in branch %d are:", i))
		for _, adjacent in pairs(branches[i]) do
			print(adjacent)
		end
		print("")
	end
end

---Gets a generator from a XYZ coordinates
---@param genXYZ table Contains the coordinates of a grid square
---@return IsoGenerator Generator is that grid square
function ISGenTweaksUtils.getGeneratorFromPos(genXYZ)
	local square = getCell():getGridSquare(genXYZ.x, genXYZ.y, genXYZ.z)
	if square then
		local generator = square:getGenerator()
		if generator then
			return generator
		end
	end
	return nil
end

---Saves the given generator coordinates to the ModData
---@param generator IsoGenerator Generator to be stored
function ISGenTweaksUtils.saveGeneratorToModData(generator)
	--Storing Generator on GlobalModData
	local exists = false
	local genID = 0
	local generatorSquare = generator:getSquare()
	local generatorData = {x = generatorSquare:getX(), y = generatorSquare:getY(), z = generatorSquare:getZ()}
	local genModData = ModData.getOrCreate("GenTweaksGenerators")
	for _, data in pairs(genModData) do
		if data.x == generatorData.x and data.y == generatorData.y and data.z == generatorData.z then
			exists = true
		end
	end
	if not exists then
		repeat
			local sameID = false
			genID = ZombRand(9999)
			for i,_ in pairs(genModData) do
				if i == genID then
					sameID = true
				end
			end
		until (sameID == false)
		genModData[genID] = generatorData
	end
end



------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

