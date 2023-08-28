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
        context:addOption("Check Radius", generator, ISGenTweaksPowerShare.checkRadius, player)
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISGenTweaksUtils.onContextMenu)

------------------ Returning file for 'require' ------------------
return ISGenTweaksContextMenu