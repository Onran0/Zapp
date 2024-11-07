local timer = load_script("voxelenergy:scripts/base/timer.lua", true)
local timers = load_script("voxelenergy:scripts/base/timers.lua")

local selfId = "voxelenergy:timer_1t"

timers.addInstance(selfId, timer)
timer:initialize(selfId)
timer:setDefaultWaitTicks(1)

function on_placed(x, y, z)
	timer:onPlaced(x, y, z)
end

function on_broken(x, y, z)
	timer:onBroken(x, y, z)
end

function on_interact(x, y, z)
	return timer:onInteract(x, y, z)
end

function on_update(x, y, z)
	timer:onUpdate(x, y, z)
end

function on_blocks_tick(tps)
	timer:tick(tps)
end