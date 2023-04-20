local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt

script.on_render_event(Defines.RenderEvents.LAYER_PLAYER,
function()
  if Hyperspace.ships.player:HasEquipment("fm_invisible_ship") > 0 then
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_Scale(0, 0, 0)
  end
end,
function()
  if Hyperspace.ships.player:HasEquipment("fm_invisible_ship") > 0 then
    Graphics.CSurface.GL_PopMatrix()
  end
end)
