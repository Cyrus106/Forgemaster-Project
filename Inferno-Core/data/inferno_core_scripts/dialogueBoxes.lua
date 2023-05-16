
local dialogueBox = {
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
            Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix(self.sound, 1, false)
          end
          currentText = currentText:sub(0, charsToRender)
          Graphics.CSurface.GL_DrawRect(self.x, self.y, self.w, self.h, self.fillColor)
          Graphics.CSurface.GL_DrawRectOutline(self.x - 5, self.y - 5, self.w + 5, self.h + 5, self.borderColor, 5)
          Graphics.freetype.easy_printAutoNewlines(
              self.font, 
              self.x + 5, 
              self.y + 5, 
              self.w - 10, 
              currentText
          )
          self.timer = self.timer + Hyperspace.FPS.SpeedFactor / 16
      end
  end,
  Advance = function(self)
      self.textIndex = self.textIndex + 1
      self.timer = 0
      if self.textIndex > #self.text then
          self.active = false
      end
  end,

  Reset = function(self)
      self.textIndex = 1
      self.timer = 0
      self.active = true
  end,

  New = function(self, table)
      self.__index = self
      setmetatable(table, self)
      return table
  end,
}

tutorialBox = dialogueBox:New {
  font = 1, 
  x = 300, 
  y = 200, 
  w = 400,
  h = 200, 
  text = {"Hello, welcome to the tutorial test, to the left you can see the broken tutorial text box, just ignore it please, we will remove it soon, then there will be only me. :)"}
}


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end, 
function()
  tutorialBox:Render()
end)