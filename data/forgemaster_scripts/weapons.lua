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
local popWeapons = {}
popWeapons["FM_LASER_PHOTON"] = {
  count = 1,
  countSuper = 1
}
popWeapons["FM_LASER_PHOTON_2"] = {
  count = 1,
  countSuper = 1
}
popWeapons["FM_LASER_PHOTON_ENEMY"] = {
  count = 1,
  countSuper = 1
}
popWeapons["FM_LASER_PHOTON_2_ENEMY"] = {
  count = 1,
  countSuper = 1
}
popWeapons["FM_CHAINGUN_FIRE"] = {
  count = 1,
  countSuper = 1
}
popWeapons["FM_GATLING_ANCIENT_PHOTON"] = {
  count = 1,
  countSuper = 1
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
local roomDamageWeapons = {}
roomDamageWeapons["FM_PULSEDEEP"] = {
  ion = 2, hull=0
}
roomDamageWeapons["FM_BEAM_EXPLOSION"] = {
  ion =0, hull = 1
}
roomDamageWeapons["FM_BEAM_EXPLOSION_PLAYER"] = {
  ion =0, hull = 1
}
roomDamageWeapons["FM_BEAM_EXPLOSION_EGG"] = {
  ion =0, hull = 1
}
roomDamageWeapons["FM_BEAM_ION_PIRCE"] = {
  ion = 1, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY"] = {
  ion = 2, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_2"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_2_PLAYER"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_3"] = {
  ion = 4, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_CONS"] = {
  ion = 2, hull=0
}
roomDamageWeapons["FM_MISSILES_CLOAK_STUN"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_MISSILES_CLOAK_STUN_PLAYER"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_MISSILES_CLOAK_STUN_MEGA"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_FORGEMAN_DRONE_WEAPON"] = {
  hull = 1, ion=0
}
roomDamageWeapons["FM_RVS_AC_CHARGE_EMP"] = {
  ion = 1, hull=0
}
roomDamageWeapons["FM_BEAM_EXPLOSION_ENEMY"] = {
  ion =0, hull = 1
}
roomDamageWeapons["FM_BEAM_ION_PIRCE_ENEMY"] = {
  ion = 1, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_ENEMY"] = {
  ion = 2, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_2_ENEMY"] = {
  ion = 3, hull=0
}
roomDamageWeapons["FM_FOCUS_ENERGY_3_ENEMY"] = {
  ion = 4, hull=0
}
roomDamageWeapons["ROYAL_LASER"] = {
  ion =0, hull = 1
}
roomDamageWeapons["ROYAL_LASER_WRECK"] = {
  ion =1, hull = 1
}

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(ship, projectile, location, damage, forceHit, shipFriendlyFire)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage then
    damage.iIonDamage = damage.iIonDamage + roomDamage.ion
    log("hulldmg"..damage.iDamage)
    log("iondmg"..damage.iIonDamage)
  end
  return Defines.CHAIN_CONTINUE, forceHit, shipFriendlyFire
--[[
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ship, projectile, damage, response)
  local hullDmgAmount = nil --extra damage inflicted when hitting a room
  local ionDmgAmount = nil  --extra ion inflicted when hitting a room
  local roomDamageWeapon = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name]
  
  pcall(function() hullDmgAmount = roomDamageWeapon.hull end)
  pcall(function() ionDmgAmount = roomDamageWeapon.ion end)
  if hullDmgAmount or ionDmgAmount then
    local extraRoomDamageHit = Hyperspace.Damage()
    extraRoomDamageHit.iDamage = hullDmgAmount
    extraRoomDamageHit.iIonDamage = ionDmgAmount
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    ship:DamageArea(projectile.position, extraRoomDamageHit, true)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end--]]
  --[[
  if pcall(function() hullDmgAmount = roomDamageWeapon.hull end) and hullDmgAmount then
    local extraRoomDamageHit = Hyperspace.Damage()
    extraRoomDamageHit.iDamage = hullDmgAmount
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    ship:DamageArea(projectile.position, extraRoomDamageHit, true)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end
  if pcall(function() ionDmgAmount = roomDamageWeapon.ion end) and ionDmgAmount then
    local extraRoomDamageHit = Hyperspace.Damage()
    extraRoomDamageHit.iIonDamage = ionDmgAmount
    local weaponName = Hyperspace.Get_Projectile_Extend(projectile).name
    Hyperspace.Get_Projectile_Extend(projectile).name = ""
    ship:DamageArea(projectile.position, extraRoomDamageHit, true)
    Hyperspace.Get_Projectile_Extend(projectile).name = weaponName
  end--]]
  --[[
    --if ionDmgAmount == nil and hullDmgAmount == nil then
    local doExtrahit = 0 --checks if the extra dmg hit should be done
    if hullDmgAmount then
      extraRoomDamageHit.iDamage = hullDmgAmount
      doExtrahit = 1
    end
    if ionDmgAmount then
      doExtrahit = 1
    end
    if doExtrahit==1 then
      
      doExtrahit = 0
    end]]
  --end
end)
