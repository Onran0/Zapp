local voxelenergy = require "voxelenergy:api"
local vox_list = load_script("voxelhelp:vox_list.lua")

local wire = { internal = { } }

local pistonMoveEvent = function(oldX, oldY, oldZ, newX, newY, newZ)
	local active = wire:getWireState(newX, newY, newZ)
	local sx, sy, sz = voxelenergy.findNearbyEnergySource(newX, newY, newZ)

	if sy == -1 and active then
		wire:setWireState(newX, newY, newZ, false)
	elseif sy ~= -1 and not active then
		wire:setWireState(newX, newY, newZ, true)
	end
	
	local newState = wire:getWireState(newX, newY, newZ)

	if newState ~= active then 
		voxelenergy.setActiveWires(oldX, oldY, oldZ, newState)
	end
end

voxelenergy.registerPistonMoveEvent("voxelenergy:wire_on", pistonMoveEvent)
voxelenergy.registerPistonMoveEvent("voxelenergy:wire_off", pistonMoveEvent)

function wire:disabledWirePlaced(x, y, z)
	if voxelenergy.energyIsNearby(x, y, z) then
		voxelenergy.setActiveWires(x, y, z, true)
	end
end

function wire:activeWireBroken(x, y, z)
	local points = wire.internal:getWirePoints(x, y, z)

	if points:size() > 0 then
		for i = 0, points:iterations() do
			local point = points:get(i)
			if not point.hasEnergy then
				voxelenergy.setActiveWiresInNeighbours(point.x, point.y, point.z, false)
			end
		end
	end
end

function wire.internal:getWirePoints(x, y, z)
	local points = vox_list:new()

	for i = -1, 1, 2 do
		wire.internal:addPositionToNearbySources(x + i, y, z, points)
		wire.internal:addPositionToNearbySources(x, y + i, z, points)
		wire.internal:addPositionToNearbySources(x, y, z + i, points)
	end

	return points
end

function wire.internal:addPositionToNearbySources(x, y, z, points)
	if not voxelenergy.isWire(x, y, z) then
		return
	end

	local sx, sy, sz = voxelenergy.findNearbyEnergySource(x, y, z)

	local hasEnergy = sy ~= -1

	points:add({ x = x, y = y, z = z, hasEnergy = hasEnergy })
end

function wire:getWireState(x, y, z)
	return get_block(x, y, z) == block_index("voxelenergy:wire_on")
end

function wire:setWireState(x, y, z, state)
	local wireIndex = nil
	if state then wireIndex = block_index("voxelenergy:wire_on") else wireIndex = block_index("voxelenergy:wire_off") end
	set_block(x, y, z, wireIndex, get_block_states(x, y, z))
end

return wire