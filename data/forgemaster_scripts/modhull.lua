local vter = mods.inferno.vter
local getLimitAmount = mods.inferno.getLimitAmount
local setLimitAmount = mods.inferno.setLimitAmount
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt


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
  local damageChance = math.floor((augValue % 1) * 100)
  local randomNumber = Hyperspace.random32() % 100
  if randomNumber < damageChance then
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
        local scrapGain = randomInt(10, 20)
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

--cyclo arsenal and stuff
--[[mods.inferno.cycloWeapon = function()--checks if you have cyclo arsenal, then limits your system if you do
  local augValue = Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_HULL_FASTWEAPON") --maybe later replaed with a req counting the resulting bars
  if augValue > 0 then
    setLimitAmount(3,3,0)
  end
end--]]

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(shipManager, AugName, AugValue)
  
  if AugName == "AUTO_COOLDOWN" and shipManager:HasAugmentation("FM_MODULAR_HULL_FASTWEAPON") > 0 then
    local emptyWeaponBars = shipManager:GetSystemPowerMax(3) - shipManager:GetSystemPower(3) - math.max(getLimitAmount(3,0),shipManager:GetSystemPowerMax(3) - shipManager:GetSystem(3).healthState.first) 
    local cooldownModifier = (emptyWeaponBars * 0.1)-0.05
    AugValue = AugValue + cooldownModifier
  end

  return Defines.Chain.CONTINUE, AugValue
end)

mods.inferno.cycloShield = function()--as above, but for the shilds augment
  local augValue = Hyperspace.ships.player:GetAugmentationValue("FM_MODULAR_HULL_FASTSHIELD") 
  if augValue > 0 then
    setLimitAmount(0,4,0)
  end
end

--script.on_game_event("FMCORE_ONJUMP", false, function() mods.inferno:cycloWeapon() end)
script.on_game_event("FMCORE_ONJUMP", false, function() mods.inferno:cycloShield() end)

