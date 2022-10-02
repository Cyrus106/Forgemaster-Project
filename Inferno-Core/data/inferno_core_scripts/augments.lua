--[[
script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
    local systems=nil
    if pcall(function() systems=Hyperspace.ships.player.vSystemList end) then
      systems=Hyperspace.ships.player.vSystemList
    end

    if systems then
      local boost=math.floor(Hyperspace.ships.player:GetAugmentationValue("SKILLED_MANNING"))
      boost=math.min(boost,3)
      for system in mods.inferno.vter(systems) do
        system.iActiveManned=math.max(boost,system.iActiveManned)
        system.computerLevel=math.max(boost,system.computerLevel)
        if not system.bManned then system.bManned=(boost>=1) end
      end
    end
end)
--]]
script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  if pcall(function() local _=Hyperspace.ships.player.cloneSystem.fTimeToClone end) then
    local increment=Hyperspace.FPS.SpeedFactor/16
    local modifier=2^Hyperspace.ships.player:GetAugmentationValue("CLONE_SPEED") --Negative values make the duration shorter, longer values make it longer.
    Hyperspace.ships.player.cloneSystem.fTimeToClone=Hyperspace.ships.player.cloneSystem.fTimeToClone+((modifier-1)*increment)
  end
end)
