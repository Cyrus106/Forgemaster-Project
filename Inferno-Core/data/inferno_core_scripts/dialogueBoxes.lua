
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
  font = 1, --The font that the dialogue is rendered in
  x = 300, --x coordinate of the top-left corner of the dialogue box
  y = 200, --y coordinate of the top left corner of the dialogue box
  w = 400, --width of the dialogue box (in pixels)
  h = 200, --height of the dialogue box (in pixels)
  textSpeed = 30,
  text = {"Hello, welcome to the tutorial test, to the left you can see the broken tutorial text box, just ignore it please, we will remove it soon, then there will be only me. :)"} --An array of messages to display
}


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end, 
function()
  if Hyperspace.ships.player.myBlueprint.blueprintName=="PLAYER_SHIP_TUTORIAL" then
    tutorialBox:Render()
  end
end)

shipStatBox = dialogueBox:New {
  font = 1, --The font that the dialogue is rendered in
  x = 335, --x coordinate of the top-left corner of the dialogue box
  y = 516, --y coordinate of the top left corner of the dialogue box
  w = 105, --width of the dialogue box (in pixels)
  h = 170, --height of the dialogue box (in pixels)
  text = {"ship stats go here"}, --An array of messages to display  
  Render = function(self) --simplified render function because no typing needed!
      if self.active then
          Graphics.CSurface.GL_DrawRect(self.x, self.y, self.w, self.h, self.fillColor)
          Graphics.CSurface.GL_DrawRectOutline(self.x - 5, self.y - 5, self.w + 5, self.h + 5, self.borderColor, 5)
          Graphics.freetype.easy_print(
              self.font, 
              self.x + 5, 
              self.y + 5, 
              --self.w - 10, 
              self.text[self.textIndex]
          )
      end
  end,11
}

StatTexts = {
  "Slots:\nWeapons: ",
  "\nDrones: ",
  "\n\n}: ",
  " |: ",
  "\nHull: ",
  "\nCrewcap: ",
  "\nSystemcap: ",
}

shipCrewLimits={}
shipSystemLimits={}

GetShipStats = function(theShip) 
  shipStatBox.text[1]=StatTexts[1]..math.floor(theShip.weaponSlots)..StatTexts[2]..math.floor(theShip.droneSlots)..StatTexts[3]..math.floor(theShip.missiles)..StatTexts[4]..math.floor(theShip.drone_count)..StatTexts[5]..math.floor(theShip.health)
  
  shipStatBox.text[1]=shipStatBox.text[1]..StatTexts[6]..(math.floor(shipCrewLimits[theShip.blueprintName] or shipCrewLimits[DEFAULT] or 8))
  
  shipStatBox.text[1]=shipStatBox.text[1]..StatTexts[7]..(math.floor(shipSystemLimits[theShip.blueprintName] or shipSystemLimits[DEFAULT] or 8))
end

script.on_render_event(Defines.RenderEvents.MAIN_MENU, function() end, 
function()
  if (not Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame) and Hyperspace.Global.GetInstance():GetShipManager(0) then
    theShip=Hyperspace.Global.GetInstance():GetShipManager(0).myBlueprint
    GetShipStats(theShip)
    shipStatBox:Render()
  end
end)
do
  local shipNode = RapidXML.xml_document("data/hyperspace.xml"):first_node("FTL"):first_node("ships"):first_node("customShip")
  local crewNode = shipNode:last_node("crewLimit")
  local systemNode = shipNode:last_node("systemLimit")
  if crewNode then
    local crewLimit = tonumber(crewNode:value())
    if crewLimit and crewLimit ~= 8 then
      shipCrewLimits[DEFAULT] = crewLimit
    end
  end
  if systemNode then
    local systemLimit = tonumber(systemNode:value())
    if systemLimit and systemLimit ~= 8 then
      shipSystemLimits[DEFAULT] = systemLimit
    end
  end
  shipNode = shipNode:next_sibling("customShip")
  local crewNode = nil
  local systemNode = nil
  while shipNode do
    local crewNode = shipNode:last_node("crewLimit")
    local systemNode = shipNode:last_node("systemLimit")
    if crewNode then
      local crewLimit = tonumber(crewNode:value())
      if crewLimit and crewLimit ~= 8 then
        shipCrewLimits[shipNode:first_attribute("name"):value()] = crewLimit
      end
    end
    if systemNode then
      local systemLimit = tonumber(systemNode:value())
      if systemLimit and systemLimit ~= 8 then
        shipSystemLimits[shipNode:first_attribute("name"):value()] = systemLimit
      end
    end
    shipNode = shipNode:next_sibling("customShip")
  end
end--]]
