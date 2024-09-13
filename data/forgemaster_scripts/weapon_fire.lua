local vter = mods.fusion.vter
local real_projectile = mods.fusion.real_projectile
local randomInt = mods.fusion.randomInt

local redShot = Hyperspace.Resources:GetImageId "weapon_projectiles/fm_surge_laser_proj_red.png"
local blueShot = Hyperspace.Resources:GetImageId "weapon_projectiles/fm_surge_laser_proj_blue.png"

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE,
function(projectile, weapon)
  local otherShip = Hyperspace.ships(1 - weapon.iShipId)--projectile:GetOwnerId())
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
      projectile.position.x = projectile.position.x + math.random(-12, 12)
      projectile.position.y = projectile.position.y + math.random(-7, 7)
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

local holyShitProjectiles = {
  "fm_flamethrower_shot",
  "fm_missiles_burst_fire_shot",
  "laser_ancient",
  "ion_heavy",
  "asteroid_proj_2",
  "debris_large_fire",
  "debris_large_electric",
  "debris_large_gold",
  "debris_med_toxic",
  "ponyproj",
  "radiantproj",
  "asteroid_proj_2",
  "crystal_burst_red",
  "energy_purple",
  "laser_heavy",
  "laser_royal",
  "laser_hull",
  "laser_light",
  "laser_ancient",
  "ion_heavy",
  "asteroid_proj_small1",
  "toxicpod",
  "toxicpod",
  "asteroid_proj_2",
  "debris_large_fire",
  "debris_large_electric",
  "debris_large_gold",
  "debris_med_toxic",
  "ponyproj",
  "radiantproj",
  "asteroid_proj_2",
  "crystal_burst_red",
  "energy_purple",
  "laser_heavy",
  "laser_royal",
  "babyorchid",
  "detergent"
}
local animControl = Hyperspace.Animations
local function makeNewDamage(t)
  local dmg = Hyperspace.Damage()
  for k,v in pairs(t) do
    dmg[k] = v
  end
  return dmg
end
local holyShitEffects ={
  {dmg={iDamage=1}},
  {dmg={iIonDamage=1}},
  {dmg={iPersDamage=1}},
  {dmg={iSystemDamage=1}},
  {dmg={fireChance=10}},
  {dmg={breachChance=10}},
  {dmg={iPersDamage=3, iStun=300}},
  {dmg={iDamage=2, iIonDamage=2}},
  {dmg={iDamage=4}},
  {wpn="FM_HOLYSHIT_10"},--beans?
  {wpn="FM_HOLYSHIT_11"},--burning tinybug
  {wpn="FM_HOLYSHIT_12"},--drain o2
  {deathAnim="artillery_cealaformer_explosion"},--nebula thingy (using this anim artillery_cealaformer_explosion)
  {dmg={iDamage=-2,iSystemDamage=-2}},
  {dmg={iDamage=1,iSystemDamage=1,iPersDamage=1,iIonDamage=1}},
  {dmg={iIonDamage=3}},
  {dmg={iPersDamage=3}},
  {dmg={iSystemDamage=3}},
  {wpn="FM_HOLYSHIT_19"},
  {wpn="FM_HOLYSHIT_20"}
}
script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE,
function(projectile, weapon)
    if weapon.blueprint.name == "FM_HOLYSHIT" or weapon.blueprint.name == "FM_HOLYSHIT_INVIS" then
      projectile.flight_animation = animControl:GetAnimation(holyShitProjectiles[math.random(#holyShitProjectiles)])
      local effect=holyShitEffects[math.random(#holyShitEffects)]
      if effect.dmg then
        for k,v in pairs(effect.dmg) do
          projectile.damage[k] = v
        end
        --projectile.Damage = makeNewDamage(effect.dmg)
      end
      if effect.wpn then
        projectile.extend.name = effect.wpn
      end
      if effect.deathAnim then
        projectile.death_animation = animControl:GetAnimation(effect.deathAnim)
      end
      projectile.position.x = projectile.position.x + math.random(-24, 24)
      projectile.position.y = projectile.position.y + math.random(-14, 14)
    end
end)