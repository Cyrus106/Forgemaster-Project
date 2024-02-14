
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
local vter = mods.inferno.vter
local RoomEffect = mods.inferno.RoomEffect
local GetRoom = mods.inferno.GetRoom
script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, 
function(ShipManager, Projectile, Damage, CollisionResponse)
    local shieldPower = ShipManager.shieldSystem.shields.power
    local popData = mods.inferno.popWeapons[Projectile.extend.name]
    if popData then
        popData.count = popData.count or 0
        if shieldPower.super.first <= 0 and CollisionResponse.damage > Damage.iShieldPiercing then
            ShipManager.shieldSystem:CollisionReal(Projectile.position.x, Projectile.position.y, Hyperspace.Damage(), true)
            shieldPower.first = math.max(0, shieldPower.first - popData.count)
        end
    end
    return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, 
function(ShipManager, Projectile, Damage, CollisionResponse)
    local shieldPower = ShipManager.shieldSystem.shields.power
    local popData = mods.inferno.popWeapons[Projectile.extend.name]
    if popData and shieldPower.super.first > 0 then
        popData.countSuper = popData.countSuper or 0
        Damage.iDamage = Damage.iDamage + popData.countSuper
    end
    return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, 
function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    if Projectile then
        local roomDamage = mods.inferno.roomDamageWeapons[Projectile.extend.name]
        if roomDamage then
            Damage.iDamage = Damage.iDamage + (roomDamage.hull or 0)
            Damage.iIonDamage = Damage.iIonDamage + (roomDamage.ion or 0)
            Damage.iSystemDamage = Damage.iSystemDamage + (roomDamage.sys or 0)
        end
    end
    return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
end)

local function MakeDamage(table)
    local ret = Hyperspace.Damage()
    ret.iDamage = table.hull or 0 
    ret.iIonDamage = table.ion or 0 
    ret.iSystemDamage = table.system or 0 
    return ret
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local tileDamage = mods.inferno.tileDamageWeapons[Projectile.extend.name]
    if tileDamage and beamHitType ~= Defines.BeamHit.SAME_TILE then
        local weaponName = Projectile.extend.name
        Projectile.extend.name = ""
        local farPoint = Hyperspace.Pointf(-2147483648, -2147483648)
        ShipManager:DamageBeam(Location, farPoint, MakeDamage(tileDamage))
        Projectile.extend.name = weaponName
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local impact = mods.inferno.impactBeams[Projectile.extend.name]
    if beamHitType ~= Defines.BeamHit.SAME_TILE and impact then
        local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
        local blueprint = Hyperspace.Blueprints:GetWeaponBlueprint(impact)
        local impactOwner = Projectile.ownerId
        local target = Hyperspace.Pointf(Location.x // 35 * 35 + 17.5, Location.y // 35 * 35 + 17.5)
        local targetSpace = ShipManager.iShipId
        if Hyperspace.ShipGraph.GetShipInfo(targetSpace):GetSelectedRoom(target.x, target.y, true) ~= -1 then
            local blast = SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
            blast.extend.customDamage.accuracyMod = 2147483647
        end
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    local bomb = mods.inferno.bombBeams[Projectile.extend.name]
    if beamHitType ~= Defines.BeamHit.SAME_TILE and bomb then
        local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
        local blueprint = Hyperspace.Blueprints:GetWeaponBlueprint(bomb)
        local bombOwner = Projectile.ownerId
        local target = Hyperspace.Pointf(Location.x // 35 * 35 + 17.5, Location.y // 35 * 35 + 17.5)
        local targetSpace = ShipManager.iShipId
        if Hyperspace.ShipGraph.GetShipInfo(targetSpace):GetSelectedRoom(target.x, target.y, true) ~= -1 then
            SpaceManager:CreateBomb(blueprint, bombOwner, target, targetSpace)
        end
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, 
function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
    if Projectile then
        local roomDamage = mods.inferno.hitEveryRoom[Projectile.extend.name]
        if roomDamage then
            local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
            local blueprint = Hyperspace.Blueprints:GetWeaponBlueprint(roomDamage)
            local impactOwner = Projectile.ownerId
            local targetSpace = ShipManager.iShipId
            
            local weaponName = Projectile.extend.name
            Projectile.extend.name = ""
            for roomNumber = 0, Hyperspace.ShipGraph.GetShipInfo(targetSpace):RoomCount() - 1 do
                local target = ShipManager:GetRoomCenter(roomNumber)
                local blast = SpaceManager:CreateLaserBlast(blueprint, target, targetSpace, impactOwner, target, targetSpace, 0)
                blast.extend.customDamage.accuracyMod = 2147483647
            end
            Projectile.extend.name = weaponName
        end
    end
    return Defines.Chain.CONTINUE
end)



--AUGMENT EFFECTS
local function EffectResist(ShipManager, Damage)
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_BREACH")
    if Damage.breachChance > 0 then --In cases of negative augValue, do not add breach chance to weapons without breach (Intentional)
        Damage.breachChance = math.max(0, Damage.breachChance - augValue)
    end
    local augValue = ShipManager:GetAugmentationValue("FMCORE_NO_FIRE")
    if Damage.fireChance > 0 then --In cases of negative augValue, do not add fire chance to weapons without fire (Intentional)
        Damage.fireChance = math.max(0, Damage.fireChance - augValue)
    end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, 
function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    EffectResist(ShipManager, Damage)
    return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    EffectResist(ShipManager, Damage)
    return Defines.Chain.CONTINUE, beamHitType
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
  return Defines.Chain.CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  if beamHitType ~= Defines.BeamHit.SAME_TILE then
    AdditionalBreaches(ShipManager, Location, Damage)
  end
  return Defines.Chain.CONTINUE, beamHitType
end)

do
    local AsteroidResist = false
    local ResistAugs = {ROCK_ARMOR = true, SYSTEM_CASING = true}
    script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA,
    function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    --If projectile is an asteroid, set AsteroidResist to true so resistances are triggered during the following resist augment checks in DamageArea
      if Projectile:GetType() == 2 then 
        AsteroidResist = true 
        --Prevent subsequent callbacks from running as we do not want this to register as a regular impact 
        --Additionally we do not want any subsequent callbacks to call GetAugmentationValue("SYSTEM_CASING") which will prevent the resistances from being modified
        return Defines.Chain.HALT, forceHit, shipFriendlyFire
      end
      return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
    end, 1000)

    --Make sure HasAugmentation return a positive value
    script.on_internal_event(Defines.InternalEvents.HAS_AUGMENTATION,
    function(ShipManager, AugName, AugValue)
      if ResistAugs[AugName] and AsteroidResist then
        AugValue = 1
        return Defines.Chain.HALT, AugValue
      end
      return Defines.Chain.CONTINUE, AugValue
    end)

    --Make sure both resist values are temporarily replaced with asteroid resist value
    script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
    function(ShipManager, AugName, AugValue)
      if ResistAugs[AugName] and AsteroidResist then
        local chanceForDamage = 1 - AugValue
        local chanceForAsteroidDamge = 1 - ShipManager:GetAugmentationValue("FMCORE_ASTEROID_RESIST_HULL")
        AugValue = 1 - (chanceForDamage * chanceForAsteroidDamge)
        if AugName == "SYSTEM_CASING" then
            --SYSTEM_CASING check happens last within DamageArea, so this is where AsteroidResist is set to false so that resist augs are only modified on asteroid impact
            AsteroidResist = false --This could be done within DAMAGE_AREA_HIT, but this would only work when the asteroid doesn't miss
        end
        return Defines.Chain.HALT, AugValue
      end
      return Defines.Chain.CONTINUE, AugValue
    end)

   

  end
  
  script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, 
  function(ShipManager, Projectile, Damage, CollisionResponse)
      --Chance is integer between 0 and 1.
      local resChance = ShipManager:GetAugmentationValue("FMCORE_ASTEROID_RESIST_SHIELD") 
      local rng = math.random()
      if rng < resChance and Projectile:GetType() == 2 then
         return Defines.Chain.PREEMPT
      end    
      return Defines.Chain.CONTINUE
  end)


local AcidWeapons = {}
setmetatable(AcidWeapons, {__index = function(table, key) return 0 end})
--Acid room effect
do
    local UNIQUE_KEY = {}
    --INIT ACID TABLES
    script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
    function(ShipManager)
        if not ShipManager.table[UNIQUE_KEY] then
            ShipManager.table[UNIQUE_KEY] = true
            for room in vter(ShipManager.ship.vRoomList) do
                room.table[UNIQUE_KEY] = {timer = 0}
            end
        end
    end, 2147483647)
    --INCREMENT TIMER
    script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
    function(ShipManager)
        if ShipManager.table[UNIQUE_KEY] then
            for room in vter(ShipManager.ship.vRoomList) do
                local acidTable = room.table[UNIQUE_KEY]
                acidTable.timer = math.max(acidTable.timer - Hyperspace.FPS.SpeedFactor / 16, 0)
            end
        end
    end)

    --APPLY EFFECT
    local function ApplyAcid(ShipManager, Location, Projectile)
        local room = GetRoom(ShipManager, Location)
        if room then
            local acidTable = room.table[UNIQUE_KEY]
            acidTable.timer = acidTable.timer + AcidWeapons[Projectile.extend.name]
        end
    end

    script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
    function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
        if beamHitType == Defines.BeamHit.NEW_ROOM then
            ApplyAcid(ShipManager, Location, Projectile)
        end
        return Defines.Chain.CONTINUE, beamHitType
    end)

    script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, 
    function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
        if Projectile then
            ApplyAcid(ShipManager, Location, Projectile)
        end
        return Defines.Chain.CONTINUE
    end)



    --APPROPIATELY MODIFY DAMAGE
    local function AcidDamage(ShipManager, Location, Damage)
        local room = GetRoom(ShipManager, Location)
        if room and room.table[UNIQUE_KEY].timer > 0 then
            Damage.iDamage = Damage.iDamage * 2
        end
    end

    script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA,
    function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
        AcidDamage(ShipManager, Location, Damage)
        return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
    end, -1000)

    script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
    function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
        AcidDamage(ShipManager, Location, Damage)
        return Defines.Chain.CONTINUE, beamHitType
    end, -1000)

    --VISUAL EFFECT FOR AFFECTED ROOMS
    local AcidEffect = RoomEffect:New {
        borderColor = Graphics.GL_Color(0 / 255, 162 / 255, 61 / 255, 1),
        roomColor = Graphics.GL_Color(8 / 255, 237 / 255, 36 / 255, 1),
        --[[
        gradient = {
            Graphics.GL_Color(1 / 255, 169 / 255, 58 / 255, 1),
            Graphics.GL_Color(2 / 255, 184 / 255, 53 / 255, 1),
            Graphics.GL_Color(4 / 255, 200 / 255, 48 / 255, 1),
            Graphics.GL_Color(6 / 255, 215 / 255, 43 / 255, 1),
            Graphics.GL_Color(7 / 255, 229 / 255, 38 / 255, 1),
        },
        --]]
    }
    script.on_render_event(Defines.RenderEvents.SHIP_FLOOR, function(Ship, experimental) end,
    function(Ship, experimental)
        for room in vter(Ship.vRoomList) do
            if not room.bBlackedOut and room.table[UNIQUE_KEY].timer > 0 then
                AcidEffect:Render(room)
            end
        end
    end)
    script.on_render_event(Defines.RenderEvents.SHIP_MANAGER, function(ShipManager, showInterior, doorControlMode) end,
    function(ShipManager, showInterior, doorControlMode)
        local canSeeRooms = false
        if ShipManager.iShipId == 1 then
            canSeeRooms = (ShipManager._targetable.hostile and (not ShipManager:HasSystem(10) or not ShipManager.cloakSystem.bTurnedOn)) or ShipManager.bContainsPlayerCrew
        else
            canSeeRooms = ShipManager.bShowRoom
        end
        canSeeRooms = canSeeRooms and not ShipManager.bDestroyed and not ShipManager.bJumping
        if canSeeRooms then
            for room in vter(ShipManager.ship.vRoomList) do
                local x = room.rect.x + room.rect.w - 6 --- 5
                local y = room.rect.y + 5 --+ 5
                local timer = room.table[UNIQUE_KEY].timer
                if timer > 0 then
                    Graphics.CSurface.GL_SetColor(AcidEffect.borderColor) 
                    Graphics.freetype.easy_printRightAlign(51, x, y, string.format("%.0f", timer))
                end
            end
        end
    end)
end
function SetAcidWeapon(weapon,time)
    AcidWeapons[weapon] = time
end