--[[  LIBZHL_API void Fire(std::vector<Pointf> &points, int target);
	LIBZHL_API bool FireNextShot();
	LIBZHL_API void ForceCoolup();
	LIBZHL_API Projectile *GetProjectile();
	LIBZHL_API bool IsChargedGoal();
	LIBZHL_API static Projectile *__stdcall LoadProjectile(int fd);
	LIBZHL_API int NumTargetsRequired();
	LIBZHL_API void OnRender(float alpha, bool forceVisual);
	LIBZHL_API void RenderChargeBar(float unk);
	LIBZHL_API static void __stdcall SaveProjectile(Projectile *p, int fd);
	LIBZHL_API void SelectChargeGoal();
	LIBZHL_API void SetCooldownModifier(float mod);
	LIBZHL_API void SetCurrentShip(Targetable *ship);
	LIBZHL_API void SetHacked(int hacked);
	LIBZHL_API int SpendMissiles();
	LIBZHL_API static int __stdcall StringToWeapon(const std::string &str);
	LIBZHL_API void Update();
	LIBZHL_API void constructor(const WeaponBlueprint *bp, int shipId);



  %nodefaultdtors ProjectileFactory;
  %rename("%s") ProjectileFactory;
  %rename("%s") ProjectileFactory::Fire;
  %rename("%s") ProjectileFactory::FireNextShot;
  %rename("%s") ProjectileFactory::ForceCoolup;
  %rename("%s") ProjectileFactory::GetProjectile;
  %rename("%s") ProjectileFactory::IsChargedGoal;
  %rename("%s") ProjectileFactory::NumTargetsRequired;
  %rename("%s") ProjectileFactory::SetCooldownModifier;
  %rename("%s") ProjectileFactory::SetCurrentShip;
  %rename("%s") ProjectileFactory::SetHacked;
  //%rename("%s") ProjectileFactory::SpendMissiles;
  //%rename("%s") ProjectileFactory::StringToWeapon;
  %rename("%s") ProjectileFactory::cooldown;
  %rename("%s") ProjectileFactory::subCooldown;
  %rename("%s") ProjectileFactory::baseCooldown;
  %rename("%s") ProjectileFactory::blueprint;
  %rename("%s") ProjectileFactory::localPosition;
  %rename("%s") ProjectileFactory::flight_animation;
  %rename("%s") ProjectileFactory::autoFiring;
  %rename("%s") ProjectileFactory::fireWhenReady;
  %rename("%s") ProjectileFactory::powered;
  %rename("%s") ProjectileFactory::requiredPower;
  %rename("%s") ProjectileFactory::targets;
  %rename("%s") ProjectileFactory::lastTargets;
  %rename("%s") ProjectileFactory::targetId;
  %rename("%s") ProjectileFactory::iAmmo;
  %rename("%s") ProjectileFactory::name;
  %rename("%s") ProjectileFactory::numShots;
  %rename("%s") ProjectileFactory::currentFiringAngle;
  %rename("%s") ProjectileFactory::currentEntryAngle;
  %rename("%s") ProjectileFactory::currentShipTarget;
  %rename("%s") ProjectileFactory::weaponVisual;
  %rename("%s") ProjectileFactory::mount;
  %rename("%s") ProjectileFactory::queuedProjectiles;
  %rename("%s") ProjectileFactory::iBonusPower;
  %rename("%s") ProjectileFactory::bFiredOnce;
  %rename("%s") ProjectileFactory::iSpendMissile;
  %rename("%s") ProjectileFactory::cooldownModifier;
  %rename("%s") ProjectileFactory::shotsFiredAtTarget;
  %rename("%s") ProjectileFactory::radius;
  %rename("%s") ProjectileFactory::boostLevel;
  %rename("%s") ProjectileFactory::lastProjectileId;
  %rename("%s") ProjectileFactory::chargeLevel;
  %rename("%s") ProjectileFactory::iHackLevel;
  %rename("%s") ProjectileFactory::goalChargeLevel;
  %rename("%s") ProjectileFactory::isArtillery;



%rename("%s") Blueprint;
%rename("%s") Blueprint::GetNameLong;
%rename("%s") Blueprint::GetNameShort;
%rename("%s") Blueprint::GetType;
%rename("%s") Blueprint::name;
%rename("%s") Blueprint::desc;
%rename("%s") Blueprint::type;
  ]]


  function modart()
    local artillery=Hyperspace.ships.player.artillerySystems[1].projectileFactory
    log('before1 '..tostring(artillery.cooldownModifier))
    artillery:SetCooldownModifier(0.1)
    log('after1 '..tostring(artillery.cooldownModifier))
  end

  function modart2()
    local artillery=Hyperspace.ships.player.artillerySystems[1].projectileFactory
    log('before2 '..tostring(artillery.cooldownModifier))
    artillery.cooldownModifier = 0.1
    log('after2 '..tostring(artillery.cooldownModifier))
  end

  function modart3()
    local artillery=Hyperspace.ships.player.artillerySystems[1].projectileFactory
    local artillery2=Hyperspace.ships.player.artillerySystems[0].projectileFactory
    artillery.blueprint = artillery2.blueprint
    artillery.weaponVisual = artillery2.weaponVisual
    artillery.flight_animation=artillery2.flight_animation
  end

  function mod()
    mods.vals.modart = not mods.vals.modart
  end

  function mod2()
    mods.vals.modart2 = not mods.vals.modart2
  end

  function modartmain()
    if mods.vals.modart==true then
      modart()
      modart2()
    end
  end

  function modartmain2()
    if mods.vals.modart2==true then
      modart3()
    end
  end
function art()
  art=Hyperspace.ships.player.artillerySystems[1].projectileFactory
end

function MVFS_ART(x)
  local target_artillery=Hyperspace.ships.player.artillerySystems[x].projectileFactory
  for i=0,3 do
    local current_artillery=Hyperspace.ships.player.artillerySystems[i].projectileFactory
    current_artillery.blueprint = target_artillery.blueprint
    current_artillery.weaponVisual = target_artillery.weaponVisual
    current_artillery.flight_animation=target_artillery.flight_animation
  end
end

script.on_internal_event(Defines.InternalEvents.ON_TICK, modartmain)
script.on_internal_event(Defines.InternalEvents.ON_TICK, modartmain2)
