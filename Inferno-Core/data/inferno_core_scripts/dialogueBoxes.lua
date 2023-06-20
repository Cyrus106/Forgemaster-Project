local dialogueBox = mods.inferno.dialogueBox

tutorialBox = dialogueBox:New {
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
  font = 6, --The font that the dialogue is rendered in
  x = 335, --x coordinate of the top-left corner of the dialogue box
  y = 511, --y coordinate of the top left corner of the dialogue box
  w = 100, --width of the dialogue box (in pixels)
  h = 140, --height of the dialogue box (in pixels)
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
