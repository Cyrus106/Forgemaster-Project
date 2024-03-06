local function CreateDefaultPrimitive(path)
  return Hyperspace.Resources:CreateImagePrimitiveString(path, 0, 0, 0, Graphics.GL_Color(1, 1, 1, 1), 1.0, false)
end
mods.inferno.augBoxes = {}
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
  ShouldRender = function(self,shipId)
    return Hyperspace.ships(shipId):GetAugmentationValue(self.augName) ~= 0 and self:RenderCondition(shipId)
  end,

  Render = function(self,shipId,alpha)
    Graphics.CSurface.GL_RenderPrimitiveWithAlpha(self.boxPrimitive,alpha or 1)
    Graphics.freetype.easy_print(
      0,
      35, 
      9, 
      string.format("%g%%", 100 * (self.baseValue + Hyperspace.ships(shipId):GetAugmentationValue(self.augName)))
    )
  end,
  New = function(self, table)
    self.__index = self
    setmetatable(table, self)
    table.boxPrimitive = CreateDefaultPrimitive("statusUI/"..table.augName:lower().."_counter.png")
    return table
  end,
}
local sysCdAugBox = augBox:New {
  Render = function(self,shipId,alpha)
    Graphics.CSurface.GL_RenderPrimitiveWithAlpha(self.boxPrimitive,alpha or 1)
    Graphics.freetype.easy_print(0,35,9,string.format("%g Ion", (self.baseValue - Hyperspace.ships(shipId):GetAugmentationValue(self.augName))))
  end
}

local augBoxes = {
  augBox:New {
    augName = "AUTO_COOLDOWN",
    baseValue = 1,
    RenderCondition = function(self,shipId) --If the player has any artilleries or the weapon system.
      local playerShip = Hyperspace.ships(shipId or 0)
      local hasArtillery = playerShip.artillerySystems:size() > 0
      local hasWeapons = playerShip:HasSystem(3)
      return hasArtillery or hasWeapons
    end
  },
  augBox:New { 
    augName = "SHIELD_RECHARGE",
    baseValue = 1,
    RenderCondition = function(self,shipId) --If the player has the shield system.
      local playerShip = Hyperspace.ships(shipId or 0)
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
    RenderCondition = function(self,shipId)
      return shipId==0
    end,
  },
  --inferno-core stuff
  augBox:New {
    augName = "DEIONIZATION_BOOST",
    baseValue = 5,
    Render = function(self,shipId,alpha)
      Graphics.CSurface.GL_RenderPrimitiveWithAlpha(self.boxPrimitive,alpha or 1)
      Graphics.freetype.easy_print(
        0,
        35, 
        9, 
        string.format("%.3gs/ion", (self.baseValue/(1+Hyperspace.ships(shipId):GetAugmentationValue(self.augName))))
      )
    end,
  },
  sysCdAugBox:New {
    augName = "FAST_CLOAK",
    baseValue = 4,
    RenderCondition = function(self,shipId)
      return Hyperspace.ships(shipId).cloakSystem ~= nil
    end,
  },
  sysCdAugBox:New {
    augName = "FAST_HACK",
    baseValue = 4,
    RenderCondition = function(self,shipId)
      return Hyperspace.ships(shipId).hackingSystem ~= nil
    end,
  },
  sysCdAugBox:New {
    augName = "FAST_MIND",
    baseValue = 4,
    RenderCondition = function(self,shipId)
      return Hyperspace.ships(shipId).mindSystem ~= nil
    end,
  },
  sysCdAugBox:New {
    augName = "FAST_TEMPORAL",
    baseValue = 2,--mv is so silly
    RenderCondition = function(self,shipId)
      return Hyperspace.ships(shipId):GetSystem(20) ~= nil
    end,
  },
}

local augBoxBox ={
  shipId = 0,
  boxBasePrimitive = nil,
  defaultX = 110,
  defaultY = 204,
  dragging = false,
  offsetX = 0,
  offsetY = 0,
  deltaX = 0,
  deltaY = 0,
  renderableBoxes = 0,
  dragBegin = function(self)
    local cApp = Hyperspace.Global.GetInstance():GetCApp()
    if not cApp.world.bStartedGame or cApp.gui.menu_pause then
        return
    end
    local playerShip = Hyperspace.ships(self.shipId)
    self.renderableBoxes=0
    for _, augBox in ipairs(augBoxes) do
      if augBox:ShouldRender(self.shipId) then
        self.renderableBoxes = self.renderableBoxes + 1
      end
    end
    if not (playerShip and not playerShip.bJumping) or self.renderableBoxes==0 then
        return
    end
    local currentX = self.defaultX + self.offsetX
    local currentY = self.defaultY + self.offsetY
    local mouse = Hyperspace.Mouse.position
    local iconWidth = 117
    local iconHeight = self.renderableBoxes * 24+2
    if currentX <= mouse.x and mouse.x < currentX + iconWidth and
        currentY <= mouse.y and mouse.y < currentY + iconHeight then
        self.dragging = true
        self.deltaX = mouse.x - currentX
        self.deltaY = mouse.y - currentY
    end
  end,
  Render = function(self)
    local defaultX = self.defaultX
	  local defaultY = self.defaultY
    local currentX = defaultX + self.offsetX
    local currentY = defaultY + self.offsetY
    local mouse = Hyperspace.Mouse.position
    local iconWidth = 117
    local iconHeight = self.renderableBoxes * 24
    local alpha = 1.0
    if self.dragging then
        currentX = mouse.x - self.deltaX
        currentY = mouse.y - self.deltaY
        self.offsetX = math.max(math.min(currentX - defaultX,1200-defaultX),-defaultX)
        self.offsetY = math.max(math.min(currentY - defaultY,700-defaultY),-defaultY)
    else
        if currentX <= mouse.x and mouse.x < currentX + iconWidth and
            currentY <= mouse.y and mouse.y < currentY + iconHeight then
            alpha = 0.4
        end
    end
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    Graphics.CSurface.GL_Translate(currentX, currentY)
    for _, augBox in ipairs(augBoxes) do
      if augBox:ShouldRender(self.shipId) then
        Graphics.CSurface.GL_RenderPrimitiveWithAlpha(self.boxBasePrimitive,alpha)
        augBox:Render(self.shipId, alpha)
        Graphics.CSurface.GL_Translate(0, 24)
      end
    end
    --Graphics.CSurface.GL_Translate(-currentX, -(currentY+24*self.renderableBoxes))
    Graphics.CSurface.GL_PopMatrix()
  end,
  New = function(self, table)
    self.__index = self
    setmetatable(table, self)
    table.boxBasePrimitive = CreateDefaultPrimitive("statusUI/augUI_base_"..table.shipId..".png")
    return table
  end
}
--[[
local xOffset = 110
local yOffset = 204


script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end,
function()
  if not Hyperspace.ships.player.bJumping and Hyperspace.ships.player:HasEquipment("fmcore_augbox_active") == 1 then
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    Graphics.CSurface.GL_Translate(xOffset, yOffset)
    for _, augBox in ipairs(augBoxes) do
      if augBox:ShouldRender() then
        Graphics.CSurface.GL_Translate(0, 24)
        augBox:Render()
      end
    end
    Graphics.CSurface.GL_PopMatrix()
  end
end)
--]]
--
mods.inferno.augBoxes.augBoxBoxes={
  [0] = augBoxBox:New {
    shipId = 0,
    defaultX = 110,
    defaultY = 204,
    dragging = false,
    offsetX = 0,
    offsetY = 0,
    deltaX = 0,
    deltaY = 0,
    renderableBoxes = 0,
  },
  [1] = augBoxBox:New {
    shipId = 1,
    defaultX = 670,
    defaultY = 104,
    dragging = false,
    offsetX = 0,
    offsetY = 0,
    deltaX = 0,
    deltaY = 0,
    renderableBoxes = 0,
  },
}

local augBoxBoxes = mods.inferno.augBoxes.augBoxBoxes
script.on_internal_event(Defines.InternalEvents.ON_MOUSE_R_BUTTON_DOWN, function() augBoxBoxes[0]:dragBegin() augBoxBoxes[1]:dragBegin() end)
    script.on_internal_event(Defines.InternalEvents.ON_MOUSE_R_BUTTON_UP, function()
      augBoxBoxes[0].dragging = false
      augBoxBoxes[1].dragging = false
      augBoxBoxes[0].deltaX = 0
      augBoxBoxes[1].deltaX = 0
      augBoxBoxes[0].deltaY = 0
      augBoxBoxes[1].deltaY = 0
    end)
script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end,
function()
  if not Hyperspace.ships.player.bJumping and Hyperspace.ships.player:HasEquipment("fmcore_augbox_active") == 1 then
    augBoxBoxes[0]:Render()
    if Hyperspace.ships(1) then
      augBoxBoxes[1]:Render()
    end
  end
end)

--[[ --the version with dragging the boxes
local dragging = false
local defaultX = 110
local defaultY = 204
--local xOffset = 110
--local yOffset = 204
local offsetX = 0
local offsetY = 0
local deltaX = 0
local deltaY = 0
local renderableBoxes = 0

local function dragBegin()
  local cApp = Hyperspace.Global.GetInstance():GetCApp()
  if not cApp.world.bStartedGame or cApp.gui.menu_pause then
      return
  end
  local playerShip = Hyperspace.ships.player
  renderableBoxes=0
  for _, augBox in ipairs(augBoxes) do
    if augBox:ShouldRender() then
      renderableBoxes = renderableBoxes + 1
    end
  end
  if not (playerShip and not playerShip.bJumping) or renderableBoxes==0 then
      return
  end
  local currentX = defaultX + offsetX
  local currentY = defaultY + offsetY
  local mouse = Hyperspace.Mouse.position
  local iconWidth = 117
  local iconHeight = renderableBoxes * 24+2
  if currentX <= mouse.x and mouse.x < currentX + iconWidth and
      currentY <= mouse.y and mouse.y < currentY + iconHeight then
      dragging = true
      deltaX = mouse.x - currentX
      deltaY = mouse.y - currentY
  end
end

script.on_internal_event(Defines.InternalEvents.ON_MOUSE_R_BUTTON_DOWN, dragBegin)
script.on_internal_event(Defines.InternalEvents.ON_MOUSE_R_BUTTON_UP, function()
  dragging = false
  deltaX = 0
  deltaY = 0
end)
script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, function() end,
function()
  if not Hyperspace.ships.player.bJumping and Hyperspace.ships.player:HasEquipment("fmcore_augbox_active") == 1 then
    local defaultX = defaultX
	  local defaultY = defaultY
    local currentX = defaultX + offsetX
    local currentY = defaultY + offsetY
    local mouse = Hyperspace.Mouse.position
    local iconWidth = 117
    local iconHeight = renderableBoxes * 24
    local alpha = 1.0
    if dragging then
        currentX = mouse.x - deltaX
        currentY = mouse.y - deltaY
        offsetX = math.max(math.min(currentX - defaultX,1100),-100)
        offsetY = math.max(math.min(currentY - defaultY,500),-200)
    else
        if currentX <= mouse.x and mouse.x < currentX + iconWidth and
            currentY <= mouse.y and mouse.y < currentY + iconHeight then
            alpha = 0.4
        end
    end
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_LoadIdentity()
    Graphics.CSurface.GL_Translate(currentX, currentY)
    for _, augBox in ipairs(augBoxes) do
      if augBox:ShouldRender() then
        augBox:Render(alpha)
        Graphics.CSurface.GL_Translate(0, 24)
      end
    end
    Graphics.CSurface.GL_PopMatrix()
  end
end)
--]]
-- display of enemy ammo and drone parts
local missileBox = CreateDefaultPrimitive("statusUI/top_missiles_on.png")
local missileBoxOff = CreateDefaultPrimitive("statusUI/top_missiles_on_red.png")
local droneBox = CreateDefaultPrimitive("statusUI/top_drones_on.png")
local droneBoxOff = CreateDefaultPrimitive("statusUI/top_drones_on_red.png")

script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL,
function()
  local playerShip = Hyperspace.ships.player
  local enemyShip = Hyperspace.ships.enemy
  if enemyShip and not playerShip.bJumping and playerShip:DoSensorsProvide(3) and Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame then
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
    if enemyShip:GetDroneCount() ~= 0 then
      Graphics.CSurface.GL_RenderPrimitive(droneBox)
    else
      Graphics.CSurface.GL_RenderPrimitive(droneBoxOff)
    end
    Graphics.freetype.easy_printCenter(0, 49, 15, string.format("%i", enemyShip:GetDroneCount()))
    Graphics.CSurface.GL_PopMatrix()
  end
end, function() end)


