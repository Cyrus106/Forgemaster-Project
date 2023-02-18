local vter = mods.inferno.vter
local getLimitAmount = mods.inferno.getLimitAmount
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  local otherShipId = (ship.iShipId + 1) % 2
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
  end
end)


script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  if weapon.name == "Charge Sniper" then
    local boost = weapon.queuedProjectiles:size()
    projectile.damage.iDamage = projectile.damage.iDamage + (2 * boost)
    projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + boost
    projectile.speed_magnitude = projectile.speed_magnitude * (1 + (boost / 2))
    projectile.damage.breachChance = math.floor(2.5 * (boost + 1))
    for i = 1, boost do
      weapon.queuedProjectiles[i - 1]:Kill()
    end
  end
end)


