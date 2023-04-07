--Info Box Class
local augBox = {
  --Member Variables
  augName = "AUG_NAME",
  baseValue = 0,

  boxPrimitive = nil,
  --Member Functions
  RenderCondition = function(self)
    return true
  end,
  ShoulRender = function(self)
    return Hyperspace.ships.player:GetAugmentationValue(self.augName) ~= 0 and self:RenderCondition()
  end,

  Render = function(self)
    Graphics.CSurface.GL_RenderPrimitive(self.boxPrimitive)
    Graphics.freetype.easy_print(
      0,
      35, 
      9, 
      string.format("%g%%", 100 * (self.baseValue + Hyperspace.ships.player:GetAugmentationValue(self.augName)))
    )
  end,
  New = function(self, table)
    self.__index = self
    setmetatable(table, self)
    table.boxPrimitive = Hyperspace.Resources:CreateImagePrimitiveString(
      "statusUI/"..table.augName:lower().."_counter.png",
      0,
      0,
      0,
      Graphics.GL_Color(1, 1, 1, 1),
      1.0,
      false
    )
    return table
  end,
}

local augBoxes = {
  augBox:New {
    augName = "AUTO_COOLDOWN",
    baseValue = 1,
    RenderCondition = function(self) --If the player has any artilleries or the weapon system.
      local playerShip = Hyperspace.ships.player
      local hasArtillery = playerShip.artillerySystems:size() > 0
      local hasWeapons = playerShip:HasSystem(3)
      return hasArtillery or hasWeapons
    end
  },
  augBox:New { 
    augName = "SHIELD_RECHARGE",
    baseValue = 1,
    RenderCondition = function(self) --If the player has the shield system.
      local playerShip = Hyperspace.ships.player
      local hasShields = playerShip:HasSystem(0)
      return hasShields
    end,
  },
  augBox:New {
    augName = "EXPLOSIVE_REPLICATOR",
  },
  augBox:New {
    augName = "ROCK_ARMOR",
  },
  augBox:New {
    augName = "ION_ARMOR",
  },
  augBox:New {
    augName = "SYSTEM_CASING",
  },
  augBox:New {
    augName = "SCRAP_COLLECTOR",
    baseValue = 1,
  },
}

local xOffset = 110
local yOffset = 204


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end,
function(self)
  Graphics.CSurface.GL_PushMatrix()
  Graphics.CSurface.GL_LoadIdentity()
  local extraYOffset = 0
  Graphics.CSurface.GL_Translate(xOffset, yOffset)
  for _, augBox in ipairs(augBoxes) do
    if augBox:ShoulRender() then
      Graphics.CSurface.GL_Translate(0, 24)
      augBox:Render()
    end
  end
  Graphics.CSurface.GL_PopMatrix()
end)