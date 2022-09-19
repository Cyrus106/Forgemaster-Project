mods.inferno={}



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
    mktoggle=function()
      self.marker.on=not self.marker.on
      self:qs("Marker on = "..self.marker.on)
    end,
}
script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, nothing,
function()
 up:render()
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
