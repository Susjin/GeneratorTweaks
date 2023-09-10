
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
local ISGenTweaksInteractAction = require "GeneratorTweaks/TimedActions/ISGenTweaksInteractAction"

local walkToAdjacent = luautils.walkAdj

-- ---------------- Functions related to Tooltips on the ContextMenu ---------------- --
---Creates a tooltip for the option 'Take Generator'
---@param takeOption table Contains the given option to set a tooltip
---@param genID number Tooltip's Generator ID
---@param texture string Generator texture to be set
function ISGenTweaksContextMenu.takeGeneratorTooltip(takeOption, genID, texture)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    takeOption.toolTip = ISToolTip:new()
    takeOption.toolTip:initialise()
    takeOption.toolTip:setVisible(true)
    takeOption.toolTip.maxLineWidth = 280

    if not takeOption.notAvailable then
        takeOption.toolTip:setName(getText("ContextMenu_GeneratorTake") .. " - ID: " .. tostring(genID))
        takeOption.toolTip:setTexture(texture)
        takeOption.toolTip.description = " <CENTRE><H1><SIZE:large> " .. colors.bad .. getText("Tooltip_GenTweaks_Warning") .. " <LINE> "
        takeOption.toolTip.description = takeOption.toolTip.description .. " <TEXT><CENTRE><SIZE:small> " .. colors.white .. getText("Tooltip_GenTweaks_WarningMessage")
    else
        takeOption.toolTip.description = colors.white .. getText("Tooltip_GenTweaks_StillInSystem")
    end
end

---Creates a tooltip and check validation of the option Add to Branch System
---@param addOption table Contains the given option to set a tooltip
---@param player IsoPlayer Player to show the tooltip
---@param genID number Tooltip's Generator ID
---@param texture string Generator texture to be set
function ISGenTweaksContextMenu.addToSystemTooltip(addOption, player, genID, texture)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    colors.use = colors.white
    local playerInventory = player:getInventory()
    local electricWire = playerInventory:getCountTypeRecurse("ElectricWire")
    local screwdriver = playerInventory:getCountTypeRecurse("Screwdriver")
    local electrical = player:getPerkLevel(Perks.Electricity)
    addOption.toolTip = ISToolTip:new()
    addOption.toolTip:initialise()
    addOption.toolTip:setVisible(true)
    addOption.toolTip:setTexture(texture)

    --Option not available if don't have enough items
    if electrical < 1 or screwdriver < 1 or electricWire < 1 then addOption.notAvailable = true end

    if player:isRecipeKnown("Generator") then
        addOption.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
        addOption.toolTip.description = colors.white .. getText("Tooltip_GenTweaks_AddToSystemDescription") .. " <LINE><LINE> "
        addOption.toolTip.description = addOption.toolTip.description .. getText("Tooltip_craft_Needs") .. ": <LINE> "

        if electricWire > 0 then colors.use = colors.good else colors.use = colors.bad end
            addOption.toolTip.description = addOption.toolTip.description .. colors.use .. getItemNameFromFullType("Radio.ElectricWire") .. " " .. tostring(electricWire) .. "/1 <LINE> "
        if screwdriver > 0 then colors.use = colors.good else colors.use = colors.bad end
            addOption.toolTip.description = addOption.toolTip.description .. colors.use .. getItemNameFromFullType("Base.Screwdriver") .. " " .. tostring(screwdriver) .. "/1 <LINE> "
        if electrical > 0 then colors.use = colors.good else colors.use = colors.bad end
            addOption.toolTip.description = addOption.toolTip.description .. colors.use .. " <LINE> " .. getText("IGUI_perks_Electricity") .. " " .. tostring(electrical) .. "/1 <LINE> "
    else
        addOption.notAvailable = true
        addOption.toolTip.description = getText("ContextMenu_GeneratorPlugTT")
    end
end

---Creates a tooltip and check validation of the option Add to Branch System
---@param removeOption table Contains the given option to set a tooltip
---@param player IsoPlayer Player to show the tooltip
---@param genID number Tooltip's Generator ID
---@param texture string Generator texture to be set
function ISGenTweaksContextMenu.removeFromSystemTooltip(removeOption, player, genID, texture)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    local screwdriver = player:getInventory():getCountTypeRecurse("Screwdriver")
    local electrical = player:getPerkLevel(Perks.Electricity)
    removeOption.toolTip = ISToolTip:new()
    removeOption.toolTip:initialise()
    removeOption.toolTip:setVisible(true)
    removeOption.toolTip:setTexture(texture)

    -- Option not available if don't have enough items
    if electrical < 1 or screwdriver < 1 then removeOption.notAvailable = true end

    if player:isRecipeKnown("Generator") then
        removeOption.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
        removeOption.toolTip.description = colors.white .. getText("Tooltip_GenTweaks_RemoveFromSystemDescription") .. " <LINE><LINE> "
        removeOption.toolTip.description = removeOption.toolTip.description .. getText("Tooltip_craft_Needs") .. ": <LINE> "

        if screwdriver > 0 then colors.use = colors.good else colors.use = colors.bad end
            removeOption.toolTip.description = removeOption.toolTip.description .. colors.use .. getItemNameFromFullType("Base.Screwdriver") .. " " .. tostring(screwdriver) .. "/1 <LINE> "
        if electrical > 0 then colors.use = colors.good else colors.use = colors.bad end
            removeOption.toolTip.description = removeOption.toolTip.description .. colors.use .. " <LINE> " .. getText("IGUI_perks_Electricity") .. " " .. tostring(electrical) .. "/1 <LINE> "
    else
        removeOption.notAvailable = true
        removeOption.toolTip.description = getText("ContextMenu_GeneratorPlugTT")
    end
end

-- ---------------- Functions related to actions on the ContextMenu ---------------- --
function ISGenTweaksContextMenu.checkInteractItem(player)
    local playerInventory = player:getInventory()
    local returnToContainer = {}
    local screwdriver = playerInventory:getItemFromTypeRecurse("Screwdriver")
    if screwdriver then
        table.insert(returnToContainer, screwdriver)
        ISInventoryPaneContextMenu.transferIfNeeded(player, screwdriver)
        return screwdriver, returnToContainer
    end
    return nil
end

---Sets a given share setting to the current generator branch
---@param generator IsoGenerator The Generator object that is being interacted
---@param player IsoPlayer Player interacting with the Generator
---@param setting number Branch setting 'share' value to be set in the branch
function ISGenTweaksContextMenu.onClickBranchSettings(player, generator, setting)
    walkToAdjacent(player, generator:getSquare())
    local screwdriver, returnItems = ISGenTweaksContextMenu.checkInteractItem(player)
    ISTimedActionQueue.add(ISGenTweaksInteractAction:new(player, screwdriver, "branchSetting", generator, setting))
    ISCraftingUI.ReturnItemsToOriginalContainer(player, returnItems)
end

---Adds the selected generator to the Branch System
---@param player IsoPlayer Player adding the generator to the System
---@param generator IsoGenerator The Generator object that is being interacted
function ISGenTweaksContextMenu.onClickAddGeneratorToSystem(player, generator)
    walkToAdjacent(player, generator:getSquare())
    local electricWire = player:getInventory():getItemFromTypeRecurse("ElectricWire")
    ISInventoryPaneContextMenu.transferIfNeeded(player, electricWire)
    local screwdriver, returnItems = ISGenTweaksContextMenu.checkInteractItem(player)
    ISTimedActionQueue.add(ISGenTweaksInteractAction:new(player, screwdriver, "addToSystem", generator))
    ISCraftingUI.ReturnItemsToOriginalContainer(player, returnItems)
end

---Removes the selected generator from the Branch System
---@param player IsoPlayer Player adding the generator to the System
---@param generator IsoGenerator The Generator object that is being interacted
function ISGenTweaksContextMenu.onClickRemoveGeneratorFromSystem(player, generator)
    walkToAdjacent(player, generator:getSquare())
    local screwdriver, returnItems = ISGenTweaksContextMenu.checkInteractItem(player)
    ISTimedActionQueue.add(ISGenTweaksInteractAction:new(player, screwdriver, "removeFromSystem", generator))
    ISCraftingUI.ReturnItemsToOriginalContainer(player, returnItems)
end

-- ---------------- Functions related to ContextMenu ---------------- --
---Creates the ContextMenu option when clicking a generator
---@param playerNum number Player index number
---@param contextMenu ISContextMenu Generated ContextMenu
---@param worldObjects table<number, IsoObject> Table containing objects on the clicked position
function ISGenTweaksContextMenu.onContextMenu(playerNum, contextMenu, worldObjects)
    local player = getSpecificPlayer(playerNum)
    ---@type IsoGenerator
    local generator
    for i=1, #worldObjects do
        if instanceof(worldObjects[i], "IsoGenerator") then
            generator = worldObjects[i]
        end
    end

    --if getDebug() then contextMenu:addOption("test range", worldObjects[1]:getSquare(), function(square, playerSquare) print(square:DistToProper(playerSquare))  end, player:getSquare()) end
    --local playerModData = player:getModData()

    if generator then
        local branches = ModData.getOrCreate("GenTweaksBranches")
        local genID = ISGenTweaksUtils.getIDFromGenerator(generator)
        if genID > 0 and ISGenTweaksUtils.checkModData(branches) then
            ------------------ #Setting up locals# ------------------
            local isOnBranchSystem = ISGenTweaksUtils.isOnBranchSystem(genID)
            local generatorConnected = generator:isConnected()
            local generatorActive = generator:isActivated()
            local generatorTexture = generator:getTextureName()

            ------------------ #Branch System# ------------------
            -- ------ Creating submenu  ------ --
            local generatorMenu = contextMenu:insertOptionAfter(getText("ContextMenu_GeneratorInfo"), getText("ContextMenu_GenTweaks_BranchMenu"), worldObjects, nil)
            ---@type ISContextMenu
            local generatorSubMenu = ISContextMenu:getNew(contextMenu)
            contextMenu:addSubMenu(generatorMenu, generatorSubMenu)

            if not generatorActive and generatorConnected then
                -- ------ Adding/removing to/from Branch System  ------ --
                if not isOnBranchSystem then
                    local addOption = generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_AddToSystem"), player, ISGenTweaksContextMenu.onClickAddGeneratorToSystem, generator)
                    ISGenTweaksContextMenu.addToSystemTooltip(addOption, player, genID, generatorTexture)
                elseif isOnBranchSystem then
                    local removeOption = generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_RemoveFromSystem"), player, ISGenTweaksContextMenu.onClickRemoveGeneratorFromSystem, generator)
                    ISGenTweaksContextMenu.removeFromSystemTooltip(removeOption, player, genID, generatorTexture)
                end
            else
                -- ------ Branch settings options ------ --
                if isOnBranchSystem then
                    if player:isRecipeKnown("Generator") then -- Generator magazine is read
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Disable"), player, ISGenTweaksContextMenu.onClickBranchSettings, generator, -1)
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Split"), player, ISGenTweaksContextMenu.onClickBranchSettings, generator, 0)
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Focus"), player, ISGenTweaksContextMenu.onClickBranchSettings, generator, genID)
                    else
                        generatorMenu.notAvailable = true
                        generatorMenu.toolTip = ISWorldObjectContextMenu.addToolTip()
                        generatorMenu.toolTip.description = getText("ContextMenu_GeneratorPlugTT")
                    end
                end
            end

            ------------------ #Vanilla Overrides# ------------------
            -- ------ Override tooltip of 'Generator info' option ------ --

            if player:DistToSquared(generator:getX() + 0.5, generator:getY() + 0.5) < 2 * 2 then
                local optionInfo = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorInfo"))
                optionInfo.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
                optionInfo.toolTip:setTexture(generatorTexture)
                optionInfo.toolTip.maxLineWidth = 400

                if not generatorActive and generatorConnected then
                    local option = contextMenu:getOptionFromName(getText("ContextMenu_Turn_On"))
                    option.toolTip = nil
                end
            end

            -- ------ Override tooltip of the 'Take generator' option ------ --
            if not generatorConnected then
                local branchID = ISGenTweaksUtils.getBranchIDFromGeneratorID(genID)
                if genID == branchID then
                    local option = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorTake"))
                    if isOnBranchSystem then option.notAvailable = true end
                    ISGenTweaksContextMenu.takeGeneratorTooltip(option, genID, generatorTexture)
                end
            end

            -- ------ Removing submenu if empty ------ --
            if generatorSubMenu:isEmpty() then
                contextMenu:removeOptionByName(getText("ContextMenu_GenTweaks_BranchMenu"))
            end
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksContextMenu.onContextMenu)


------------------ Returning file for 'require' ------------------
return ISGenTweaksContextMenu