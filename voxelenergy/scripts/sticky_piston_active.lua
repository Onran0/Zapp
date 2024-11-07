local voxelenergy = require "voxelenergy:api"
local piston = load_script("voxelenergy:scripts/base/piston.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_math = load_script("voxelhelp:vox_math.lua")
local vec3 = vox_math.vector3
local vox_utils = load_script("voxelhelp:vox_utils.lua")

local sticky_piston_active = { }

function sticky_piston_active:movePlayerBack(pid, movableX, movableY, movableZ, x, y, z)
	local px, py, pz = player.get_pos(pid)

	if vec3.equals(movableX, movableY, movableZ, vec3.floor(px, py, pz)) or vec3.equals(movableX, movableY, movableZ, vec3.ceil(px, py, pz)) then
		player.set_pos(pid, vox_math.vector3.add(px, py, pz, vox_math.vector3.inverse(vox_utils.getBlockDirectionVector(x, y, z))))
	end
end

function on_update(x, y, z)

	if vox_metadata.getMeta(x, y, z, "isMoving") then
		return
	end

	local frontX, frontY, frontZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)

	if not piston:canMove(x, y, z) then
		local airId = block_index("core:air")
		local movableX, movableY, movableZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, 2)
		local movableId = get_block(movableX, movableY, movableZ)

		vox_metadata.setMeta(x, y, z, "isActive", false)

		set_block(x, y, z, block_index("voxelenergy:sticky_piston_idle"), get_block_states(x, y, z))

		if movableId ~= airId and not piston:getActiveBlocksList():contains(block_name(movableId)) then
			vox_metadata.moveMeta(movableX, movableY, movableZ, frontX, frontY, frontZ)

			set_block(frontX, frontY, frontZ, movableId, get_block_states(movableX, movableY, movableZ))

			set_block(movableX, movableY, movableZ, airId)

			local moveEvent = voxelenergy.getPistonMoveEvent(block_name(movableId))

			if moveEvent ~= nil then
				moveEvent(movableX, movableY, movableZ, frontX, frontY, frontZ, false)
			end
		else
			sticky_piston_active:movePlayerBack(PlayerID, movableX, movableY, movableZ, x, y, z)
		end
	else
		if get_block(frontX, frontY, frontZ) ~= block_index("voxelenergy:sticky_piston_pusher") then
			set_block(x, y, z, block_index("core:air"))
			vox_metadata.deleteMeta(x, y, z)
		end
	end
end

function on_broken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end

return sticky_piston_active