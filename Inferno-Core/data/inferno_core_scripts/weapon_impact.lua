-- popping extra shields (and damage to zoltan shields)
--[[ appended to like this 
mods.inferno.popWeapons.FM_LASER_PHOTON = {count = 1, countSuper = 1}
]]
mods.inferno.popWeapons = {}

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(ShipManager, Projectile, Damage, CollisionResponse)
    local shieldPower = ShipManager.shieldSystem.shields.power
    local popData = nil
    if pcall(function() popData = mods.inferno.popWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end) and popData then
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
        Damage.iDamage = Damage.iDamage + popData.countSuper
    end
    return Defines.Chain.CONTINUE
end)


-- Modifies the damage of a (non-beam) weapon when hitting a room
--[[ appended to like this (values of 0 can be omitted)
mods.inferno.roomDamageWeapons.FM_MISSILES_CLOAK_STUN_PLAYER = {hull = 0, ion = 3, sys = 0}
]]
mods.inferno.roomDamageWeapons = {}

local function Damage(table)
    local ret = Hyperspace.Damage()
    ret.iDamage = table.hull or 0 
    ret.iIonDamage = table.ion or 0 
    ret.iSystemDamage = table.system or 0 
    return ret
end

-- deals an extra instance of damage on every tile hit by a beam/pinpoint
--[[ appended to like this (values of 0 can be omitted)
mods.inferno.tileDamageWeapons.FM_BEAM_ION_PIERCE = Damage {ion = 1}
]]
mods.inferno.tileDamageWeapons ={}

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
  
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local tileDamage
    pcall(function() tileDamage = mods.inferno.tileDamageWeapons[Hyperspace.Get_Projectile_Extend(Projectile).name] end)
    if tileDamage and beamHitType ~= Defines.BeamHit.SAME_TILE then
        local weaponName = Hyperspace.Get_Projectile_Extend(Projectile).name
        Hyperspace.Get_Projectile_Extend(Projectile).name = ""
        local farPoint = Hyperspace.Pointf(-2147483648, -2147483648)
        ShipManager:DamageBeam(Location, farPoint, tileDamage)
        Hyperspace.Get_Projectile_Extend(Projectile).name = weaponName
    end
    return Defines.Chain.CONTINUE, beamHitType
end)


--creates a hit of a specified LASER weaopon on each tile hit (it spawns the projectile of the weapon)
--[[appended to like this
    mods.inferno.impactBeams.FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_LASER"
]]
mods.inferno.impactBeams = {}

--Instant Impact (Until accuracy stats are exposed, please ensure all weapons used in impactBeams have accuracy 100)
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
end)

--like impactBeams but spawns bombs instead (this means you can see teh projectile first)
mods.inferno.bombBeams = {}

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
end)

-- like impactBeams but for non-beams and hitting every room once
mods.inferno.hitEveryRoom = {}

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

local function effectResist(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_BREACH")
    if augValue ~= 0 and Damage.breachChance >= 0 then
        Damage.breachChance = Damage.breachChance - augValue
    end
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_FIRE")
    if augValue ~= 0 and Damage.fireChance >= 0 then
        Damage.fireChance = Damage.fireChance - augValue
    end
    return Defines.CHAIN_CONTINUE, forceHit, shipFriendlyFire
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, effectResist)
  
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, effectResist)