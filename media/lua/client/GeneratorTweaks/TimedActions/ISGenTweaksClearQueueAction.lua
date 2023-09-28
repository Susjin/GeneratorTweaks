require "TimedActions/ISBaseTimedAction"
----------------------------------------------------------------------------------------------
---	Generator Tweaks
---	@author: peteR_pg
---	Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/GeneratorTweaks

---	All the methods related to the ClearQueue action
---	@class ISGenTweaksClearQueueAction : ISBaseTimedAction
--- @field character IsoPlayer The player clearing queue
---	@return ISGenTweaksClearQueueAction
local ISGenTweaksClearQueueAction = ISBaseTimedAction:derive("ISGenTweaksClearQueueAction")
----------------------------------------------------------------------------------------------

function ISGenTweaksClearQueueAction:isValid()
    return true
end

function ISGenTweaksClearQueueAction:update()

end

function ISGenTweaksClearQueueAction:start()

end

function ISGenTweaksClearQueueAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISGenTweaksClearQueueAction:perform()
    --Ending Action
    ISBaseTimedAction.perform(self)
    ISTimedActionQueue.clear(self.character)
end

---Starts the ClearQueue TimedAction
---@param character IsoPlayer The player doing the action
---@return ISGenTweaksClearQueueAction
function ISGenTweaksClearQueueAction:new(character)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.useProgressBar = false
    o.maxTime = 1

    return o
end

------------------ Returning file for 'require' ------------------
return ISGenTweaksClearQueueAction