
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- Main file with all functions
--- @class ISGenTweaksOverride
local ISGenTweaksOverride = {}
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local ISGenTweaksPowerSet = require "GeneratorTweaks/ISGenTweaksPowerSet"
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local isSP = (isClient() == false) and (isServer() == false)

-- ---------------- Compatibility with 'Generator Time Remaining' ---------------- --
local hasTimeRemaining = getActivatedMods():contains("GeneratorTimeRemaining")
local GTR
if hasTimeRemaining then
    require("ISUI/gtr_main")
    GTR = require("gtr_options")
end

-- ---------------- Functions related to fixing power issue ---------------- --
---Overwrite default vanilla behaviour to fix generator consumption
local oldActivatePerform = ISActivateGenerator.perform
function ISActivateGenerator:perform()
    oldActivatePerform(self)
    if self.activate == true then
        if isSP then
            ISGenTweaksPowerSet.correctGenerator(self.generator)
            ISGenTweaksUtils.saveGeneratorToModData(self.generator)
            ISGenTweaksPowerShare.createAllBranches()
        else
            ---@type IsoGridSquare
            local genSquare = self.generator:getSquare()
            sendClientCommand("GenTweaks", "startGenerator", {x = genSquare:getX(), y = genSquare:getY(), z = genSquare:getZ()})
        end
    end
end

-- ---------------- Functions related to the Generator InfoWindow ---------------- --
---Overwrite default vanilla behaviour to set the name of the Generator InfoWindow
local oldSetObject = ISGeneratorInfoWindow.setObject
function ISGeneratorInfoWindow:setObject(object)
    oldSetObject(self, object)
    local genID = ISGenTweaksUtils.getIDFromGenerator(object)
    if genID > 0 then self.panel:setName(getText("IGUI_Generator_TypeGas") .. " - ID: " .. tostring(genID)) end
end

---Overwrite default vanilla behaviour to set the description of the Generator InfoWindow (Compatible with 'Generator Time Remaining')
local _ = ISGeneratorInfoWindow.getRichText
function ISGeneratorInfoWindow.getRichText(object, displayStats)
    local square = object:getSquare()
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    if not displayStats then
        local text = ""
        if square and not square:isOutside() and square:getBuilding() then
            text = text .. " <INDENT:10> " .. colors.bad .. getText("IGUI_Generator_IsToxic")
        end
        return text
    end
    local fuel = math.ceil(object:getFuel())
    local condition = object:getCondition()

    local text = getText("IGUI_Generator_FuelAmount", fuel) .. " <LINE> " .. getText("IGUI_Generator_Condition", condition) .. " <LINE> "
    if hasTimeRemaining then text = getText("IGUI_Generator_FuelAmount", fuel) .. GTR:toString(object, fuel) .. " <LINE> " .. getText("IGUI_Generator_Condition", condition) .. " <LINE> " end

    if object:isActivated() then
        --Default consumption and items list
        text = text ..  " <LINE> " .. getText("IGUI_PowerConsumption") .. ": <LINE> ";
        text = text .. " <INDENT:10> "
        local items = object:getItemsPowered()
        for i=0,items:size()-1 do
            text = text .. "   " .. items:get(i) .. " <LINE> ";
        end
        text = text .. getText("IGUI_Total") .. ": " .. ISGenTweaksUtils.roundNumber(object:getTotalPowerUsing(), 2) .. " L/h"
    end
    --All the new branch information
    text = ISGenTweaksOverride.setTextForDescription(object, text)

    if square and not square:isOutside() and square:getBuilding() then
        text = text .. " <LINE><LINE> " .. colors.bad .. getText("IGUI_Generator_IsToxic")
    end
    return text
end

---Creates the description of the Branches information for the Generator InfoWindow
---@param generator IsoGenerator Generator shown in the InfoWindow
---@param text string Previous text description used in the InfoWindow
function ISGenTweaksOverride.setTextForDescription(generator, text)
    local colors = ISGenTweaksUtils.getColorsFromAcessibility()
    local branches = ModData.getOrCreate("GenTweaksBranches")
    if ISGenTweaksUtils.checkModData(branches) then
        local genID = ISGenTweaksUtils.getIDFromGenerator(generator)
        if genID > -1 then
            local branchID = ISGenTweaksUtils.getBranchFromGeneratorID(branches, genID)
            local branchMode = ISGenTweaksUtils.getBranchModeFromID(branches[branchID])
            local branchTotal = ISGenTweaksUtils.getBranchTotalPowerFromID(branches[branchID])
            local branchEach = ISGenTweaksUtils.getBranchEachPowerFromTotal(branches[branchID].share, branchTotal)
            local shareSetting = ISGenTweaksUtils.getShareSetting(branches[branchID].share)
            local correctedPower = ISGenTweaksUtils.roundNumber(ISGenTweaksPowerSet.calculateTotalPower(generator), 2)
            local currentPower = ISGenTweaksUtils.roundNumber(generator:getTotalPowerUsing(), 2)
            local isActivated = generator:isActivated()

            if shareSetting == 0 then
                if (currentPower ~= correctedPower) and isActivated then
                    text = text .. " " .. getText("IGUI_GenTweaks_NeedsCorrection")
                end
                --BranchInfo
                text = text .. " <LINE><LINE> <INDENT:0> "
                text = text .. getText("IGUI_GenTweaks_BranchInfo", branchID)
                text = text .. " <LINE> <INDENT:10> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalGen", branchTotal.count) .. " <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalPower", ISGenTweaksUtils.roundNumber(branchTotal.total, 2)) .. " L/h <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchMode") .. branchMode
            elseif shareSetting == 1 then
                if (currentPower ~= ISGenTweaksUtils.roundNumber(branchEach, 2)) and isActivated then
                    text = text .. " " .. getText("IGUI_GenTweaks_NeedsCorrection")
                end
                --BranchInfo
                text = text .. " <LINE><LINE> <INDENT:0> "
                text = text .. getText("IGUI_GenTweaks_BranchInfo", branchID)
                text = text .. " <LINE> <INDENT:10> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalGen", branchTotal.count) .. " <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalPower", ISGenTweaksUtils.roundNumber(branchTotal.total, 2)) .. " L/h <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchMode") .. branchMode

            elseif shareSetting == 2 then
                local isFocusPower = genID == branches[branchID].share and ISGenTweaksUtils.roundNumber(branchTotal.total, 2) or 0
                if (currentPower ~= isFocusPower) and isActivated then
                    text = text .. " " .. getText("IGUI_GenTweaks_NeedsCorrection")
                end
                --BranchInfo
                text = text .. " <LINE><LINE> <INDENT:0> "
                text = text .. getText("IGUI_GenTweaks_BranchInfo", branchID)
                text = text .. " <LINE> <INDENT:10> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalGen", branchTotal.count) .. " <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchTotalPower", ISGenTweaksUtils.roundNumber(branchTotal.total, 2)) .. " L/h <LINE> "
                text = text .. getText("IGUI_GenTweaks_BranchMode") .. branchMode
                text = text .. " <LINE> " .. getText("IGUI_GenTweaks_PowerFocusGen", branches[branchID].share)
            end
        else
            text = text .. " <LINE><LINE><INDENT:0> " .. colors.bad .. getText("IGUI_GenTweaks_NotInModData")
        end
    end
    return text
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksOverride