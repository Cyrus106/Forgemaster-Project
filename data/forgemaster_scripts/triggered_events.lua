local vter = mods.fusion.vter
local real_projectile = mods.fusion.real_projectile
local randomInt = mods.fusion.randomInt

--[[script.on_game_event("FUSION_ONCREWZERO", false,
function()
  if Hyperspace.ships.enemy and not Hyperspace.ships.enemy.bAutomated then 
    Hyperspace.ships.enemy:AddAugmentation("HIDDEN FM_PURGE_AUG")
      if Hyperspace.ships.player:HasEquipment("gbgozer_player") > 0 then
        Hyperspace.ships.enemy:AddAugmentation("HIDDEN TWISTED_KESTREL_GHOST_PURGE")
      end
  end
end)--]]

script.on_game_event("FM_BOSS_KES1_SUICIDE", false,
function()
  for artillery in vter(Hyperspace.ships.player.artillerySystems) do
    artillery:SetPowerCap(0)
  end
end)
