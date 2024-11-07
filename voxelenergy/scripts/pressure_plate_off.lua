local plate = load_script("voxelenergy:scripts/base/pressure_plate.lua")

function on_placed(x, y, z)
	plate:onPlaced(x, y, z)
end

function on_update(x, y, z)
	plate:onUpdate(x, y, z)
end

function on_broken(x, y, z)
	plate:onBroken(x, y, z)
end