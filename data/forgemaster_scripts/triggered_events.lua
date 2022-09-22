script.on_game_event("FMCORE_ONCREWZERO",false,
function()
  if Hyperspace.ships.enemy and not Hyperspace.ships.enemy.bAutomated then --ok to check if Hyperspace.ships.enemy because it's not ON_TICK
    Hyperspace.ships.enemy:AddAugmentation("HIDDEN FM_PURGE_AUG")--no idea if enemies have augment slots or not
      if Hyperspace.ships.player:HasEquipment("gbgozer_player")>0 then
        Hyperspace.ships.enemy:AddAugmentation("HIDDEN TWISTED_KESTREL_GHOST_PURGE")
      end
  end
end)
