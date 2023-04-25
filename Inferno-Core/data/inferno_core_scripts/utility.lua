mods.inferno = {}

mods.inferno.vter = function(cvec)
  local i = -1 --so the first returned value is indexed at zero
  local n = cvec:size()
  return function ()
      i = i + 1
      if i < n then return cvec[i] end
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
  return (Hyperspace.random32() % (max - min + 1)) + min
end

function mods.inferno.GetLimitAmount(ShipSystem)
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

function mods.inferno.SetLimitAmount(ShipSystem, limit)
  ShipSystem:ClearStatus()
  ShipSystem:SetPowerLoss(limit)
end