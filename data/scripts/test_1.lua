function forceUpgrade_oxygen()--A function that is accessed later
    Hyperspace.ships.player.oxygenSystem:UpgradeSystem(1)
end
function forceUpgrade_weapons()--A function that is accessed later
    Hyperspace.ships.player.weaponSystem:UpgradeSystem(1)
end
function forceUpgrade_shields()--A function that is accessed later
    Hyperspace.ships.player.shieldSystem:UpgradeSystem(1)
end
--Every time the event "OXYGEN_FORCE_UPGRADE" runs, the function forceUpgrade_oxygen runs
script.on_game_event("OXYGEN_FORCE_UPGRADE", false, forceUpgrade_oxygen)
--Every time the event "WEAPONS_FORCE_UPGRADE" runs, the function forceUpgrade_weapons runs
script.on_game_event("WEAPONS_FORCE_UPGRADE", false, forceUpgrade_weapons)
--Every time the event "SHIELDS_FORCE_UPGRADE" runs, the function forceUpgrade_shields runs
script.on_game_event("SHIELDS_FORCE_UPGRADE",false,forceUpgrade_shields)
--the arguement false here means it does not happen again upon reload, IE saving and reloading



--Stuff to work on later
function yoinky_sploinky()
  log('Yoinky Sploinky')--Writes 'Yoinky Sploinky' to HS_LOG in the FTL folder
end
--This event is commented out, would occur as a deatheffect of crew affected by FM_ABDUCT_LASER
script.on_game_event("LUA_TEST_YOINKY",false,yoinky_sploinky)



function downgrade_enemy()
  --Hyperspace.ships.enemy.weaponSystem:UpgradeSystem(-20)
  Hyperspace.ships.enemy.teleportSystem:UpgradeSystem(-20)
  Hyperspace.ships.enemy.droneSystem:UpgradeSystem(-20)
  --Hyperspace.ships.enemy.cloakSystem:UpgradeSystem(-20)
end


--Test for drawing and stuff. No mouseover yet.

mods.vals = {}--I think this stores initiallized values
mods.vals.repair_oxygenSystem = 100
mods.vals.repair_teleportSystem = 0
mods.vals.repair_cloakSystem = 0
mods.vals.repair_batterySystem = 0
mods.vals.repair_mindSystem = 0
mods.vals.repair_cloneSystem = 0
mods.vals.repair_hackingSystem = 0
mods.vals.repair_shieldSystem = 0
mods.vals.repair_weaponSystem = 200
mods.vals.repair_droneSystem = 0
mods.vals.repair_engineSystem = 0
mods.vals.repair_medbaySystem = 0

mods.vals.testBoxBool = false -- TODO: This would be initialized differently to save for the entire run, I'm just goin off of the way Detergent Mode works



function boxBool_Toggle()
    if mods.vals.testBoxBool then
      mods.vals.testBoxBool = false
      log('set to false')

    else
      mods.vals.testBoxBool = true
      log('set to true')
    end
end

script.on_game_event("DRAW", false, boxBool_Toggle)
function nothing()
end

--[[function test_before_rend()
    if mods.vals.testBoxBool then
      log('thingy before')
      Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 3.0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0))
      Graphics.freetype.easy_print(40, 400, 400, 'SEX');
    else
      log('no thingy before')
    end
end]]
--[[function test_after_rend()
    if mods.vals.testBoxBool then
      log('thingy after')
      Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
      Graphics.freetype.easy_print(40, 400, 400, 'SEX 2');
    else
      log('no thingy after')
    end
end
script.on_render_event(Defines.RenderEvents.LAYER_FRONT, nothing, test_after_rend)]]




function rendertest2()
    --if mods.vals.testBoxBool then
      log('thingy after hello')
      Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
      --Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
      --Graphics.freetype.easy_print(40, 400, 400, 'SEX 2')

      Graphics.CSurface.GL_DrawRectOutline(300, 300, 400, 400, Graphics.GL_Color(0.4, 1.0, 0.2, 1.0), 2)
      Graphics.freetype.easy_print(20, 350, 350, 'So long, and thanks for all the fish!')
      Graphics.CSurface.GL_DrawLine(500, 100, 600, 100.0, 5.0, Graphics.GL_Color(0.4, 1.0, 0.2, 1.0))
      Graphics.CSurface.GL_DrawLine(750, 750, 755, 755, 5.0, Graphics.GL_Color(0.4, 0.1, 1.0, 1.0))
      Graphics.CSurface.GL_DrawTriangle(Hyperspace.Point(1,1), Hyperspace.Point(100,100), Hyperspace.Point(-200,-200), Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
      log('thingy after goodbye')
    --else
      --log('no thingy after')
    --end
end
--script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, nothing, rendertest2)
--[[function auto_repair_modhull()
  Hyperspace.ships.player.oxygenSystem:PartialRepair(mods.vals.repair_oxygenSystem,true)
  Hyperspace.ships.player.teleportSystem:PartialRepair(mods.vals.repair_teleportSystem,true)
  Hyperspace.ships.player.cloakSystem:PartialRepair(mods.vals.repair_cloakSystem,true)
  Hyperspace.ships.player.batterySystem:PartialRepair(mods.vals.repair_batterySystem ,true)
  Hyperspace.ships.player.mindSystem:PartialRepair(mods.vals.repair_mindSystem ,true)
  Hyperspace.ships.player.cloneSystem:PartialRepair(mods.vals.repair_cloneSystem ,true)
  Hyperspace.ships.player.hackingSystem:PartialRepair(mods.vals.repair_hackingSystem ,true)
  Hyperspace.ships.player.shieldSystem:PartialRepair(mods.vals.repair_shieldSystem ,true)
  Hyperspace.ships.player.weaponSystem:PartialRepair(mods.vals.repair_weaponSystem ,true)
  Hyperspace.ships.player.droneSystem:PartialRepair(mods.vals.repair_droneSystem ,true)
  Hyperspace.ships.player.engineSystem:PartialRepair(mods.vals.repair_engineSystem ,true)"nil method"
  Hyperspace.ships.player.medbaySystem:PartialRepair(mods.vals.repair_medbaySystem ,true) "nil method"
end]]
--[[SYS_SHIELDS,    //0
    SYS_ENGINES,    //1
    SYS_OXYGEN,     //2
    SYS_WEAPONS,    //3
    SYS_DRONES,     //4
    SYS_MEDBAY,     //5
    SYS_PILOT,      //6
    SYS_SENSORS,    //7
    SYS_DOORS,      //8
    SYS_TELEPORTER, //9
    SYS_CLOAKING,   //10
    SYS_ARTILLERY,  //11
    SYS_BATTERY,    //12
    SYS_CLONEBAY,   //13
    SYS_MIND,       //14
    SYS_HACKING,    //15
    SYS_TEMPORAL    = 20,]]
    function repair_auto()
      if not Hyperspace.SpaceManager.gamePaused then

          --shields
          if Hyperspace.ships.player:HasSystem(0) == '' then
            Hyperspace.ships.player.shieldSystem:PartialRepair(mods.vals.repair_shieldSystem,true)
          else
          end
          --oxygen
          if Hyperspace.ships.player:HasSystem(2) == '' then
            Hyperspace.ships.player.oxygenSystem:PartialRepair(mods.vals.repair_oxygenSystem,true)
          else
          end
          --weapons
          if Hyperspace.ships.player:HasSystem(3) == '' then
            Hyperspace.ships.player.weaponSystem:PartialRepair(mods.vals.repair_weaponSystem,true)
          else
          end
          --drones
          if Hyperspace.ships.player:HasSystem(4) == '' then
            Hyperspace.ships.player.droneSystem:PartialRepair(mods.vals.repair_droneSystem,true)
          else
          end
          --teleporter
          if Hyperspace.ships.player:HasSystem(9) == '' then
            Hyperspace.ships.player.teleportSystem:PartialRepair(mods.vals.repair_teleportSystem,true)
          else
          end
          --cloaking
          if Hyperspace.ships.player:HasSystem(10) == '' then
            Hyperspace.ships.player.cloakSystem:PartialRepair(mods.vals.repair_cloakSystem,true)
          else
          end
          --battery
          if Hyperspace.ships.player:HasSystem(12) == '' then
            Hyperspace.ships.player.batterySystem:PartialRepair(mods.vals.repair_batterySystem,true)
          else
          end
          --clonebay
          if Hyperspace.ships.player:HasSystem(13) == '' then
            Hyperspace.ships.player.cloneSystem:PartialRepair(mods.vals.repair_cloneSystem,true)
          else
          end
          --mind
          if Hyperspace.ships.player:HasSystem(14) == '' then
            Hyperspace.ships.player.mindSystem:PartialRepair(mods.vals.repair_mindSystem,true)
          else
          end
          --hacking
          if Hyperspace.ships.player:HasSystem(15) == '' then
            Hyperspace.ships.player.hackingSystem:PartialRepair(mods.vals.repair_hackingSystem,true)
          else
          end
        end
    end
function tyy()
        log('hello')
        --log(type(Hyperspace.Resources:CreateImagePrimitiveString("img/ship/forgemasterbase.png", 0, 0, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false)))
        Graphics.CSurface:GL_CreatePixelImagePrimitive("img/ship/forgemasterbase.png", 0, 0, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false)
        log('goodbye')
end
--script.on_render_event(Defines.RenderEvents.LAYER_FRONT,tyy,tyy)

--script.on_internal_event(Defines.InternalEvents.ON_TICK, repair_auto)

script.on_game_event("MBA_2",false,downgrade_enemy)--This didn't work when set to true, might be a bug? Also did not work when tied to MBA, because of order of opperations, most likely
