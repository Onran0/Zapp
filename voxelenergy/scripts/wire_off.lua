local wire = load_script("voxelenergy:scripts/base/wire.lua")

function on_placed(x, y, z)
	wire:disabledWirePlaced(x, y, z)
end