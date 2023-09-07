
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- Main file with all functions
--- @class ISGenTweaksContextMenu
local ISGenTweaksContextMenu = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local isSP = (isClient() == false) and (isServer() == false)

-- ---------------- Functions related to Tooltips on the ContextMenu ---------------- --
---Creates a tooltip for the option 'Take Generator'
---@param takeOption table Contains the given option to set a tooltip
---@param genID number Tooltip's Generator ID
function ISGenTweaksContextMenu.takeGeneratorTooltip(takeOption, genID)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    takeOption.toolTip = ISToolTip:new()
    takeOption.toolTip:initialise()
    takeOption.toolTip:setVisible(true)
    takeOption.toolTip.maxLineWidth = 300
    takeOption.toolTip:setName(getText("ContextMenu_GeneratorTake") .. " - ID: " .. tostring(genID))

    takeOption.toolTip.description = " <CENTRE><H1><SIZE:large> " .. colors.bad .. getText("Tooltip_GenTweaks_Warning") .. " <LINE> "
    takeOption.toolTip.description = takeOption.toolTip.description .. " <TEXT><CENTRE><SIZE:small> " .. colors.white .. getText("Tooltip_GenTweaks_WarningMessage")
end


-- ---------------- Functions related to actions on the ContextMenu ---------------- --
---Sets a given share setting to the current generator branch
---@param generator IsoGenerator Generator being interacted with
---@param branches KahluaTable ModData table containing all generators 'branches' in the world
---@param setting number Branch setting 'share' value to be set in the branch
function ISGenTweaksContextMenu.onClickBranchSettings(generator, branches, setting)
    if isSP then
        ISGenTweaksUtils.setBranchSetting(generator, branches, setting)
    else
        local genSquare = generator:getSquare()
        sendClientCommand("GenTweaks", "branchSetting", {x = genSquare:getX(), y = genSquare:getY(), z = genSquare:getZ(), share = setting})
    end
end


-- ---------------- Functions related to ContextMenu ---------------- --
---Creates the ContextMenu option when clicking a generator
---@param _player number Player index number
---@param contextMenu ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function ISGenTweaksContextMenu.onContextMenu(_player, contextMenu, worldObjects)
    local player = getSpecificPlayer(_player)
    ---@type IsoGenerator
    local generator
    for i=1, #worldObjects do
        if instanceof(worldObjects[i], "IsoGenerator") then
            generator = worldObjects[i]
        end
    end

    if getDebug() then contextMenu:addOption("test range", worldObjects[1]:getSquare(), function(square, playerSquare) print(square:DistToProper(playerSquare))  end, player:getSquare()) end

    if generator then
        local genID = ISGenTweaksUtils.getIDFromGenerator(generator)
        if genID > 0 then
            local branches = ModData.getOrCreate("GenTweaksBranches")
            --Branch settings options
            if generator:isActivated() then
                --Creating submenu
                local generatorMenu = contextMenu:insertOptionAfter(getText("ContextMenu_Turn_Off"), getText("ContextMenu_GenTweaks_BranchMenu"), worldObjects, nil)
                ---@type ISContextMenu
                local generatorSubMenu = ISContextMenu:getNew(contextMenu)
                contextMenu:addSubMenu(generatorMenu, generatorSubMenu)
                --Adding options
                generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Disable"), generator, ISGenTweaksContextMenu.onClickBranchSettings, branches, -1)
                generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Split"), generator, ISGenTweaksContextMenu.onClickBranchSettings, branches, 0)
                generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Focus"), generator, ISGenTweaksContextMenu.onClickBranchSettings, branches, genID)
            end
            --Override tooltip of 'Generator info' option
            if player:DistToSquared(generator:getX() + 0.5, generator:getY() + 0.5) < 2 * 2 then
                local option = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorInfo"))
                option.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
                option.toolTip.maxLineWidth = 400
            end
            --Override tooltip of the 'Take generator' option
            if ISGenTweaksUtils.checkModData(branches) and not generator:isConnected() then
                local branchID = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID)
                if genID == branchID then
                    local option = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorTake"))
                    ISGenTweaksContextMenu.takeGeneratorTooltip(option, genID)
                end
            end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksContextMenu.onContextMenu)


------------------ Returning file for 'require' ------------------
return ISGenTweaksContextMenu