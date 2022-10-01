mods.inferno.weapon_functions:append({
  function(weapon,projectile)
    if weapon.name=="'Multiplicity' Barrage Laser" then
      local projectile_number=(weapon.numShots-weapon.queuedProjectiles:size())%weapon.numShots --modulus for when weapon fires fast enough to queue mroe shots
        if projectile_number<=5 then --projectiles that aim towards the targetted system, change visual here when possible

        elseif projectile_number<=12 then --make seven projectiles hit a random system
          local sys_list=Hyperspace.ships.enemy.vSystemList
          local system_target=sys_list[Hyperspace.random32()%sys_list:size()]
          projectile.target=system_target.location
        else  --make the rest hit a random room
          projectile.target=Hyperspace.ships.enemy:GetRandomRoomCenter()
        end
        projectile.entryAngle=-1 --Sets it to randomize on entry
    end
  end,
})
