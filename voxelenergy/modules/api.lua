local arrays = require "voxelhelp:arrays"
local blocks = require "voxelhelp:blocks"
local math_helper = require "voxelhelp:math/math_helper"
local list = require "voxelhelp:list"
local vec3 = vox_math.vector3

local voxelenergy = { internal = { } }

local energyIsNearbyList = list()
local activeEnergySourcesList = list()
local activeEnergyPointsList = list()
local directionWireList = arrays.to_list({ "voxelenergy:direction_wire_on", "voxelenergy:direction_wire_off" })
local wireList = arrays.to_list({ "voxelenergy:wire_on", "voxelenergy:wire_off" })
local activeButtonIsNearbyList = list()
local electricElementsList = list()
local pistonMoveEvents = list()
local energyIsNearbyConditions = list()
local addons = list()
local maybeEnergyList = list()

energyIsNearbyList:add("voxelenergy:wire_on")

activeEnergyPointsList:add("voxelenergy:wire_on")
activeEnergyPointsList:add("voxelenergy:direction_wire_on")

maybeEnergyList:add("voxelenergy:direction_wire_on")
maybeEnergyList:add("voxelenergy:wire_on")

electricElementsList:addList(wireList)
electricElementsList:addList(directionWireList)

local wire

local function checkWireScript()
	if not wire then
		wire = require "voxelenergy:base/wire"
	end
end

-- API Voxel Energy

function voxelenergy.is_wire(x, y, z)
	return wireList:contains(block_name(get_block(x, y, z)))
end

function voxelenergy.is_direction_wire(x, y, z)
	return directionWireList:contains(block_name(get_block(x, y, z)))
end

function voxelenergy.is_active_energy_point(x, y, z)
	return voxelenergy.is_active_energy_point_by_name(block_name(get_block(x, y, z)))
end

function voxelenergy.is_active_energy_source(x, y, z)
	return voxelenergy.is_active_energy_source_by_name(block_name(get_block(x, y, z)))
end

function voxelenergy.is_active_energy_point_by_name(name)
	return activeEnergyPointsList:contains(name)
end

function voxelenergy.is_active_energy_source_by_name(name)
	return activeEnergySourcesList:contains(name)
end

function voxelenergy.maybe_energy(x, y, z)
	return voxelenergy.maybeEnergyByName(block_name(get_block(x, y, z)))
end

function voxelenergy.maybe_energy_by_name(name)
	return maybeEnergyList:contains(name)
end

function voxelenergy.get_maybe_energy_list()
	return maybeEnergyList
end

function voxelenergy.is_front_relative_source(bx, by, bz, x, y, z)
	local fx, fy, fz = vox_utils.getShiftedPositionRelativeRotation(bx, by, bz, 1)
	if fx == x and fy == y and fz == z then
		return true
	end
	return false
end

function voxelenergy.is_energy_coming_to(fromX, fromY, fromZ, toX, toY, toZ, onlySourcesCheck)
	local isEnergyComing
	local func

	if onlySourcesCheck then
		func = voxelenergy.is_active_energy_source
	else
		func = voxelenergy.is_active_energy_point
	end

	isEnergyComing = func(fromX, fromY, fromZ)

	if not isEnergyComing then
		energyIsNearbyConditions:foreach(
		function (element)
			if onlySourcesCheck and not element.isSourceCondition then
				return
			end

			if get_block(fromX, fromY, fromZ) == block_index(element.blockName) then
				if element.func(fromX, fromY, fromZ, toX, toY, toZ) then
					isEnergyComing = true
					return true
				end
			end
		end
		)
	end

	return isEnergyComing
end

function voxelenergy.energy_is_nearby(x, y, z)
	local isEnergyNearby = blocks.is_any_block_nearby_by_names(x, y, z, energyIsNearbyList)

	if not isEnergyNearby then
		energyIsNearbyConditions:foreach(
		function (element)
			local blockId = block.index(element.blockName)
			local nearbyBlocks = blocks.neighbors(x, y, z)

			if nearbyBlocks:size() > 0 then
				for j = 0, nearbyBlocks:iterations() do
					local vec = nearbyBlocks:get(j)

					if block.get(vec.x, vec.y, vec.z) == blockId and element.func(vec.x, vec.y, vec.z, x, y, z) then
						isEnergyNearby = true
						return true
					end
				end
			end
		end
		)
	end

	return isEnergyNearby
end

function voxelenergy.get_active_energy_points(x, y, z)
	local list = blocks.neighbors(x, y, z)

	for i = 0, list:iterations() do
		local vec = list:get(i)

		
	end

	return vox_utils.getPositionsOfNearbyBlocks(x, y, z, activeEnergyPointsList)
end

function voxelenergy.isElectricElement(x, y, z)
 	return electricElementsList.contains(block_name(get_block(x, y, z)))
end

-- start Find closest energy source functions

function voxelenergy.findNearbyEnergySource(x, y, z)
	return voxelenergy.internal.findNearbyEnergySource(x, y, z, x, y, z, { })
end

function voxelenergy.internal.findNearbyEnergySource(x, y, z, startX, startY, startZ, checkedMeta)
	local fx, fy, fz = -1, -1, -1

	for i = -1, 1, 2 do
		fx, fy, fz = voxelenergy.internal.findNearbyEnergySource_nextChain(x + i, y, z, startX, startY, startZ, checkedMeta)

		if fy ~= -1 then
			return fx, fy, fz
		end

		
		fx, fy, fz = voxelenergy.internal.findNearbyEnergySource_nextChain(x, y + i, z, startX, startY, startZ, checkedMeta)
		
		if fy ~= -1 then
			return fx, fy, fz
		end

		fx, fy, fz = voxelenergy.internal.findNearbyEnergySource_nextChain(x, y, z + i, startX, startY, startZ, checkedMeta)
		
		if fy ~= -1 then
			return fx, fy, fz
		end
	end

	return -1, -1, -1
end

function voxelenergy.internal.findNearbyEnergySource_nextChain(x, y, z, startX, startY, startZ, checkedMeta)
	voxelenergy.internal.checkWireScript()

	local key = x..y..z
	if checkedMeta[key] then
		return -1, -1, -1
	else
		checkedMeta[key] = true
	end

	local sx, sy, sz = voxelenergy.internal.findNearbyEnergySource_checkBlock(block_name(get_block(x, y, z)), x, y, z, startX, startY, startZ)

	if sy ~= -1 then
		return sx, sy, sz
	end

	if voxelenergy.isWire(x, y, z) and wire:getWireState(x, y, z) then
		local nearbyBlocks = vox_utils.getNearbyBlocks(x, y, z)
		if nearbyBlocks:size() > 0 then
			for i = 0, nearbyBlocks:iterations() do
				local nearbyBlock = nearbyBlocks:get(i)

				sx, sy, sz = voxelenergy.internal.findNearbyEnergySource_checkBlock(nearbyBlock.name, nearbyBlock.x, nearbyBlock.y, nearbyBlock.z, x, y, z)

				if sy ~= -1 then
					return sx, sy, sz
				end
			end
		end
		return voxelenergy.internal.findNearbyEnergySource(x, y, z, startX, startY, startZ, checkedMeta)
	end

	return -1, -1, -1
end

function voxelenergy.internal.findNearbyEnergySource_checkBlock(sName, sx, sy, sz, x, y, z)
	if vec3.distance(sx, sy, sz, x, y, z) <= 1.0 and voxelenergy.isEnergyComingTo(sx, sy, sz, x, y, z, true) then
		return sx, sy, sz
	else
		return -1, -1, -1
	end
end

-- end

function voxelenergy.setActiveWires(x, y, z, active, forcibly, isBrokedWire)
	if not isBrokedWire and not voxelenergy.isWire(x, y, z) then
		for i = -1, 1, 2 do
			if voxelenergy.isWire(x + i, y, z) then voxelenergy.setActiveWiresInNeighbours(x + i, y, z, active, forcibly) end
			if voxelenergy.isWire(x, y + i, z) then voxelenergy.setActiveWiresInNeighbours(x, y + i, z, active, forcibly) end
			if voxelenergy.isWire(x, y, z + i) then voxelenergy.setActiveWiresInNeighbours(x, y, z + i, active, forcibly) end
		end

		return true
	else
		return voxelenergy.setActiveWiresInNeighbours(x, y, z, active, forcibly)
	end
end

function voxelenergy.setActiveWiresInNeighbours(x, y, z, active, forcibly)
	local target = nil
	local replacement = nil

	if active then
		target = false
		replacement = true
	else
		target = true
		replacement = false
	end

	return voxelenergy.internal.setActiveWires7arg(x, y, z, active, forcibly, target, replacement)
end

function voxelenergy.internal.setActiveWires7arg(x, y, z, active, forcibly, target, replacement)
	voxelenergy.internal.checkWireScript()

	if not active and not forcibly then
		local blockData = { blockStates = get_block_states(x, y, z) , blockId = get_block(x, y, z) }
		set_block(x, y, z, block_index("core:air"), 0, true)
		local sx, sy, sz = voxelenergy.findNearbyEnergySource(x, y, z)
		set_block(x, y, z, blockData.blockId, blockData.blockStates, true)
		if sy ~= -1 then
			return false
		end
	end

	vox_utils.replaceBlocksAlongChainByFunctions(x, y, z, 
	function(x, y, z)
		return voxelenergy.isWire(x, y, z) and wire:getWireState(x, y, z) == target
	end

	,

	function(x, y, z)
		wire:setWireState(x, y, z, replacement)
	end
	)

	if voxelenergy.isWire(x, y, z) and wire:getWireState(x, y, z) == target then
		wire:setWireState(x, y, z, replacement)
	end

	return true
end

function voxelenergy.internal.findBlockEventFunctionInList(blockName, list)
	local eventFunction = nil

	list:foreach(
	function (element)
		if element.blockName == blockName then
			eventFunction = element.func
			return true
		end
	end
	)

	return eventFunction
end

function voxelenergy.registerPistonMoveEvent(blockName, func)
	if blockName == nil or func == nil then
		return false
	elseif voxelenergy.getPistonMoveEvent(blockName) ~= nil then
		voxelenergy.internal.printf("Piston move event for block \"%s\" already registered.", blockName)
		return false
	end

	pistonMoveEvents:add({ blockName = blockName, func = func })

	voxelenergy.internal.printf("Successfully registered piston move event for block \"%s\"", blockName)
	return true
end

function voxelenergy.getPistonMoveEvent(blockName)
	return voxelenergy.internal.findBlockEventFunctionInList(blockName, pistonMoveEvents)
end

function voxelenergy.registerConditionForEnergyIsNearby(blockName, conditionFunc, isSourceCondition)
	if blockName == nil or conditionFunc == nil or voxelenergy.getConditionForEnergyIsNearby(blockName) ~= nil then
		return false
	end

	energyIsNearbyConditions:add({ blockName = blockName, func = conditionFunc, isSourceCondition = isSourceCondition })
	maybeEnergyList:add(blockName)

	voxelenergy.internal.printf("Successfully registered condition for \"voxelenergy.energyIsNearby\" for block \"%s\"", blockName)

	return true
end

function voxelenergy.getConditionForEnergyIsNearby(blockName)
	return voxelenergy.internal.findBlockEventFunctionInList(blockName, energyIsNearbyConditions)
end

function voxelenergy.registerElectricElement(blockName)
	if blockName == nil or electricElementsList:contains(blockName) then
		return false
	end

	electricElementsList:add(blockName)

	return true
end

function voxelenergy.registerEnergySource(blockName, withoutConditions)
	if blockName == nil or activeEnergySourcesList:contains(blockName) then
		return false
	end

	if withoutConditions then
		energyIsNearbyList:add(blockName)
	end

	activeEnergySourcesList:add(blockName)
	voxelenergy.registerEnergyPoint(blockName)

	return true
end

function voxelenergy.registerEnergyPoint(blockName)
	if blockName == nil or activeEnergyPointsList:contains(blockName) then
		return false
	end

	activeEnergyPointsList:add(blockName)
	maybeEnergyList:add(blockName)
	voxelenergy.registerElectricElement(blockName)

	return true
end

function voxelenergy.registerAddon(addonName)
	if voxelenergy.isAddonExist(addonName) then
		return false
	end

	addons:add(addonName)

	voxelenergy.internal.print("Successfully registered addon \""..addonName.."\"")

	return true
end

function voxelenergy.isAddonExist(addonName)
	return addons:contains(addonName)
end

function voxelenergy.getAddonsList()
	return addons
end

function voxelenergy.internal.printf(msg, ...)
	voxelenergy.internal.print(msg:format(...))
end

function voxelenergy.internal.print(msg)
	print("Voxel Energy: " .. msg)
end

return voxelenergy