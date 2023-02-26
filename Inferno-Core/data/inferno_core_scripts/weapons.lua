local vter = mods.inferno.vter
local getLimitAmount = mods.inferno.getLimitAmount
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt


script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  if ship:GetAugmentationValue("WEAPON_LOCKDOWN") > 0 and real_projectile(projectile) then 
    projectile.damage.bLockdown = true
  end
end)


script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  local beam_pierce_modifier = ship:GetAugmentationValue("AUG_BEAM_PIERCE")
  if projectile:GetType() == 5 then
    --conditional fix for weapons with negative damage and nonnegative shield piercing
    if projectile.damage.iShieldPiercing >= 0 then
      projectile.damage.iShieldPiercing = math.max(projectile.damage.iShieldPiercing, 1 - projectile.damage.iDamage)
    end
    projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + beam_pierce_modifier
  end
end)