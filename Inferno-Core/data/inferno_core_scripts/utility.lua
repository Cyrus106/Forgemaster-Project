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
  if projectile.damage.iDamage == 0 and
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
    projectile.damage.iStun == 0
  then
    return false
  else
    return true
  end
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

--the info hud.

local extraInfo = {
  xOffset = 110,
  yOffset = 204,
  extraYOffset = 0,
  augList ={
    [1] = "AUTO_COOLDOWN",
    [2] = "SHIELD_RECHARGE",
    [3] = "EXPLOSIVE_REPLICATOR",
    [4] = "ROCK_ARMOR",
    [5] = "ION_ARMOR",
    [6] = "SYSTEM_CASING",
    [7] = "SCRAP_COLLECTOR",
    
  },
  augValues ={
    [1] = 1, --+ Hyperspace.ships.player:GetAugmentationValue("AUTO_COOLDOWN"),
    [2] = 1, --+ Hyperspace.ships.player:GetAugmentationValue("SHIELD_RECHARGE"),
    [3] = 0, --Hyperspace.ships.player:GetAugmentationValue("EXPLOSIVE_REPLICATOR"),
    [4] = 0, --Hyperspace.ships.player:GetAugmentationValue("ROCK_ARMOR"),
    [5] = 0, --Hyperspace.ships.player:GetAugmentationValue("ION_ARMOR"),
    [6] = 0, --Hyperspace.ships.player:GetAugmentationValue("SYSTEM_CASING"),
    [7] = 1, --+ Hyperspace.ships.player:GetAugmentationValue("SCRAP_COLLECTOR"),
    
  },
  render = function(self)
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    for augCounter=1, #(self.augList) , 1 do
      if Hyperspace.ships.player:HasEquipment(self.augList[augCounter]) ~= 0 then
        Graphics.CSurface.GL_RenderPrimitive(Hyperspace.Resources:CreateImagePrimitiveString(
          "statusUI/"..string.lower(self.augList[augCounter]).."_counter.png",
          self.xOffset,--x
           self.yOffset + self.extraYOffset,--y (This box will not shift like normal variable boxes because the position is predefined. This is mostly for example purposes.)
            0,
            Graphics.GL_Color(1, 1, 1, 1.0),
          1.0,
          false))
        Graphics.freetype.easy_print(0, self.xOffset +35, self.yOffset + self.extraYOffset +9, string.format("%g%%", 100 * (self.augValues[augCounter])))
        self.extraYOffset = self.extraYOffset + 24
      end
    end
    Graphics.CSurface.GL_PopMatrix()
    self.extraYOffset = 0
  end,
  update = function(self)
    self.augValues[1] = 1 + Hyperspace.ships.player:GetAugmentationValue("AUTO_COOLDOWN")
    self.augValues[2] = 1 + Hyperspace.ships.player:GetAugmentationValue("SHIELD_RECHARGE")
    self.augValues[3] = Hyperspace.ships.player:GetAugmentationValue("EXPLOSIVE_REPLICATOR")
    self.augValues[4] = Hyperspace.ships.player:GetAugmentationValue("ROCK_ARMOR")
    self.augValues[5] = Hyperspace.ships.player:GetAugmentationValue("ION_ARMOR")
    self.augValues[6] = Hyperspace.ships.player:GetAugmentationValue("SYSTEM_CASING")
    self.augValues[7] = 1 + Hyperspace.ships.player:GetAugmentationValue("SCRAP_COLLECTOR")
    --self.reloadSpeed = 1 +  Hyperspace.ships.player:GetAugmentationValue(extraInfo.augList[extraInfo.augCounter])
  end,
}

script.on_render_event(Defines.RenderEvents.LAYER_PLAYER,
function() 
extraInfo:update()
end,
function()
extraInfo:render() 
end)