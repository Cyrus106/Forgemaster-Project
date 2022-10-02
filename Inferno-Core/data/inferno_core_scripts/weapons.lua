wa=false
script.on_internal_event(Defines.InternalEvents.ON_TICK,
function()
  local weapons=nil
  if pcall(function() weapons=Hyperspace.ships.player.weaponSystem.weapons end) then
    weapons=Hyperspace.ships.player.weaponSystem.weapons
  end
  if weapons then
    for weapon in mods.inferno.vter(weapons) do
      if weapon.boostLevel<0 then --for resetting weapons from a chain properly by setting the boostLevel to be negative, triggering this.
        weapon.boostLevel=0
        weapon.cooldown.first=0
        weapon.chargeLevel=0
      end


      --if (Hyperspace.ships.player.weaponSystem:Powered() or (Hyperspace.ships.player:HasEquipment("fmcore_conservative_fix")==1)) then

        while true do
          local projectile=weapon:GetProjectile()
          if projectile then
            Hyperspace.Global.GetInstance():GetCApp().world.space.projectiles:push_back(projectile)
            mods.inferno.weapon_functions:fire(weapon,projectile)
          else
            break
          end
        end

      --end
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
    --mods.inferno.up:qs(weapon.name.." Just Fired!")
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
mods.inferno.real_projectile = function(projectile) --replace when we have access to the death animation and can check directly
  if projectile.damage.iDamage == 0 and
    projectile.damage.iShieldPiercing == 0 and
    projectile.damage.fireChance == 0 and
    projectile.damage.breachChance == 0 and
    projectile.damage.stunChance == 0 and
    projectile.damage.iIonDamage == 0 and
    projectile.damage.iSystemDamage == 0 and
    projectile.damage.iPersDamage == 0 and
    projectile.damage.bHullBuster == false and
    projectile.damage.ownerId == -1 and
    projectile.damage.selfId == -1 and
    projectile.damage.bLockdown == false and
    projectile.damage.crystalShard == false and
    projectile.damage.bFriendlyFire == true and
    projectile.damage.iStun == 0
  then
    return false
  else
    return true
  end
end

mods.inferno.weapon_functions:append({
function(weapon,projectile)
  if Hyperspace.ships.player:GetAugmentationValue("WEAPON_LOCKDOWN")>0 and mods.inferno.real_projectile(projectile) then
    projectile.damage.bLockdown=true
  end
end,

function(weapon,projectile)
  local beam_pierce_modifier=Hyperspace.ships.player:GetAugmentationValue("AUG_BEAM_PIERCE")
  if projectile:GetType()==5 then
    --conditional fix for weapons with negative damage
    projectile.damage.iShieldPiercing=math.max(projectile.damage.iShieldPiercing,1-projectile.damage.iDamage)


    projectile.damage.iShieldPiercing=projectile.damage.iShieldPiercing+beam_pierce_modifier
  end
end,
})
