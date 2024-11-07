local energy_lamp = load_script("voxelenergy:scripts/base/energy_lamp.lua")

function on_placed(x, y, z)
	energy_lamp:updateLamp(x, y, z)
end

function on_update(x, y, z)
	energy_lamp:updateLamp(x, y, z)
end

function on_broken(x, y, z)
	energy_lamp:onBroken(x, y, z)
end