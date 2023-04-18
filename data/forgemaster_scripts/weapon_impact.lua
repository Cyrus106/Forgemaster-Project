-- Make photon-like guns pop shields
local popWeapons = {
  FM_LASER_PHOTON = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_2 = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_ENEMY = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_2_ENEMY = {count = 1, countSuper = 1},
  FM_CHAINGUN_FIRE = {count = 1, countSuper = 1},
  FM_GATLING_ANCIENT_PHOTON = {count = 1, countSuper = 1},
}

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(shipManager, projectile, damage, response)
    local shieldPower = shipManager.shieldSystem.shields.power
    local popData = nil
    if pcall(function() popData = popWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end) and popData then
        if shieldPower.super.first > 0 then
            if popData.countSuper > 0 then
                shipManager.shieldSystem:CollisionReal(projectile.position.x, projectile.position.y, Hyperspace.Damage(), true)
                shieldPower.super.first = math.max(0, shieldPower.super.first - popData.countSuper)
            end
        else
            shipManager.shieldSystem:CollisionReal(projectile.position.x, projectile.position.y, Hyperspace.Damage(), true)
            shieldPower.first = math.max(0, shieldPower.first - popData.count)
        end
    end
end)

-- Weapons that do extra damage of a certain type on room hit
local function Damage(table)
    local ret = Hyperspace.Damage()
    ret.iDamage = table.hull or 0 
		ret.iIonDamage = table.ion or 0 
		ret.iSystemDamage = table.system or 0 
    return ret
end

--Implementation: On hit, this damage is applied for projectile weapons. It is applied per-tile for beam weapons.
local roomDamageWeapons = {
  FM_PULSEDEEP = Damage {ion = 2},
  FM_BEAM_EXPLOSION = Damage {hull = 1},
  FM_BEAM_EXPLOSION_PLAYER = Damage {hull = 1},
  FM_BEAM_EXPLOSION_EGG = Damage {hull = 1},
  FM_BEAM_ION_PIRCE = Damage {ion = 1},
  FM_FOCUS_ENERGY = Damage {ion = 2},
  FM_FOCUS_ENERGY_2 = Damage {ion = 3},
  FM_FOCUS_ENERGY_2_PLAYER = Damage {ion = 3},
  FM_FOCUS_ENERGY_3 = Damage {ion = 4},
  FM_FOCUS_ENERGY_CONS = Damage {ion = 2},
  FM_MISSILES_STUN_CLOAK = Damage {ion = 3},
  FM_MISSILES_STUN_CLOAK_PLAYER = Damage {ion = 3},
  FM_MISSILES_STUN_CLOAK_MEGA = Damage {ion = 3},
  FM_FORGEMAN_DRONE_WEAPON = Damage {hull = 1},
  FM_RVS_AC_CHARGE_EMP = Damage {ion = 1},
  FM_BEAM_EXPLOSION_ENEMY = Damage {ion = 1},
  FM_BEAM_ION_PIERCE_ENEMY = Damage {ion = 1},
  FM_FOCUS_ENERGY_ENEMY = Damage {ion = 2},
  FM_FOCUS_ENERGY_2_ENEMY =  Damage {ion = 3},
  FM_FOCUS_ENERGY_3_ENEMY = Damage {ion = 4},
}

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, location, damage, shipFriendlyFire)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage then
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    ship:DamageArea(projectile.position, roomDamage, true)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage and beamHitType == Defines.BeamHit.NEW_TILE then
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    local farPoint = Hyperspace.Pointf(-2147483648, -2147483648)
    ShipManager:DamageBeam(Location, farPoint, roomDamage)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end
  return Defines.Chain.CONTINUE, beamHitType
end)
