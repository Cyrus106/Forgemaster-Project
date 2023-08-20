local vter = mods.inferno.vter
local RoomEffect = mods.inferno.RoomEffect

local ionResistEffect = RoomEffect:New {
  borderColor = Graphics.GL_Color(21 / 255, 62 / 255, 61 / 255, 1),
  roomColor = Graphics.GL_Color(78 / 255, 107 / 255, 98 / 255, 1),
  gradient = {
    Graphics.GL_Color(65 / 255, 171 / 255, 130 / 255, 1),
    Graphics.GL_Color(71 / 255, 148 / 255, 117 / 255, 1),
    Graphics.GL_Color(75 / 255, 130 / 255, 108 / 255, 1),
    Graphics.GL_Color(76 / 255, 118 / 255, 103 / 255, 1),
    Graphics.GL_Color(77 / 255, 112 / 255, 100 / 255, 1),
    Graphics.GL_Color(78 / 255, 109 / 255, 99 / 255, 1),
  },
}


local systemResistEffect = RoomEffect:New {
  borderColor = Graphics.GL_Color(61 / 255, 69 / 255, 69 / 255, 1),
  roomColor = Graphics.GL_Color(135 / 255, 147 / 255, 148 / 255, 1),
}

local ResistIcon = {
  icon = nil,
  fill = nil,
  color = Graphics.GL_Color(1, 1, 1, 1),
  
  Render = function(self, room, fillFraction, color)
    color = color or self.color

    Graphics.CSurface.GL_Translate(room.rect.x, room.rect.y)
    Graphics.CSurface.GL_RenderPrimitive(self.icon)
    Graphics.CSurface.GL_Translate(-room.rect.x, -room.rect.y)
    Graphics.CSurface.GL_BlitImagePartial(
      self.fill, 
      room.rect.x,
      room.rect.y + self.fill.height * (1 - fillFraction), 
      self.fill.width, 
      fillFraction * self.fill.height,
      0, 
      1, 
      1 - fillFraction, 
      1, 
      1, 
      color, 
      false)
  end,
  
  New = function(self, table)
    table = table or {}
    self.__index = self
    setmetatable(table, self)
    table.icon = Hyperspace.Resources:CreateImagePrimitiveString(
      table.icon, 
      0, 
      0, 
      0, 
      Graphics.GL_Color(1, 1, 1, 1), 
      1.0, 
      false)
    table.fill = Hyperspace.Resources:GetImageId(table.fill)
    return table
  end
}


local systemFill = Graphics.GL_Color(1, 1, 1, 1)
local ionFill = Graphics.GL_Color(0, 255 / 255, 178 / 255, 1)


local leftShield = ResistIcon:New {
  icon = "resistIcons/resist_shield_ui_left.png",
  fill = "resistIcons/resist_shield_ui_fill_left.png",
  color = systemFill,
}
local rightShield = ResistIcon:New {
  icon = "resistIcons/resist_shield_ui_right.png",
  fill = "resistIcons/resist_shield_ui_fill_right.png",
  color = ionFill,
}






script.on_render_event(Defines.RenderEvents.SHIP_FLOOR, function(Ship, experimental) end,
function(Ship, experimental)
  for room in vter(Ship.vRoomList) do
    if not room.bBlackedOut then
      local sysResist = room.extend.sysDamageResistChance
      local ionResist = room.extend.ionDamageResistChance
      if sysResist > ionResist and sysResist > 0 then
        systemResistEffect:Render(room)
      elseif ionResist >= sysResist and ionResist > 0 then
        ionResistEffect:Render(room)
      end
    end
  end
end)

script.on_render_event(Defines.RenderEvents.SHIP_MANAGER, function(ShipManager, showInterior, doorControlMode) end,
function(ShipManager, showInterior, doorControlMode)
  local canSeeRooms = false
 
  if ShipManager.iShipId == 1 then
      canSeeRooms = (ShipManager._targetable.hostile and (not ShipManager:HasSystem(10) or not ShipManager.cloakSystem.bTurnedOn)) or ShipManager.bContainsPlayerCrew
  else
      canSeeRooms = ShipManager.bShowRoom
  end

  canSeeRooms = canSeeRooms and not ShipManager.bDestroyed and not ShipManager.bJumping
  
  if canSeeRooms then
    for room in vter(ShipManager.ship.vRoomList) do
      local sysResist = room.extend.sysDamageResistChance
      local ionResist = room.extend.ionDamageResistChance
      if sysResist > 0 or ionResist > 0 then
        Graphics.CSurface.GL_Translate(4, 4)
        if sysResist <= 0 then
          leftShield:Render(room, ionResist / 100, ionFill)
          rightShield:Render(room, ionResist / 100)
        elseif ionResist <= 0 then
          leftShield:Render(room, sysResist / 100)
          rightShield:Render(room, sysResist / 100, systemFill)
        else
          leftShield:Render(room, sysResist / 100)
          rightShield:Render(room, ionResist / 100)
        end
        Graphics.CSurface.GL_Translate(-4, -4)
      end
    end
  end
 
end)
--[[
Renderlayer 0: Ship::OnRenderFloor (After) SHIP_FLOOR
Renderlayer 1 Ship::OnRenderBreaches (Before) SHIP_BREACHES
Renderlayer 2 Ship::OnRenderSparks (Before) SHIP_SPARKS
Renderlayer 3 ShipManager::OnRender (After) (Rooms must be visible) SHIP_MANAGER
Renderlayer 4 ShipManager::OnRender (After) SHIP_MANAGER
--]]