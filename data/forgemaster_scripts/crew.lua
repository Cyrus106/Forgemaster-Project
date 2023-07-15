local vter = mods.inferno.vter
local DefaultTable = mods.inferno.DefaultTable

--BLOOD MORPH

local function MorphBoost(table) 
  local def = Hyperspace.StatBoostDefinition()
  def.stat = Hyperspace.CrewStat[table.stat]
  if type(table.value) == "boolean" then
    def.value = table.value
    def.boostType = Hyperspace.StatBoostDefinition.BoostType.SET
  else
    def.amount = table.value
    def.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
  end
  def.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
  def.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
  def.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
  def.cloneClear = false
  return def
end

local MorphBoosts = DefaultTable {
  --MV crew
  human = MorphBoost {stat = "MAX_HEALTH", value = 15},
  zoltan = MorphBoost {stat = "BONUS_POWER", value = 1},

  --FM crew
  
  DEFAULT = MorphBoost {stat = "MAX_HEALTH", value = 10} --Default boost for when a crew does not have one assigned 
}


script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER,
function(ActivatedPower, ShipManager)
  if ActivatedPower.def.name == "fm_blood_morph_absorb" then --Blood Morph power
    local powerCrew = ActivatedPower.crew --Power user
    for targetCrew in vter(ShipManager.vCrewList) do 
	--For all other friendly crew in the same room do this
      if targetCrew.iRoomId == powerCrew.iRoomId and targetCrew.iShipId == powerCrew.iShipId and targetCrew ~= powerCrew then 
        local boostDefinition = MorphBoosts[targetCrew:GetSpecies()]
        local boost = Hyperspace.StatBoost(boostDefinition)
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(boost, powerCrew)
      end
    end
  end
  return Defines.Chain.CONTINUE
end)
--]]

--Generate table-like string containing all races to be filled in later
local crewTab = {}
local parent = RapidXML.xml_document("data/hyperspace.xml"):first_node("FTL"):first_node("crew")
while parent do
	local child = parent:first_node("race")
	while child do
		table.insert(crewTab, child:first_attribute("name"):value())
		child = child:next_sibling("race")
	end
	parent = parent:next_sibling("crew")
end
log("\n\n{\n\t"..table.concat(crewTab," = ,\n\t").." = ,\n}")
--Check FTL_HS.log for all races in all mods patched. Just a tool to be used for filling out the table, unless we make a function to calculate boosts another way.
--[[
Result will look like this
 {
	hologram = ,
	human = ,
	human_humanoid = ,
	human_rebel = ,
	human_rebel_medic = ,
	human_medic = ,
	human_engineer = ,
	human_soldier = ,
	easter_coomer = ,
	easter_tommy = ,
	easter_bubby = ,
	human_technician = ,
	human_technician_drone = ,
	human_mfk = ,
	human_legion = ,
	human_legion_pyro = ,
	unique_cyra = ,
	unique_tully = ,
	unique_vance = ,
	unique_haynes = ,
	unique_jerry = ,
	unique_jerry_gun = ,
	unique_jerry_pony = ,
	unique_jerry_pony_crystal = ,
	unique_leah = ,
	unique_leah_mfk = ,
	human_angel = ,
	unique_ellie = ,
	unique_ellie_stephan = ,
	unique_ellie_lvl1 = ,
	unique_ellie_lvl2 = ,
	unique_ellie_lvl3 = ,
	unique_ellie_lvl4 = ,
	unique_ellie_lvl5 = ,
	unique_ellie_lvl6 = ,
	engi = ,
	engi_separatist = ,
	engi_separatist_nano = ,
	engi_defender = ,
	unique_turzil = ,
	zoltan = ,
	zoltan_monk = ,
	zoltan_peacekeeper = ,
	zoltan_devotee = ,
	zoltan_martyr = ,
	unique_devorak = ,
	unique_anurak = ,
	zoltan_osmian = ,
	zoltan_osmian_hologram = ,
	zoltan_osmian_enemy = ,
	orchid = ,
	orchid_chieftain = ,
	orchid_vampweed = ,
	orchid_cultivator = ,
	gardener = ,
	mantis = ,
	mantis_suzerain = ,
	mantis_free = ,
	mantis_free_chaos = ,
	mantis_warlord = ,
	mantis_bishop = ,
	unique_kaz = ,
	unique_freddy = ,
	unique_freddy_fedora = ,
	unique_freddy_jester = ,
	unique_freddy_sombrero = ,
	unique_freddy_twohats = ,
	rock = ,
	easter_brick = ,
	rock_outcast = ,
	rock_commando = ,
	rock_crusader = ,
	rock_paladin = ,
	rock_paladin_enemy = ,
	unique_symbiote = ,
	rock_cultist = ,
	unique_vortigon = ,
	unique_tuco = ,
	unique_ariadne = ,
	rock_elder = ,
	crystal = ,
	crystal_liberator = ,
	crystal_sentinel = ,
	unique_ruwen = ,
	unique_dianesh = ,
	unique_obyn = ,
	unique_obyn_temp = ,
	nexus_obyn_cel = ,
	slug = ,
	slug_hektar = ,
	slug_hektar_box = ,
	unique_billy = ,
	unique_billy_box = ,
	slug_saboteur = ,
	slug_knight = ,
	unique_nights = ,
	unique_slocknog = ,
	slug_clansman = ,
	slug_ranger = ,
	unique_irwin = ,
	unique_irwin_demon = ,
	unique_sylvan = ,
	nexus_sylvan_cel = ,
	nexus_sylvan_gman = ,
	bucket = ,
	sylvanrick = ,
	sylvansans = ,
	saltpapy = ,
	sylvanmaid = ,
	sylvanleah = ,
	sylvanrebel = ,
	dylan = ,
	nexus_pants = ,
	prime = ,
	sylvan1d = ,
	sylvanclan = ,
	beans = ,
	leech = ,
	leech_ampere = ,
	unique_tonysr = ,
	unique_tyrdeo = ,
	unique_tyrdeo_bird = ,
	unique_alkram = ,
	siren = ,
	siren_harpy = ,
	shell = ,
	shell_scientist = ,
	shell_mechanic = ,
	shell_guardian = ,
	shell_radiant = ,
	unique_alkali = ,
	blob = ,
	unique_ooj = ,
	unique_ooj_love = ,
	blobcrystal = ,
	blobfreemantis = ,
	blobhuman = ,
	bloblizard = ,
	blobleech = ,
	blobmantis = ,
	blobpony = ,
	blobrock = ,
	blobsalt = ,
	blobshell = ,
	bloborchid = ,
	blobslug = ,
	blobspider = ,
	blobweaver = ,
	blobhatch = ,
	blobswarm = ,
	blobzoltan = ,
	gold = ,
	goldsoldier = ,
	goldampere = ,
	goldchieftain = ,
	goldcrusader = ,
	golddefend = ,
	goldroyal = ,
	goldsabo = ,
	goldsuzerain = ,
	goldsentinel = ,
	goldtoxic = ,
	goldwarlord = ,
	goldwelder = ,
	goldqueen = ,
	techno = ,
	technoengi = ,
	technoancient = ,
	technoavatar = ,
	technolanius = ,
	technobattle = ,
	technobattle2 = ,
	technoboarderion = ,
	technorepair = ,
	technodoctor = ,
	technomanning = ,
	technorecon = ,
	technoatom = ,
	technodirector = ,
	technomender = ,
	technoa55 = ,
	technogana = ,
	technoroomba = ,
	lanius = ,
	lanius_augmented = ,
	unique_anointed = ,
	lanius_welder = ,
	unique_eater = ,
	phantom = ,
	phantom_alpha = ,
	phantom_goul = ,
	phantom_goul_alpha = ,
	phantom_mare = ,
	phantom_mare_alpha = ,
	phantom_wraith = ,
	phantom_wraith_alpha = ,
	unique_dessius = ,
	gbeleanor = ,
	gbscoleri = ,
	gbslimer = ,
	gbpsych = ,
	gbvinz = ,
	gbzuul = ,
	spider = ,
	spider_weaver = ,
	spider_hatch = ,
	unique_queen = ,
	easter_angel = ,
	spider_venom = ,
	spider_venom_chaos = ,
	tinybug = ,
	unique_guntput = ,
	lizard = ,
	unique_metyunt = ,
	pony = ,
	pony_tamed = ,
	easter_sunkist = ,
	ponyc = ,
	pony_engi = ,
	pony_engi_chaos = ,
	pony_engi_nano = ,
	pony_engi_nano_chaos = ,
	cognitive = ,
	cognitive_automated = ,
	cognitive_advanced = ,
	cognitive_advanced_automated = ,
	obelisk = ,
	unique_wither = ,
	obelisk_royal = ,
	eldritch_cat = ,
	eldritch_thing = ,
	eldritch_thing_weak = ,
	gnome = ,
	unique_judge_thest = ,
	unique_judge_corby = ,
	unique_judge_wakeson = ,
	a55 = ,
	gana = ,
	battle = ,
	drone_battle = ,
	drone_yinyang = ,
	drone_yinyang_board = ,
	drone_yinyang_chaos = ,
	loot_separatist_1 = ,
	drone_battle2 = ,
	repairboarder = ,
	repair = ,
	divrepair = ,
	butler = ,
	drone_recon = ,
	drone_recon_defense = ,
	drone_recon_boarder = ,
	doctor = ,
	surgeon = ,
	surgeon_chaos = ,
	manning = ,
	manningenemy = ,
	drone_holodrone = ,
	drone_holodrone_chaos = ,
	mender = ,
	menderr = ,
	director = ,
	atom = ,
	atomr = ,
	roomba = ,
	eldritch_spawn = ,
	snowman = ,
	snowman_chaos = ,
	acid = ,
	fm_repair_hull = ,
	fm_ion_anomaly_crew = ,
	fm_ion_anomaly_crew_enemy = ,
	fm_ion_instant_1 = ,
	fm_ion_instant_2 = ,
	fm_ion_instant_3 = ,
	fm_ion_instant_4 = ,
	fm_power_drain = ,
	fm_explode_instant = ,
	fm_drone_hack = ,
	fm_missile_ion = ,
	fm_forgemasterperson = ,
	fm_forgemasterperson_player = ,
	fm_plated = ,
	fm_plated_shell = ,
	fm_separatist_bronze = ,
	fm_separatist_cobalt = ,
	fm_nano_cobalt = ,
	fm_separatist_twisted = ,
	fm_blood_morph = ,
	fm_fallen = ,
	fm_crystal_red = ,
	fm_crystal_blue = ,
	fm_crystal_green = ,
	fm_crystal_white = ,
	fm_crystal_black = ,
	fm_crystal_prison = ,
	fm_terminus = ,
	unique_remington = ,
	unique_mossberg = ,
	gbgozer = ,
	gbgozer_player = ,
	fm_human_texture = ,
	orchid_fire = ,
	husk_slug = ,
	husk_slug_player = ,
	mantis_crackerjack = ,
	fm_power = ,
	fm_fire_intruder = ,
	fm_ancalagon_battle = ,
	fm_ancalagon_monitor = ,
	manningenemy_2 = ,
	twisted_mender = ,
	twisted_yinyang_ship = ,
	twisted_yinyang_board = ,
	twisted_drone_battle2 = ,
	twisted_surgeon = ,
	fm_holy1 = ,
	fm_holy2 = ,
	fm_holy3 = ,
	fm_holy4 = ,
	fm_holy5 = ,
	fm_holy6 = ,
	fm_holy7 = ,
	fm_holy8 = ,
	fm_holy9 = ,
	fm_holy10 = ,
	fm_meatman = ,
	fm_holy11 = ,
	fm_holy12 = ,
	fm_holy13 = ,
	fm_holy14 = ,
	fm_holy15 = ,
	fm_holy16 = ,
	fm_holy17 = ,
	fm_holy18 = ,
	fm_holy19 = ,
	fm_holy20 = ,
	fm_bio_cloud = ,
	fm_generic_crewjank = ,
}
--]]

