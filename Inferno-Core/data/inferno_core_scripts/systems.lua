mods.inferno.system_callbacks={
    sys_id=14,
    just_on=false,
    shutdown_events={},
    activate_events={},
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
