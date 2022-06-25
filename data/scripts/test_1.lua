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


function test_before_rend()
    if mods.vals.testBoxBool then
      log('thingy before')
      Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 3.0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0))
    else
      log('no thingy before')
    end
end
function test_after_rend()
    if mods.vals.testBoxBool then
      log('thingy after')
      Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
    else
      log('no thingy after')
    end
end
script.on_render_event(Defines.RenderEvents.LAYER_FRONT, test_before_rend, test_after_rend)




script.on_game_event("MBA_2",false,downgrade_enemy)--This didn't work when set to true, might be a bug? Also did not work when tied to MBA, because of order of opperations, most likely
