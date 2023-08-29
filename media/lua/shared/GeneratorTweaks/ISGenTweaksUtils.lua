
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
	for i = 1, #table do
		local square = getCell():getGridSquare(table[i].x, table[i].y, table[i].z)
		if square then
			print(string.format("X: %d, Y: %d, Z: %d", square:getX(), square:getY(), square:getZ()))
		end
	end
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



------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

