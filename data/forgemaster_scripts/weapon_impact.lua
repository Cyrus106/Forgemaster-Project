local vter = mods.inferno.vter

-- Make photon-like guns pop shields
local popWeapons = {
  FM_LASER_PHOTON = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_2 = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_ENEMY = {count = 1, countSuper = 1},
  FM_LASER_PHOTON_2_ENEMY = {count = 1, countSuper = 1},
  FM_ARBOREAL_EXE = {count = 2, countSuper = 0}, --Does 3 hull damage, so pops 3 shields and does 3 damage to superShields
  FM_ARBOREAL_REV = {count = 3, countSuper = 3},
  FM_CHAINGUN_FIRE = {count = 1, countSuper = 1},
  FM_GATLING_ANCIENT_PHOTON = {count = 1, countSuper = 1},
}

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(ShipManager, Projectile, Damage, CollisionResponse)
    local shieldPower = ShipManager.shieldSystem.shields.power
    local popData = nil
    if pcall(function() popData = popWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end) and popData then
        if shieldPower.super.first <= 0 and CollisionResponse.damage > Damage.iShieldPiercing then
            ShipManager.shieldSystem:CollisionReal(Projectile.position.x, Projectile.position.y, Hyperspace.Damage(), true)
            shieldPower.first = math.max(0, shieldPower.first - popData.count)
        end
    end
    return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  local shieldPower = ShipManager.shieldSystem.shields.power
  local popData = nil
  if pcall(function() popData = popWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end) and popData and shieldPower.super.first > 0 then
      Damage.iDamage = Damage.iDamage + popData.countSuper
  end
  return Defines.Chain.CONTINUE
end)

-- Weapons that do extra damage of a certain type on room hit



local roomDamageWeapons = {
  FM_PULSEDEEP = {ion = 2},
  FM_MISSILES_CLOAK_STUN = {ion = 3},
  FM_MISSILES_CLOAK_STUN_PLAYER = {ion = 3},
  FM_MISSILES_CLOAK_STUN_MEGA = {ion = 3},
  FM_MISSILES_CLOAK_STUN_ENEMY = {ion = 3},
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
  FM_FOCUS_ENERGY_1 = Damage {ion = 2},
  FM_FOCUS_ENERGY_2 = Damage {ion = 3},
  FM_FOCUS_ENERGY_2_PLAYER = Damage {ion = 3},
  FM_FOCUS_ENERGY_3 = Damage {ion = 4},
  FM_FOCUS_ENERGY_CONS = Damage {ion = 2},
  FM_BEAM_ION_PIERCE_ENEMY = Damage {ion = 1},
  FM_FOCUS_ENERGY_1_ENEMY = Damage {ion = 2},
  FM_FOCUS_ENERGY_2_ENEMY =  Damage {ion = 3},
  FM_FOCUS_ENERGY_3_ENEMY = Damage {ion = 4},
}


script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
  local roomDamage
  pcall(function() roomDamage = roomDamageWeapons[Hyperspace.Get_Projectile_Extend(projectile).name] end)
  if roomDamage then
    Damage.iDamage = Damage.iDamage + (roomDamage.hull or 0)
    Damage.iIonDamage = Damage.iIonDamage + (roomDamage.ion or 0)
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
    local bombOwner = Projectile.ownerId
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
    local impactOwner = Projectile.ownerId
    local target = Hyperspace.Pointf(Location.x // 35 * 35 + 17.5, Location.y // 35 * 35 + 17.5)
    local targetSpace = ShipManager.iShipId
    if Hyperspace.ShipGraph.GetShipInfo(targetSpace):GetSelectedRoom(target.x, target.y, true) ~= -1 then
      SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
    end
  end
end)

--To hit every room on the targeted ship with an effect (Until accuracy stats are exposed, please ensure all weapons used in hitEveryRoom have accuracy 100)
local hitEveryRoom = {
  FM_ARBOREAL_EXE = "FM_ARBOREAL_EXE_STATBOOST",
  FM_ARBOREAL_REV = "FM_ARBOREAL_REV_STATBOOST",

  FM_TERMINUS = "FM_TERMINUS_STATBOOST",
}


script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
  local roomDamage
  pcall(function() roomDamage = hitEveryRoom[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
  if roomDamage then
    local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
    local blueprint = Hyperspace.Global.GetInstance():GetBlueprints():GetWeaponBlueprint(roomDamage)
    local impactOwner = Projectile.ownerId
    local targetSpace = ShipManager.iShipId
    
    local weaponName = Hyperspace.Get_Projectile_Extend(Projectile).name
    Hyperspace.Get_Projectile_Extend(Projectile).name = ""
    for roomNumber = 0, Hyperspace.ShipGraph.GetShipInfo(targetSpace):RoomCount() - 1 do
      local target = ShipManager:GetRoomCenter(roomNumber)
      SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
    end
    Hyperspace.Get_Projectile_Extend(Projectile).name = weaponName
  end
  return Defines.CHAIN_CONTINUE
end)



--SPECIAL CASES:
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT,
function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
  if Hyperspace.Get_Projectile_Extend(Projectile).name == "FM_ABDUCT_LASER" then
    local targetRoomNumber = Hyperspace.ShipGraph.GetShipInfo(ShipManager.iShipId):GetSelectedRoom(Location.x, Location.y, true)
  

    local playTeleportSound = false
    for crew in vter(ShipManager.vCrewList) do
      if crew.iShipId == ShipManager.iShipId and crew.iRoomId == targetRoomNumber then --Only abducts enemy crew
        local arrivalRoomNumber = Hyperspace.random32() % Hyperspace.ShipGraph.GetShipInfo(Projectile.ownerId):RoomCount()
        Hyperspace.Get_CrewMember_Extend(crew):InitiateTeleport(Projectile.ownerId, arrivalRoomNumber)
        playTeleportSound = true
      end
    end
  
    if playTeleportSound then
      Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("teleport",-1,false)
    end
  end
  return Defines.CHAIN_CONTINUE
end)