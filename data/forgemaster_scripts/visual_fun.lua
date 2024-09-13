local vter = mods.fusion.vter
local real_projectile = mods.fusion.real_projectile
local randomInt = mods.fusion.randomInt

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
