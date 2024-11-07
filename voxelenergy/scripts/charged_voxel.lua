local voxelenergy = require "voxelenergy:api"

voxelenergy.registerEnergySource("voxelenergy:charged_voxel", true)

voxelenergy.registerPistonMoveEvent("voxelenergy:charged_voxel",
	function (oldX, oldY, oldZ, newX, newY, newZ, pistonState)
		if pistonState then
			voxelenergy.setActiveWires(newX, newY, newZ, true)
		else
			voxelenergy.setActiveWires(oldX, oldY, oldZ, false)
		end
	end
)

function on_placed(x, y, z)
	voxelenergy.setActiveWires(x, y, z, true)
end

function on_broken(x, y, z)
	voxelenergy.setActiveWires(x, y, z, false)
end