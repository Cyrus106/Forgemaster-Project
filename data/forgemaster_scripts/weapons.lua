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

-- Wapons that do extra damage of a certain type on room hit
local function Damage(table)
    local ret = Hyperspace.Damage()
    ret.iDamage = table.hull or 0 
		ret.iIonDamage = table.ion or 0 
		ret.iSystemDamage = table.system or 0 
    return ret
end

--TODO: Supply proper implementation for beams and pinpoint using the DAMAGE_BEAM callback. (Either add a tileDamageWeapons table or restructure this)
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

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, damage, response)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage then
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    ship:DamageArea(projectile.position, roomDamage, true)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end
end)
