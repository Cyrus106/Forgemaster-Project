local vter = mods.inferno.vter
local eventParser = Hyperspace.CustomEventsParser.GetInstance()
local capp = Hyperspace.Global.GetInstance():GetCApp()
local function copyTable(t)
	local newT = {}
	for k, v in pairs(t) do
		newT[k]=v
	end
	return newT
end

local UNIQUE_KEY = {}

local loadEvent = function(Event)
  eventParser:LoadEvent(capp.world,Event,false,-1)
end
local addHiddenAugmentation = function(ShipManager,augmentId)
  ShipManager:AddAugmentation("HIDDEN "..augmentId)
  ShipManager:RemoveItem(augmentId)
end

local modulesToCap={
  ["FM_MODULAR_HULL_FORTIFIED"]=5,
  ["FM_MODULAR_HULL_NO_BREACH"]=5,
  ["FM_MODULAR_HULL_NO_FIRE"]=5,
  ["FM_MODULAR_HULL_RESILIENT"]=5,
  ["FM_MODULAR_HULL_GUARDIAN"]=5,
  ["FM_MODULAR_HULL_FLOORING"]=5,
  ["FM_MODULAR_HULL_VENGEANCE1"]=5,
  --update
  ["FM_MODULAR_HULL_UPDATE_WEAPONS"]=1,
  ["FM_MODULAR_HULL_UPDATE_SHIELDS"]=1,
  --["FM_MODULAR_HULL_UPDATE_ENGINES"]=1,
  ["FM_MODULAR_HULL_UPDATE_MED"]=1,
  --["FM_MODULAR_HULL_UPDATE_DRONES"]=1,
  --["FM_MODULAR_HULL_UPDATE_OXYGEN"]=1,
  --["FM_MODULAR_HULL_UPDATE_TELEPORTER"]=1,
  ["FM_MODULAR_HULL_UPDATE_CLOAKING"]=1,
  --["FM_MODULAR_HULL_UPDATE_PILOT"]=1,
  --["FM_MODULAR_HULL_UPDATE_DOORS"]=1,
  --turrets
  ["FM_MODULAR_HULL_TURRET_WEAPONS"]=1,
  ["FM_MODULAR_HULL_TURRET_SHIELDS"]=1,
  ["FM_MODULAR_HULL_TURRET_ENGINES"]=1,
  ["FM_MODULAR_HULL_TURRET_MED"]=1,
  ["FM_MODULAR_HULL_TURRET_DRONES"]=1,
  ["FM_MODULAR_HULL_TURRET_OXYGEN"]=1,
  ["FM_MODULAR_HULL_TURRET_TELEPORTER"]=1,
  ["FM_MODULAR_HULL_TURRET_CLOAKING"]=1,
  ["FM_MODULAR_HULL_TURRET_PILOT"]=1,
  ["FM_MODULAR_HULL_TURRET_DOORS"]=1,
  --sys cd
  ["FM_MODULAR_HULL_CLOAK_COOLDOWN"]=1,
  --more expensive stuff
  ["FM_MODULAR_HULL_ENCASED"]=5,--2 notches
  ["FM_MODULAR_HULL_VENGEANCE2"]=5,--2 notches
  ["FM_MODULAR_HULL_AERO"]=5,--3 notches
}
local modules={
  "FM_MODULAR_HULL_FORTIFIED",
  "FM_MODULAR_HULL_NO_BREACH",
  "FM_MODULAR_HULL_NO_FIRE",
  "FM_MODULAR_HULL_RESILIENT",
  "FM_MODULAR_HULL_GUARDIAN",
  "FM_MODULAR_HULL_FLOORING",
  "FM_MODULAR_HULL_VENGEANCE1",
  --update
  "FM_MODULAR_HULL_UPDATE_WEAPONS",
  "FM_MODULAR_HULL_UPDATE_SHIELDS",
  --"FM_MODULAR_HULL_UPDATE_ENGINES",
  "FM_MODULAR_HULL_UPDATE_MED",
  --"FM_MODULAR_HULL_UPDATE_DRONES",
  --"FM_MODULAR_HULL_UPDATE_OXYGEN",
  --"FM_MODULAR_HULL_UPDATE_TELEPORTER",
  "FM_MODULAR_HULL_UPDATE_CLOAKING",
  --"FM_MODULAR_HULL_UPDATE_PILOT",
  --"FM_MODULAR_HULL_UPDATE_DOORS",
  --turrets
  "FM_MODULAR_HULL_TURRET_WEAPONS",
  "FM_MODULAR_HULL_TURRET_SHIELDS",
  "FM_MODULAR_HULL_TURRET_ENGINES",
  "FM_MODULAR_HULL_TURRET_MED",
  "FM_MODULAR_HULL_TURRET_DRONES",
  "FM_MODULAR_HULL_TURRET_OXYGEN",
  "FM_MODULAR_HULL_TURRET_TELEPORTER",
  "FM_MODULAR_HULL_TURRET_CLOAKING",
  "FM_MODULAR_HULL_TURRET_PILOT",
  "FM_MODULAR_HULL_TURRET_DOORS",
  --sys cd
  "FM_MODULAR_HULL_CLOAK_COOLDOWN",
  --more expensive stuff
  "FM_MODULAR_HULL_ENCASED",--2 notches
  "FM_MODULAR_HULL_VENGEANCE2",--2 notches
  "FM_MODULAR_HULL_AERO",--3 notches
}
local capstones={
  --"FM_MODULAR_HULL_SALT",--both op and terrible at the same time
  --"FM_MODULAR_HULL_DUSK",-- too lazy to art
  --"FM_MODULAR_HULL_MURAL",--only works for player
  "FM_MODULAR_HULL_COMPRESS",
  --"FM_MODULAR_HULL_UPLINK",--probably bad for alastair
  "FM_MODULAR_HULL_FASTSHIELD",
  "FM_MODULAR_HULL_FASTWEAPON",
  --"FM_MODULAR_HULL_PERFECT",--not impactful?
  "FM_MODULAR_HULL_MAGNETIC",
  --"FM_MODULAR_HULL_CREWKILL",--too lazy to art
  "FM_MODULAR_HULL_PARTICLE",
  "FM_MODULAR_HULL_RESISTSMASH",
  "FM_MODULAR_HULL_WEAPON_IGNITE",
  "FM_MODULAR_HULL_OFFENSE_SCRAMBLE",
  "FM_MODULAR_HULL_DEFENSE_SCRAMBLE",
}


local getNewRandomModularThingy = function(ShipManager,thingy,cap)
  if not ShipManager.table[UNIQUE_KEY] then
    ShipManager.table[UNIQUE_KEY]={
      ["remainingMods"] = copyTable(modules),
      ["remainingCapstones"] = copyTable(capstones),
    }
  end
  local rand = nil
  local randomThingy = nil
  if #ShipManager.table[UNIQUE_KEY][thingy]>0 then 
    rand=math.random(#ShipManager.table[UNIQUE_KEY][thingy])
    randomThingy = ShipManager.table[UNIQUE_KEY][thingy][rand]
  else
    if thingy=="remainingMods" then
      rand=math.random(#modules)
      randomThingy = modules[rand]
    else
      rand=math.random(#capstones)
      randomThingy = capstones[rand]
    end
  end
  while true do
    if not cap then cap={} end
    if ShipManager:HasAugmentation(randomThingy) < (cap[randomThingy] or 1) then
      return randomThingy
    end
    if #ShipManager.table[UNIQUE_KEY][thingy]<=0 then
      break
    elseif #ShipManager.table[UNIQUE_KEY][thingy]==1 then
      table.remove(ShipManager.table[UNIQUE_KEY][thingy],rand)
      break
    end
    table.remove(ShipManager.table[UNIQUE_KEY][thingy],rand)
    rand=math.random(#ShipManager.table[UNIQUE_KEY][thingy])
    randomThingy = ShipManager.table[UNIQUE_KEY][thingy][rand] or randomThingy
  end
  return randomThingy
end


local getNewRandomModule = function(ShipManager)
  return getNewRandomModularThingy(ShipManager,"remainingMods",modulesToCap)
end
local getNewRandomCapstone = function(ShipManager)
  return getNewRandomModularThingy(ShipManager,"remainingCapstones")
end

local function installNextCapstone(ShipManager)
  local currentNotches = ShipManager:HasEquipment("FM_HULL_UPGRADE_POINTS")
  local currentCapstones = ShipManager:HasEquipment("FM_HULL_CAPSTONES")
  while true do 
    if currentNotches-5*currentCapstones>4 then
      local newthing=getNewRandomCapstone(ShipManager)
      --print(currentNotches.." "..newthing)
      addHiddenAugmentation(ShipManager,newthing)
      return
    end
    local newthing=getNewRandomModule(ShipManager)
    --print(newthing)
    addHiddenAugmentation(ShipManager,newthing)
    currentNotches = ShipManager:HasEquipment("FM_HULL_UPGRADE_POINTS")
    --print(currentNotches)
  end
end


local fixAllSys = function(ShipManager)
  for sys in vter(ShipManager.vSystemList) do
    sys.healthState.first=sys.healthState.second
  end
end
local upAllMainSys = function(ShipManager)
  for sys in vter(ShipManager.vSystemList) do
    local sysId = sys:GetId()
    if not Hyperspace.ShipSystem.IsSubsystem(sysId) then
      if not (((sysId==9 or sysId==13) and sys.healthState.second>=4) or (sysId==1 and sys.healthState.second>=8) or (sysId==10 and sys.healthState.second>=3)) and sys.healthState.second<30 then 
        sys:UpgradeSystem(1)
      end
    end
  end
end
local upSpecialSys = function(ShipManager)
  local sysIds={[0]=1,[1]=1,[3]=2,[4]=2}
  for k,v in pairs(sysIds) do
    local sys = ShipManager:GetSystem(k)
    if sys.healthState.second<30 and not (sys.healthState.second>7 and k==1)then
      sys:UpgradeSystem(math.min(v,30-sys.healthState.second))
    end
  end
  --[[ShipManager:GetSystem(0):UpgradeSystem(1)
  ShipManager:GetSystem(1):UpgradeSystem(1)
  ShipManager:GetSystem(3):UpgradeSystem(2)
  ShipManager:GetSystem(4):UpgradeSystem(2)--]]
end
local multiStageFightEvents ={
  FM_FORGEMASTER_CRUISER_ENEMY = {
    default = function(ShipManager)
      loadEvent("FORGEMASTER_PHASE_DEFAULT_END")
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
    end,
    function(ShipManager)
      loadEvent("FORGEMASTER_PHASE_3_END")
      ShipManager:GetSystem(4):UpgradeSystem(math.min(6,30-ShipManager:GetSystem(4).healthState.second))
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
    end,
    function(ShipManager)
      loadEvent("FORGEMASTER_PHASE_2_END")
      ShipManager:GetSystem(9):ClearStatus()
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
    end,
    function(ShipManager)
      loadEvent("FORGEMASTER_PHASE_1_END")
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
    end,
  },
  FM_FORGEMASTER_CRUISER_ENEMY_LAST_STRAW = {
    default = function(ShipManager)
      loadEvent("FORGEMASTER_PHASE_DEFAULT_END_NOMERCY")
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
      installNextCapstone(ShipManager)
    end,
    [4] = function(ShipManager)
      loadEvent("FORGEMASTER_RETALIATE")
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
      installNextCapstone(ShipManager)
    end,
    [2] = function(ShipManager)
      loadEvent("FORGEMASTER_RETALIATE_STRONK")
      fixAllSys(ShipManager)
      upAllMainSys(ShipManager)
      upSpecialSys(ShipManager)
      installNextCapstone(ShipManager)
      installNextCapstone(ShipManager)
    end,
  }
}
local forgeFightEvents ={
  default = function(ShipManager)
    loadEvent("FORGEMASTER_PHASE_3_END")
    ShipManager:GetSystem(4):UpgradeSystem(math.min(6,30-ShipManager:GetSystem(4).healthState.second))
    fixAllSys(ShipManager)
    upAllMainSys(ShipManager)
    upSpecialSys(ShipManager)
    installNextCapstone(ShipManager)
  end,
  function(ShipManager)
    loadEvent("FORGEMASTER_PHASE_3_END")
    ShipManager:GetSystem(4):UpgradeSystem(math.min(6,30-ShipManager:GetSystem(4).healthState.second))
    fixAllSys(ShipManager)
    upAllMainSys(ShipManager)
    upSpecialSys(ShipManager)
    installNextCapstone(ShipManager)
  end,
  function(ShipManager)
    loadEvent("FORGEMASTER_PHASE_2_END")
    ShipManager:GetSystem(9):ClearStatus()
    fixAllSys(ShipManager)
    upAllMainSys(ShipManager)
    upSpecialSys(ShipManager)
    installNextCapstone(ShipManager)
  end,
  function(ShipManager)
    loadEvent("FORGEMASTER_PHASE_1_END")
    fixAllSys(ShipManager)
    upAllMainSys(ShipManager)
    upSpecialSys(ShipManager)
    installNextCapstone(ShipManager)
  end,
}

local undyingShip = function(ShipManager,Damage,Projectile)
  local revives = ShipManager:HasAugmentation("FM_REVIVE")
  if revives>0 and (ShipManager.ship.hullIntegrity.first-Damage.iDamage<1 or (Damage.bhullBuster==true and ShipManager.ship.hullIntegrity.first-Damage.iDamage*2<1)) then
    if Projectile then Projectile:Kill() end
    local space = Hyperspace.Global.GetInstance():GetCApp().world.space
    for proj in vter(space.projectiles) do
      if proj.targetId==ShipManager.iShipId and proj.currentSpace == ShipManager.iShipId then
        proj:Kill()
      end
    end
    Damage.iDamage=0
    ShipManager.ship.hullIntegrity.first=ShipManager.ship.hullIntegrity.second
    --print("fixedShip")
    ShipManager:RemoveItem("HIDDEN FM_REVIVE")
    if multiStageFightEvents[ShipManager.myBlueprint.blueprintName] then
      if multiStageFightEvents[ShipManager.myBlueprint.blueprintName][revives] then
        multiStageFightEvents[ShipManager.myBlueprint.blueprintName][revives](ShipManager)
      else
        multiStageFightEvents[ShipManager.myBlueprint.blueprintName]["default"](ShipManager)
      end
    end
    --[[
    if ShipManager.myBlueprint.blueprintName == "FM_FORGEMASTER_CRUISER_ENEMY" then
      --ShipManager.ship.hullIntegrity.second = ShipManager.ship.hullIntegrity.second*2
      if forgeFightEvents[revives] then
        forgeFightEvents[revives](ShipManager)
      end
      fixAllSys(ShipManager)
      --print("fixedSystems")
      upAllMainSys(ShipManager)
      --print("Upgraded1")
      upSpecialSys(ShipManager)
      --print("Upgraded2")
      installNextCapstone(ShipManager)
      --print(ShipManager:HasEquipment("FM_HULL_CAPSTONES").."th Capstone given")
    end
    --]]
    return true
    --print("good thing he had a totem of undying :)")
  end
  return false
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA,
  function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    if undyingShip(ShipManager,Damage,Projectile) then
      return Defines.Chain.PREEMPT, forceHit, shipFriendlyFire
    else
      return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
    end
  end, 1000
)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
  function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    if undyingShip(ShipManager,Damage,Projectile) then
      return Defines.Chain.PREEMPT, beamHitType
    else
      return Defines.Chain.CONTINUE, beamHitType
    end
  end, 1000
)
--[[script.on_internal_event(Defines.InternalEvents.DAMAGE_SYSTEM, 
  function(ShipManager, Projectile,roomId, Damage)
    undyingShip(ShipManager,Damage)
    return Defines.Chain.CONTINUE
  end, 1000
)--]]
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
function(ship)
  if ship:HasAugmentation("FM_REVIVE")>0 and ship.ship.hullIntegrity.first<6 then
    local dmg = Hyperspace.Damage()
    dmg.iDamage=2
    undyingShip(ship,dmg)
  end
end, 1000)

function giveRevive(shipId)
  addHiddenAugmentation(Hyperspace.ships(shipId),"FM_REVIVE")
  return Hyperspace.ships(shipId):HasAugmentation("FM_REVIVE")
end
function forceCapstone(shipId)
  installNextCapstone(Hyperspace.ships(shipId))
end
function forcenextPhase(shipId)
  local ship=Hyperspace.ships(shipId)
  if ship:HasAugmentation("FM_REVIVE")>0 and ship.ship.hullIntegrity.first<6 then
    local dmg = Hyperspace.Damage()
    dmg.iDamage=30
    undyingShip(ship,dmg)
  end
end
--[[
function spawnAncBoarder(ShipManager)
  local bp = Hyperspace.Global.GetInstance():GetBlueprints():GetDroneBlueprint("FM_ANCALAGON_BATTLE")
  local drone = ShipManager:CreateSpaceDrone(bp)
  drone.powerRequired=0
  drone.powered=true
  drone:SetDeployed(true)
  return drone
end
--]]

--[[he won't need this anymore
  
		<rooms>
			<room id="5"> <!--medbay-->
				<roomAnim renderLayer="0">fm_energy_resist_2x2</roomAnim>
				<roomAnim renderLayer="3">energized_icon</roomAnim>
			</room>
			<room id="8"> <!--weapons-->
				<roomAnim renderLayer="0">fm_energy_resist_2x2</roomAnim>
				<roomAnim renderLayer="3">energized_icon</roomAnim>
			</room>
			<room id="1"> <!--shields-->
				<roomAnim renderLayer="0">fm_energy_resist_3x2</roomAnim>
				<roomAnim renderLayer="3">energized_icon</roomAnim>
			</room>
			<room id="15"> <!--cloaking-->
				<roomAnim renderLayer="0">fm_energy_resist_1x2</roomAnim>
				<roomAnim renderLayer="3">energized_icon</roomAnim>
			</room>
		</rooms>
]]

--[[
  LUA WPN=BP:GetWeaponBlueprint("ROYAL_DREAD")
LUA pds = Hyperspace.Global.GetInstance():GetCApp().world.space:CreatePDSFire(WPN,Hyperspace.Point(0,0),Hyperspace.Pointf(20,20),1,true)
custom ASB anyone?

LUA ANIM=animControl:GetAnimation("detergent")
LUA for proj in mods.inferno.vter(Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles) do proj.flight_animation = ANIM end
detergent ASB when?
]]