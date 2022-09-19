mods.inferno.system_callbacks={
    sys_id=14,
    just_on=false,
    shutdown_events={},
    activate_events={},
    whileactive_events={},
    procedure=function(self)
        local sys=nil
        if pcall(function()
          sys=Hyperspace.ships.player:GetSystem(self.sys_id)
        end) then
           sys=Hyperspace.ships.player:GetSystem(self.sys_id)
        end

        if sys then
          if sys.iLockCount==-1 then --if the system is locked
            if not self.just_on then-- if the system is locked and was not activated last frame, meaning it was just turned on
              self:activate()
            end
            self.just_on=true
            if not Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then --may be source of memory leak if there is one, added this after establishing framework
              self:whileactive()
            end
          elseif self.just_on then --if the system was locked (meaning activated) last frame and is no longer locked
            self.just_on=false
            self:shutdown()
          end
        end
    end,

    shutdown = function(self)
      for key,func in ipairs(self.shutdown_events) do
        func()
      end
    end,

    activate = function(self)
      for key,func in ipairs(self.activate_events) do
        func()
      end
    end,

    whileactive = function(self)
      for key,func in ipairs(self.whileactive_events) do
        func()
      end
    end,

    --Inheritence Stuff
    new = function(self,o)
      o = o or {}
      self.__index = self
      setmetatable(o, self)
      o.shutdown_events={
        append=function(self,functions)
              local len=#self
              for key,func in ipairs(functions) do
                self[len+key]=func
              end
        end,
      }
      o.activate_events={
        append=function(self,functions)
              local len=#self
              for key,func in ipairs(functions) do
                self[len+key]=func
              end
        end,
      }
      o.whileactive_events={
        append=function(self,functions)
              local len=#self
              for key,func in ipairs(functions) do
                self[len+key]=func
              end
        end,
      }
      return o
    end,
}
mods.inferno.mindcallbacks=mods.inferno.system_callbacks:new({
  sys_id=14,
})

mods.inferno.mindcallbacks.shutdown_events:append({
function() --fix for level 4 mind control, runs first
  Hyperspace.ships.player.mindSystem:LockSystem(4)
end,

function()
  local speedup=Hyperspace.ships.player:GetAugmentationValue("FAST_MIND")
  local current_lock=Hyperspace.ships.player.mindSystem.iLockCount
  local lock=current_lock-speedup
  local real_lock=math.max(lock,0)
  Hyperspace.ships.player.mindSystem:LockSystem(real_lock)
end,
})

script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  mods.inferno.mindcallbacks:procedure()
end)

mods.inferno.cloakingcallbacks=mods.inferno.system_callbacks:new({
  sys_id=10,
})


mods.inferno.cloakingcallbacks.shutdown_events:append({
function()
  local speedup=Hyperspace.ships.player:GetAugmentationValue("FAST_CLOAK")
  local current_lock=Hyperspace.ships.player.cloakSystem.iLockCount
  local lock=current_lock-speedup
  local real_lock=math.max(lock,0)
  Hyperspace.ships.player.cloakSystem:LockSystem(real_lock)
end,
})

script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  mods.inferno.cloakingcallbacks:procedure()
end)

mods.inferno.hackingcallbacks=mods.inferno.system_callbacks:new({
  sys_id=15,
})

mods.inferno.hackingcallbacks.shutdown_events:append({
function()
  local speedup=Hyperspace.ships.player:GetAugmentationValue("FAST_HACK")
  local current_lock=Hyperspace.ships.player.hackingSystem.iLockCount
  local lock=current_lock-speedup
  local real_lock=math.max(lock,0)
  Hyperspace.ships.player.hackingSystem:LockSystem(real_lock)
end,
})

script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  mods.inferno.hackingcallbacks:procedure()
end)

mods.inferno.temporalcallbacks=mods.inferno.system_callbacks:new({
  sys_id=20,
})

mods.inferno.temporalcallbacks.shutdown_events:append({
function()
  local speedup=Hyperspace.ships.player:GetAugmentationValue("FAST_TEMPORAL")
  local current_lock=Hyperspace.ships.player:GetSystem(20).iLockCount
  local lock=current_lock-speedup
  local real_lock=math.max(lock,0)
  Hyperspace.ships.player:GetSystem(20):LockSystem(real_lock)
end,
})

script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  mods.inferno.temporalcallbacks:procedure()
end)



--mind control duration proof of concept
---[[
mods.inferno.mindcallbacks.whileactive_events:append({
function()
  --every tick, the timer increments by Hyperspace.FPS.SpeedFactor/16
  local increment=Hyperspace.FPS.SpeedFactor/16
  local modifier=math.max(Hyperspace.ships.player:GetAugmentationValue("LONG_MIND"),1) --could just calculate this value upon activation to minimize memory usuage, if it's an issue
  Hyperspace.ships.player.mindSystem.controlTimer.first=Hyperspace.ships.player.mindSystem.controlTimer.first+((1/modifier)-1)*increment
end,
})

mods.inferno.hackingcallbacks.whileactive_events:append({
function()
    local increment=Hyperspace.FPS.SpeedFactor/16
    local modifier=math.max(Hyperspace.ships.player:GetAugmentationValue("LONG_HACK"),1) --could just calculate this value upon activation to minimize memory usuage, if it's an issue
    Hyperspace.ships.player.hackingSystem.effectTimer.first=Hyperspace.ships.player.hackingSystem.effectTimer.first+((1/modifier)-1)*increment
end,

function()
    local damage=Hyperspace.ships.player:GetAugmentationValue("HACKING_DAMAGE")--could be calculate on system activation
    Hyperspace.ships.player.hackingSystem.currentSystem:PartialDamage(damage)
end,
})
--]]
--[[
mods.inferno.hackingcallbacks.activate_events:append({
function()
  system_location=Hyperspace.ships.player.hackingSystem.currentSystem.location
  local damage=Hyperspace.Damage()
  damage.bLockdown=true
  damage.fireChance=10
  Hyperspace.ships.enemy:DamageArea(system_location,damage,true)
end
})
--]]
