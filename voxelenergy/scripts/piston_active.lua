local vox_utils = load_script("voxelhelp:vox_utils.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local piston = load_script("voxelenergy:scripts/base/piston.lua")

function on_update(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isMoving") then
		return
	end
	
	if not piston:canMove(x, y, z) then
		set_block(x, y, z, block_index("voxelenergy:piston_idle"), get_block_states(x, y, z))
		vox_metadata.setMeta(x, y, z, "isActive", false)
	else
		local frontX, frontY, frontZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)

		if get_block(frontX, frontY, frontZ) ~= block_index("voxelenergy:piston_pusher") then
			set_block(x, y, z, block_index("core:air"), 0)
			vox_metadata.deleteMeta(x, y, z)
		end
	end
end

function on_broken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end