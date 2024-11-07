local vox_list = load_script("voxelhelp:vox_list.lua")

local timers = { list = vox_list:new() }

timers.list:add({ "voxelenergy:timer_1t" })
timers.list:add({ "voxelenergy:timer_5t" })
timers.list:add({ "voxelenergy:timer_10t" })
timers.list:add({ "voxelenergy:timer_20t" })

function timers.addInstance(id, instance)
	timers.list:foreach(
	function(element)
		if element[1] == id then
			element[2] = instance
		end
	end
	)
end

return timers