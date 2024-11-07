local button = load_script("voxelenergy:scripts/base/button.lua")

function on_broken(x, y, z)
	button:onBroken(x, y, z)
end

function on_blocks_tick(tps)
	button:tick(tps)
end

function on_interact()
	return true
end

function on_placed(x, y, z)
	button:onUpdate(x, y, z)
end

function on_update(x, y, z)
	button:onUpdate(x, y, z)
end