-- Helper functions
local function cbwrap(value, callback)
    return callback and callback(value) or value
end
local function table_to_list_string(tbl, delimiter, toStrFunc)
    if #tbl == 0 then
        return ""
    elseif #tbl == 1 then
        return cbwrap(tbl[1], toStrFunc)
    end
    delimiter = delimiter or " or "
    if #tbl == 2 then
        return cbwrap(tbl[1], toStrFunc)..delimiter..cbwrap(tbl[2], toStrFunc)
    else
        local res = cbwrap(tbl[1], toStrFunc)
        for i = 2, #tbl - 1 do
            res = res..", "..cbwrap(tbl[i], toStrFunc)
        end
        return res..delimiter..cbwrap(tbl[#tbl], toStrFunc)
    end
end
local function contains(tbl,elem)
    for key, value in pairs(tbl) do
        if value == elem then return true, key end
    end
    return false
end

--table of costs(or ranges of costs as strings?) or costs in scrap to a string of the cost
local function get_cost_string(costs)
    ret = {}
    if type(costs)=="table" then
        if costs[1] and costs[1]>0 then
            table.insert(ret,costs[1].."~")
        end
        if costs[2] and costs[2]>0 then
            table.insert(ret,costs[2].."}")
        end
        if costs[3] and costs[3]>0 then
            table.insert(ret,costs[3].."|")
        end
    else
        return costs.."~"
    end
    return table.concat(ret,", ")
end
local any_phatom = {"phantom_goul","phantom","phantom_mare","phantom_wraith",displayName="[REDACTED]"}
local any_AC_1 = {
    "GB_AC_1",
    "GB_AC_1_CASELESS",
    "GB_AC_1_HV",
    "GB_AC_1_FREE",
    "GB_AC_1_HE",
    "GB_AC_1_EMP",
    "GB_AC_1_HEAT",
    "GB_AC_1_INCENDIARY",
    "GB_AC_1_FLECHETTE",
    "GB_AC_1_RAD",
    displayName ="Any AC1"
}
local any_AC_2 = {
    "GB_AC_2",
    "GB_AC_2_CASELESS",
    "GB_AC_2_HV",
    "GB_AC_2_FREE",
    "GB_AC_2_HE",
    "GB_AC_2_EMP",
    "GB_AC_2_HEAT",
    "GB_AC_2_INCENDIARY",
    "GB_AC_2_FLECHETTE",
    "GB_AC_2_RAD",
    displayName ="Any AC2"
}
local ANY_ASSAULT_DRONE = {"ASSAULT_PIERCE","ASSAULT_PARTICLE",displayName = "Assault Drone"}
local ANY_COMBAT_2 = {"COMBAT_2_LASER","COMBAT_2_BEAM",displayName = "Combat II Drone"}
local ANY_COMBAT_1 = {"COMBAT_1_LASER","COMBAT_1_BEAM",displayName = "Combat I Drone"}
local ANY_ENERGY_AMP = {"ENERGY_1_AMP2","ENERGY_1_AMP3","ENERGY_1_AMP4",displayName = "Amp Energy Drone"}
local ANY_FOCUS_AMP = {"FOCUS_1_AMP2","FOCUS_1_AMP3","FOCUS_1_AMP4",displayName = "Amp Pinpoint Drone"}
local ANY_COMBAT_CONSERVATIVE = {"COMBAT_CONSERVATIVE_BEAM","COMBAT_CONSERVATIVE_LASER",displayName = "Conservative Drone"}
local ANY_BATTLE_DRONE = {"BATTLETOG_DEFEND","BATTLETOG_BOARDER",displayName = "Battle Drone"}
local ANY_PEST_DRONE = {"PEST_RAD","PEST_DEBUFF",displayName = "Pest Drone"}
local ANY_RECON_DRONE = {"RECON_BOARDER","RECON_DEFENSE",displayName = "Recon Drone"}
-- Table of all FM recipes and their ingredients, ingredients listed on the same index in multiple versions of the same recipe indicate that tehy are interchantable
mods.Forgemaster.recipes = {
    FM_LASER_ANOMALY_1 = {
        {
            costs = 40,
            "LASER_BIO",
            "LASER_FROST_1",
        }
    },
    FM_FLAMETHROWER = {
        {
            costs = 50,
            any_phatom,
            "LASER_FIRE",
        }
    },
    FM_PHASER_SUFFOCATION = {
        {
            costs = 55,
            {"lanius",displayName="[REDACTED]"},
            "ION_PIERCE_2",
        }
    },
    FM_LASER_PHOTON = {
        {
            costs = 25,
            "LASER_PARTICLE",
            "LASER_LIGHT",
        }
    },

    FM_LASER_PHOTON_2 = {
        {
            costs = 50,
            "LASER_PARTICLE_2",
            "LASER_LIGHT_2",
        }
    },

    FM_LASER_HUMAN = {
        {
            costs = 40,
            "LASER_HEAVY_1",
            "LASER_BIO",
        }
    },

    FM_LASER_ION_MEGA = {
        {
            costs = {110, 5},
            "LASER_PIERCE_2",
            "BOMB_ION",
        }
    },
    FM_SURGE_LASER = {
        {
            costs = 80,
            "LASER_BURST_5",
            "SHOTGUN_4",
        }
    },
    FM_CHAINGUN_FIRE = {
        {
        costs = 30,
        "LASER_CHAINGUN_2",
        "LASER_FIRE"
        }
    },
    
    
    
    FM_CHAINGUN_ION = {
        {
            costs = 60,
            "LASER_CHAINGUN_2",
            "ION_CHARGEGUN"
        },
        {
            costs = 30,
            "LASER_CHAINGUN_2",
            "ION_CHARGEGUN_2"
        }
    },
    
    FM_ION_TRI_FIRE = {
        {
            costs = 35,
			"ION_FIRE",
			"ION_TRI",
		}
    },



    FM_ENERGY_DISC = {
        {
            costs = 50,
			"ENERGY_HULL",
			{"MINELAUNCHER_1","MINELAUNCHER_2","MINELAUNCHER_FIRE","MINELAUNCHER_STUN",},
		}
    },
		
    FM_SHOTGUN_ENERGY= {
        {
            costs = 80,
			"SHOTGUN_3",
			"ENERGY_CHARGEGUN",
		}
    },

    FM_PULSE_1 = {
        {
            costs = 40,
			"LASER_BURST_2",
			"ENERGY_1",
		}
    },

    FM_PULSE_2 = {
        {
            costs = 50,
			"LASER_BURST_3",
			"ENERGY_2",
		}
    },

    FM_PULSE_3 = {
        {
            costs = 60,
			"LASER_BURST_5",
			"ENERGY_3",
		}
    },

    FM_PULSEDEEP = {
        {
            costs = 50,
			"ENERGY_HULL",
			"ION_HEAVY",
		}
    },
    
    
    
    FM_BEAM_MINING_2 = {
        { 
            costs = 120,
			{"BEAM_MINING"},
			{"BEAM_LONG_2"},
		}
    },

    FM_BEAM_MINING_3 = {
        { 
            costs = 70,
			{"FM_BEAM_MINING_2"},
			{"FOCUS_2"},
		},
        { 
            costs = 50,
			{"FM_BEAM_MINING_2"},
			{"FOCUS_3"},
		}
    },

    FM_BEAM_PARTICLE_PIERCE = {
        { 
            costs = 35,
            {"BEAM_PARTICLE"},
            {"BEAM_PIERCE"},
        }
    },
    

    FM_BEAM_GUILLOTINE_CHAIN = {
        { 
            costs = {110,2,5},
            {"NANOBOT_DEFENSE_SYSTEM","LOCKED_NANOBOT_DEFENSE_SYSTEM", displayName = "[Redacted]"},
			{"BEAM_GUILLOTINE"},
		}
    },

    FM_BEAM_EXPLOSION = {
        { 
            costs = 75,
			{"BOMB_1"},
			{"BEAM_2"},
		}
    },

    FM_FOCUS_FUELED_1 = {
        { 
            costs = 70,
			{"FOCUS_CHAIN"},
			{"MISSILES_3"},
		}
    },

    FM_FOCUS_ENERGY_1 = {
        {  
            costs = 40,
			{"ENERGY_1"},
			{"FOCUS_1"},
		}
    },

    FM_FOCUS_ENERGY_2 = {
        { 
            costs = 60,
			{"ENERGY_2"},
			{"FOCUS_2"},
		}
    },


    FM_FOCUS_ENERGY_3 = {
        { 
            costs = 60,
			{"ENERGY_3"},
			{"FOCUS_3"},
		}
    },

    FM_FOCUS_ENERGY_CONS = {
        { 
            costs = 50,
            {"ENERGY_CONSERVATIVE"},
            {"FOCUS_1"},
		}
    },
		
    FM_FOCUS_VIRUS = {
        { 
            costs = 50,
            {"FM_CORROSIVE_2"},
            {"FOCUS_BIO"},
		}
    },
		

    FM_FOCUS_ADAPT = {
        { 
            costs = 50,
            {"FOCUS_CHAIN"},
            {"BEAM_ADAPT"},
		}
    },

    FM_BEAM_ION_PIERCE = {
        { 
            costs = 100,
			{"ION_1","ION_2"},
			{"BEAM_BREACH"},
		}
    },
    
    FM_BEAM_ETERNITY = {
        { 
            costs = 40,
            {"BEAM_LONG"},
            {"BEAM_SCYTHE"},
        }
    },

    BEAM_PRISM_SCATTER = {
        { 
            costs = 60,
			{"BEAM_PRISM_1"},
			{"AA_ION_RAINBOW"},
		}
    },
        
        
        
    FM_SHOTGUN_ANOMALY = {
        { 
            costs = 45,
			{"SHOTGUN_TOXIC"},
			{"LASER_FROST_2"},
		}
    },

    FM_SHOTGUN_AETHER = {
        {  
            costs = 60,
			{"SHOTGUN_4"},
            {"BLUELIST_AETHER","ANCIENT_LASER",displayName ="some forgotten technology"},
            --bonus_req = {"BLUELIST_AETHER",lvl = 1}
		}
    },

    FM_SHOTGUN_CURSED = {
        {  
            costs = 30,
			{"SHOTGUN_2"},
			{"lanius", displayName = "lanius and clonebay lvl 3"},
            bonus_req = {"clonebay",lvl = 3}
		}
    },

    FM_ENERGY_RAILBLENDER = {
        { 
            costs = 140,
			{"SHOTGUN_CHARGE"},
			{"ENERGY_CHARGEGUN"},
		}
    },

    FM_SHOTGUN_BRONZE = {
        { 
            costs = 10,
			{"SHOTGUN_2"},
            {"CRYSTAL_BURST_1",
			"CRYSTAL_BURST_2",
			"CRYSTAL_HEAVY_1",
			"CRYSTAL_HEAVY_2",
			"CRYSTAL_STUN",
			"CRYSTAL_SHOTGUN",
			"CRYSTAL_CHARGEGUN",
			"BOMB_LOCK","CRYSTAL_BURST_1_RED",
			"CRYSTAL_BURST_2_RED",
			"CRYSTAL_HEAVY_1_RED",
			"CRYSTAL_HEAVY_2_RED",
			"CRYSTAL_STUN_RED",
			"CRYSTAL_SHOTGUN_RED",
			"CRYSTAL_CHARGEGUN_RED",
			"MINELAUNCHER_CRYSTAL", displayName="any Crystal weapon"},
        }
    },
    FM_SHOTGUN_INDIUM = {
        { 
            costs = 100,
			{"FM_SHOTGUN_BRONZE"},
            
        }
    },
    FM_SHOTGUN_RHENIUM = {
        { 
            costs = 150,
			{"FM_SHOTGUN_INDIUM"},
            
        }
    },
    FM_SHOTGUN_SILVER = {
        { 
            costs = 200,
			{"FM_SHOTGUN_RHENIUM"},
            
        }
    },
    FM_SHOTGUN_PALLADIUM = {
        { 
            costs = 250,
			{"FM_SHOTGUN_SILVER"},
            
        }
    },
    
		
    FM_SHOTGUN_IRIDIUM = {
        { 
            costs = 250,
			{"FM_SHOTGUN_PALLADIUM"},
			{"CRYSTAL_BURST_1_RED",
			"CRYSTAL_BURST_2_RED",
			"CRYSTAL_HEAVY_1_RED",
			"CRYSTAL_HEAVY_2_RED",
			"CRYSTAL_STUN_RED",
			"CRYSTAL_SHOTGUN_RED",
			"CRYSTAL_CHARGEGUN_RED",
			"MINELAUNCHER_CRYSTAL", displayName="any Elite Crystal weapon"},
		}
    },
    FM_SHOTGUN_PLATINUM = {
        { 
            costs = 260,
			{"FM_SHOTGUN_IRIDIUM"},
            
        }
    },

    FM_SHOTGUN_OSMIUM = {
        { 
            costs = 260,
			{"FM_SHOTGUN_PLATINUM"},
            
        }
    },
    FM_SHOTGUN_NOBELIUM = {
        { 
            costs = 260,
			{"FM_SHOTGUN_OSMIUM"},
            
        }
    },


    FM_SHOTGUN_HASSIUM = {
        { 
            costs = 260,
			{"FM_SHOTGUN_NOBELIUM"},
			{"CRYSTAL_BURST_1_RED",
			"CRYSTAL_BURST_2_RED",
			"CRYSTAL_HEAVY_1_RED",
			"CRYSTAL_HEAVY_2_RED",
			"CRYSTAL_STUN_RED",
			"CRYSTAL_SHOTGUN_RED",
			"CRYSTAL_CHARGEGUN_RED",
			"MINELAUNCHER_CRYSTAL", displayName="any Elite Crystal weapon"},
		}
    },
        
        
        
    FM_MISSILES_BURST_FIRE = {
        { 
            costs = 90,
			{"MISSILES_4"},
			{"MISSILES_FIRE"},
		}
    },

    FM_MISSILES_CLOAK_STUN = {
        { 
            costs = 70,
			{"MISSILES_CLOAK"},
			{"ENERGY_STUN"},
		}
    },

    FM_BOMB_CRYSTAL_FIRE = {
        { 
            costs = 60,
			{"BOMB_FIRE"},
			{"BOMB_LOCK"},
		}
    },

    FM_BOMB_CRYSTAL_BIO = {
        { 
            costs = 80,
			{"BOMB_BIO"},
			{"BOMB_LOCK"},
		}
    },

    FM_BOMB_CRUNCH = {
        { 
            costs = 99999,
			{"BOMB_BIO"},
			{"BOMB_LOCK"},
		}
    },

    FM_MINELAUNCHER_HULL = {
        { 
            costs = 90,
			{"LASER_HULL_2"},
			{"MINELAUNCHER_BREACH"},
		}
    },

    FM_MINELAUNCHER_BIO = {
        { 
            costs = 140,
			{"MISSILES_BIO"},
			{"MINELAUNCHER_2"},
		}
    },

    FM_ION_MISSILES = {
        { 
            costs = 80,
			{"MISSILES_3"},
			{"ION_3"},
		}
    },


    FM_IMPRISMENT_INDUCER = {
        { 
            costs = 55,
			{"BOMB_STUN"},
			{"CRYSTAL_STUN"},
		},
        { 
            costs = 25,
            {"BOMB_STUN"},
            {"CRYSTAL_STUN_RED"},
        }
    },



    FM_RVS_AC_CHARGE = {
        {
            costs = 60,
            any_AC_1,
            any_AC_1,
        },
        {
            costs = 40,
            any_AC_1,
            any_AC_1,
            any_AC_1,
        },
        {
            costs = 20,
            any_AC_1,
            any_AC_1,
            any_AC_1,
            any_AC_1,
        }
    },
		
		
    MAMMOTH_CANNON = {
        {
            costs = 60,
			{"MISSILES_V5_SINGLE","MISSILES_V5_MULTI", displayName = "any V5 Missiles"},
			any_AC_2,
            any_AC_2,
		}
    },
		
        
    FM_BEAM_BASILISK = {
        { 
            costs = 0,
			{"leech"},
			{"KERNEL_1_ELITE","KERNEL_2_ELITE","KERNEL_HEAVY_ELITE","KERNEL_HULL_ELITE","KERNEL_CHARGE_ELITE"},
		}
    },
    
    
    
    
    
    --DRONES
    FM_ENERGY_COMBAT_BEAM1 = {
		{
            costs = 37,
            ANY_ENERGY_AMP,
            ANY_COMBAT_2,
		}
    },

    FM_AMBER_DRONE = {
		{
            costs = 37,
            ANY_ASSAULT_DRONE,
			{"CRYSTAL_HEAVY_1"},
		}
    },

    FM_CRYSTAL_DRONE = {
		{
            costs = 37,
            ANY_ASSAULT_DRONE,
			{"CRYSTAL_SHOTGUN"},
		}
    },

    FM_CURA_DRONE = {
		{
            costs = 110,
            ANY_COMBAT_CONSERVATIVE,
            ANY_BATTLE_DRONE,
			{"MANNING"},
		}
    },



    FM_FLAMETHROWER_DRONE = {
		{
            costs = 37,
            ANY_ASSAULT_DRONE,
			any_phatom,
		}
    },

    FM_FORGEMAN_DRONE = {
		{--Maybe lock this one behind a "craft each of the weapons the drone has at least once" metavariable
            costs = 37,
            ANY_COMBAT_2,
			{"fm_plated"},
		}
    },

    FM_ISHIMURA_DRONE = {
		{
            costs = 37,
            ANY_FOCUS_AMP,
			{"FOCUS_3"},
		}
    },

    FM_KESTREL_DRONE = {
		{
            costs = 100,
            ANY_COMBAT_1,
			{"LASER_BURST_3"},
		}
    },

    FM_MFK_KESTREL_DRONE = {
		{
            costs = 100,
            ANY_COMBAT_1,
			{"LASER_LIGHT"},
		}
    },

    FM_MFK_PICKET_DRONE = {
		{
            costs = 37,
            ANY_RECON_DRONE,
			{"EX_TELEPORT_HEAL"},
		}
    },

    FM_SIREN_DRONE = {
		{
            costs = 37,
            ANY_PEST_DRONE,
			{"BOMB_STUN"},
		}
    },
    
    
    
    rock = {
        {
            "FISH_FOOD_ROCK",
            "human",
            "aaaaaaaaaaaa"
        }
    },
    shell = {
        "FISH_FOOD_TINCAN",
        "slug",
        "aaaaaaaaaaaa"
    },
}
-- Table of all FM ingredients and what they are used in
mods.Forgemaster.ingredients = {}
local ingredients = mods.Forgemaster.ingredients
--[[
ingredients.LASER_CHAINGUN_2 = {
    [1] = {
        needs = {"ION_CHARGEGUN", "ION_CHARGEGUN_2"},
        makes = "FM_CHAINGUN_ION",
        costs = "30-60"
    },
    [2] = {
        needs = {"LASER_FIRE"},
        makes = "FM_CHAINGUN_FIRE",
        costs = "30"
    }
}--]]

--recipes -> ??? -> ingredients
function mods.Forgemaster.reload_recipes()
    mods.Forgemaster.ingredients = {}
    ingredients = mods.Forgemaster.ingredients
    for result, recipe in pairs(mods.Forgemaster.recipes) do
        --local newtbl = {makes=result}
        for _, subRecipe in ipairs(recipe) do--iterating over the different recipes for a gun
            for _, ingredient in ipairs(subRecipe) do --iterating over all ingredients per recipe
                if type(ingredient)=="string" then
                    mods.Forgemaster.ingredients[ingredient] = mods.Forgemaster.ingredients[ingredient] or {}
                    if(not contains(mods.Forgemaster.ingredients[ingredient],result)) then
                        table.insert(mods.Forgemaster.ingredients[ingredient],result)
                    end
                elseif type(ingredient)=="table" then
                    for _, entry_in_ingredientList in ipairs(ingredient) do --iterating over all the ingredients that can be put into this list
                        if mods.Forgemaster.ingredients[entry_in_ingredientList] then
                            if(not contains(mods.Forgemaster.ingredients[entry_in_ingredientList],result)) then
                                table.insert(mods.Forgemaster.ingredients[entry_in_ingredientList],result)
                            end
                        else
                            mods.Forgemaster.ingredients[entry_in_ingredientList] = {result}
                        end
                    end
                end
            end
        end
    end
end
mods.Forgemaster.reload_recipes()


-- Write FM forging tips
local function weapon_title_from_name(name)
    local ret = Hyperspace.Blueprints:GetWeaponBlueprint(name):GetNameShort()
    if string.len(ret) == 0 then return "[REDACTED]" end
    return ret
end
-- taking in 
local function ingredient_title_from_entry(ingredient,index)
    if type(ingredient)=="table" and ingredient.displayName then return ingredient.displayName end
    if type(ingredient)=="table" then name = ingredient[index or 1] else name = ingredient end
    local ret = Hyperspace.Blueprints:GetWeaponBlueprint(name):GetNameShort()
    if string.len(ret) > 0 then return ret end
    ret = Hyperspace.Blueprints:GetDroneBlueprint(name):GetNameShort()
    if string.len(ret) > 0 then return ret end
    local aug = Hyperspace.Blueprints:GetAugmentBlueprint(name)
    if not tostring(Hyperspace.version):find("1.13") and string.len(aug:GetNameShort()) > 0 then return aug:GetNameShort() end
    ret = Hyperspace.Blueprints:GetCrewBlueprint(name):GetNameShort()
    if (ingredient == "human" or ret ~= Hyperspace.Blueprints:GetCrewBlueprint("human"):GetNameShort()) then return ret end
    return false
end
--turns an ingredientList of a recipe into a string of the names of the ingredients that exist, if the ingredientList is a string its interpreted as an ID 
local function ingredient_list_to_string(ingredientList)
    if(type(ingredientList)=="string") then return ingredient_title_from_entry(ingredientList) or "" end
    local ingredientList_truenames = {}
    for index, value in ipairs(ingredientList) do
        local ingredient_truename = ingredient_title_from_entry(value)
        if(ingredient_truename) then
            table.insert(ingredientList_truenames,ingredient_truename)
        end
    end
    local ret = table_to_list_string(ingredientList_truenames," or ")
    if ingredientList.displayName and #ret>0 then return ingredientList.displayName end
    return ret
end
--[[
script.on_internal_event(Defines.InternalEvents.WEAPON_DESCBOX, function(bp, desc)
    local recipes = ingredients[bp.name]
    if recipes then
        Hyperspace.Mouse.tooltip = Hyperspace.Mouse.tooltip.."\n"
        --desc = desc.."\n"
        for _, recipe in ipairs(recipes) do
            local otherIngredients = table_to_list_string(recipe.needs, recipe.needsAll and " and " or " or ", weapon_title_from_name)
            if(ingredient_title_from_entry(recipe.makes)) then 
                Hyperspace.Mouse.tooltip = Hyperspace.Mouse.tooltip..string.format("Forge with %s to make %s (%s~).\n", otherIngredients, weapon_title_from_name(recipe.makes), recipe.costs)
            end
        end
        return desc
    end
end)--]]

local forgestring = "Forge with %s to make %s (%s)."
local forgestring_alone = "Forge to make %s (%s)."
--recipeList is all the recipes for the same item that have differing costs
local function recipes_to_strings(recipeList,ingredient)
    local recipeStrings = {}
    for recipe_index, recipe in ipairs(recipeList) do--iterating over the 1-2 recipes
        local ingredient_strings = {}
        local valid_recipe = false
        local invalid_recipe = false
        local index_where_current_ingredient
        for ingredient_index, ingredient_list in ipairs(recipe) do--this is all the ingredients/list of possible alternative ingredients
            local valid_recipe_temp,index_temp
            if type(ingredient_list)=="string" then
                valid_recipe_temp = ingredient_list==ingredient
            else
                valid_recipe_temp, index_temp= contains(ingredient_list,ingredient)
            end
            if(valid_recipe_temp) then
                index_where_current_ingredient = index_where_current_ingredient or ingredient_index
            end
            valid_recipe = valid_recipe or valid_recipe_temp
            if not valid_recipe_temp or index_where_current_ingredient ~= ingredient_index then
                local ingredient_string = ingredient_list_to_string(ingredient_list)
                if #ingredient_string==0 then invalid_recipe=true end
                table.insert(ingredient_strings,ingredient_string)
            end
        end
        if valid_recipe and not invalid_recipe then
            if(#ingredient_strings>0) then
                table.insert(recipeStrings,forgestring:format(table_to_list_string(ingredient_strings, " and "),"%s",get_cost_string(recipe.costs or 0)))
            else
                table.insert(recipeStrings,forgestring_alone:format("%s",get_cost_string(recipe.costs or 0)))
            end
        end
    end
    return recipeStrings
end

mods.Forgemaster.power_efficient_ingredients = {
    ENERGY_CHARGEGUN_PLAYER = "ENERGY_CHARGEGUN",
    ENERGY_2_PLAYER = "ENERGY_2",
    BEAM_GUILLOTINE_PLAYER = "BEAM_GUILLOTINE",
    BEAM_2_PLAYER = "BEAM_2",
    FOCUS_BIO_PLAYER = "FOCUS_BIO",
    LASER_FROST_2_PLAYER = "LASER_FROST_2",
    SHOTGUN_TOXIC_PLAYER = "SHOTGUN_TOXIC",
    SHOTGUN_2_PLAYER = "SHOTGUN_2",
    MISSILES_FIRE_PLAYER = "MISSILES_FIRE",
    MISSILES_4_PLAYER = "MISSILES_4",
    ENERGY_STUN_PLAYER = "ENERGY_STUN",
    MISSILES_CLOAK_PLAYER = "MISSILES_CLOAK",
    
    FM_SHOTGUN_BRONZE_PLAYER = "FM_SHOTGUN_BRONZE",
    FM_SHOTGUN_INDIUM_PLAYER = "FM_SHOTGUN_INDIUM",
    FM_SHOTGUN_RHENIUM_PLAYER = "FM_SHOTGUN_RHENIUM",
    FM_SHOTGUN_SILVER_PLAYER = "FM_SHOTGUN_SILVER",
    FM_SHOTGUN_PALLADIUM_PLAYER = "FM_SHOTGUN_PALLADIUM",
    FM_SHOTGUN_IRIDIUM_PLAYER = "FM_SHOTGUN_IRIDIUM",
    FM_SHOTGUN_PLATINUM_PLAYER = "FM_SHOTGUN_PLATINUM",
    FM_SHOTGUN_OSMIUM_PLAYER = "FM_SHOTGUN_OSMIUM",
    FM_SHOTGUN_NOBELIUM_PLAYER = "FM_SHOTGUN_NOBELIUM",
    
}

script.on_internal_event(Defines.InternalEvents.WEAPON_DESCBOX, function(bp, desc)
    local recipes = ingredients[mods.Forgemaster.power_efficient_ingredients[bp.name] or bp.name]--this is a list of all the items that can be crafted from the this here item
    if recipes then
        --desc = desc.."\n"
        for _, thing_this_can_make in ipairs(recipes) do
            local recipe = mods.Forgemaster.recipes[thing_this_can_make]
            local recipes_for_this_thing = recipes_to_strings(recipe,mods.Forgemaster.power_efficient_ingredients[bp.name] or bp.name)    --table_to_list_string(mods.Forgemaster.recipes[recipe]," or ", ingredient_title_from_entry)
            if(ingredient_title_from_entry(thing_this_can_make)and #recipes_for_this_thing>0) then 
                for _, recipe_string in ipairs(recipes_for_this_thing) do
                    Hyperspace.Mouse.tooltip = #Hyperspace.Mouse.tooltip > 0 and Hyperspace.Mouse.tooltip.."\n" or ""
                    Hyperspace.Mouse.tooltip = Hyperspace.Mouse.tooltip..string.format(recipe_string, ingredient_title_from_entry(thing_this_can_make))
                    --print(Hyperspace.Mouse.tooltip)
                end
            end
        end
        --Hyperspace.Mouse.tooltip = Hyperspace.Mouse.tooltip:sub(1,#Hyperspace.Mouse.tooltip-1)
        return desc
    end
end)
--148

-- eepy && !(wanna_draw || need_to_do_school)