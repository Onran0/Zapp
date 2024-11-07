local lever = load_script("voxelenergy:scripts/base/lever.lua")

function on_interact(x, y, z)
	return lever:onInteract(x, y, z)
end

function on_broken(x, y, z)
	lever:onBroken(x, y, z)
end

function on_placed(x, y, z)
	lever:onUpdate(x, y, z)
end

function on_update(x, y, z)
	lever:onUpdate(x, y, z)
end