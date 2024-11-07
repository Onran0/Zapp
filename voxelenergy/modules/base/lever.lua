local voxelenergy = require "voxelenergy:api"
local commons = load_script("voxelenergy:scripts/base/interactive_source_commons.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")

local lever = { }

voxelenergy.registerPistonMoveEvent("voxelenergy:lever_on", function(oldX, oldY, oldZ, newX, newY, newZ)
	voxelenergy.setActiveWires(oldX, oldY, oldZ, false)
	voxelenergy.setActiveWires(newX, newY, newZ, true)
end)
voxelenergy.registerEnergySource("voxelenergy:lever_on", true)
voxelenergy.registerElectricElement("voxelenergy:lever_off")

function lever:onBroken(x, y, z)
	local active = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if active then voxelenergy.setActiveWires(x, y, z, false) end
end

function lever:onInteract(x, y, z)
	local newLeverIndex = nil
	local activeLeverIndex = block_index("voxelenergy:lever_on")
	local active = false

	if get_block(x, y, z) == activeLeverIndex then
		newLeverIndex = block_index("voxelenergy:lever_off")
		active = false
	else
		newLeverIndex = activeLeverIndex
		active = true
	end

	set_block(x, y, z, newLeverIndex, get_block_states(x, y, z))

	voxelenergy.setActiveWires(x, y, z, active)

	vox_metadata.setMeta(x, y, z, "isActive", active)

	return true
end

function lever:onUpdate(x, y, z)
	commons:onUpdate(x, y, z, lever)
end

return lever