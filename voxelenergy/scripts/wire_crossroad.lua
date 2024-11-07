local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_math = load_script("voxelhelp:vox_math.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")

local wire_crossroad = { internal = { } }

voxelenergy.registerElectricElement("voxelenergy:wire_crossroad")

voxelenergy.registerConditionForEnergyIsNearby("voxelenergy:wire_crossroad",
	
function (sourceX, sourceY, sourceZ, x, y, z)
	if wire_crossroad:hasEnergy(sourceX, sourceY, sourceZ, x, y, z) then
		return true
	end
end
)

function on_placed(x, y, z)
	wire_crossroad:update(x, y, z)
end

function on_update(x, y, z)
	wire_crossroad:update(x, y, z)
end

function on_broken(x, y, z)
	vox_metadata.deleteMeta(x, y, z)
end

function wire_crossroad:update(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isUpdating") then
		return
	end

	vox_metadata.setMeta(x, y, z, "isUpdating", true)

	local points = wire_crossroad:getPoints(x, y, z)
	local inputFinded = false
	local inX, inY, inZ = 0, 0, 0
	local outX, outY, outZ = 0, 0, 0

	for i = 0, points:iterations() do
		inputFinded = false

		local point = points:get(i)

		if voxelenergy.isDirectionWire(point.x1, point.y1, point.z1) and voxelenergy.isFrontRelativeSource(point.x1, point.y1, point.z1, x, y, z) then
			inputFinded = true
			inX, inY, inZ = point.x1, point.y1, point.z1
			outX, outY, outZ = point.x2, point.y2, point.z2
		elseif voxelenergy.isDirectionWire(point.x2, point.y2, point.z2) and voxelenergy.isFrontRelativeSource(point.x2, point.y2, point.z2, x, y, z) then
			inputFinded = true
			inX, inY, inZ = point.x2, point.y2, point.z2
			outX, outY, outZ = point.x1, point.y1, point.z1
		end

		if inputFinded then
			local hasEnergyInInput = voxelenergy.isActiveEnergyPoint(inX, inY, inZ)
			local hasEnergyInOutput = voxelenergy.isActiveEnergyPoint(outX, outY, outZ)

			if hasEnergyInInput ~= hasEnergyInOutput and voxelenergy.isWire(outX, outY, outZ) then
				voxelenergy.setActiveWiresInNeighbours(outX, outY, outZ, hasEnergyInInput)
			end
		end
	end

	set_block(x, y, z, block_index("voxelenergy:wire_crossroad"), get_block_states(x, y, z))

	vox_metadata.setMeta(x, y, z, "isUpdating", false)
end

local pointAxes =
{
	{ 1, 0, 0 },
	{ -1, 0, 0 },
	{ 0, 1, 0 },
	{ 0, -1, 0 },
	{ 0, 0, 1 },
	{ 0, 0, -1 }
}

function wire_crossroad:hasEnergy(cx, cy, cz, x, y, z)
	if cx == x and cy == y and cz == z then
		return false
	end

	local axis = 0
	
	if cx > x then
		axis = 1
	elseif cx < x then
		axis = 2
	else
		if cy > y then
			axis = 3
		elseif cy < y then
			axis = 4
		else
			if cz > z then
				axis = 5
			elseif cz < z then
				axis = 6
			end
		end
	end

	if axis ~= 0 then
		return get_block(vox_math.vector3.add(cx, cy, cz, wire_crossroad.internal:getPointCoordsByAxis(axis))) == block_index("voxelenergy:direction_wire_on")
	else
		return false
	end
end

function wire_crossroad.internal:getPointCoordsByAxis(axis)
	if axis == 0 then
		return nil, nil, nil
	else
		local point = pointAxes[axis]

		return point[1], point[2], point[3]
	end
end

function wire_crossroad:getPoints(x, y, z)
	local sources = vox_list:new()

	wire_crossroad.internal:addPoint(x + 1, y, z, x - 1, y, z, sources)
	wire_crossroad.internal:addPoint(x, y + 1, z, x, y - 1, z, sources)
	wire_crossroad.internal:addPoint(x, y, z + 1, x, y, z - 1, sources)

	return sources
end

function wire_crossroad.internal:addPoint(x1, y1, z1, x2, y2, z2, sources)
	sources:add({ x1 = x1, y1 = y1, z1 = z1, x2 = x2, y2 = y2, z2 = z2 })
end

return wire_crossroad