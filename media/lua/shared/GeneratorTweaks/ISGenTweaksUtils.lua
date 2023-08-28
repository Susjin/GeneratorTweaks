
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksUtils
local ISGenTweaksUtils = {}
----------------------------------------------------------------------------------------------

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

------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

