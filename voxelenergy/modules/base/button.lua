local voxelenergy = require "voxelenergy:api"
local commons = require "voxelenergy:base/interactive_source_commons"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")

local button = { }

local activeTimeInTicks = 17
local ticks = load_script("voxelhelp:vox_ticked_block.lua", true)

ticks.onTick = function (x, y, z, tps)
	local disableAfter = vox_metadata.getMeta(x, y, z, "disableAfter")

	if disableAfter ~= nil then
		if disableAfter > 0 then
			vox_metadata.setMeta(x, y, z, "disableAfter", disableAfter - 1)
		else
			button:setActiveButton(x, y, z, false)
			vox_metadata.setMeta(x, y, z, "disableAfter", nil)
		end
	end
end

voxelenergy.registerEnergySource("voxelenergy:button_on", true)
voxelenergy.registerElectricElement("voxelenergy:button_off")

voxelenergy.registerPistonMoveEvent("voxelenergy:button_on", 
	function (oldX, oldY, oldZ, newX, newY, newZ, pistonState)

		if vox_metadata.getMeta(newX, newY, newZ, "isActive") then
			voxelenergy.setActiveWires(oldZ, oldY, oldZ, false)
		end

		ticks:unsubscribe(oldX, oldY, oldZ)
		ticks:subscribe(newX, newY, newZ)
	end
)

function button:onBroken(x, y, z)
	ticks:unsubscribe(x, y, z)

	local isActive = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if isActive then
		voxelenergy.setActiveWires(x, y, z, false)
	end
end

function button:onInteract(x, y, z)
	button:setActiveButton(x, y, z, true)
	vox_metadata.setMeta(x, y, z, "disableAfter", activeTimeInTicks)
	return true
end

function button:isButtonActive(x, y, z)
	return vox_metadata.getMeta(x, y, z, "isActive")
end

function button:setActiveButton(x, y, z, active)
	vox_metadata.setMeta(x, y, z, "isActive", active)

	local index

	if active then index = block_index("voxelenergy:button_on") else index = block_index("voxelenergy:button_off") end

	set_block(x, y, z, index, get_block_states(x, y, z))

	voxelenergy.setActiveWires(x, y, z, active)

	if active then
		ticks:subscribe(x, y, z)
	else
		ticks:unsubscribe(x, y, z)
	end
end

function button:tick(tps)
	if not ticks:initialized() then
		ticks:initialize("voxelenergy:button_on")
	end

	ticks:tick(tps)
end

function button:onUpdate(x, y, z)
	commons:onUpdate(x, y, z, button)
end

return button