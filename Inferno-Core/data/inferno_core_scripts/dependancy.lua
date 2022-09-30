mods.inferno={}

mods.inferno.wait=function(seconds,func,loop)
  local current_time=Hyperspace.FPS.RunningTime
  local trigger_time=current_time+seconds
  local loop=loop or 1
  script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
      if Hyperspace.FPS.RunningTime>trigger_time and func then
        func()
        if loop>1 then
          mods.inferno.wait(seconds,func,loop-1)
        end
        func=nil
      end
   end)
end

mods.inferno.vter=function(cvec)
  local i=-1 --so the first returned value is indexed at zero
  local n=cvec:size()
  return function ()
      i=i+1
      if i<n then return cvec[i] end
  end
end

mods.inferno.repair=function()
  for system in mods.inferno.vter(Hyperspace.ships.player.vSystemList) do
    system.healthState.first=system.healthState.second
  end
end

mods.inferno.getLimitAmount=function(sys_id)
  if not Hyperspace.ships.player:HasSystem(sys_id) then return 0 end
  --priority is loss,limit,divide, as in divide overrides both loss and limit, and limit overrides loss
  local system=Hyperspace.ships.player:GetSystem(sys_id)
  local absolute_max_bars=Hyperspace.ships.player:GetSystemPowerMax(sys_id)--returns the maximum amount of power the system can have, so basically the level
  local current_max_bars=system:GetPowerCap() --only considers limit and divide events, not loss, this only matters if loss is the ONLY type of <status>
  if absolute_max_bars~=current_max_bars then
    return absolute_max_bars-current_max_bars
  elseif system.iTempPowerLoss>0 then
    return system.iTempPowerLoss
  else
    return 0
  end
  --this returns the amount of bars that have been limited
  --because divide overrides everything, it would be best to call Hyperspace.ships.player:ClearStatusSystem(sys_id) before applying a new limit based upon the old
end

script.on_game_event("ADD_LIMIT",false,function()
  local first_limit=mods.inferno.getLimitAmount(1)
  Hyperspace.ships.player:ClearStatusSystem(1)
  local new_limit=first_limit+1
  local cap=Hyperspace.ships.player:GetSystemPowerMax(1)
  Hyperspace.ships.player:GetSystem(1):SetPowerCap(cap-new_limit)
end)


mods.inferno.up={
    timer=999,--So it doesn't render on game startup
    config={
        print_x=100,
        print_y=100,
        font=10,
        line_length=400,
        duration=5,
        messages=10,
    },
    marker={
      w=2,
      h=2,
      x=0,
      y=0,
      on=false,
      color=Graphics.GL_Color(1.0,0.5,0.5,1.0),
    },
    render=function(self)
        if self.marker.on then
          Graphics.CSurface.GL_DrawRect(
          self.marker.x,
          self.marker.y,
          self.marker.w,
          self.marker.h,
          self.marker.color
        )
        end



        if self.timer <= self.config.duration then
            Graphics.freetype.easy_printAutoNewlines(
                self.config.font,
                self.config.print_x,
                self.config.print_y,
                self.config.line_length,
                table.concat(self.queue,"\n")
            )
           self.timer=self.timer+(Hyperspace.FPS.SpeedFactor/16)
        elseif #self.queue>1 then
            self.timer = 0 --Only reset timer when there are other elements in the array
            table.remove(self.queue,1)
        else
            table.remove(self.queue,1)
        end
    end,
    queue={},
    qs=function(self,string)
        if self.timer > self.config.duration then
            self.timer=0
        end
        table.insert(self.queue,tostring(string))
        if #self.queue > self.config.messages then
            table.remove(self.queue,1)
        end
    end,
    clear=function(self)
        self.queue={}
        self.timer=999
    end,
    mk=function(self,x,y)
      self.marker.x=x
      self.marker.y=y
      self:qs("X = "..x.." Y = "..y)
    end,
    mktoggle=function(self)
      self.marker.on=not self.marker.on
      self:qs("Marker on = "..self.marker.on)
    end,
}
script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function() end,
function()
 mods.inferno.up:render()
end
)


script.on_load(
function()
  --Creating a global variable with our addon's information,
  --so that dependancies can be checked when the game loads
  _G["INFERNO_CORE_INFO"]={
      version="0.5",--No idea what number to put here
      }
  if _G["FORGEMASTER_INFO"] then
    Hyperspace.ErrorMessage("Forgemaster was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
  end

  if _G["TCC_INFO"] then
    Hyperspace.ErrorMessage("Trash Compactor Collection was patched before Inferno-Core! Please re-patch your mods, and make sure to put Inferno-Core first!")
  end
end
)
