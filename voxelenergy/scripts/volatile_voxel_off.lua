local voxelenergy = require "voxelenergy:api"
local volatile_voxel = load_script("voxelenergy:scripts/base/volatile_voxel.lua")

voxelenergy.registerPistonMoveEvent("voxelenergy:volatile_voxel_off", 
	function (oldX, oldY, oldZ, newX, newY, newZ, pistonState)
		volatile_voxel:pistonMoveEvent(oldX, oldY, oldZ, newX, newY, newZ, pistonState)
	end
)

function on_placed(x, y, z)
	volatile_voxel:update(x, y, z)
end

function on_update(x, y, z)
	volatile_voxel:update(x, y, z)
end

function on_broken(x, y, z)
	volatile_voxel:onBroken(x, y, z)
end