if not (Hyperspace.version and Hyperspace.version.major == 1 and Hyperspace.version.minor >= 8) then
	error("Incorrect Hyperspace version detected! Auto Library requires Hyperspace 1.8+")
end

local vter = function(cvec) --Taken from Vertex
	local i = -1 -- so the first returned value is indexed at zero
	local n = cvec:size()
	return function()
		i = i + 1
		if i < n then return cvec[i] end
	end
end

mods.autolibrary = {}

--[[
Checks if the ship is auto in the blueprints. A.K.A if they're an auto by default.
If no ship is given, will use the player ship.
Can be overriden with overrideBaseAutomated.
]]
function mods.autolibrary.isBaseAutomated(ship)
	if Hyperspace.playerVariables.override_base_automated < 1 then
		local ship = ship or Hyperspace.ships.player
		local shipDefinition = Hyperspace.CustomShipSelect.GetInstance():GetDefinition(ship.myBlueprint.blueprintName)
		return shipDefinition.forceAutomated.value or (ship.myBlueprint.originalCrewCount == 0 and shipDefinition.crewList:size() == 0)
	else
		return (Hyperspace.playerVariables.override_base_automated == 2)
	end
end

local isBaseAutomated = mods.autolibrary.isBaseAutomated

--[[
This lets you use isBaseAutomated as a req for events
]]
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	if ship.iShipId == 0 and not Hyperspace.Global.GetInstance():GetCApp().menu.shipBuilder.bOpen then
		Hyperspace.playerVariables.is_base_automated = (isBaseAutomated(ship) and 1 or 0)
	end
end)

--[[
Allows you to override isBaseAutomated so it will always return true or false.
If override is false, isBaseAutomated will return to its normal behavior.
Otherwise, it will make isBaseAutomated always return the bool/bool version of the argument provided (second argument).
If no bool is given (no second argument), it will flip the current bool being used.
This function uses varargs so that the flipping behavior will happen only if you don't provide a bool argument,
and not if you provide nil as the argument.
]]
function mods.autolibrary.overrideBaseAutomated(override, ...)
	local n = select("#", ...)
	local arg = {...}
	local bool = nil
	
	if n == 0 then
		bool = not (Hyperspace.playerVariables.override_base_automated == 2) --Flip the current state
	else
		bool = arg[1] --Use the bool given
	end
	
	if override then
		if bool then
			Hyperspace.playerVariables.override_base_automated = 2
		else
			Hyperspace.playerVariables.override_base_automated = 1
		end
	else
		Hyperspace.playerVariables.override_base_automated = 0
	end
end

--[[
THIS VERSION WILL BE REINSTATED WHEN LUA SAVING IS ADDED

Allows you to override isBaseAutomated so it will always return true or false.
If override is false, isBaseAutomated will return to its normal behavior.
Otherwise, it will make isBaseAutomated always return the bool provided.
You can also set it to use a custom function for determining isBaseAutomated. Make sure this function takes a ship argument.

function mods.autolibrary.overrideBaseAutomated(override, boolOrFunc)
	if override then
		if type(boolOrFunc) == "boolean" then
			mods.autolibrary.baseAutomatedBoolOverride = boolOrFunc
			Hyperspace.playerVariables.override_base_automated = 1
		elseif type(boolOrFunc) == "function" then
			mods.autolibrary.baseAutomatedFuncOverride = boolOrFunc
			Hyperspace.playerVariables.override_base_automated = 2
		else
			error("Error in overrideBaseAutomated, boolOrFunc must be a boolean or a function!", 2)
		end
	else
		Hyperspace.playerVariables.override_base_automated = 0
	end
end
]]

--Reset override_base_automated when you're in the hangar
script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
	if Hyperspace.Global.GetInstance():GetCApp().menu.shipBuilder.bOpen then
		Hyperspace.playerVariables.override_base_automated = 0
	end
end)

--[[
Auto-Ship Augment Code

To use this, make an augment with AUTOMATED_SHIP set as a function.

Values greater than 1 have effects equivalent to having higher levels of AUTOMATED_MANNING and AUTOMATED_REPAIR.
Check their comments for more information.
]]
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	if ship.iShipId == 0 then --If it's the player ship
		local autoAugValue = ship:GetAugmentationValue("AUTOMATED_SHIP")
		ship.bAutomated = autoAugValue > 0
	end
end)

--Code to make normal Auto-Ships stack with AUTOMATED_SHIP
script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE, function(ship, name, value)
	pcall(function()
		if name == "AUTOMATED_SHIP" and isBaseAutomated(ship) then
			value = value + 1
		end
	end)
	return Defines.Chain.CONTINUE, value
end)

--Code to make AUTOMATED_SHIP stack
script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ship, name, value)
	if name == "AUTOMATED_MANNING" or name == "AUTOMATED_REPAIR" then
		pcall(function()
			local extraCores = math.max(ship:GetAugmentationValue("AUTOMATED_SHIP") - 1, 0)
			local valuePerCore = 1 --two cores means double attributes
			value = value + extraCores * valuePerCore
		end)
	end
	return Defines.Chain.CONTINUE, value
end)

--[[
These tables are for tracking the manning value increases of every manning function run in a tick.
This fixes a bug where the manning functions wouldn't stack properly if a crew was manning the system.

They are global just in case there's a use-case for modifying them directly or reading them.
Index 0 is for the player ship, and index 1 is for the enemy ship.
]]
mods.autolibrary.lastManningLevelIncreases = {}
local lastManningLevelIncreases = mods.autolibrary.lastManningLevelIncreases

mods.autolibrary.lastSingleSystemManningLevelIncreases = {}
local lastSingleSystemManningLevelIncreases = mods.autolibrary.lastSingleSystemManningLevelIncreases

--Class and metatable for the tables in lastSingleSystemManningLevelIncreases. Contains the manning level increases for every system in the player/enemy ship.
local SingleSystemManningLevelIncreases = {}

SingleSystemManningLevelIncreases.defaultValues = {}
SingleSystemManningLevelIncreases.__metatable = "SingleSystemManningLevelIncreases is protected."
SingleSystemManningLevelIncreases.__index = SingleSystemManningLevelIncreases.defaultValues

--Set the default value of 0 for every valid systemId
for i = 0, 15 do SingleSystemManningLevelIncreases.defaultValues[i] = 0 end
SingleSystemManningLevelIncreases.defaultValues[20] = 0 --Temporal

--Constructor
SingleSystemManningLevelIncreases.new = function()
	local newSingleSystemManningLevelIncreases = {}
	setmetatable(newSingleSystemManningLevelIncreases, SingleSystemManningLevelIncreases)
	return newSingleSystemManningLevelIncreases
end

--Reset the last manning level increases
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	lastManningLevelIncreases[ship.iShipId] = 0
	lastSingleSystemManningLevelIncreases[ship.iShipId] = SingleSystemManningLevelIncreases.new()
end)

--[[
Adds the specified level to the manning level of every mannable system in ship.
If the system is manned, it will choose the crew manning level if it is higher.

The levels work the same as the function levels listed in the Auto-Manning Augment Code section.
It will not subtract from piloting.

Must be run every tick with ON_TICK or SHIP_LOOP (recommended) to work!
]]
function mods.autolibrary.setManningLevel(level, ship)
	local manningValue = math.floor(level) --Manning level must be an integer
	local mannedSystems = {}
	--Only iterate through crew list once, rather than running a utility function for each system and iterating each time
	for crew in vter(ship.vCrewList) do 
		mannedSystems[crew.iManningId] = true
	end  

	for system in vter(ship.vSystemList) do
		local systemId = system:GetId()
		
		if systemId == 6 then --If the system is piloting
			if manningValue > 0 then
				system.bManned = true
			else --skip piloting
				goto continue
			end
		end
		
		if mannedSystems[systemId] then --If system is manned then
			system.iActiveManned = math.max(system.iActiveManned, manningValue + lastManningLevelIncreases[ship.iShipId] + lastSingleSystemManningLevelIncreases[ship.iShipId][systemId] + (ship.bAutomated and 1 or 0))
			--need to add any previous manning level increases, and one if it's automated
		else
			--Add manning level
			system.iActiveManned = system.iActiveManned + manningValue 
		end
		--Cap at 3
		system.iActiveManned = math.min(system.iActiveManned, 3)
		::continue::
	end
	lastManningLevelIncreases[ship.iShipId] = lastManningLevelIncreases[ship.iShipId] + manningValue
end

local setManningLevel = mods.autolibrary.setManningLevel

--[[
Adds the specified level to the manning level of the specified system in ship.
If the system is manned, it will choose the crew manning level if it is higher.

The levels work the same as the function levels listed in the Auto-Manning Augment Code section.
Unlike setManningLevel, it can subtract manning level from piloting.

Must be run every tick with ON_TICK or SHIP_LOOP (recommended) to work!
]]
function mods.autolibrary.setManningLevelSingleSystem(level, systemId, ship)
	if not ship:HasSystem(systemId) then --Don't run if the ship doesn't have the system
		return
	end
	
	local manningValue = math.floor(level) --Manning level must be an integer
	local system = ship:GetSystem(systemId)
	local crewManningSystem = false
	
	for crew in vter(ship.vCrewList) do
		if crew.iManningId == systemId then
			crewManningSystem = true
			break
		end
	end
	
	if systemId == 6 then --If the system is piloting
		system.bManned = true
	end
	
	if crewManningSystem then
		--Manning level is max between augment manning and current manning
		system.iActiveManned = math.max(system.iActiveManned, manningValue + lastManningLevelIncreases[ship.iShipId] + lastSingleSystemManningLevelIncreases[ship.iShipId][systemId] + (ship.bAutomated and 1 or 0))
		--need to add any previous manning level increases, and one if it's automated
	else
		--Add manning level
		system.iActiveManned = system.iActiveManned + manningValue 
	end
	--Cap at 3
	system.iActiveManned = math.min(system.iActiveManned, 3)
	lastSingleSystemManningLevelIncreases[ship.iShipId][systemId] = lastSingleSystemManningLevelIncreases[ship.iShipId][systemId] + manningValue
end

--[[
Auto-Manning Augment Code

To use this, make an augment with AUTOMATED_MANNING set as a function.
This will only man systems, and not repair the ship or prevent being crew killed.

Function level 0 will do nothing (except count for blue options).
Function level 1 will give unskilled manning.
Function level 2 will give level 1 manning.
Function level 3+ will give level 2 manning.
Negative function values will subtract from other auto-manning augments or the auto-manning of base Auto-Ships.
However, it will not subtract piloting if it would become 0.
]]
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	local manningAugValue = ship:GetAugmentationValue("AUTOMATED_MANNING")
	
	if manningAugValue ~= 0 then
		setManningLevel(manningAugValue, ship)
	end
end)

--[[
Makes a ship automatically repair, like an Auto-Ship.
The repair speed is multiplied by speed.
If speed is negative, it won't damage systems, but will reverse repairs.

Must be run every tick with ON_TICK or SHIP_LOOP (recommended) to work!
]]
function mods.autolibrary.setAutoRepair(speed, ship)
	for system in vter(ship.vSystemList) do
		if not system.bBreached then
			system:PartialRepair(speed, true) --true means that it repairs at speed * the basic autoship repair speed, false means autoRepair * human repair speed (3 times faster than auto)
		end
	end
end

local setAutoRepair = mods.autolibrary.setAutoRepair

--[[
Makes a specified system automatically repair, like in an Auto-Ship.
The repair speed is multiplied by speed.
If speed is negative, it won't damage systems, but will reverse repairs.

Must be run every tick with ON_TICK or SHIP_LOOP (recommended) to work!
]]
function mods.autolibrary.setAutoRepairSingleSystem(speed, systemId, ship)
	local system = ship:GetSystem(systemId)
	if not system.bBreached then
		system:PartialRepair(speed, true) --true means that it repairs at speed * the basic autoship repair speed, false means autoRepair * human repair speed (3 times faster than auto)
	end
end

--[[
Auto-Repair Augment Code

To use this, make an augment with AUTOMATED_REPAIR set as a function.
This will only repair systems, and not man them or prevent being crew killed.

Function level 0 will do nothing (except count for blue options).
Function level 1 will repair at normal Auto-Ship speeds.

Any other function level will multiply the speed by the level. For example:
Function level 0.5 will repair at half normal Auto-Ship speeds.
Function level 2 will repair at double normal Auto-Ship speeds.
Function level -1 won't damage systems, but will reverse repairs.

Note: If you use this with AUTOMATED_SHIP or a standard Auto-Ship, it will add the repair speed, not replace it.
]]
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
	local repairAugValue = ship:GetAugmentationValue("AUTOMATED_REPAIR")
	if repairAugValue ~= 0 then --Prevent repair progress from being "held" when repairAugValue is less than or equal to 0
		setAutoRepair(repairAugValue, ship)
	end
end)