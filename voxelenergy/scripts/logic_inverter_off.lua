local logic_inverter = load_script("voxelenergy:scripts/base/logic_inverter.lua")

function on_placed(x, y, z)
	logic_inverter:updateLogicInverter(x, y, z)
end

function on_update(x, y, z)
	logic_inverter:updateLogicInverter(x, y, z)
end

function on_broken(x, y, z)
	logic_inverter:onBroken(x, y, z)
end