script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  local artilleries=nil
  if pcall(function() artilleries=Hyperspace.ships.player.artillerySystems end) then
    artilleries=Hyperspace.ships.player.artillerySystems
  end
  if artilleries then
    for artillery in mods.inferno.vter(artilleries) do
      local projectile=artillery.projectileFactory:GetProjectile()
      if projectile then
        Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles:push_back(projectile)
        mods.inferno.artillery_functions:fire(artillery,projectile)
      end
    end
  end
end)

mods.inferno.artillery_functions={
  append=function(self,functions)
        local len=#self
        for key,func in ipairs(functions) do
          self[len+key]=func
        end
  end,
  fire = function(self,artillery,projectile)
    for key,func in ipairs(self) do
      func(artillery,projectile)
    end
  end,
}

mods.inferno.artillery_functions:append({
function(artillery,projectile)
  if projectile:GetType()==4 and tar then --if projectile is a bomb
    --mods.inferno.up:qs("Self-Targeting Bomb Fired!")
    projectile:SetDestinationSpace(0)
    projectile.target=Hyperspace.ships.player:GetRandomRoomCenter()
    projectile.targetId=0
  end
end,
})
tar=false
