
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- Main file with all functions
--- @class ISGenTweaksUtils
local ISGenTweaksUtils = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local pairs = pairs
local print = print

-- ---------------- Miscellaneous Functions ---------------- --
---Prints a message in the log only if in debug mode
---@param message string Message to be printed
function ISGenTweaksUtils.debugMessage(message)
	if getDebug() then
		print(message)
	end
end

---Checks if a ModData table has any value in it
---@param ModDataTable table Table to check if it's nil
function ISGenTweaksUtils.checkModData(ModDataTable)
	local count = 0
	if ModDataTable then
		for _, _ in pairs(ModDataTable) do
			count = count + 1
		end
	end
	return count > 0
end

---Get all the Good/Bad colors from acessibility settings
function ISGenTweaksUtils.getColorsFromAcessibility()
	local colors = {}
	colors.white = " <RGB:1,1,1> "
	colors.good = " <RGB:" .. getCore():getGoodHighlitedColor():getR() .. "," .. getCore():getGoodHighlitedColor():getG() .. "," .. getCore():getGoodHighlitedColor():getB() .. "> "
	colors.bad  = " <RGB:" .. getCore():getBadHighlitedColor():getR() .. "," .. getCore():getBadHighlitedColor():getG() .. "," .. getCore():getBadHighlitedColor():getB() .. "> "
	return colors
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
	ISGenTweaksUtils.debugMessage(string.format("X: %d, Y: %d, Z: %d", table.x, table.y, table.z))
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

-- ---------------- Functions related to general Generator interactions ---------------- --
---Gets the current setting of a branch from it's value
---@param shareValue number	'share' index inside the Branch's ModData table
---@return number Setting to be tested when applying power split
function ISGenTweaksUtils.getShareSetting(shareValue)
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	if not ISGenTweaksUtils.checkModData(totalGenerators) then return -1 end

	if shareValue == 0 then return 1 end
	if shareValue > 0 then
		local genExists = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[shareValue])
		if genExists and genExists:isActivated() then
			return 2
		else
			return 1
		end
	end
	return 0
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
			else
				return "notFound"
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
	if not ISGenTweaksUtils.checkModData(totalGenerators) then return -1 end
	if instanceof(generator, "IsoGenerator") then
		local square = generator:getSquare()
		local squarePos = {x = square:getX(), y = square:getY(), z = square:getZ()}
		for i, data in pairs(totalGenerators) do
			if (data.x == squarePos.x) and (data.y == squarePos.y) and (data.y == squarePos.y) then
				return i
			end
		end
	end
	return -1
end

---Checks if a Generator is on the Branch System
---@param genID number Generator ID in ModData table
---@return number The branch index that the generator is located (-1 if non-existent)
function ISGenTweaksUtils.isOnBranchSystem(genID)
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	if not ISGenTweaksUtils.checkModData(totalGenerators) then return false end
	return totalGenerators[genID].branch and true or false
end

---Sets if a Generator is on the Branch System
---@param genID number Generator ID in ModData table
---@param addOrRemove boolean If true, adds to the Branch System, if false, removes from it
function ISGenTweaksUtils.setIsOnBranchSystem(genID, addOrRemove)
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	if not ISGenTweaksUtils.checkModData(totalGenerators) then return false end
	totalGenerators[genID].branch = addOrRemove
	if addOrRemove == false then
		local branchID = ISGenTweaksUtils.getBranchIDFromGeneratorID(genID)
		if branchID == genID then
			ModData.getOrCreate("GenTweaksBranches")[genID].share = -1
		end
	end
end

---Gets in what branch a specific generator is located from it's ID
---@param genID number Generator ID in ModData table
---@return number The branch index that the generator is located (-1 if non-existent)
function ISGenTweaksUtils.getBranchIDFromGeneratorID(genID)
	local branches = ModData.getOrCreate("GenTweaksBranches")
	if not ISGenTweaksUtils.checkModData(branches) then return false end

	for i, data in pairs(branches) do
		for j = 1, #data do
			if branches[i][j] == genID then
				return i
			end
		end
	end
	return -1
end

---Gets a text with the current mode of a given Branch
---@param share number Value inside the 'share' index of a Branch
---@return string Text with the correct 'Power setting' of that Branch
function ISGenTweaksUtils.getBranchModeFromSetting(share)
	local focus = ISGenTweaksUtils.getShareSetting(share)
	if focus == 0 then
		return getText("IGUI_GenTweaks_NoPowerSetting")
	elseif focus == 1 then
		return getText("IGUI_GenTweaks_PowerSplit")
	elseif focus == 2 then
		return getText("IGUI_GenTweaks_PowerFocus", share)
	end
end

---Get the total power a whole Branch of generators is consuming
---@param branch KahluaTable ModData table containing all data from the given Branch
---@return table Contains the index 'total' and 'count' with the total power and amount of generators counted
function ISGenTweaksUtils.getBranchTotalPower(branch)
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	if not ISGenTweaksUtils.checkModData(totalGenerators) then return {} end

	local branchPower = {}
	branchPower.total = 0
	branchPower.count = 0
	for j = 1, #branch do
		local generator = ISGenTweaksUtils.getGeneratorFromPos(totalGenerators[branch[j]])
		if instanceof(generator, "IsoGenerator") and generator:isActivated() then
			branchPower.total = branchPower.total + generator:getTotalPowerUsing()
			branchPower.count = branchPower.count + 1
			--ISGenTweaksUtils.debugMessage(string.format("Branch %d current: sum: %.2f | count: %d", branchID, branchPower.total, branchPower.count))
		end
	end
	return branchPower
end

---Gets the power that needs to be set to each generator in a Branch
---@param branch KahluaTable ModData table containing all data from the given Branch
---@return number Power to be set in each generator
function ISGenTweaksUtils.getBranchEachPower(branch)
	local branchPower = ISGenTweaksUtils.getBranchTotalPower(branch)
	local shareSetting = ISGenTweaksUtils.getShareSetting(branch.share)
	if shareSetting == 1 then
		local average = (branchPower.total / branchPower.count)
		if branchPower.count == 0 then average = 0 end
		return ISGenTweaksUtils.roundNumber(average, 5)
	elseif shareSetting == 2 then
		return ISGenTweaksUtils.roundNumber(branchPower.total, 5)
	end
end


---Saves the given generator coordinates to the ModData
---@param generator IsoGenerator Generator to be stored
function ISGenTweaksUtils.saveGeneratorToModData(generator)
	--Storing Generator on GlobalModData
	local exists = false
	local genID = 0
	local generatorSquare = generator:getSquare()
	local generatorData = {x = generatorSquare:getX(), y = generatorSquare:getY(), z = generatorSquare:getZ(), branch = false}
	local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
	for i, data in pairs(totalGenerators) do
		if data.x == generatorData.x and data.y == generatorData.y and data.z == generatorData.z then
			exists = true
			genID = i
			break
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
	else
		if totalGenerators[genID].branch == nil then
			totalGenerators[genID].branch = false
		end
	end
end

-- ---------------- Functions related to actions on the ContextMenu ---------------- --
---Sets a given share setting to the current generator branch
---@param genID number ID of the Generator being interacted with
---@param setting number Branch setting 'share' value to be set in the branch
function ISGenTweaksUtils.setBranchSetting(genID, setting)
	local branches = ModData.getOrCreate("GenTweaksBranches")
	if not ISGenTweaksUtils.checkModData(branches) then return false end
	local branchIndex = ISGenTweaksUtils.getBranchIDFromGeneratorID(genID)

	if (branchIndex ~= -1) and (genID ~= -1) then
		branches[branchIndex].share = setting
	end
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksUtils

