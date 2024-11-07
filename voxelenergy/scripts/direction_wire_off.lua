local direction_wire = load_script("voxelenergy:scripts/base/direction_wire.lua")

function on_placed(x, y, z)
	direction_wire:updateWire(x, y, z)
end

function on_update(x, y, z)
	direction_wire:updateWire(x, y, z)
end

function on_broken(x, y, z)
	direction_wire:onWireBroken(x, y, z)
end