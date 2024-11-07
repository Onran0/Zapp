local wire = load_script("voxelenergy:scripts/base/wire.lua")

function on_broken(x, y, z)
	wire:activeWireBroken(x, y, z)
end