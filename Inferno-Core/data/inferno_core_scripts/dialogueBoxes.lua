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
  x = 6, --x coordinate of the top-left corner of the dialogue box
  y = 59, --y coordinate of the top left corner of the dialogue box
  w = 178, --width of the dialogue box (in pixels)
  h = 51, --height of the dialogue box (in pixels)
  text = {"Ship Stats (YOU SHOULD NOT SEE THIS MESSAGE)"}, --An array of messages to display  

  timer = 2147483647, --Such that text starts fully rendered
  Render = function(self)
		if self.active then
			local currentText = self.text[self.textIndex]
			local charsToRender = math.floor(self.timer * self.textSpeed)
			if charsToRender > #currentText then
				charsToRender = #currentText
			else -- if not done, play sound
				if self.soundTimer > 0.07 then
					self.soundTimer = 0
					Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix(self.sound, 1, false)
				end
				self.soundTimer = self.soundTimer + Hyperspace.FPS.SpeedFactor / 16
			end
			currentText = currentText:sub(0, charsToRender)
			Graphics.CSurface.GL_DrawRect(self.x + 2, self.y + 2, self.w - 2, self.h - 2, self.fillColor)
			Graphics.CSurface.GL_DrawRectOutline(self.x, self.y, self.w, self.h, self.borderColor, 2)
			Graphics.freetype.easy_printAutoNewlines(self.font, self.x + 7, self.y + 2, self.w - 12, currentText)
			self.timer = self.timer + Hyperspace.FPS.SpeedFactor / 16
		end
	end,
}

script.on_render_event(Defines.RenderEvents.MAIN_MENU, function() end, 
function()
  local playerShip = nil
	playerShip = Hyperspace.ships.player
  if Hyperspace.Global.GetInstance():GetCApp().menu.shipBuilder.bOpen and playerShip then
		local shipBlueprint = playerShip.myBlueprint
		local crewCap = Hyperspace.CustomShipSelect.GetInstance():GetDefinition(shipBlueprint.blueprintName).crewLimit
		local sysCap = Hyperspace.CustomShipSelect.GetInstance():GetDefinition(shipBlueprint.blueprintName).systemLimit
    shipStatBox.text[1] = string.format(
    "Hull: %i    Weapons: %i    Drones: %i\n}: %i    |: %i\nCrew Cap: %i    System Cap: %i", 
    shipBlueprint.health,
    shipBlueprint.weaponSlots,
    shipBlueprint.droneSlots,
    shipBlueprint.missiles,
    shipBlueprint.drone_count,
    crewCap or 8,
    sysCap or 8)
    shipStatBox:Render()
  end
end)
