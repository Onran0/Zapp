local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")

local volatile_voxel = { internal = { } }

voxelenergy.registerEnergyPoint("voxelenergy:volatile_voxel_on")
voxelenergy.registerElectricElement("voxelenergy:volatile_voxel_off")

function volatile_voxel:onBroken(x, y, z)
	local active = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if active then voxelenergy.setActiveWires(x, y, z, false) end
end

function volatile_voxel:pistonMoveEvent(oldX, oldY, oldZ, newX, newY, newZ, pistonState)
	if pistonState then
		volatile_voxel:update(newX, newY, newZ)
	else
		voxelenergy.setActiveWires(oldX, oldY, oldZ, false)
	end
end

function volatile_voxel:update(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isUpdating") then
		return
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", true)

	local inputX, inputY, inputZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)

	local outputs = volatile_voxel:getOutputs(x, y, z, inputX, inputY, inputZ)

	local volatileVoxelState = voxelenergy.isActiveEnergyPoint(inputX, inputY, inputZ)

	if volatile_voxel:getVolatileVoxelState(x, y, z) == volatileVoxelState then
		vox_metadata.setMeta(x, y, z, "isUpdating", false)
		return
	end

	volatile_voxel:setVolatileVoxelState(x, y, z, volatileVoxelState)

	for i = 0, outputs:iterations() do
		local output = outputs:get(i)

		if voxelenergy.isWire(output.x, output.y, output.z) then
			voxelenergy.setActiveWiresInNeighbours(output.x, output.y, output.z, volatileVoxelState)
		end
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", false)
end

function volatile_voxel:getVolatileVoxelState(x, y, z)
	return get_block(x, y, z) == block_index("voxelenergy:volatile_voxel_on")
end

function volatile_voxel:setVolatileVoxelState(x, y, z, active)
	local index

	if active then index = block_index("voxelenergy:volatile_voxel_on") else index = block_index("voxelenergy:volatile_voxel_off") end

	set_block(x, y, z, index, get_block_states(x, y, z))

	vox_metadata.setMeta(x, y, z, "isActive", active)
end

function volatile_voxel:getOutputs(x, y, z, inputX, inputY, inputZ)
	local outputs = vox_list:new()

	for i = -1, 1, 2 do
		volatile_voxel.internal:addOutput(x + i, y, z, inputX, inputY, inputZ, outputs)
		volatile_voxel.internal:addOutput(x, y + i, z, inputX, inputY, inputZ, outputs)
		volatile_voxel.internal:addOutput(x, y, z + i, inputX, inputY, inputZ, outputs)
	end

	return outputs
end

function volatile_voxel.internal:addOutput(x, y, z, inputX, inputY, inputZ, outputs)

	if x ~= inputX or y ~= inputY or z ~= inputZ then
		outputs:add({ x = x, y = y, z = z })
	end
end

return volatile_voxel