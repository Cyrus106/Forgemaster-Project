mods.Forgemaster.invisibleShip=false


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER,
function()
  if mods.Forgemaster.invisibleShip then --if you want to tie this to a game variable just do
                                        --if Hyperspace.ships.player:HasEquipment("game_variable_name")
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_Scale(0, 0, 0)
  end
end,
function()
  if mods.Forgemaster.invisibleShip then--if you want to tie this to a game variable just do
                                        --if Hyperspace.ships.player:HasEquipment("game_variable_name")
    Graphics.CSurface.GL_PopMatrix()
  end
end)
