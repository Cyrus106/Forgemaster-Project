local vter = mods.inferno.vter
local real_projectile = mods.inferno.real_projectile
local randomInt = mods.inferno.randomInt

local callback_runner = {
    identifier = "",

  __call = function(self, ...)
    for key,functable in ipairs(self) do
      for _,func in ipairs(functable) do
        local success, res = pcall(func, ...)
        if not success then
          log(string.format(
          "Failed to call function in callback '%s' due to error:\n %s",
          self.identifier,
          res))
        elseif res then return end
      end
    end
  end,

  add = function(self, func, priority)
    local priority = priority or 0
    if type(priority) ~= 'number' or math.floor(priority) ~= priority then
      error("Priority argument must be an integer!", 3)
    end
    local priority = priority or 0
    local ptab = nil
    for _,v in ipairs(self) do
      if getmetatable(v).priority == priority then
        ptab = v break
      end
    end
    if not ptab then 
      ptab = setmetatable({}, {priority = priority}) 
      table.insert(self, ptab) 
    end
    if type(func) ~= 'function' then
      error("Second argument must be a function!", 3)
    end
    table.insert(ptab, func)
    table.sort(self,
    function(lesser,greater) 
      return getmetatable(lesser).priority > getmetatable(greater).priority --larger numbers come first
    end)
  end,

  new = function(self, o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
  end,
}

Defines.SystemEvents = {
  ON_ACTIVATE = callback_runner:new({identifier = "Defines.SystemEvents.ON_ACTIVATE"}),
  ON_SHUTDOWN = callback_runner:new({identifier = "Defines.SystemEvents.ON_SHUTDOWN"}),
  ON_RUN = callback_runner:new({identifier = "Defines.SystemEvents.ON_RUN"}),
}


local system_callbacks = {
  name="",
  just_on = {[0] = false, [1] = false},
  procedure = function(self)
    for i = 0, 1 do
      local sys = nil
      pcall(function() 
        if type(self.name) == 'string' then  
          sys = Hyperspace.ships(i)[self.name]
        else 
          sys = Hyperspace.ships(i):GetSystem(self.name)
        end
      end)
      if sys then
        if sys.iLockCount == -1 then --if the system is locked
          if not self.just_on[i] then-- if the system is locked and was not activated last frame, meaning it was just turned on
            Defines.SystemEvents.ON_ACTIVATE(Hyperspace.ships(i), sys)
          end
          self.just_on[i] = true
          if not Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then
            Defines.SystemEvents.ON_RUN(Hyperspace.ships(i), sys)
          end
        elseif self.just_on[i] then --if the system was locked (meaning activated) last frame and is no longer locked
          self.just_on[i] = false
          Defines.SystemEvents.ON_SHUTDOWN(Hyperspace.ships(i), sys)
        end
      end
    end
  end,

  new = function(self,name)
    --all system_callbacks objects will share the same 'shutdown', 'activate', and 'run' tables, similar to Hyperspace's callbacks with arguments
    self.__index = self
    local table = setmetatable({}, self)
    table.just_on = {[0] = false, [1] = false}
    table.name = name
    script.on_internal_event(Defines.InternalEvents.ON_TICK, function() table:procedure() end, 1000)
    return table
  end,
}

system_callbacks:new('teleportSystem')
system_callbacks:new('cloakSystem')
system_callbacks:new('batterySystem')
system_callbacks:new('mindSystem')
system_callbacks:new('hackingSystem')
system_callbacks:new(20) --custom system, can only be accessed by numerical identifier




function script.on_system_event(SystemEvent, func, priority)
  local validEvent = false
  for _, v in pairs(Defines.SystemEvents) do
    if v == SystemEvent then validEvent = true break end
  end
  if not validEvent then
    log("\n\nValid SystemEvents:\nON_ACTIVATE\nON_SHUTDOWN\nON_RUN")
    error("First argument of function 'script.on_system_event' must be a valid SystemEvent! Check the FTL_HS.log file for more information.", 2)
  end
  SystemEvent:add(func, priority)
end

Defines.FireEvents = {
  WEAPON_FIRE = callback_runner:new({identifier = "Defines.FireEvents.WEAPON_FIRE"}),
  ARTILLERY_FIRE = callback_runner:new({identifier = "Defines.FireEvents.ARTILLERY_FIRE"}),
}
script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  for i = 0, 1 do
    local weapons = nil
    local ship = Hyperspace.ships(i)
    pcall(function() weapons = ship.weaponSystem.weapons end)
    if weapons and ship.weaponSystem:Powered() then 
      for weapon in vter(weapons) do
        while true do
          local projectile = weapon:GetProjectile()
          if projectile then
            Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles:push_back(projectile)
            Defines.FireEvents.WEAPON_FIRE(ship, weapon, projectile)
          else
            break
          end
        end
      end
    end
  end
end, 1000)

script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  for i = 0, 1 do
    local artilleries = nil
    local ship = Hyperspace.ships(i)
    pcall(function() artilleries = ship.artillerySystems end)
    if artilleries then 
      for artillery in vter(artilleries) do
        while true do
          local weapon = artillery.projectileFactory
          local projectile = weapon:GetProjectile()
          if projectile then
            Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles:push_back(projectile)
            Defines.FireEvents.ARTILLERY_FIRE(ship, artillery, projectile)
          else
            break
          end
        end
      end
    end
  end
end, 1000)


function script.on_fire_event(FireEvent, func, priority)
  local validEvent = false
  for _, v in pairs(Defines.FireEvents) do
    if v == FireEvent then validEvent = true break end
  end
  if not validEvent then
    log("\n\nValid FireEvents:\nWEAPON_FIRE\nARTILLERY_FIRE")
    error("First argument of function 'script.on_fire_event' must be a valid FireEvent! Check the FTL_HS.log file for more information.", 2)
  end
  FireEvent:add(func, priority)
end
