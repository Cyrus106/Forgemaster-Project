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
function nothing()
end


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

mods.vals = {}--I think this stores initiallized values
mods.vals.weirdhack = false
mods.vals.hacklevel = 0
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

    --FM_AUTOREPAIR_MEDICAL is listed twice so it maps to both medical systems
    mods.vals.Auto_Repair_Augments={[0]="FM_AUTOREPAIR_SHIELDS", --0
                                    [1]= "FM_AUTOREPAIR_ENGINES", --1
                                    [2]="FM_AUTOREPAIR_OXYGEN", --2
                                    [3]="FM_AUTOREPAIR_WEAPONS", --3
                                    [4]="FM_AUTOREPAIR_DRONES", --4
                                    [5]="FM_AUTOREPAIR_MEDICAL", --5
                                    [6]="FM_AUTOREPAIR_PILOT", --6
                                    [7]="FM_AUTOREPAIR_SENSORS", --7
                                    [8]="FM_AUTOREPAIR_DOORS", --8
                                    [9]="FM_AUTOREPAIR_TELEPORTER", --9
                                    [10]="FM_AUTOREPAIR_CLOAKING", --10
                                    --[11]="FM_AUTOREPAIR_ARTILLERY", --11 Handled differently, duplicate systems
                                    [12]="FM_AUTOREPAIR_BATTERY", --12
                                    [13]="FM_AUTOREPAIR_MEDICAL", --13
                                    [14]="FM_AUTOREPAIR_MIND", --14
                                    [15]="FM_AUTOREPAIR_HACKING", --15
                                    [20]="FM_AUTOREPAIR_TEMPORAL" } --20
    function repair_auto()
      if not Hyperspace.SpaceManager.gamePaused then
          for i,v in pairs(mods.vals.Auto_Repair_Augments) do
              --if Hyperspace.ships.player:HasSystem(i) == '' then
              if Hyperspace.ships.player:HasSystem(i) then
                --local repair_value = Hyperspace.ships.player:GetAugmentationValue(v)
                  Hyperspace.ships.player:GetSystem(i):PartialRepair(100,true)
                --Hyperspace.ships.player:GetSystem(i):PartialRepair(repair_value,true)
              end
          end

          local artillery = Hyperspace.ships.player.artillerySystems
          if artillery then
              for x=0,artillery:size() do
                --local repair_value = Hyperspace.ships.player:GetAugmentationValue("FM_AUTOREPAIR_ARTILLERY")
                artillery[x]:PartialRepair(100,true)
              end
          end


      end
    end
--script.on_internal_event(Defines.InternalEvents.ON_TICK, repair_auto)


--examples for graphics functions
function D()

  local y=Hyperspace.Resources:CreateImagePrimitiveString("ships_glow/zmt_boss_crystal_suicide_gib2.png", 0, 0, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false)
   Graphics.CSurface.GL_RenderPrimitive(y)
   Graphics.CSurface.GL_DrawShield(100, 200, 300.0, 200.0, 1, 300, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 5)
   Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
   Graphics.CSurface.GL_DrawLine(6.0, 6.0, 100.0, 100.0, 5.0, Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
   Graphics.freetype.easy_print(40, 400, 400, 'SEX 2')
   Graphics.CSurface.GL_DrawRectOutline(300, 300, 400, 400, Graphics.GL_Color(0.4, 1.0, 0.2, 1.0), 2)
   Graphics.freetype.easy_print(20, 350, 350, 'So long, and thanks for all the fish!')
   Graphics.CSurface.GL_DrawLine(500, 100, 600, 100.0, 5.0, Graphics.GL_Color(0.4, 1.0, 0.2, 1.0))
   Graphics.CSurface.GL_DrawLine(750, 750, 755, 755, 5.0, Graphics.GL_Color(0.4, 0.1, 1.0, 1.0))
   Graphics.CSurface.GL_DrawTriangle(Hyperspace.Point(1,1), Hyperspace.Point(100,100), Hyperspace.Point(-200,-200), Graphics.GL_Color(1.0, 0.2, 0.2, 1.0))
end
--script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, nothing, D)
function axle()
  local y=Hyperspace.Resources:CreateImagePrimitiveString("ship/zfm_gunhydra_b_base.png", 100, 100, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false)
  Graphics.CSurface.GL_RenderPrimitive(y)
end
--script.on_render_event(Defines.RenderEvents.LAYER_FRONT,nothing, axle)

--test functions, may or may not work

--[[iDamage = 0;
		iShieldPiercing = 0;
		fireChance = 0;
		breachChance = 0;
		stunChance = 0;
		iIonDamage = 0;
		iSystemDamage = 0;
		iPersDamage = 0;
		bHullBuster = 0;
		ownerId = -1;
		selfId = -1;
		bLockdown = false;
		crystalShard = false;
		bFriendlyFire = true;
		iStun = 0;]]
function beam()
  local projectile=Hyperspace.Damage()
  projectile.iDamage = 2
  projectile.iShieldPiercing = 10
  projectile.fireChance = 10
  projectile.breachChance = 10
  Hyperspace.ships.player:DamageBeam(Hyperspace.Pointf(1,1), Hyperspace.Pointf(200,200), projectile)
  log('Function complete')
end
function dam()
  local projectile=Hyperspace.Damage()
  projectile.iDamage = 2
  projectile.iShieldPiercing = 10
  projectile.fireChance = 10
  projectile.breachChance = 10
  Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRoomCenter(0), projectile, true)
  log('Function complete')
end

--script.on_render_event(Defines.RenderEvents.LAYER_FRONT,tyy,tyy)

function fixie()
  local artillery=Hyperspace.ships.player.artillerySystems
  artillery[0].interiorImage = Hyperspace.Resources:CreateImagePrimitiveString("ship/interior/room_artillery_7.png", 315, 105, 0, Graphics.GL_Color(1.0, 1.0, 1.0, 1.0), 1.0, false)
  artillery[1].interiorImage = Hyperspace.Resources:CreateImagePrimitiveString("ship/interior/room_artillery_4.png", 315, 280, 0, Graphics.GL_Color(1.0, 1.0, 1.0, 1.0), 1.0, false)
  artillery[3].interiorImage = Hyperspace.Resources:CreateImagePrimitiveString("ship/interior/room_artillery_5.png", 350, 0, 0, Graphics.GL_Color(1.0, 1.0, 1.0, 1.0), 1.0, false)
end


function weirdhack()
  if mods.vals.weirdhack then
      for i,v in pairs(mods.vals.Auto_Repair_Augments) do
          --if Hyperspace.ships.enemy:HasSystem(i) == '' and Hyperspace.ships.enemy:IsSystemHacked(i) == 2 then
          if Hyperspace.ships.enemy:HasSystem(i) and Hyperspace.ships.enemy:IsSystemHacked(i) == 2 then
              Hyperspace.ships.enemy:GetSystem(i):PartialDamage(5)
          end
      end
  end
end
function togglehack()
  if mods.vals.weirdhack then
    mods.vals.weirdhack = false
  else
    mods.vals.weirdhack = true
  end
end
function sethack()
  Hyperspace.ships.enemy.weaponSystem:SetHackingLevel(mods.vals.hacklevel)
end
function shl(x)
  mods.vals.hacklevel=x
end
script.on_internal_event(Defines.InternalEvents.ON_TICK,sethack)
script.on_game_event("TOGGLE_HACK",false,togglehack)
script.on_internal_event(Defines.InternalEvents.ON_TICK, weirdhack)


script.on_game_event("MBA_2",false,downgrade_enemy)--This didn't work when set to true, might be a bug? Also did not work when tied to MBA, because of order of opperations, most likely
