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
        if shieldPower.super.first <= 0 then
            shipManager.shieldSystem:CollisionReal(projectile.position.x, projectile.position.y, Hyperspace.Damage(), true)
            shieldPower.first = math.max(0, shieldPower.first - popData.count)
        end
    end
    return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(shipManager, projectile, damage, response)
  local shieldPower = shipManager.shieldSystem.shields.power
  local popData = nil
  if pcall(function() popData = popWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end) and popData and shieldPower.super.first > 0 then
      damage.iDamage = damage.iDamage + popData.countSuper
  end
  return Defines.Chain.CONTINUE
end)

-- Weapons that do extra damage of a certain type on room hit



local roomDamageWeapons = {
  FM_PULSEDEEP = {ion = 2},
  FM_MISSILES_CLOAK_STUN = {ion = 3},
  FM_MISSILES_CLOAK_STUN_PLAYER = {ion = 3},
  FM_MISSILES_CLOAK_STUN_MEGA = {ion = 3},
  FM_FORGEMAN_DRONE_WEAPON = {hull = 1},
  FM_RVS_AC_CHARGE_EMP = {ion = 1},
}

local function Damage(table)
  local ret = Hyperspace.Damage()
  ret.iDamage = table.hull or 0 
  ret.iIonDamage = table.ion or 0 
  ret.iSystemDamage = table.system or 0 
  return ret
end

local tileDamageWeapons = {
  FM_BEAM_ION_PIERCE = Damage {ion = 1},
  FM_FOCUS_ENERGY = Damage {ion = 2},
  FM_FOCUS_ENERGY_2 = Damage {ion = 3},
  FM_FOCUS_ENERGY_2_PLAYER = Damage {ion = 3},
  FM_FOCUS_ENERGY_3 = Damage {ion = 4},
  FM_FOCUS_ENERGY_CONS = Damage {ion = 2},
  FM_BEAM_ION_PIERCE_ENEMY = Damage {ion = 1},
  FM_FOCUS_ENERGY_ENEMY = Damage {ion = 2},
  FM_FOCUS_ENERGY_2_ENEMY =  Damage {ion = 3},
  FM_FOCUS_ENERGY_3_ENEMY = Damage {ion = 4},
}


script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(ship, projectile, location, damage, forceHit, shipFriendlyFire)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage then
    damage.iDamage = damage.iDamage + (roomDamage.hull or 0)
    damage.iIonDamage = damage.iIonDamage + (roomDamage.ion or 0)
  end
  return Defines.CHAIN_CONTINUE, forceHit, shipFriendlyFire
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  local tileDamage
  pcall(function() tileDamage = tileDamageWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
  if tileDamage and beamHitType ~= Defines.BeamHit.SAME_TILE then
    local weaponName = Hyperspace.Get_Projectile_Extend(Projectile).name
    Hyperspace.Get_Projectile_Extend(Projectile).name = ""
    local farPoint = Hyperspace.Pointf(-2147483648, -2147483648)
    ShipManager:DamageBeam(Location, farPoint, tileDamage)
    Hyperspace.Get_Projectile_Extend(Projectile).name = weaponName
  end
  return Defines.Chain.CONTINUE, beamHitType
end)


local bombBeams = {
  --[[
  FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_BOMB",
  FM_BEAM_EXPLOSION_PLAYER = "FM_BEAM_EXPLOSION_BOMB",
  FM_BEAM_EXPLOSION_EGG = "FM_BEAM_EXPLOSION_BOMB",
  FM_BEAM_EXPLOSION_ENEMY = "FM_BEAM_EXPLOSION_BOMB",
  --]]
}

--Tile based bombs
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  local bomb
  pcall(function() bomb = bombBeams[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
  if beamHitType ~= Defines.BeamHit.SAME_TILE and bomb then
    local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
    local blueprint = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(bomb)
    local bombOwner = (ShipManager.iShipId + 1) % 2
    local target = Hyperspace.Pointf(Location.x // 35 * 35 + 17.5, Location.y // 35 * 35 + 17.5)
    local targetSpace = ShipManager.iShipId
    if Hyperspace.ShipGraph.GetShipInfo(targetSpace):GetSelectedRoom(target.x, target.y, true) ~= -1 then
      SpaceManager:CreateBomb(blueprint, bombOwner, target, targetSpace)
    end
  end
end)

local impactBeams = {
  FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_LASER",
  FM_BEAM_EXPLOSION_PLAYER = "FM_BEAM_EXPLOSION_LASER",
  FM_BEAM_EXPLOSION_EGG = "FM_BEAM_EXPLOSION_LASER",
  FM_BEAM_EXPLOSION_ENEMY = "FM_BEAM_EXPLOSION_LASER",
  FM_FORGEMAN_DRONE_WEAPON = "FM_BEAM_EXPLOSION_LASER"
}

--Instant Impact (Until accuracy stats are exposed, please ensure all weapons used in impactBeams have accuracy 100)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  local impact
  pcall(function() impact = impactBeams[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
  if beamHitType ~= Defines.BeamHit.SAME_TILE and impact then
    local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
    local blueprint = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(impact)
    local impactOwner = (ShipManager.iShipId + 1) % 2
    local target = Hyperspace.Pointf(Location.x // 35 * 35 + 17.5, Location.y // 35 * 35 + 17.5)
    local targetSpace = ShipManager.iShipId
    if Hyperspace.ShipGraph.GetShipInfo(targetSpace):GetSelectedRoom(target.x, target.y, true) ~= -1 then
      SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
    end
  end
end)