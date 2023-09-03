
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
--local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
--local pairs = pairs


-- ---------------- Functions related to Tooltips on the ContextMenu ---------------- --
function ISGenTweaksContextMenu.takeGeneratorTooltip(takeOption, genID)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    takeOption.toolTip = ISToolTip:new()
    takeOption.toolTip:initialise()
    takeOption.toolTip:setVisible(true)
    takeOption.toolTip.maxLineWidth = 300
    takeOption.toolTip:setName(getText("ContextMenu_GeneratorTake") .. " - ID: " .. tostring(genID))

    takeOption.toolTip.description = " <CENTRE><H1><SIZE:large> " .. colors.bad .. getText("Tooltip_GenTweaks_Warning") .. " <LINE><LINE> "
    takeOption.toolTip.description = takeOption.toolTip.description .. " <TEXT><CENTRE><SIZE:small> " .. colors.white .. getText("Tooltip_GenTweaks_WarningMessage")
end




-- ---------------- Functions related to actions on the ContextMenu ---------------- --
---Sets the current generator to be the focus of power consumption of the whole branch it is in
---@param generator IsoGenerator Generator being interacted with
function ISGenTweaksContextMenu.setFocusPower(generator)
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if not branches then return end

    local genID = ISGenTweaksUtils.getIDFromGenerator(generator) --Gets the ID, if non-existent, create one
    if genID == -1 then ISGenTweaksUtils.saveGeneratorToModData(generator); genID = ISGenTweaksUtils.getIDFromGenerator(generator); end
    local branchIndex = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID) --Gets the branch, if non-existent, put in one
    if branchIndex == -1 then ISGenTweaksPowerShare.checkAllConnections(); branchIndex = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID); end

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
    local branchIndex = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID) --Gets the branch, if non-existent, put in one
    if branchIndex == -1 then ISGenTweaksPowerShare.checkAllConnections(); branchIndex = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID); end

    if branchIndex ~= -1 then
        branches[branchIndex].share = 0
    end
end

-- ---------------- Functions related to ContextMenu ---------------- --
---Creates the ContextMenu option when clicking a generator
---@param _player number Player index number
---@param context ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function ISGenTweaksContextMenu.onContextMenu(_player, context, worldObjects)
    local player = getSpecificPlayer(_player)
    ---@type IsoGenerator
    local generator
    for i=1, #worldObjects do
        if instanceof(worldObjects[i], "IsoGenerator") then
            generator = worldObjects[i]
        end
    end

    if generator then
        local branches = ModData.getOrCreate("GenTweaksBranches")

        context:addOption("Split", generator, ISGenTweaksContextMenu.setSplitPower)
        context:addOption("Focus", generator, ISGenTweaksContextMenu.setFocusPower)

        local genID = ISGenTweaksUtils.getIDFromGenerator(generator)
        if genID > 0 then
            if player:DistToSquared(generator:getX() + 0.5, generator:getY() + 0.5) < 2 * 2 then
                local option = context:getOptionFromName(getText("ContextMenu_GeneratorInfo"))
                option.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
            end
            if branches and not generator:isConnected() then
                local branchID = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID)
                if genID == branchID then
                    local option = context:getOptionFromName(getText("ContextMenu_GeneratorTake"))
                    ISGenTweaksContextMenu.takeGeneratorTooltip(option, genID)
                end
            end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksContextMenu.onContextMenu)



------------------ Returning file for 'require' ------------------
return ISGenTweaksContextMenu