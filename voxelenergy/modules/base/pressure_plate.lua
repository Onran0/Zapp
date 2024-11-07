local voxelenergy = require "voxelenergy:api"
local commons = load_script("voxelenergy:scripts/base/interactive_source_commons.lua")
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")

local plate = { }

local ticks = load_script("voxelhelp:vox_ticked_block.lua", true)

ticks:initialize("voxelenergy:pressure_plate")

ticks.onTick = function (x, y, z, tps)
	local px, py, pz = player.get_pos(1)
	px = math.floor(px)
	py = math.floor(py)
	pz = math.floor(pz)
	local xeq = false
	local zeq = false
	local yeq = false
	local dirX, dirY, dirZ = vox_utils.getBlockDirectionVector(x, y, z)

	xeq = px == x
	zeq = pz == z

	if dirY == 1 or dirY == -1 then
		if dirY == 1 then
			yeq = py == y
		else
			yeq = py == y - 1
		end
	else
		yeq = py == y

		if not yeq then
			yeq = py == y - 1
		end
	end

	local active = plate:isPlateActive(x, y, z)
	if xeq and yeq and zeq then
		if not active then plate:setActivePlate(x, y, z, true) end
	elseif active then
		plate:setActivePlate(x, y, z, false)
	end
end

voxelenergy.registerEnergySource("voxelenergy:pressure_plate_on", true)
voxelenergy.registerElectricElement("voxelenergy:pressure_plate_off")

local pistonMoveEvent = function(oldX, oldY, oldZ, newX, newY, newZ)
	ticks:unsubscribe(oldX, oldY, oldZ)
	ticks:subscribe(newX, newY, newZ)

	if plate:isPlateActive(newX, newY, newZ) then
		voxelenergy.setActiveWires(oldX, oldY, oldZ, false)
	end
end

voxelenergy.registerPistonMoveEvent("voxelenergy:pressure_plate_on", pistonMoveEvent)
voxelenergy.registerPistonMoveEvent("voxelenergy:pressure_plate_off", pistonMoveEvent)

function plate:onPlaced(x, y, z)
	plate:onUpdate(x, y, z)

	if get_block(x, y, z) == block_index("core:air") then
		return
	end

	ticks:subscribe(x, y, z)
end

function plate:onBroken(x, y, z)
	ticks:unsubscribe(x, y, z)

	local isActive = vox_metadata.getMeta(x, y, z, "isActive")

	vox_metadata.deleteMeta(x, y, z)

	if isActive then
		voxelenergy.setActiveWires(x, y, z, false)
	end
end

function plate:isPlateActive(x, y, z)
	return vox_metadata.getMeta(x, y, z, "isActive")
end

function plate:setActivePlate(x, y, z, active)
	vox_metadata.setMeta(x, y, z, "isActive", active)

	local index

	if active then index = block_index("voxelenergy:pressure_plate_on") else index = block_index("voxelenergy:pressure_plate_off") end

	set_block(x, y, z, index, get_block_states(x, y, z))

	voxelenergy.setActiveWires(x, y, z, active)
end

function plate:tick(tps)
	ticks:tick(tps)
end

function plate:onUpdate(x, y, z)
	commons:onUpdate(x, y, z, plate)
end

return plate