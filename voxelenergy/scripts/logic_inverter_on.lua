local voxelenergy = require "voxelenergy:api"
local vec3 = load_script("voxelhelp:vox_math.lua").vector3
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local logic_inverter = load_script("voxelenergy:scripts/base/logic_inverter.lua")

voxelenergy.registerConditionForEnergyIsNearby("voxelenergy:logic_inverter_on",
	
function (sourceX, sourceY, sourceZ, x, y, z)
	local fx, fy, fz = vox_utils.getShiftedPositionRelativeRotation(sourceX, sourceY, sourceZ, 1)

	if vec3.equals(x, y, z, fx, fy, fz) then
		return false
	end

	return not voxelenergy.isEnergyComingTo(fx, fy, fz, sourceX, sourceY, sourceZ)
end
, true)

function on_placed(x, y, z)
	logic_inverter:updateLogicInverter(x, y, z)
end

function on_update(x, y, z)
	logic_inverter:updateLogicInverter(x, y, z)
end

function on_broken(x, y, z)
	logic_inverter:onBroken(x, y, z, true)
end