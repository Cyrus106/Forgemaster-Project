script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  if AugName:sub(0, 8) ~= "ANTIAUG_" then
    local OtherShipManager = Hyperspace.Global.GetInstance():GetShipManager(1 - ShipManager.iShipId)
    if OtherShipManager then
      --Subtract other ship's ANTIAUG value from calculated value.
        AugValue = AugValue - OtherShipManager:GetAugmentationValue("ANTIAUG_"..AugName) 
    end
  end
  return Defines.Chain.CONTINUE, AugValue
end)

