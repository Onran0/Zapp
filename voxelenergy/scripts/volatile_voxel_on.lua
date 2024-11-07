local voxelenergy = require "voxelenergy:api"
local vec3 = load_script("voxelhelp:vox_math.lua").vector3
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local volatile_voxel = load_script("voxelenergy:scripts/base/volatile_voxel.lua")

voxelenergy.registerPistonMoveEvent("voxelenergy:volatile_voxel_on", 
	function (oldX, oldY, oldZ, newX, newY, newZ, pistonState)
		volatile_voxel:pistonMoveEvent(oldX, oldY, oldZ, newX, newY, newZ, pistonState)
	end
)

voxelenergy.registerConditionForEnergyIsNearby("voxelenergy:volatile_voxel_on",
	
function (sourceX, sourceY, sourceZ, x, y, z)
	local fx, fy, fz = vox_utils.getShiftedPositionRelativeRotation(sourceX, sourceY, sourceZ, 1)

	if not voxelenergy.isEnergyComingTo(fx, fy, fz, sourceX, sourceY, sourceZ) then
		return false
	end

	return not vec3.equals(fx, fy, fz, x, y, z)
end
, true)

function on_placed(x, y, z)
	volatile_voxel:update(x, y, z)
end

function on_update(x, y, z)
	volatile_voxel:update(x, y, z)
end

function on_broken(x, y, z)
	volatile_voxel:onBroken(x, y, z)
end