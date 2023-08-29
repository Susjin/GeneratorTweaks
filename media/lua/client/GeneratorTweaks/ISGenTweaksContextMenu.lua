----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/

--- Main file with all functions
--- @class ISGenTweaksContextMenu
local ISGenTweaksContextMenu = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
--local pairs = pairs

---Sets the current generator to be the focus of power consumption of the whole branch it is in
---@param generator IsoGenerator Generator being interacted with
function ISGenTweaksContextMenu.setFocusPower(generator)
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if not branches then return end

    local genID = ISGenTweaksUtils.getIDFromGenerator(generator) --Gets the ID, if non-existent, create one
    if genID == -1 then ISGenTweaksUtils.saveGeneratorToModData(generator); genID = ISGenTweaksUtils.getIDFromGenerator(generator); end
    local branchIndex = ISGenTweaksUtils.getBranchFromID(branches, genID) --Gets the branch, if non-existent, put in one
    if branchIndex == -1 then ISGenTweaksPowerShare.checkAllConnections(); branchIndex = ISGenTweaksUtils.getBranchFromID(branches, genID); end

    if (genID ~= -1) and (branchIndex ~= -1) then
        branches[branchIndex].share = genID
    end
end

---Sets the current branch the generator is in to split all it's power consumption between generators
---@param generator IsoGenerator Generator being interacted with
function ISGenTweaksContextMenu.setSplitPower(generator)
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if not branches then return end

    local genID = ISGenTweaksUtils.getIDFromGenerator(generator) --Gets the ID, if non-existent, create one
    if genID == -1 then ISGenTweaksUtils.saveGeneratorToModData(generator); genID = ISGenTweaksUtils.getIDFromGenerator(generator); end
    local branchIndex = ISGenTweaksUtils.getBranchFromID(branches, genID) --Gets the branch, if non-existent, put in one
    if branchIndex == -1 then ISGenTweaksPowerShare.checkAllConnections(); branchIndex = ISGenTweaksUtils.getBranchFromID(branches, genID); end

    if branchIndex ~= -1 then
        branches[branchIndex].share = 0
    end
end

------------------ Functions related to ContextMenu ------------------

---Creates the ContextMenu option when clicking a generator
---@param _player number Player index number
---@param context ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function ISGenTweaksContextMenu.onContextMenu(_player, context, worldObjects)
    local player = getSpecificPlayer(_player)
    local generator
    for i=1, #worldObjects do
        if instanceof(worldObjects[i], "IsoGenerator") then
            generator = worldObjects[i]
        end
    end

    if generator then
        context:addOption("Check Branches", player, ISGenTweaksPowerShare.checkAllConnections)
        context:addOption("Split", generator, ISGenTweaksContextMenu.setSplitPower)
        context:addOption("Focus", generator, ISGenTweaksContextMenu.setFocusPower)
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksContextMenu.onContextMenu)

------------------ Functions related to Vanilla Overrides ------------------

---Overwrite default vanilla behaviour to fix generator consumption
local oldActivatePerform = ISActivateGenerator.perform
function ISActivateGenerator:perform()
    oldActivatePerform(self)
    if self.activate == true then
        ISGenTweaksPowerSet.correctGenerator(self.generator)
        ISGenTweaksUtils.saveGeneratorToModData(self.generator)
        ISGenTweaksPowerShare.checkAllConnections()
    end
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksContextMenu