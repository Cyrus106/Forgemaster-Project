local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt

local redShot = Hyperspace.Resources:GetImageId "weapon_projectiles/fm_surge_laser_proj_red.png"
local blueShot = Hyperspace.Resources:GetImageId "weapon_projectiles/fm_surge_laser_proj_blue.png"

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE,
function(projectile, weapon)
  local otherShip = Hyperspace.Global.GetInstance():GetShipManager(1 - projectile:GetOwnerId())
  if weapon.blueprint.name == "FM_SURGE_LASER" then
    local projectile_number = (weapon.numShots - weapon.queuedProjectiles:size()) % weapon.numShots --modulus for when weapon fires fast enough to queue more shots
      if projectile_number <= 5 then --projectiles that aim towards the targetted system
        projectile.flight_animation.animationStrip = redShot
        projectile.speed_magnitude = projectile.speed_magnitude * 1.4
      elseif projectile_number <= 12 then --make seven projectiles hit a random system
        local sys_list = otherShip.vSystemList
        local system_target = sys_list[Hyperspace.random32() % sys_list:size()]
        projectile.target = system_target.location
        projectile.flight_animation.animationStrip = blueShot
        projectile.speed_magnitude = projectile.speed_magnitude * 1.2
      else  --make the rest hit a random room
        projectile.target = otherShip:GetRandomRoomCenter()
      end
      projectile.entryAngle = -1 --Sets it to randomize on entry
      --Randomize positions of projectiles into a visual cluster
      projectile.position.x = projectile.position.x + randomInt(-12, 12)
      projectile.position.y = projectile.position.y + randomInt(-7, 7)
  end

  return Defines.Chain.CONTINUE
end)

local shotTextures = {
  [0] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_1.png",
  [1] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_2.png",
  [2] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_3.png",
  [3] = Hyperspace.Resources:GetImageId "weapon_projectiles/charge_sniper_4.png",
}
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE,
function(projectile, weapon)
  if weapon.blueprint.name == "FM_CHARGE_SNIPER" then
    local boost = weapon.queuedProjectiles:size() --gets how many projectiles are charged up (i think this doesn't include the one that got already shot)
    projectile.damage.iDamage = projectile.damage.iDamage + (2 * boost) --increasing damage based on boost (following line same but for other stats)
    projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + boost
    projectile.speed_magnitude = projectile.speed_magnitude * (1 + (boost / 2))
    projectile.damage.breachChance = math.floor(2.5 * (boost + 1))
    weapon.queuedProjectiles:clear() -- delete all the other projectiles
    projectile.flight_animation.animationStrip = shotTextures[boost] -- sets the projectile to look diffrently based on boost
  end
end)