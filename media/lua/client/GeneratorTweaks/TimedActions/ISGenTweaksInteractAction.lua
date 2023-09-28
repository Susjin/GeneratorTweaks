require "TimedActions/ISBaseTimedAction"
----------------------------------------------------------------------------------------------
--- Generator Tweaks
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

--- All the methods related to the Generator Interactions
--- @class ISGenTweaksInteractAction : ISBaseTimedAction
--- @field character IsoPlayer The player doing the action
--- @field screwdriver HandWeapon Screwdriver used in the action
--- @field actionCommand string Interaction to be executed
--- @field generator IsoGenerator Generator being interacted with
--- @field share number Branch setting 'share' value to be set in the branch
--- @field genID number ID of the Generator being interacted with
--- @return ISGenTweaksInteractAction
local ISGenTweaksInteractAction = ISBaseTimedAction:derive("ISGenTweaksInteractAction")
----------------------------------------------------------------------------------------------
--Setting up locals
local ISGenTweaksUtils = require "GeneratorTweaks/ISGenTweaksUtils"
local ISGenTweaksPowerShare = require "GeneratorTweaks/ISGenTweaksPowerShare"
local isSP = (isClient() == false) and (isServer() == false)

local textsTypes = {
    branchSetting = {
        getText("ContextMenu_GenTweaks_Disable"),
        getText("ContextMenu_GenTweaks_Split"),
        getText("ContextMenu_GenTweaks_Focus")
    },
    addToSystem = getText("ContextMenu_GenTweaks_AddToSystem"),
    removeFromSystem = getText("ContextMenu_GenTweaks_RemoveFromSystem")
}
local timeSetting = {
    branchSetting = 50,
    addToSystem = 200,
    removeFromSystem = 200
}

local function predicateScrewdriver(screwdriver, player)
    return (screwdriver and (screwdriver:getType() == "Screwdriver") or false) and
            (screwdriver and player:getInventory():contains(screwdriver) or false) and
             (screwdriver and (not screwdriver:isBroken()) or false)
end


function ISGenTweaksInteractAction:isValid()
    local needWire = self.actionCommand == "addToSystem" and self.character:getInventory():containsTypeRecurse("ElectricWire") or true

    return predicateScrewdriver(self.screwdriver, self.character) and
            self.generator:getObjectIndex() ~= -1 and needWire
end

function ISGenTweaksInteractAction:update()
    self.character:faceThisObject(self.generator)
    self.character:setMetabolicTarget(Metabolics.UsingTools)

    self.screwdriver:setJobDelta(self:getJobDelta())
end

function ISGenTweaksInteractAction:waitToStart()
    self.character:faceThisObject(self.generator)
    return self.character:shouldBeTurning()
end

function ISGenTweaksInteractAction:start()
    if self.actionCommand == "branchSetting" then
        self.screwdriver:setJobType(textsTypes[self.actionCommand][(ISGenTweaksUtils.getShareSetting(self.share))+1]) -- HACK to get the correct text
    else
        self.screwdriver:setJobType(textsTypes[self.actionCommand])
    end

    self:setOverrideHandModels(self.screwdriver, nil)
    self:setActionAnim("Loot")
    self.character:SetVariable("LootPosition", "Low")
    self.character:reportEvent("EventLootItem")
    self.sound = self.character:playSound("GeneratorConnect")
end

function ISGenTweaksInteractAction:stopSound()
    if self.sound and self.character:getEmitter():isPlaying(self.sound) then
        self.character:stopOrTriggerSound(self.sound)
    end
end

function ISGenTweaksInteractAction:stop()
    self.screwdriver:setJobDelta(0.0)
    self:stopSound()
    ISBaseTimedAction.stop(self)
end

function ISGenTweaksInteractAction:perform()
    self.screwdriver:setJobDelta(0.0)
    self:stopSound()

    ISGenTweaksUtils.debugMessage(self.actionCommand)

    if self.actionCommand == "branchSetting" then
        if isSP then
            ISGenTweaksUtils.setBranchSetting(self.genID, self.share)
        else
            sendClientCommand("GenTweaks", self.actionCommand, {genID = self.genID, share = self.share})
        end

        local branchID = ISGenTweaksUtils.getBranchIDFromGeneratorID(self.genID)
        local haloColor = self.share == -1 and HaloTextHelper.getColorRed() or HaloTextHelper.getColorGreen()
        HaloTextHelper.addText(self.character, getText("IGUI_GenTweaks_SettingsApplied", branchID), haloColor)
    elseif self.actionCommand == "addToSystem" then
        local electricWire = self.character:getInventory():getItemFromTypeRecurse("ElectricWire")
        electricWire:getContainer():Remove(electricWire)

        if isSP then
            ISGenTweaksUtils.setIsOnBranchSystem(self.genID, true)
            ISGenTweaksPowerShare.createAllBranches()
        else
            sendClientCommand("GenTweaks", self.actionCommand, {genID = self.genID})
        end
        HaloTextHelper.addText(self.character, getText("IGUI_GenTweaks_AddedToSystem"), HaloTextHelper.getColorGreen())
    elseif self.actionCommand == "removeFromSystem" then
        self.character:getInventory():AddItem("Radio.ElectricWire")

        if isSP then
            ISGenTweaksUtils.setIsOnBranchSystem(self.genID, false)
            ISGenTweaksPowerShare.createAllBranches()
        else
            sendClientCommand("GenTweaks", self.actionCommand, {genID = self.genID})
        end
        HaloTextHelper.addText(self.character, getText("IGUI_GenTweaks_RemovedFromSystem"), HaloTextHelper.getColorRed())
    end

    --Finish TimedAction
    ISInventoryPage.dirtyUI() --Refresh inventory
    ISBaseTimedAction.perform(self)
end

---Starts a generator interaction TimedAction
---@param character IsoPlayer The player doing the action
---@param screwdriver InventoryItem Screwdriver used in the action
---@param actionCommand string Interaction to be executed
---@param generator IsoGenerator Generator being interacted with
---@param share number Branch setting 'share' value to be set in the branch
---@return ISGenTweaksInteractAction
function ISGenTweaksInteractAction:new(character, screwdriver, actionCommand, generator, share)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.screwdriver = screwdriver
    o.actionCommand = actionCommand
    o.generator = generator
    o.share = share
    o.genID = ISGenTweaksUtils.getIDFromGenerator(generator)
    o.maxTime = timeSetting[actionCommand] - (character:getPerkLevel(Perks.Electricity) * 3)
    if character:isTimedActionInstant() then o.maxTime = 10 end

    return o
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksInteractAction