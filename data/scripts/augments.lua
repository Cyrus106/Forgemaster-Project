--until I get GetAugmentationValue to work, these will not actually be augments
mods.vals.FDM=1
mods.vals.instantmind=false

function addfiredamage()
  if mods.vals.FDM ~=1 then

    for i,v in pairs(mods.vals.Auto_Repair_Augments) do
        if Hyperspace.ships.player:HasSystem(i) then
          local roomnumber=Hyperspace.ships.player:GetSystemRoom(i)
          local fires=Hyperspace.ships.player:GetFireCount(roomnumber)
          --local FDM = -100
          if fires ~=0 then --this line makes it so half-sabotaged systems can reset, because running this every tick apparently prevents that
            Hyperspace.ships.player:GetSystem(i):PartialDamage((mods.vals.FDM-1)*fires) --This accounts for the normal damage done by fires, which is a PartialDamage of 1 per tick
          end
        end
    end
  end
end

--mindSystem.iArmed tells you if the button has been clicked and the symbol is ready to mind control a crew
--mindSystem.iLockCount tells you what the system is locked to. If the system is active, this value is -1
function instantmind()
  if mods.vals.instantmind then --this way the variable is checked first so no trouble with nils, which is why 'and' is not used here
    --if Hyperspace.ships.player.mindSystem:GetLocked() == true then
    local mindsys=Hyperspace.ships.player.mindSystem


    if mindsys:GetLocked() == true and Hyperspace.ships.player:GetSystemPower(14) > 5 then
      mindsys:LockSystem(0)
    elseif mindsys.iLockCount>=4 then
      mindsys:LockSystem(1)
    end
  end
end


function mindlog()
  local mindtimer=Hyperspace.ships.player.mindSystem.lockTimer
  log(tostring(''))
  log("stop "..tostring(mindtimer.Stop))
  log("update "..tostring(mindtimer.Update))
  log("maxtime "..tostring(mindtimer.maxTime))
  log("mintime "..tostring(mindtimer.minTime))
  log("currtime "..tostring(mindtimer.currTime))
  log("currgoal "..tostring(mindtimer.currGoal))
  log("loop "..tostring(mindtimer.loop))
  log("running "..tostring(mindtimer.running))
end


script.on_internal_event(Defines.InternalEvents.ON_TICK, addfiredamage)
script.on_internal_event(Defines.InternalEvents.ON_TICK, instantmind)
