local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")

local direction_wire = { }

function direction_wire:updateWire(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isUpdating") then
		return
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", true)

	local inX, inY, inZ = direction_wire:getInput(x, y, z)
	local outX, outY, outZ = direction_wire:getOutput(x, y, z)

	local hasEnergy = false

	local blockName = block_name(get_block(inX, inY, inZ))

	if voxelenergy.isDirectionWire(inX, inY, inZ) then
		local in_outX, in_outY, in_outZ = direction_wire:getOutput(inX, inY, inZ)

		if in_outX == x and in_outY == y and in_outZ == z then
			hasEnergy = direction_wire:getWireState(inX, inY, inZ)
		end
	else
		hasEnergy = voxelenergy.isEnergyComingTo(inX, inY, inZ, x, y, z)
	end 

	if hasEnergy == direction_wire:getWireState(x, y, z) then
		vox_metadata.setMeta(x, y, z, "isUpdating", false)
		return
	end

	direction_wire:setWireState(x, y, z, hasEnergy)

	if voxelenergy.isWire(outX, outY, outZ) and voxelenergy.isActiveEnergyPoint(outX, outY, outZ) ~= hasEnergy then
		voxelenergy.setActiveWires(outX, outY, outZ, hasEnergy)
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", false)
end

function direction_wire:onWireBroken(x, y, z)
	local active = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if active then voxelenergy.setActiveWires(x, y, z, false) end
end

function direction_wire:setWireState(x, y, z, active)
	local index = nil
	if active then index = block_index("voxelenergy:direction_wire_on") else index = block_index("voxelenergy:direction_wire_off") end
	set_block(x, y, z, index, get_block_states(x, y, z))

	vox_metadata.setMeta(x, y, z, "isActive", active)
end

function direction_wire:getWireState(x, y, z)
	return block_name(get_block(x, y, z)) == "voxelenergy:direction_wire_on"
end

function direction_wire:getInput(x, y, z)
	return vox_utils.getShiftedPositionRelativeRotation(x, y, z, -1)
end

function direction_wire:getOutput(x, y, z)
	return vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)
end

return direction_wire