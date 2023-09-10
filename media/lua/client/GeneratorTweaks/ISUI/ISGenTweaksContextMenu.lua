
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
---Sets a given share setting to the current generator branch
---@param generator IsoGenerator Generator being interacted with
---@param player IsoPlayer Player interacting with the Generator
---@param branches KahluaTable ModData table containing all generators 'branches' in the world
---@param setting number Branch setting 'share' value to be set in the branch
function ISGenTweaksContextMenu.onClickBranchSettings(generator, player, branches, setting)
    if isSP then
        ISGenTweaksUtils.setBranchSetting(generator, branches, setting)
    else
        local genSquare = generator:getSquare()
        sendClientCommand("GenTweaks", "branchSetting", {x = genSquare:getX(), y = genSquare:getY(), z = genSquare:getZ(), share = setting})
    end
    HaloTextHelper.addText(player, getText("IGUI_GenTweaks_SettingsApplied", ISGenTweaksUtils.getBranchFromGeneratorID(branches, ISGenTweaksUtils.getIDFromGenerator(generator))), HaloTextHelper.COLOR_GREEN)
end

---Adds the selected generator to the Branch System
---@param player IsoPlayer Player adding the generator to the System
---@param totalGenerators KahluaTable ModData table containing all Generator IDs
---@param genID number Generator ID to get added
function ISGenTweaksContextMenu.onClickAddGeneratorToSystem(player, totalGenerators, genID)
    local electricWire = player:getInventory():getItemFromTypeRecurse("ElectricWire")
    --ISInventoryPaneContextMenu.transferIfNeeded(player, electricWire)

    if electricWire then
        electricWire:getContainer():Remove(electricWire)
        totalGenerators[genID].branch = true
        HaloTextHelper.addText(player, getText("IGUI_GenTweaks_AddedToSystem"), HaloTextHelper.COLOR_GREEN)
    end
end

---Removes the selected generator from the Branch System
---@param player IsoPlayer Player adding the generator to the System
---@param totalGenerators KahluaTable ModData table containing all Generator IDs
---@param genID number Generator ID to get added
function ISGenTweaksContextMenu.onClickRemoveGeneratorFromSystem(player, totalGenerators, genID)
    player:getInventory():AddItem("Radio.ElectricWire")
    totalGenerators[genID].branch = false
    HaloTextHelper.addText(player, getText("IGUI_GenTweaks_RemovedFromSystem"), HaloTextHelper.COLOR_GREEN)
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

    if generator then
        local genID = ISGenTweaksUtils.getIDFromGenerator(generator)
        if genID > 0 then
            -- ------ Setting up locals -- ------
            local branches = ModData.getOrCreate("GenTweaksBranches")
            local totalGenerators = ModData.getOrCreate("GenTweaksGenerators")
            local generatorActive = generator:isActivated()

            -- ------ Creating submenu  ------ --
            local generatorMenu = contextMenu:insertOptionAfter(getText("ContextMenu_GeneratorInfo"), getText("ContextMenu_GenTweaks_BranchMenu"), worldObjects, nil)
            ---@type ISContextMenu
            local generatorSubMenu = ISContextMenu:getNew(contextMenu)
            contextMenu:addSubMenu(generatorMenu, generatorSubMenu)

            if not generatorActive then
                -- ------ Adding/removing to/from Branch System  ------ --
                if not totalGenerators[genID].branch then
                    local addOption = generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_AddToSystem"), player, ISGenTweaksContextMenu.onClickAddGeneratorToSystem, totalGenerators, genID)
                    ISGenTweaksContextMenu.addToSystemTooltip(addOption, player, genID, generator:getTextureName())
                elseif totalGenerators[genID].branch then
                    local removeOption = generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_RemoveFromSystem"), player, ISGenTweaksContextMenu.onClickRemoveGeneratorFromSystem, totalGenerators, genID)
                    ISGenTweaksContextMenu.removeFromSystemTooltip(removeOption, player, genID, generator:getTextureName())
                end
            else
                -- ------ Branch settings options ------ --
                if totalGenerators[genID].branch then
                    if player:isRecipeKnown("Generator") then -- Generator magazine is read
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Disable"), generator, ISGenTweaksContextMenu.onClickBranchSettings, player, branches, -1)
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Split"), generator, ISGenTweaksContextMenu.onClickBranchSettings, player, branches, 0)
                        generatorSubMenu:addOption(getText("ContextMenu_GenTweaks_Focus"), generator, ISGenTweaksContextMenu.onClickBranchSettings, player, branches, genID)
                    else
                        generatorMenu.notAvailable = true
                        generatorMenu.toolTip = ISWorldObjectContextMenu.addToolTip()
                        generatorMenu.toolTip.description = getText("ContextMenu_GeneratorPlugTT")
                    end
                end
            end

            -- ------ Override tooltip of 'Generator info' option ------ --
            if player:DistToSquared(generator:getX() + 0.5, generator:getY() + 0.5) < 2 * 2 then
                local option = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorInfo"))
                option.toolTip:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID))
                option.toolTip.maxLineWidth = 400
            end

            -- ------ Override tooltip of the 'Take generator' option ------ --
            if ISGenTweaksUtils.checkModData(branches) and not generator:isConnected() then
                local branchID = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID)
                if genID == branchID then
                    local option = contextMenu:getOptionFromName(getText("ContextMenu_GeneratorTake"))
                    ISGenTweaksContextMenu.takeGeneratorTooltip(option, genID)
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