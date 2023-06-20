

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  if AugName:sub(0,8)~="ANTIAUG_" then
    local OtherShipManager = Hyperspace.Global.GetInstance():GetShipManager(1 - ShipManager.iShipId) -- funny math so it can check other ship stuff
    if OtherShipManager then
      local augModifier = OtherShipManager:GetAugmentationValue("ANTIAUG_"..AugName)
      if augModifier ~= 0 then -- when the other ship has the augment
        AugValue = AugValue - augModifier -- changing augment by the opposing ship's ANTIAUG_ of the augment
      end
    end
  end
  return Defines.Chain.CONTINUE, AugValue
end)

