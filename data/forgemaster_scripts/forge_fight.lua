local undyingShip = function(ShipManager,Damage)
  local revives = ShipManager:HasAugmentation("FM_REVIVE")
  if revives>0 and (ShipManager.ship.hullIntegrity.first-Damage.iDamage<1 or Damage.bhullBuster and ShipManager.ship.hullIntegrity.first-Damage.iDamage*2<1) then
    --[[if ShipManager.myBlueprint.blueprintName == "FM_FORGEMASTER_CRUISER_ENEMY" then
        ShipManager.ship.hullIntegrity.second = ShipManager.ship.hullIntegrity.second*2
    end--]]
    ShipManager.ship.hullIntegrity.first=ShipManager.ship.hullIntegrity.second
    Damage.iDamage=0
    ShipManager:RemoveItem("HIDDEN FM_REVIVE")
    --print("good thing he had a totem of undying :)")
  end
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA,
  function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
    undyingShip(ShipManager,Damage)
    return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
  end, 1000)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
  function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
    undyingShip(ShipManager,Damage)
    return Defines.Chain.CONTINUE, beamHitType
  end, 1000)