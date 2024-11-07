local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")

local logic_inverter = { internal = { } }

voxelenergy.registerElectricElement("voxelenergy:logic_inverter_on")
voxelenergy.registerElectricElement("voxelenergy:logic_inverter_off")

function logic_inverter:updateLogicInverter(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isUpdating") then
		return
	end
	vox_metadata.setMeta(x, y, z, "isUpdating", true)

	local inX, inY, inZ = logic_inverter.getInput(x, y, z)

	local outputs = logic_inverter.getOutputs(x, y, z)

	local inverterState = true

	if voxelenergy.isEnergyComingTo(inX, inY, inZ, x, y, z) then
		inverterState = false
	end

	if logic_inverter:getLogicInverterState(x, y, z) == inverterState then
		vox_metadata.setMeta(x, y, z, "isUpdating", false)
		return
	end

	logic_inverter:setLogicInverterState(x, y, z, inverterState)

	for i = 0, outputs:iterations() do
		local block = outputs:get(i)
		local blockX, blockY, blockZ = block[1], block[2], block[3]

		if voxelenergy.isWire(blockX, blockY, blockZ) and voxelenergy.isActiveEnergyPoint(blockX, blockY, blockZ) ~= inverterState then
			voxelenergy.setActiveWiresInNeighbours(blockX, blockY, blockZ, inverterState, false)
		end
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", false)
end

function logic_inverter:getLogicInverterState(x, y, z)
	local blockName = block_name(get_block(x, y, z))

	if blockName == "voxelenergy:logic_inverter_on" then
		return true
	elseif blockName == "voxelenergy:logic_inverter_off" then
		return false
	else
		print("Unknown invertor state: "..blockName)
		return false
	end
end

function logic_inverter:setLogicInverterState(x, y, z, active)
	local index

	if active then index = block_index("voxelenergy:logic_inverter_on") else index = block_index("voxelenergy:logic_inverter_off") end

	set_block(x, y, z, index, get_block_states(x, y, z))

	vox_metadata.setMeta(x, y, z, "isActive", active)
end

function logic_inverter:onBroken(x, y, z, isActiveInverter)
	if isActiveInverter then voxelenergy.setActiveWires(x, y, z, false) end

	vox_metadata.deleteMeta(x, y, z)
end

function logic_inverter.getInput(x, y, z)
	return vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)
end

function logic_inverter.getOutputs(x, y, z)
	local inX, inY, inZ = logic_inverter.getInput(x, y, z)

	local outputs = vox_list:new()

	for i = -1, 1, 2 do
		logic_inverter.internal:addOutput(x + i, y, z, inX, inY, inZ, outputs)
		logic_inverter.internal:addOutput(x, y + i, z, inX, inY, inZ, outputs)
		logic_inverter.internal:addOutput(x, y, z + i, inX, inY, inZ, outputs)
	end

	return outputs
end

function logic_inverter.internal:addOutput(x, y, z, inX, inY, inZ, outputs)

	if x ~= inX or y ~= inY or z ~= inZ then

		outputs:add({ x, y, z })
	end

end

return logic_inverter