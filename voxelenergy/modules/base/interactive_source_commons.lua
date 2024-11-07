local commons = { }
local vox_utils = load_script("voxelhelp:vox_utils.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")

local notAllowedGroundBlocks = vox_list:new()
notAllowedGroundBlocks:add("core:air")
notAllowedGroundBlocks:add("voxelenergy:button_on")
notAllowedGroundBlocks:add("voxelenergy:button_off")
notAllowedGroundBlocks:add("voxelenergy:lever_on")
notAllowedGroundBlocks:add("voxelenergy:lever_off")
notAllowedGroundBlocks:add("voxelenergy:pressure_plate_on")
notAllowedGroundBlocks:add("voxelenergy:pressure_plate_off")

function commons:onUpdate(x, y, z, metatable)
	local airId = block_index("core:air")
	if notAllowedGroundBlocks:contains(block_name(get_block(vox_utils.getShiftedPositionRelativeRotation(x, y, z, -1)))) then
		set_block(x, y, z, airId)
		metatable:onBroken(x, y, z)
	end
end

return commons