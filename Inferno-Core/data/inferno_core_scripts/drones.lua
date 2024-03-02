vter = mods.inferno.vter
mods.inferno.chainDrones={}
mods.inferno.chainDrones.DRONE_MISSILES={scaling=0.1, max="10"}

--this is currently not active but maybe will lead to something

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
    local combatdrones = ShipManager.spaceDrones
    local speed = ShipManager:GetAugmentationValue("FR_NEXUS_DRONES_BOOST")
    if ShipManager:HasAugmentation("FR_NEXUS_DRONES_BOOST") > 0 then 
        for combatdrone in vter(combatdrones) do
            if combatdrone.powered then
                if combatdrone.currentSpeed and combatdrone.weaponCooldown >= 0 then
                    combatdrone.weaponCooldown = (combatdrone.weaponCooldown) - Hyperspace.FPS.SpeedFactor / 16 * (speed - 1)
                    if combatdrone.weaponCooldown <= 0 then
                        combatdrone.weaponCooldown = -1
                    end
                end
            end
                for _ = 1, speed - 1 do
                    combatdrone:OnLoop()
                end
            end
        end
    end
)

  
local function spaceDroneBooster(shipMgr)
    local augName = "_TM_AUG_SPACE_DRONE_BOOSTER"
    if shipMgr:HasAugmentation(augName) <= 0 then
        return
    end
    local augValue = shipMgr:GetAugmentationValue(augName)
    if augValue <= 0 then
        return
    end
    local extraUpdates = augValue + (shipMgr.table._tm_sdbRemnant or 0)
    extraUpdates, shipMgr.table._tm_sdbRemnant = math.modf(extraUpdates)
    local drones = shipMgr.spaceDrones
    for i = 0, drones:size() - 1 do
        local drone = drones[i]
        if drone.powered then
            for _ = 1, extraUpdates do
                drone:OnLoop()
            end
        end
    end
    return
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, spaceDroneBooster)