local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt


script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
function(ship, weapon, projectile)
  if ship:GetAugmentationValue("WEAPON_LOCKDOWN") > 0 and real_projectile(projectile) then 
    projectile.damage.bLockdown = true
  end
end)

local function beam_pierce(ship, _, projectile)
  local beam_pierce_modifier = ship:GetAugmentationValue("AUG_BEAM_PIERCE")
  if projectile:GetType() == 5 then
    --conditional fix for weapons with negative damage and nonnegative shield piercing
    if projectile.damage.iShieldPiercing >= 0 then
      projectile.damage.iShieldPiercing = math.max(projectile.damage.iShieldPiercing, 1 - projectile.damage.iDamage)
    end
    projectile.damage.iShieldPiercing = projectile.damage.iShieldPiercing + beam_pierce_modifier
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, beam_pierce)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, beam_pierce)

local function GetRandomPoint(center, radius)
  local radius = radius * (Hyperspace.random32() / 2147483647)
  local angle = 2 * math.pi * (Hyperspace.random32() / 2147483647)
  local x = center.x + radius * math.cos(angle)
  local y = center.y + radius * math.sin(angle)
  return x, y
end


--Weapon radius reduction

if getmetatable(Hyperspace.WeaponBlueprint)['.instance']['.get']['radius'] then --if WeaponBlueprint::radius is accessible.

  script.on_fire_event(Defines.FireEvents.WEAPON_FIRE,
  function(ship, weapon, projectile)
    if ship:HasAugmentation("RADIUS_REDUCTION") > 0 then
      projectile.target.x, projectile.target.y = GetRandomPoint(weapon.lastTargets[0], weapon.radius)
    end
  end)

  script.on_internal_event(Defines.InternalEvents.ON_TICK,
  function()
    for i = 0, 1 do 
      local ShipManager = Hyperspace.Global.GetInstance():GetShipManager(i)
      if ShipManager then
        weaponSystem = ShipManager.weaponSystem
        if weaponSystem then
          for weapon in vter(weaponSystem.weapons) do
            weapon.radius = math.max(0, weapon.blueprint.radius - ShipManager:GetAugmentationValue("RADIUS_REDUCTION"))
          end
        end
      end
    end
  end)

end