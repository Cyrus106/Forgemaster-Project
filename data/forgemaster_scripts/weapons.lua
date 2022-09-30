mods.inferno.weapon_functions:append({
  function(weapon,projectile)
    if weapon.name=="'Multiplicity' Barrage Laser" then
      local count=weapon.queuedProjectiles:size()
      for i=0,count-1 do
        local proj=weapon.queuedProjectiles[i]
        if i<5 then--make five projectiles hit the targeted system
          proj.target=projectile.target
        elseif i<12 then --make seven projectiles hit a random system
          local sys_list=Hyperspace.ships.enemy.vSystemList
          local system_target=sys_list[Hyperspace.random32()%sys_list:size()]
          proj.target=system_target.location
        else  --make the rest hit a random room
          proj.target=Hyperspace.ships.enemy:GetRandomRoomCenter()
        end
        proj.entryAngle=-1 --Sets it to randomize on entry
      end
    end
  end,
})
