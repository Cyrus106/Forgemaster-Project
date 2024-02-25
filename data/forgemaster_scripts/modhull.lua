local vter = mods.inferno.vter
local GetLimitAmount = mods.inferno.GetLimitAmount
local SetLimitAmount = mods.inferno.SetLimitAmount
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt
local RoomEffect = mods.inferno.RoomEffect

local getEmptyBars = function(ShipManager,sysId)
  return ShipManager:GetSystemPowerMax(sysId) - ShipManager:GetSystemPower(sysId) - math.max(GetLimitAmount(ShipManager:GetSystem(sysId)),ShipManager:GetSystemPowerMax(sysId) - ShipManager:GetSystem(sysId).healthState.first)
end

--Overcharmed
script.on_game_event("FMCORE_ONDAMAGE",false,
function()
  local extraNotches = Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_UPGRADE_EXTRANOTCHES") 
  local damageQuantity = Hyperspace.ships.player:HasEquipment("FM_HULL_UPGRADE_POINTS") - (15 + extraNotches)
  local damage = Hyperspace.Damage() 
  damage.fireChance = 5
  damage.breachChance = 10
  for i = 1, damageQuantity do 
    local roomCenter = Hyperspace.ships.player:GetRandomRoomCenter() 
    Hyperspace.ships.player:DamageArea(roomCenter, damage, true) 
  end
end
)

--Murals
script.on_game_event("FMCORE_ONDAMAGE",false,
function()
  local augValue = Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_HULL_MURAL") 
  local guaranteedDamage = math.floor(augValue)
  local damage = Hyperspace.Damage()
  damage.iDamage = 1
  for i = 1, guaranteedDamage do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRandomRoomCenter(), damage, true)
  end
  local damageChance = math.floor((augValue % 1))
  if math.random() < damageChance then
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRandomRoomCenter(), damage, true)
  end
end)

--Self Arm (Twisted Rock)
local selfArm = {
    queuedScrap = 0,
    counterFrame = Hyperspace.Resources:CreateImagePrimitiveString(
                "statusUI/rage_counter.png",
                373,--x
                 42,--y (This box will not shift like normal variable boxes because the position is predefined. This is mostly for example purposes.)
                  0,
                  Graphics.GL_Color(1, 1, 1, 1.0),
                1.0,
                false),
    render = function(self)
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM") > 0 then                                                          
        Graphics.CSurface.GL_PushMatrix()
        Graphics.CSurface.GL_LoadIdentity()
        Graphics.CSurface.GL_RenderPrimitive(self.counterFrame)
        Graphics.freetype.easy_printCenter(0, 424, 58, string.format("%i", self.queuedScrap))
        Graphics.CSurface.GL_PopMatrix()
      end
    end,

    onDamage = function(self)
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM") ~= 0 then
        local scrapGain = math.random(10, 20)
        self.queuedScrap = self.queuedScrap + scrapGain
      end
    end,

    redeem = function(self)
      if Hyperspace.ships.player:HasAugmentation("TWISTED_HULL_ARM") ~= 0 then
        Hyperspace.ships.player:ModifyScrapCount(self.queuedScrap, false)--"false" means this isn't affected by scrap arms
        self.queuedScrap = 0
      end
    end,
    reset = function(self)
      self.queuedScrap = 0
    end,
}

script.on_render_event(Defines.RenderEvents.LAYER_PLAYER,
function() end,
function()
  selfArm:render() 
end)
script.on_game_event("START_BEACON_REAL", false, function() selfArm:reset() end)
script.on_game_event("FMCORE_ONJUMP", false, function() selfArm:reset() end)
script.on_game_event("FMCORE_ONDAMAGE", false, function() selfArm:onDamage() end)
script.on_game_event("FM_HULLKILL_TRACKER_EVENT", false, function() selfArm:redeem() end) --We can find a better check for kills later.
script.on_game_event("FM_CREWKILL_TRACKER_EVENT", false, function() selfArm:redeem() end)


script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)

  if ShipManager and AugName == "AUTO_COOLDOWN" and ShipManager:GetAugmentationValue("FM_MODULAR_HULL_FASTWEAPON") > 0 then
    local emptyWeaponBars = getEmptyBars(ShipManager,3)
    local cooldownModifier = (emptyWeaponBars * ShipManager:GetAugmentationValue("FM_MODULAR_HULL_FASTWEAPON")) --maybe i will later make it stackable
    AugValue = AugValue + cooldownModifier
  end

  return Defines.Chain.CONTINUE, AugValue
end)
script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)

  if ShipManager and AugName == "SHIELD_RECHARGE" and ShipManager:GetAugmentationValue("FM_MODULAR_HULL_FASTSHIELD") > 0 then
    local emptyWeaponBars = getEmptyBars(ShipManager,0)
    local cooldownModifier = (emptyWeaponBars * ShipManager:GetAugmentationValue("FM_MODULAR_HULL_FASTSHIELD")) --maybe i will later make it stackable
    AugValue = AugValue + cooldownModifier
  end

  return Defines.Chain.CONTINUE, AugValue
end)
--[[
script.on_game_event("FMCORE_ONJUMP", false, 
function()
  if Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_HULL_FASTSHIELD") > 0 then
    local shieldSystem = Hyperspace.ships.player:GetSystem(0)
    local oldLimit = GetLimitAmount(shieldSystem)
    local newLimit = math.max(oldLimit, 4)
    SetLimitAmount(shieldSystem, newLimit)
  end
end)--]]

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE,
function(projectile, weapon)
  if weapon:HasAugmentation("FM_MODULAR_HULL_WEAPON_IGNITE") > 0 and not weapon.isArtillery and mods.multiverse.is_first_shot(weapon,true) then
    local ship = Hyperspace.ships(projectile:GetOwnerId())
    ship:StartFire(ship:GetSystem(3).roomId)
  end
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE,
function(ShipManager, Projectile, Damage, CollisionResponse)
  if ShipManager:HasAugmentation("FM_MODULAR_HULL_FASTSHIELD") > 0 then
    local rng = math.random()
    local resChance = 1-0.8^(getEmptyBars(ShipManager,0)+1)
    if rng < resChance and Projectile:GetType() ~= 5 then
      Projectile:Kill()
      return Defines.Chain.PREEMPT
    end
  end
  return Defines.Chain.CONTINUE
end)

local calculateCrits = function(ShipManager,Damage)
  local extraNotches = ShipManager:GetAugmentationValue("FM_MODULAR_UPGRADE_EXTRANOTCHES") 
  local critRate = 0.01*(ShipManager:HasEquipment("FM_HULL_UPGRADE_POINTS") - (15 + extraNotches))
  local extraRecursions = ShipManager:HasEquipment("FM_HULL_CAPSTONES")-3
  local critmult=1
  if Damage.iDamage==0 and Damage.iIonDamage==0 and Damage.iSystemDamage==0 then return end
  for i=0,extraRecursions do
    if critRate>math.random() then
      Damage.iDamage=Damage.iDamage*2
      Damage.iIonDamage=math.min(Damage.iIonDamage*2,11)--fix for crash
      Damage.iSystemDamage=Damage.iSystemDamage*2
      critmult=critmult*2
    else
      break
    end
  end
  if critmult>1 then
    print(" you have taken a CRITICAL HIT: "..critmult.."x! ("..100*critRate^math.log(critmult,2).."%% chance)")
  end
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA,
  function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    calculateCrits(ShipManager,Damage)
    return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
  end, -1000)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
  function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    calculateCrits(ShipManager,Damage)
    return Defines.Chain.CONTINUE, beamHitType
  end, -1000)

-- rendering of turrets/repair sys Update
local sysIdToAug={
  [0]="SHIELDS","ENGINES","OXYGEN","WEAPONS","DRONES","MED","PILOT","SENORS","DOORS","TELEPORTER","CLOAKING",
  "ARTILLERY","BATTERY","MED","MIND","HACKING",[20]="TEMPORAL"
}
mods.Forgemaster.augs={}
mods.Forgemaster.augs.UpdateEffect = RoomEffect:New {
  borderColor = Graphics.GL_Color(52 / 255, 55 / 255, 71 / 255, 0.75),
  roomColor = Graphics.GL_Color(58 / 255, 80 / 255, 130 / 255, 0.5),
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
mods.Forgemaster.augs.TurretEffect = RoomEffect:New {
  borderColor = Graphics.GL_Color(71 / 255, 61 / 255, 52 / 255, 0.75),
  roomColor = Graphics.GL_Color(130 / 255, 80 / 255, 58 / 255, 0.5),
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
local UpdateEffect = mods.Forgemaster.augs.UpdateEffect
local TurretEffect = mods.Forgemaster.augs.TurretEffect
script.on_render_event(Defines.RenderEvents.SHIP_FLOOR, function(Ship, experimental) end,
function(Ship, experimental)
  for sys in vter(Hyperspace.ships(Ship.iShipId).vSystemList) do
    local room = Ship.vRoomList[sys:GetRoomId()]
    if not room.bBlackedOut then
      if Ship:HasAugmentation("FM_MODULAR_HULL_UPDATE_"..sysIdToAug[sys:GetId()]) > 0 then
        UpdateEffect:Render(room)
      end
      if Ship:HasAugmentation("FM_MODULAR_HULL_TURRET_"..sysIdToAug[sys:GetId()]) > 0 then
        TurretEffect:Render(room)
      end
    end
  end
end)

--[[
Must expose:

Repariable::fDamage
OuterHull;
Ship::vOuterWalls
--]]

--[[
local function SystemDamaged(ShipManager)
  for system in vter(ShipManager.vSystemList) do
    local health = system.healthState
    if health.first < health.second then
      return true
    end
  end
  return false
end

--For when breaches are properly exposed
local function IsBreached(ShipManager)
  for breach in vter(ShipManager.ship.vOuterWalls) do
    if breach.fDamage > 0 then 
      return true 
    end
  end
  return false
end

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  if AugName == "ROCK_ARMOR" then
    if not (SystemDamaged(ShipManager) or IsBreached(ShipManager)) then
      local unbrokenCount = ShipManager:HasAugmentation("FM_UNBROKEN_ARMOR")
      AugValue = 1 - (1 - AugValue) * 0.5 ^ unbrokenCount
    end
  end
  return Defines.Chain.CONTINUE, AugValue
end)
--]]