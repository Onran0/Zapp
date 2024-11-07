local button = load_script("voxelenergy:scripts/base/button.lua")

function on_interact(x, y, z)
	return button:onInteract(x, y, z)
end

function on_placed(x, y, z)
	button:onUpdate(x, y, z)
end

function on_update(x, y, z)
	button:onUpdate(x, y, z)
end