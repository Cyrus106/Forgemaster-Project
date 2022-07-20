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
mods.vals.animbool = false
mods.vals.overchargebool = false

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
      if not Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then
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
script.on_internal_event(Defines.InternalEvents.ON_TICK, repair_auto)


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
  projectile.iSystemDamage = 69
  projectile.breachChance = 10
  for i =0,40 do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRoomCenter(i), projectile, true)
  end
end
function ras()
  local projectile=Hyperspace.Damage()
  projectile.iSystemDamage = -99
  for i =0,40 do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRoomCenter(i), projectile, true)
  end
end

function ion()
  local projectile=Hyperspace.Damage()
  projectile.iIonDamage = 8
  for i =0,40 do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRoomCenter(i), projectile, true)
  end
end

function dam2()
  local projectile=Hyperspace.Damage()
  projectile.iDamage = 1
  for i =0,40 do
    Hyperspace.ships.player:DamageArea(Hyperspace.ships.player:GetRoomCenter(i), projectile, true)
  end
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
--script.on_internal_event(Defines.InternalEvents.ON_TICK,sethack)
script.on_game_event("TOGGLE_HACK",false,togglehack)
script.on_internal_event(Defines.InternalEvents.ON_TICK, weirdhack)


script.on_game_event("MBA_2",false,downgrade_enemy)--This didn't work when set to true, might be a bug? Also did not work when tied to MBA, because of order of opperations, most likely

  function repairall()
        for i=0,10 do
            if Hyperspace.ships.player:HasSystem(i) then
              for x=1,20 do
                Hyperspace.ships.player:GetSystem(i):PartialRepair(1000000,true)
              end
            end
        end

        for i=12,15 do
            if Hyperspace.ships.player:HasSystem(i) then
              for x=1,20 do
                Hyperspace.ships.player:GetSystem(i):PartialRepair(1000000,true)
              end
            end
        end

        if Hyperspace.ships.player:HasSystem(20) then
          for x=1,20 do
            Hyperspace.ships.player:GetSystem(i):PartialRepair(1000000,true)
          end
        end

        --[[local artillery = Hyperspace.ships.player.artillerySystems
        if artillery then
            for x=0,artillery:size() do
              artillery[x]:PartialRepair(10000000,true)
            end
        end]]

  end


--[[  struct GL_Texture
  {
      /*** Default Constructor
      @function GL_Texture
      */

      /***
      @tfield int id
      */
  	int id_;
      /***
      @tfield int width
      */
  	int width_;
      /***
      @tfield int height
      */
  	int height_;
      /***
      @tfield bool isLogical
      */
  	bool isLogical_;
      /***
      @tfield float u_base
      */
  	float u_base_;
      /***
      @tfield float v_base
      */
  	float v_base_;
      /***
      @tfield float u_size
      */
  	float u_size_;
      /***
      @tfield float v_size
      */
  	float v_size_;
  };]]





--Animation testing STUFF
function anim()
  --local y=Hyperspace.Resources:CreateImagePrimitiveString("ships_glow/zmt_boss_crystal_suicide_gib2.png", 0, 0, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false)
   --Graphics.CSurface.GL_RenderPrimitive(y)
    --[[local tex=Graphics.GL_Texture()
    tex.id=Hyperspace.Resources:GetImageId("ships_glow/zmt_boss_crystal_suicide_gib2.png")
    tex.width=100
    tex.height=100
    tex.u_base=100
    tex.v_base=100
    tex.u_size=200
    tex.v_size=300
    tex.isLogical=true]]

   local tex = Hyperspace.Resources:GetImageId("effects/explosion_ancalagon_breach.png")
   local x = 100
   local y = 100
   local size_x = tex.width
   local size_y = tex.height
   local start_x = 0
   local end_x = tex.width
   local start_y = 10
   local end_y = tex.height
   local alpha = 1
   local color = Graphics.GL_Color(0.5, 0.5, 0.5, 0.5)
   local mirror = false
   --GL_BlitImagePartial(GL_Texture *tex, float x, float y, float size_x, float size_y, float start_x, float end_x, float start_y, float end_y, float alpha, GL_Color color, bool mirror)
   Graphics.CSurface.GL_BlitImagePartial(tex, x, y, size_x, size_y, start_x, end_x, start_y, end_y, alpha, color, mirror)
--start_y and end_y are floats within the range of 0 to 1, start_y is larger
--start_y and end_y are in the range of 0 to one. Start_y>end_y, and y increases as you go up.
--start_x and end_x work similarly, in a range of 0 to 1. start_x < end_x, where x increases from left to right

   --[[LUA log(start_y)[Lua]: 4
   LUA log(end_y)[Lua]: 0
   LUA log(start_x)[Lua]: -3
   LUA log(end_x)[Lua]: 10]]

end





--[[tex = Hyperspace.Resources:GetImageId("ship/testerfm_floor.png")
 x = 150
 y = 150
 --COUNTING FRAMES FROM ZERO
 size_x = 20 --width of a frame
 size_y = 20 --height of a frame
 start_x = 0 -- framenumber/numberofframes
 end_x = 10 --framenumber+1/numberofframes
 start_y = 1 --keep it this way for now because this is just for weapon explosions
 end_y = 0 --keep this way for now
 alpha = 1 --keep this way for now
 color = Graphics.GL_Color(1, 1, 1, 1)--keep this way for now
 mirror = false --keep this way for now

 rotation =0
function anim2()
   Graphics.CSurface.GL_BlitImagePartial(tex, x, y, size_x, size_y, start_x, end_x, start_y, end_y, alpha, color, mirror)
   --Graphics.CSurface.GL_BlitPixelImage(tex, 300, 300, 40, 40, rotation, color, mirror)
end]]




--[[function renderframe(imagepath, framenumber, numberofframes, position_x, position_y)
  local tex=Hyperspace.Resources:GetImageId(imagepath)
  Graphics.CSurface.GL_BlitImagePartial(tex, position_x, position_y, (tex.width)/(numberofframes), tex.height, framenumber/numberofframes, (framenumber+1)/(numberofframes), 1, 0, 1, Graphics.GL_Color(1, 1, 1, 1), false)
end



local animtimer_seconds = 0

function renderanim(imagepath, numberofframes, position_x, position_y,seconds)
  if mods.vals.animbool then

    animtimer_seconds = animtimer_seconds + (Hyperspace.FPS.SpeedFactor / 16)
    local tex=Hyperspace.Resources:GetImageId(imagepath)
    local framenumber=math.floor((animtimer_seconds*numberofframes)/seconds)
    Graphics.CSurface.GL_BlitImagePartial(tex, position_x, position_y, (tex.width)/(numberofframes), tex.height, framenumber/numberofframes, (framenumber+1)/(numberofframes), 1, 0, 1, Graphics.GL_Color(1, 1, 1, 1), false)
    if animtimer_seconds > seconds then
        animtimer_seconds = 0
        mods.vals.animbool = false
    end
  end
end]]








function renderoverrooms()

    renderframe("effects/explosion_ancalagon_breach.png",fn,14,100,100)

end


function newthing()
    if mods.vals.animbool then
      for i=0,25 do
        local room=Hyperspace.ships.enemy:GetRoomCenter(i)
        renderanim("effects/explosion_ancalagon_breach.png",14,room.x,room.y,10)
      end
    end
end


function animation_fun()
  mods.vals.animbool=true
end


function stonks()
  Hyperspace.playerVariables[twisted_rock_scrap_counter]=100
  log(Hyperspace.playerVariables[twisted_rock_scrap_counter])
end

function var_to_scrap()
  log(Hyperspace.playerVariables[twisted_rock_scrap_counter])
  Hyperspace.ships.player:ModifyScrapCount(Hyperspace.playerVariables[twisted_rock_scrap_counter])
  Hyperspace.playerVariables[twisted_rock_scrap_counter]=0
end

local overcharge_seconds = 0

function overcharge()
  if mods.vals.overchargebool then
    local overchargetime = 10/Hyperspace.ships.player:GetSystemPower(0)
    overcharge_seconds = overcharge_seconds + (Hyperspace.FPS.SpeedFactor / 16)
    if overcharge_seconds > overchargetime then
        overcharge_seconds = 0
        Hyperspace.ships.player.shieldSystem:AddSuperShield(Hyperspace.Point(0,0))
        log(overchargetime)
    end
  end
end



function firetest()
  --local x = Hyperspace.ships.player:GetWeaponList()
  --log(tostring(x[1]))
  --x[1]:SetCooldownModifer(200)
Hyperspace.ships.player.artillerySystems[1].projectileFactory:SetCooldownModifier(100)
end
--script.on_internal_event(Defines.InternalEvents.ON_TICK, firetest)
script.on_internal_event(Defines.InternalEvents.ON_TICK, overcharge)
script.on_game_event("ANIMATION_FUN",false,animation_fun)
--script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, nothing, newthing)








--[[
function yy()
  Graphics.CSurface.GL_RenderPrimitive(Hyperspace.Resources:CreateImagePrimitiveString("ship/Forgemaster_cruiser_1_gib1.png", 0, 0, 0, Graphics.GL_Color(0.5, 0.5, 0.5, 1.0), 1.0, false))
end]]

--script.on_render_event(Defines.RenderEvents.LAYER_FRONT, nothing, yy)


--Hyperspace.Global.GetInstance():GetCApp().world.starMap:ModifyPursuit(-5) important
