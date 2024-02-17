local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt

script.on_system_event(
    Defines.SystemEvents.ON_SHUTDOWN,
    function(ship, sys) 
      if sys:GetId() == 14 then
        sys:LockSystem(4)
      end
    end,
    2147483647)--priority

local COOLDOWN_AUGS = {
  [9] = "FAST_TELEPORT",
  [10] = "FAST_CLOAK",
  [12] = "FAST_BATTERY",
  [14] = "FAST_MIND",
  [15] = "FAST_HACK",
  [20] = "FAST_TEMPORAL",
}

script.on_system_event(
  Defines.SystemEvents.ON_SHUTDOWN,
  function(ship, sys)
    local augName = COOLDOWN_AUGS[sys:GetId()]
    local speedup = math.floor(ship:GetAugmentationValue(augName))
    local newlock = math.max(sys.iLockCount - speedup, 0)
    sys:LockSystem(newlock)
  end,
 -1000)

script.on_system_event(Defines.SystemEvents.ON_RUN,
function(ship, sys)
  if sys:GetId() == 14 then
    local increment = Hyperspace.FPS.SpeedFactor / 16
    local modifier = 2 ^ ship:GetAugmentationValue("LONG_MIND") --Negative values make the duration shorter, longer values make it longer.
    sys.controlTimer.first = sys.controlTimer.first + (1 / modifier - 1) * increment
  end
end)

script.on_system_event(Defines.SystemEvents.ON_RUN,
function(ship, sys)
  if sys:GetId() == 12 then
    local increment = Hyperspace.FPS.SpeedFactor / 16
    local modifier = 2 ^ ship:GetAugmentationValue("LONG_BATTERY") --Negative values make the duration shorter, longer values make it longer.
    sys.effectTimer.first = sys.effectTimer.first + (1 / modifier - 1) * increment
  end
end)

script.on_system_event(Defines.SystemEvents.ON_RUN,
function(ship, sys)
  if sys:GetId() == 15 then
    local damage = ship:GetAugmentationValue("HACKING_DAMAGE")
    sys.currentSystem:PartialDamage(damage)
  end
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
function(shipManager)
  for sys in vter(shipManager.vSystemList) do
    local roomNumber = sys:GetRoomId()
    local fires = shipManager:GetFireCount(roomNumber)
    if fires ~= 0 then --this line makes it so half-sabotaged systems can reset, because running this every tick apparently prevents that
        local augValue = shipManager:GetAugmentationValue("FIRE_IMMUNITY")
        local fireImmunity = math.min(augValue, 1) / 2
        sys:PartialDamage(-fireImmunity * fires)
    end
  end
end)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, 
function(ShipManager)
  local deionizationBoost = ShipManager:GetAugmentationValue("DEIONIZATION_BOOST")
  for sys in vter(ShipManager.vSystemList) do
    sys.lockTimer.currTime=sys.lockTimer.currTime + Hyperspace.FPS.SpeedFactor /16 * deionizationBoost
  end
end)