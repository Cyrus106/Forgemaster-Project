script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  local weapons=nil
  if pcall(function() weapons=Hyperspace.ships.player.weaponSystem.weapons end) then
    weapons=Hyperspace.ships.player.weaponSystem.weapons
  end
  if weapons then
    for weapon in mods.inferno.vter(weapons) do
      if weapon.boostLevel<0 then
        weapon.boostLevel=0
        weapon.cooldown.first=0
        weapon.chargeLevel=0
      end
      local projectile=weapon:GetProjectile()
      if projectile then
        Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles:push_back(projectile)
        mods.inferno.weapon_functions:fire(weapon,projectile)
      end
    end
  end
end)

mods.inferno.weapon_functions={
  append=function(self,functions)
        local len=#self
        for key,func in ipairs(functions) do
          self[len+key]=func
        end
  end,
  fire = function(self,weapon,projectile)
    for key,func in ipairs(self) do
      func(weapon,projectile)
    end
  end,
}


--[[
iDamage = 0;
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
iStun = 0;
]]

mods.inferno.weapon_functions:append({
function(weapon,projectile)
  if Hyperspace.ships.player:GetAugmentationValue("WEAPON_LOCKDOWN")>0 then
    projectile.damage.bLockdown=true
    if projectile._targetable.type==2 then --so it applies to flak projectiles, this may not be the proper solution
      for proj in mods.inferno.vter(weapon.queuedProjectiles) do
        proj.damage.bLockdown=true
      end
    end
  end
end,

function(weapon,projectile)
  local beam_pierce_modifier=Hyperspace.ships.player:GetAugmentationValue("BEAM_PIERCE")
  if projectile._targetable.type==5 then
    projectile.damage.iShieldPiercing=projectile.damage.iShieldPiercing+beam_pierce_modifier
  end
end,
})
