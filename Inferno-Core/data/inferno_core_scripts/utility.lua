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

mods.inferno.dialogueBox = {
  --Set these members in constructor
  x = 0, 
  y = 0,
  w = 100,
  h = 100,
  font = 51,
  text = {"Default"},
  textSpeed = 10, --Characters per second
  
  sound = "autofireOff",
  
  
  --Do not set these members
  textIndex = 1,
  timer = 0,
  soundTimer = 0,
  active = true,
  
  --Frame
  fillColor = Graphics.GL_Color(53 / 255, 75 / 255, 89 / 255, 0.75),
  borderColor = Graphics.GL_Color(1, 1, 1, 1),
  
  Render = function(self)
      if self.active then
          local currentText = self.text[self.textIndex]
          local charsToRender = math.floor(self.timer * self.textSpeed)
          if charsToRender > #currentText then
            charsToRender = #currentText
          else --If not done, play sound
            if self.soundTimer > 0.07 then
              self.soundTimer = 0
              Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix(self.sound, 1, false)
            end
            self.soundTimer = self.soundTimer + Hyperspace.FPS.SpeedFactor / 16
          end
          currentText = currentText:sub(0, charsToRender)
          Graphics.CSurface.GL_DrawRect(self.x + 5, self.y + 5, self.w - 5, self.h - 5, self.fillColor)
          Graphics.CSurface.GL_DrawRectOutline(self.x, self.y, self.w, self.h, self.borderColor, 5)
          Graphics.freetype.easy_printAutoNewlines(
              self.font, 
              self.x + 10, 
              self.y + 10, 
              self.w - 20, 
              currentText
          )
          self.timer = self.timer + Hyperspace.FPS.SpeedFactor / 16
      end
  end,
  Advance = function(self)
      self.textIndex = self.textIndex + 1
      self.timer = 0
      self.soundTimer = 0
      if self.textIndex > #self.text then
          self.active = false
      end
  end,

  Reset = function(self)
      self.textIndex = 1
      self.timer = 0
      self.soundTimer = 0
      self.active = true
  end,

  New = function(self, table)
      self.__index = self
      setmetatable(table, self)
      return table
  end,
}

local function iter(table, index)
  index = index - 1
  local value = table[index]
  if value then
    return index, value
  end
end

local function ipairs_reverse(table)
  return iter, table, #table + 1
end

local function timeIndex()
  if Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then
    return 0
  else
    return Hyperspace.FPS.SpeedFactor / 16
  end
end

mods.inferno.EffectVector = { 
  lastVal = 0,
  Update = function(self)
    local modifier = 0
    for i, effect in ipairs_reverse(self) do
      effect.timer = effect.timer - timeIndex()
      if effect.timer <= 0 then
        modifier = modifier + effect.strength
        table.remove(self, i)
      end
    end
    return modifier
  end,
  Apply = function(self, effectDefinition) --NOTE: you must still manually apply the effect, this is just for durations and tracking so there's no interference with the native applications of the effect.
    local effect = {
      strength = effectDefinition.strength,
      timer = effectDefinition.duration,
    }
    table.insert(self, effect)
    self.lastVal = self.lastVal + effectDefinition.strength
  end,
  Clear = function(self)
    for i, v in ipairs_reverse(self) do 
      table.remove(self, i)
    end
  end,
  New = function(self, o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
  end,
}