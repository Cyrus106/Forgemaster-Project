local vter = mods.inferno.vter

-- Make photon-like guns pop shields
local popWeapons = mods.inferno.popWeapons
popWeapons.FM_LASER_PHOTON = {count = 1, countSuper = 1}
popWeapons.FM_LASER_PHOTON_2 = {count = 1, countSuper = 1}
popWeapons.FM_LASER_PHOTON_ENEMY = {count = 1, countSuper = 1}
popWeapons.FM_LASER_PHOTON_2_ENEMY = {count = 1, countSuper = 1}
popWeapons.FM_ARBOREAL_EXE = {count = 2, countSuper = 0} --Does 3 hull damage, so pops 3 shields and does 3 damage to superShields
popWeapons.FM_ARBOREAL_REV = {count = 3, countSuper = 3}
popWeapons.FM_CHAINGUN_FIRE = {count = 1, countSuper = 1}
popWeapons.FM_GATLING_ANCIENT_PHOTON = {count = 1, countSuper = 1}


-- Weapons that do extra damage of a certain type on room hit
local roomDamageWeapons = mods.inferno.roomDamageWeapons
roomDamageWeapons.FM_PULSEDEEP = {ion = 2}
roomDamageWeapons.FM_MISSILES_CLOAK_STUN = {ion = 3}
roomDamageWeapons.FM_MISSILES_CLOAK_STUN_PLAYER = {ion = 3}
roomDamageWeapons.FM_MISSILES_CLOAK_STUN_MEGA = {ion = 3}
roomDamageWeapons.FM_MISSILES_CLOAK_STUN_ENEMY = {ion = 3}
roomDamageWeapons.FM_RVS_AC_CHARGE_EMP = {ion = 1}



local tileDamageWeapons = mods.inferno.tileDamageWeapons
tileDamageWeapons.FM_BEAM_ION_PIERCE = {ion = 1}
tileDamageWeapons.FM_FOCUS_ENERGY = {ion = 2}
tileDamageWeapons.FM_FOCUS_ENERGY_2 = {ion = 3}
tileDamageWeapons.FM_FOCUS_ENERGY_2_PLAYER = {ion = 3}
tileDamageWeapons.FM_FOCUS_ENERGY_3 = {ion = 4}
tileDamageWeapons.FM_FOCUS_ENERGY_CONS = {ion = 2}
tileDamageWeapons.FM_BEAM_ION_PIERCE_ENEMY = {ion = 1}
tileDamageWeapons.FM_FOCUS_ENERGY_ENEMY = {ion = 2}
tileDamageWeapons.FM_FOCUS_ENERGY_2_ENEMY =  {ion = 3}
tileDamageWeapons.FM_FOCUS_ENERGY_3_ENEMY = {ion = 4}

local impactBeams = mods.inferno.impactBeams
impactBeams.FM_BEAM_EXPLOSION = "FM_BEAM_EXPLOSION_LASER"
impactBeams.FM_BEAM_EXPLOSION_PLAYER = "FM_BEAM_EXPLOSION_LASER"
impactBeams.FM_BEAM_EXPLOSION_EGG = "FM_BEAM_EXPLOSION_LASER"
impactBeams.FM_BEAM_EXPLOSION_ENEMY = "FM_BEAM_EXPLOSION_LASER"
impactBeams.FM_FORGEMAN_DRONE_WEAPON = "FM_BEAM_EXPLOSION_LASER"

--To hit every room on the targeted ship with an effect (Until accuracy stats are exposed, please ensure all weapons used in hitEveryRoom have accuracy 100)
local hitEveryRoom = mods.inferno.hitEveryRoom
hitEveryRoom.hitEveryRoomFM_ARBOREAL_EXE = "FM_ARBOREAL_EXE_STATBOOST"
hitEveryRoom.FM_ARBOREAL_REV = "FM_ARBOREAL_REV_STATBOOST"

hitEveryRoom.FM_TERMINUS = "FM_TERMINUS_STATBOOST"



--SPECIAL CASES:
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT,
function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
  if Hyperspace.Get_Projectile_Extend(Projectile).name == "FM_ABDUCT_LASER" then
    local targetRoomNumber = Hyperspace.ShipGraph.GetShipInfo(ShipManager.iShipId):GetSelectedRoom(Location.x, Location.y, true)
  

    local playTeleportSound = false
    for crew in vter(ShipManager.vCrewList) do
      if crew.iShipId == ShipManager.iShipId and crew.iRoomId == targetRoomNumber then --Only abducts enemy crew
        local arrivalRoomNumber = Hyperspace.random32() % Hyperspace.ShipGraph.GetShipInfo(Projectile.ownerId):RoomCount()
        Hyperspace.Get_CrewMember_Extend(crew):InitiateTeleport(Projectile.ownerId, arrivalRoomNumber)
        playTeleportSound = true
      end
    end
  
    if playTeleportSound then
      Hyperspace.Global.GetInstance():GetSoundControl():PlaySoundMix("teleport",-1,false)
    end
  end
  return Defines.CHAIN_CONTINUE
end)