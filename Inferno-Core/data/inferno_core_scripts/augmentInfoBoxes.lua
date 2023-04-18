local function CreateDefaultPrimitive(path)
  return Hyperspace.Resources:CreateImagePrimitiveString(path, 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
end

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
    table.boxPrimitive = CreateDefaultPrimitive("statusUI/"..table.augName:lower().."_counter.png")
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
function()
  if not Hyperspace.ships.player.bJumping and Hyperspace.ships.player:HasEquipment("fmcore_augbox_active") == 1 then
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    Graphics.CSurface.GL_Translate(xOffset, yOffset)
    for _, augBox in ipairs(augBoxes) do
      if augBox:ShoulRender() then
        Graphics.CSurface.GL_Translate(0, 24)
        augBox:Render()
      end
    end
    Graphics.CSurface.GL_PopMatrix()
  end
end)

-- display of enemy ammo and drone parts
local missileBox = CreateDefaultPrimitive("statusUI/top_missiles_on.png")
local missileBoxOff = CreateDefaultPrimitive("statusUI/top_missiles_on_red.png")
local droneBox = CreateDefaultPrimitive("statusUI/top_drones_on.png")
local droneBoxOff = CreateDefaultPrimitive("statusUI/top_drones_on_red.png")

script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL,
function()
  local playerShip = Hyperspace.ships.player
  local enemyShip = Hyperspace.ships.enemy
  if enemyShip and not playerShip.bJumping and playerShip:DoSensorsProvide(3) then
    local enemyMissiles
    --Re-implementation of native ShipManager::GetMissileCount function, replace when exposed
    if enemyShip:HasSystem(3) then
      enemyMissiles = enemyShip.weaponSystem.missile_count
    else
      enemyMissiles = enemyShip.tempMissileCount
    end

    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    Graphics.CSurface.GL_Translate(921, 7)
    
    if enemyMissiles ~= 0 then
      Graphics.CSurface.GL_RenderPrimitive(missileBox)
    else
      Graphics.CSurface.GL_RenderPrimitive(missileBoxOff)
    end
    Graphics.freetype.easy_printCenter(0, 49, 15, string.format("%i", enemyMissiles))
    
    Graphics.CSurface.GL_Translate(70, 0)
    if enemyShip:GetDroneCount() ~=0 then
      Graphics.CSurface.GL_RenderPrimitive(droneBox)
    else
      Graphics.CSurface.GL_RenderPrimitive(droneBoxOff)
    end
    Graphics.freetype.easy_printCenter(0, 49, 15, string.format("%i", enemyShip:GetDroneCount()))
    Graphics.CSurface.GL_PopMatrix()
  end
end, function() end)