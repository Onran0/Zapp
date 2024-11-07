local voxelenergy = require "voxelenergy:api"
local timers = load_script("voxelenergy:scripts/base/timers.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")

local ticks = load_script("voxelhelp:vox_ticked_block.lua", true)
local timer_base = { internal = { }, onPistonMove = nil, energyIsNearbyCondition = nil }
local defaultWaitTicks = 0

ticks.onTick = function (x, y, z, tps)
	if vox_metadata.getMeta(x, y, z, "isWaiting") then
		vox_metadata.setMeta(x, y, z, "waitingTime", vox_metadata.getMeta(x, y, z, "waitingTime") - 1)

		if vox_metadata.getMeta(x, y, z, "waitingTime") == 0 then
			vox_metadata.setMeta(x, y, z, "isWaiting", false)
			vox_metadata.setMeta(x, y, z, "waitingTime", -1)

			local newState = vox_metadata.getMeta(x, y, z, "statusAfterExpiration")

			vox_metadata.setMeta(x, y, z, "isActive", newState)

			timer_base.getOutputs(x, y, z):foreach(
			function (element)
				local x, y, z = element[1], element[2], element[3]

				if voxelenergy.isWire(x, y, z) then
					voxelenergy.setActiveWiresInNeighbours(x, y, z, newState)
				end
			end
			)

			set_block(x, y, z, get_block(x, y, z), get_block_states(x, y, z))
		end
	end
end

timer_base.onPistonMove = function (oldX, oldY, oldZ, newX, newY, newZ, pistonState)

	if vox_metadata.getMeta(newX, newY, newZ, "isActive") then
		voxelenergy.setActiveWires(oldZ, oldY, oldZ, false)
	end

	ticks:unsubscribe(oldX, oldY, oldZ)
	ticks:subscribe(newX, newY, newZ)
end

timer_base.energyIsNearbyCondition = function (sourceX, sourceY, sourceZ, x, y, z)
	return vox_metadata.getMeta(sourceX, sourceY, sourceZ, "isActive") and not voxelenergy.isFrontRelativeSource(sourceX, sourceY, sourceZ, x, y, z)
end

function timer_base:setDefaultWaitTicks(_defaultWaitTicks)
	defaultWaitTicks = _defaultWaitTicks
end

function timer_base:onUpdate(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isUpdating") then
		return
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", true)

	local inX, inY, inZ = timer_base.getInput(x, y, z)

	local newTimerState = voxelenergy.isEnergyComingTo(inX, inY, inZ, x, y, z)

	if newTimerState ~= vox_metadata.getMeta(x, y, z, "isActive") then
		if not vox_metadata.getMeta(x, y, z, "isWaiting") then
			vox_metadata.setMeta(x, y, z, "isWaiting", true)
			vox_metadata.setMeta(x, y, z, "waitingTime", defaultWaitTicks)
		end

		vox_metadata.setMeta(x, y, z, "statusAfterExpiration", newTimerState)
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", false)
end

function timer_base.getInput(x, y, z)
	return vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)
end

function timer_base.getOutputs(x, y, z)
	local inX, inY, inZ = timer_base.getInput(x, y, z)
	
	local outputs = vox_list:new()

	for i = -1, 1, 2 do
		timer_base.internal.addOutput(x + i, y, z, inX, inY, inZ, outputs)
		timer_base.internal.addOutput(x, y + i, z, inX, inY, inZ, outputs)
		timer_base.internal.addOutput(x, y, z + i, inX, inY, inZ, outputs)
	end

	return outputs
end


function timer_base.internal.addOutput(x, y, z, inX, inY, inZ, outputs)
	if x ~= inX or y ~= inY or z ~= inZ then
		outputs:add({ x, y, z })
	end
end

function timer_base:onPlaced(x, y, z)
	ticks:subscribe(x, y, z)
end

function timer_base:onBroken(x, y, z)
	ticks:unsubscribe(x, y, z)

	local isActive = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if isActive then
		voxelenergy.setActiveWires(x, y, z, false)
	end
end

function timer_base:onInteract(x, y, z)
	local nextIndex

	timers.list:foreach(
	function(element, index)
		if element[1] == block_name(get_block(x, y, z)) then
			nextIndex = index + 1
			return true
		end
	end
	)

	if nextIndex >= timers.list:size() then
		nextIndex = 0
	end

	timer_base:onBroken(x, y, z)
	local newTimerData = timers.list:get(nextIndex)
	set_block(x, y, z, block_index(newTimerData[1]), get_block_states(x, y, z))
	newTimerData[2]:onPlaced(x, y, z)

	return true
end

function timer_base:tick(tps)
	if ticks:initialized() then
		ticks:tick(tps)
	end
end

function timer_base:initialize(blockName)
	if ticks:initialized() then
		return
	end

	ticks:initialize(blockName)

	voxelenergy.registerElectricElement(blockName)

	voxelenergy.registerPistonMoveEvent(blockName, 
		timer_base.onPistonMove
	)

	voxelenergy.registerConditionForEnergyIsNearby(blockName,
		timer_base.energyIsNearbyCondition
	, true)
end

return timer_base