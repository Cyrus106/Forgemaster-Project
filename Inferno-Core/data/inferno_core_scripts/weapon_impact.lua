
--DOCUMENTATION
mods.inferno.popWeapons = {}
--[[ 
Used for popping additional shield layers and doing additional damage to zoltan shields. 

count: Additional layers popped on impact. (Default of 0)
countSuper: Additional damage to supershields on impact. (Default of 0)

Usage:
mods.inferno.popWeapons.FM_LASER_PHOTON = {count = 1, countSuper = 1}
--]]
mods.inferno.roomDamageWeapons = {}
--[[
Used to modify the damage of non-beam weapons upon room impact.

hull: Additional hull damage on room impact. (Default of 0)
ion: Additional ion damage on room impact. (Default of 0)
sys: Additional system damage on room impact. (Default of 0)

Usage:
mods.inferno.roomDamageWeapons.FM_MISSILES_CLOAK_STUN_PLAYER = {hull = 0, ion = 3, sys = 0}
--]]
mods.inferno.tileDamageWeapons = {}
--[[
Used to apply additional damage on a per-tile basis for beam weapons.

hull: Additional hull damage on room impact. (Default of 0)
ion: Additional ion damage on room impact. (Default of 0)
sys: Additional system damage on room impact. (Default of 0)

Usage:
mods.inferno.tileDamageWeapons.FM_BEAM_ION_PIERCE = {ion = 1}
--]]
mods.inferno.impactBeams = {}
--[[
Simulates an impact of the specified weapon on a per-tile bases for beam weapons. (Will work best with LASER <weaponBlueprints>, but can work with others.)

This can be used to for more complex effects previously delegated to "crewjank" (Such as damage plus animations and sound effects.)

(Note: These projectiles CAN miss. The blueprint should have <accuracyMod>100</accuracyMod> until projectile accuracy is exposed to lua.)

Usage:
mods.inferno.impactBeams.FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_LASER"
--]]
mods.inferno.bombBeams = {}
--[[
Spawns a bomb on every hit tile (for beam weapons). Similar to impactBeams, except the bomb has to teleport in, and it grants visibility of the targetted room.

Usage:
mods.inferno.impactBeams.FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_BOMB"
--]]
mods.inferno.hitEveryRoom = {}
--[[
Simulates a hit on every room in the ship. (Useful for applying shipwide statboosts.)

Usage: 
mods.inferno.hitEveryRoom.FM_TERMINUS = "FM_TERMINUS_STATBOOST"
--]]

--IMPLEMENTATION
script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(ShipManager, Projectile, Damage, CollisionResponse)
    local shieldPower = ShipManager.shieldSystem.shields.power
    local popData = nil
    if pcall(function() popData = mods.inferno.popWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end) and popData then
        popData.count = popData.count or 0
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
    if pcall(function() popData = mods.inferno.popWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end) and popData and shieldPower.super.first > 0 then
        popData.countSuper = popData.countSuper or 0
        Damage.iDamage = Damage.iDamage + popData.countSuper
    end
    return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    local roomDamage
    pcall(function() roomDamage = mods.inferno.roomDamageWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
    if roomDamage then
        Damage.iDamage = Damage.iDamage + (roomDamage.hull or 0)
        Damage.iIonDamage = Damage.iIonDamage + (roomDamage.ion or 0)
        Damage.iSystemDamage = Damage.iSystemDamage + (roomDamage.sys or 0)
    end
    return Defines.CHAIN_CONTINUE, forceHit, shipFriendlyFire
end)

local function MakeDamage(table)
    local ret = Hyperspace.Damage()
    ret.iDamage = table.hull or 0 
    ret.iIonDamage = table.ion or 0 
    ret.iSystemDamage = table.system or 0 
    return ret
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local tileDamage
    pcall(function() tileDamage = mods.inferno.tileDamageWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
    if tileDamage and beamHitType ~= Defines.BeamHit.SAME_TILE then
        local weaponName = Hyperspace.Get_Projectile_Extend(Projectile).name
        Hyperspace.Get_Projectile_Extend(Projectile).name = ""
        local farPoint = Hyperspace.Pointf(-2147483648, -2147483648)
        ShipManager:DamageBeam(Location, farPoint, MakeDamage(tileDamage))
        Hyperspace.Get_Projectile_Extend(Projectile).name = weaponName
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local impact
    pcall(function() impact = mods.inferno.impactBeams[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
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
    return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local bomb
    pcall(function() bomb = mods.inferno.bombBeams[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
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
    return Defines.CHAIN_CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
    local roomDamage
    pcall(function() roomDamage = mods.inferno.hitEveryRoom[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
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



--AUGMENT EFFECTS
local function EffectResist(ShipManager, Damage)
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_BREACH")
    Damage.breachChance = math.max(0, Damage.breachChance - augValue)
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_FIRE")
    Damage.fireChance = math.max(0, Damage.fireChance - augValue)
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, 
function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    EffectResist(ShipManager, Damage)
    return Defines.CHAIN_CONTINUE, forceHit, shipFriendlyFire
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    EffectResist(ShipManager, Damage)
    return Defines.CHAIN_CONTINUE, beamHitType
end)




--Make breach chances above 10 apply additional breaches
local function AdditionalBreaches(ShipManager, Location, Damage)
  local breachChance = Damage.breachChance
  if breachChance > 10 then --To prevent recursion
    local additionalBreaches = (breachChance // 10) - 1
    for i = 1, additionalBreaches do
      local dam = Hyperspace.Damage()
      dam.breachChance = 10
      ShipManager:DamageArea(Location, dam, true)
    end
    local dam = Hyperspace.Damage()
    dam.breachChance = breachChance % 10
    ShipManager:DamageArea(Location, dam, true)
  end
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT,
function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
  AdditionalBreaches(ShipManager, Location, Damage)
  return Defines.CHAIN_CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  if beamHitType ~= Defines.BeamHit.SAME_TILE then
    AdditionalBreaches(ShipManager, Location, Damage)
  end
  return Defines.CHAIN_CONTINUE, beamHitType
end)