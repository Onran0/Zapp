local vox_utils = load_script("voxelhelp:vox_utils.lua")

local piston_pusher = { }
local pistonBlockName = nil

function piston_pusher:update(x, y, z)

	if get_block(vox_utils.getShiftedPositionRelativeRotation(x, y, z, -1)) ~= block_index(pistonBlockName) then
		set_block(x, y, z, 0)
	end
end

function piston_pusher:initialize(_pistonBlockName)
	pistonBlockName = _pistonBlockName
end

return piston_pusher