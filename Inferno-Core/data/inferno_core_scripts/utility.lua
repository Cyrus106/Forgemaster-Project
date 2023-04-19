mods.inferno = {}

mods.inferno.vter = function(cvec)
  local i=-1 --so the first returned value is indexed at zero
  local n=cvec:size()
  return function ()
      i=i+1
      if i<n then return cvec[i] end
  end
end
mods.inferno.getLimitAmount = function(sys_id,shipId)
  local ship = Hyperspace.Global.GetInstance():GetShipManager(shipId)
  if not ship:HasSystem(sys_id) then return 0 end
  --priority is loss,limit,divide, as in divide overrides both loss and limit, and limit overrides loss
  local system = ship:GetSystem(sys_id)
  local absolute_max_bars = ship:GetSystemPowerMax(sys_id)--returns the maximum amount of power the system can have, so basically the level
  local current_max_bars = system:GetPowerCap() --only considers limit and divide events, not loss, this only matters if loss is the ONLY type of <status>
  if absolute_max_bars ~= current_max_bars then
    return absolute_max_bars - current_max_bars
  elseif system.iTempPowerLoss > 0 then
    return system.iTempPowerLoss
  else
    return 0
  end
  --this returns the amount of bars that have been limited
  --because divide overrides everything, it would be best to call Hyperspace.ships.player:ClearStatusSystem(sys_id) before applying a new limit based upon the old
end
mods.inferno.setLimitAmount = function(sys_id,level,shipId)--system ids: 0-shields,1-engines,2-oxygen,3-weapons...
  --[[if Hyperspace.ships.player:GetSystem(sys_id).iTempPowerCap > level then -- this will limit a system to a certain level, but only if the current limit is higher than the old one
    Hyperspace.ships.player:SetSystemPowerLoss(sys_id,level)
  end--]]
  local ship = Hyperspace.Global.GetInstance():GetShipManager(shipId)
  if ( ship:GetSystemPowerMax(sys_id)-mods.inferno.getLimitAmount(sys_id,shipId) ) > level then -- this will limit a system to a certain level, but only if the current limit is higher than the old one
    ship:SetSystemPowerLoss(sys_id,level)
  end
end

mods.inferno.real_projectile = function(projectile) --replace when we have access to the death animation and can check directly
  return not(projectile.damage.iDamage == 0 and
    projectile.damage.iShieldPiercing == 0 and
    projectile.damage.fireChance == 0 and
    projectile.damage.breachChance == 0 and
    projectile.damage.stunChance == 0 and
    projectile.damage.iIonDamage == 0 and
    projectile.damage.iSystemDamage == 0 and
    projectile.damage.iPersDamage == 0 and
    projectile.damage.bHullBuster == false and
    projectile.damage.ownerId == -1 and
    projectile.damage.selfId == -1 and
    projectile.damage.bLockdown == false and
    projectile.damage.crystalShard == false and
    projectile.damage.bFriendlyFire == true and
    projectile.damage.iStun == 0)
end
mods.inferno.randomInt = function(min,max)
  if math.floor(min) ~= min or math.floor(max) ~= max then
    error("randomInt function recieved non-integer inputs!", 2) 
  end
  if max<min then
    error("randomInt function error: max is less than min!", 2)
  end
  return (Hyperspace.random32() % (max-min+1)) + min
end

--for use later
local function GetLimitAmount(ShipSystem)
  --Limit priority is loss, limit, divide, as in divide overrides both loss and limit, and limit overrides loss
  local absolute_max_bars = ShipSystem.powerState.second --Maximum power level
  local current_max_bars = ShipSystem:GetPowerCap() --Only considers limit and divide events, not loss, this only matters if loss is the ONLY type of <status>
  if absolute_max_bars ~= current_max_bars then
    return absolute_max_bars - current_max_bars
  elseif ShipSystem.iTempPowerLoss > 0 then
    return ShipSystem.iTempPowerLoss
  else
    return 0
  end
end

local function SetLimitAmount(ShipSystem, limit)
  ShipSystem:ClearStatus()
  ShipSystem:SetPowerLoss(limit)
end