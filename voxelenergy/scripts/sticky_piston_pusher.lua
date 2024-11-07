local piston_pusher = load_script("voxelenergy:scripts/base/piston_pusher.lua", true)
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")

piston_pusher:initialize("voxelenergy:sticky_piston_active")

function on_update(x, y, z)
	piston_pusher:update(x, y, z)
end

function on_broken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end