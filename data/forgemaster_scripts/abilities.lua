local vter = mods.inferno.vter
local EffectVector = mods.inferno.EffectVector

local UNIQUE_KEY = {}
--Init EffectVectors
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
function(ShipManager)
  if not ShipManager.table[UNIQUE_KEY] then 
    ShipManager.table[UNIQUE_KEY] = true
    for room in vter(ShipManager.ship.vRoomList) do
      room.table[UNIQUE_KEY] = EffectVector:New()
    end
  end
end, 2147483647)

--Framework for reseting timed effects
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
function(ShipManager)
  for room in vter(ShipManager.ship.vRoomList) do
    local effectVector = room.table[UNIQUE_KEY]
    if room.extend.sysDamageResistChance ~= effectVector.lastVal then --If the resist has been changed by another method, clear effects to be safe.
      effectVector:Clear() 
    else
      local modifier = effectVector:Update()
      room.extend.sysDamageResistChance = room.extend.sysDamageResistChance - modifier
    end
    effectVector.lastVal = room.extend.sysDamageResistChance
  end
end)

--Ability Implementation
local shellFortify = {strength = 100, duration = 15}

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER,
function(ActivatedPower, ShipManager)
  if ActivatedPower.def.name == "plated_shell_fortify" then
    local room = ShipManager.ship.vRoomList[ActivatedPower.crew.iRoomId]
    local effectVector = room.table[UNIQUE_KEY]

    effectVector:Apply(shellFortify)
    room.extend.sysDamageResistChance = room.extend.sysDamageResistChance + shellFortify.strength
  end
end)
