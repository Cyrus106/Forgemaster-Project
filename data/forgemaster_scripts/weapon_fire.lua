local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt



script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  local otherShipId = 1 - ship.iShipId
  local otherShip = Hyperspace.Global.GetInstance():GetShipManager(otherShipId)
  if weapon.name == "'Multiplicity' Barrage Laser" then
    local projectile_number = (weapon.numShots - weapon.queuedProjectiles:size())%weapon.numShots --modulus for when weapon fires fast enough to queue more shots
      if projectile_number <= 5 then --projectiles that aim towards the targetted system, change visual here when possible
      elseif projectile_number <= 12 then --make seven projectiles hit a random system
        local sys_list = otherShip.vSystemList
        local system_target = sys_list[Hyperspace.random32() % sys_list:size()]
        projectile.target = system_target.location
      else  --make the rest hit a random room
        projectile.target = otherShip:GetRandomRoomCenter()
      end
      projectile.entryAngle = -1 --Sets it to randomize on entry
      --Randomize positions of projectiles into a visual cluster
      projectile.position.x = projectile.position.x + randomInt(-12, 12)
      projectile.position.y = projectile.position.y + randomInt(-7, 7)
  end
end)

local shotTextures = {
  [0] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_1.png",
  [1] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_2.png",
  [2] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_3.png",
  [3] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_4.png",
}

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  if weapon.blueprint.name == "FM_CHARGE_SNIPER" then
    local boost = weapon.queuedProjectiles:size()
    projectile.damage.iDamage = projectile.damage.iDamage + (2 * boost)
    projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + boost
    projectile.speed_magnitude = projectile.speed_magnitude * (1 + (boost / 2))
    projectile.damage.breachChance = math.floor(2.5 * (boost + 1))
    weapon.queuedProjectiles:clear()
    print(projectile.flight_animation.animationStrip)
    projectile.flight_animation.animationStrip = shotTextures[boost]
    print(projectile.flight_animation.animationStrip)
  end
end)