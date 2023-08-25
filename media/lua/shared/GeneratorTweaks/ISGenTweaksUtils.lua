
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
function ISGenTweaksUtils.printAdjacent(table)
	for i = 1, #table do
		local square = getCell():getGridSquare(table[i].x, table[i].y, table[i].z)
		if square then
			print(string.format("X: %d, Y: %d, Z: %d", square:getX(), square:getY(), square:getZ()))
		end
	end
end



---Updates all generators on the Global ModData per in-game minute
function ISGenTweaksUtils.updateEveryMinute()
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
						ISGenTweaksUtils.correctGenerator(generator)
					end
				end
			end
		end
	end
end
Events.EveryOneMinute.Add(ISGenTweaksUtils.updateEveryMinute)


---Creates the ContextMenu option when clicking a generator
---@param _player number Player index number
---@param context ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function ISGenTweaksUtils.onContextMenu(_player, context, worldObjects)
	local player = getSpecificPlayer(_player)
	local generator
	for i=1, #worldObjects do
		if instanceof(worldObjects[i], "IsoGenerator") then
			generator = worldObjects[i]
		end
	end
	
	if generator then
		context:addOption("Check Radius", generator, ISGenTweaksUtils.checkRadius, player)
	end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksUtils.onContextMenu)


------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

