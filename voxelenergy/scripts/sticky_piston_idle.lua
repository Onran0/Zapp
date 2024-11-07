local piston = load_script("voxelenergy:scripts/base/piston.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")

function on_placed(x, y, z)
	piston:update(x, y, z)
end

function on_update(x, y, z)
	piston:update(x, y, z)
end

function on_broken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end