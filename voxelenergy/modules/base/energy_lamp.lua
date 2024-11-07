local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")

local energy_lamp = { }
local enabledLampName = "voxelenergy:energy_lamp_on"
local disabledLampName = "voxelenergy:energy_lamp_off"

voxelenergy.registerElectricElement(enabledLampName)
voxelenergy.registerElectricElement(disabledLampName)

function energy_lamp:updateLamp(x, y, z)
	local lampState = energy_lamp:isLampActive(x, y, z)
	local hasEnergy = voxelenergy.energyIsNearby(x, y, z)

	if hasEnergy ~= lampState then
		energy_lamp:setLampActive(x, y, z, hasEnergy)
	end
end

function energy_lamp:isLampActive(x, y, z)
	return get_block(x, y, z) == block_index(enabledLampName)
end

function energy_lamp:setLampActive(x, y, z, active)
	local index = nil
	if active then index = block_index("voxelenergy:energy_lamp_on") else index = block_index("voxelenergy:energy_lamp_off") end
	set_block(x, y, z, index, get_block_states(x, y, z))

	vox_metadata.setMeta(x, y, z, "isActive", active)
end

function energy_lamp:onBroken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end

return energy_lamp