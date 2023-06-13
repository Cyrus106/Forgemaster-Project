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

local tutorialBox = dialogueBox:New {
  font = 1, --The font that the dialogue is rendered in
  x = 300, --x coordinate of the top-left corner of the dialogue box
  y = 100, --y coordinate of the top left corner of the dialogue box
  w = 400, --width of the dialogue box, including border (in pixels)
  h = 100, --height of the dialogue box, including border (in pixels)
  textSpeed = 30,
  text = {"Hello, welcome to the tutorial test, to the left you can see the broken tutorial text box, just ignore it please, we will remove it soon, then there will be only me. :)"} --An array of messages to display
}


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end, 
function()
  if Hyperspace.ships.player.myBlueprint.blueprintName == "PLAYER_SHIP_TUTORIAL" then
    tutorialBox:Render()
  end
end)

local shipStatBox = dialogueBox:New {
  font = 51, --The font that the dialogue is rendered in
  x = 335, --x coordinate of the top-left corner of the dialogue box
  y = 511, --y coordinate of the top left corner of the dialogue box
  w = 100, --width of the dialogue box (in pixels)
  h = 100, --height of the dialogue box (in pixels)
  text = {"Ship Stats (YOU SHOULD NOT SEE THIS MESSAGE)"}, --An array of messages to display  

  timer = 2147483647, --Such that text starts fully rendered
}

local shipCrewLimits = {}
local shipSystemLimits = {}

script.on_render_event(Defines.RenderEvents.MAIN_MENU, function() end, 
function()
  local playerShip = Hyperspace.ships.player
  if not Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and playerShip then
    local shipBlueprint = playerShip.myBlueprint
    shipStatBox.text[1] = string.format(
[[Slots:
Weapons: %i
Drones: %i
}: %i
|: %i
Hull: %i
Crewcap: %i
Systemcap: %i]], 
    shipBlueprint.weaponSlots,
    shipBlueprint.droneSlots,
    shipBlueprint.missiles,
    shipBlueprint.drone_count,
    shipBlueprint.health,
    shipCrewLimits[shipBlueprint.blueprintName],
    shipSystemLimits[shipBlueprint.blueprintName])
    shipStatBox:Render()
  end
end)
do
  local shipNode = RapidXML.xml_document("data/hyperspace.xml"):first_node("FTL"):first_node("ships"):first_node("customShip")
  local crewNode = shipNode:last_node("crewLimit")
  local systemNode = shipNode:last_node("systemLimit")
  local systemLimit
  local crewLimit
  if crewNode then
    crewLimit = tonumber(crewNode:value())
  end
  if systemNode then
    systemLimit = tonumber(systemNode:value())
  end
   --Default value of table will be defined value if there is one, or 8 if there is not
  crewLimit = crewLimit or 8 
  systemLimit = systemLimit or 8
  --When a value is not defined in the table, return the default
  setmetatable(shipCrewLimits, {__index = function() return crewLimit end}) 
  setmetatable(shipSystemLimits, {__index = function() return systemLimit end})

  shipNode = shipNode:next_sibling("customShip")
  local crewNode = nil
  local systemNode = nil
  while shipNode do
    local crewNode = shipNode:last_node("crewLimit")
    local systemNode = shipNode:last_node("systemLimit")
    if crewNode then
      local crewLimit = tonumber(crewNode:value())
      shipCrewLimits[shipNode:first_attribute("name"):value()] = crewLimit
    end
    if systemNode then
      local systemLimit = tonumber(systemNode:value())
      shipSystemLimits[shipNode:first_attribute("name"):value()] = systemLimit
    end
    shipNode = shipNode:next_sibling("customShip")
  end
end
