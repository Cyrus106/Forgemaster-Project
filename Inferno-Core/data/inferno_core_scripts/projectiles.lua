
--[[
script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  if pcall(function() local _=Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles end) then
    for projectile in mods.inferno.vter(Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles) do

    end
  end
end
)
--]]
