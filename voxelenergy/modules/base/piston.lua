local voxelenergy = require "voxelenergy:api"
local vox_metadata = load_script("voxelhelp:vox_metadata.lua")
local vox_list = load_script("voxelhelp:vox_list.lua")
local vox_utils = load_script("voxelhelp:vox_utils.lua")

local piston = { }
local activeBlocksList = vox_list:new()

local vec3 = { }

function vec3.equals(x, y, z, x1, y1, z1)
	return x == x1 and y == y1 and z == z1
end

function vec3.floor(x, y, z)
	return math.floor(x), math.floor(y), math.floor(z)
end

activeBlocksList:add("voxelenergy:piston_active")
activeBlocksList:add("voxelenergy:piston_pusher")
activeBlocksList:add("voxelenergy:sticky_piston_active")
activeBlocksList:add("voxelenergy:sticky_piston_pusher")

voxelenergy.registerElectricElement("voxelenergy:piston_idle")
voxelenergy.registerElectricElement("voxelenergy:sticky_piston_idle")

activeBlocksList:foreach(function(element)
	voxelenergy.registerElectricElement(element)
end)

function piston:getActiveBlocksList()
	return activeBlocksList
end

function piston:update(x, y, z)
	if piston:canMove(x, y, z) then
		piston:move(x, y, z)
	end
end

function piston:canMove(x, y, z)
	if vox_metadata.getMeta(x, y, z, "isMoving") or not voxelenergy.energyIsNearby(x, y, z) then
		return false
	end

	local nearbyBlocks = vox_utils.getPositionsOfNearbyBlocks(x, y, z, voxelenergy.getMaybeEnergyList())
	local size = nearbyBlocks:size()

	if size == 1 then
		local block = nearbyBlocks:get(0)

		return not vec3.equals(block.x, block.y, block.z, vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1))
	else
		return true
	end
end

function piston:move(x, y, z)
	vox_metadata.setMeta(x, y, z, "isMoving", true)

	local maxBlocksCount = 12

	local blocksCount = piston:getBlocksCount(x, y, z, maxBlocksCount + 1)

	local newBlocksData = vox_list:new()

	if blocksCount > 0 then
		if maxBlocksCount > blocksCount then
			local i = blocksCount

			while i > 0 do
				local posX, posY, posZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, i)
				local newPosX, newPosY, newPosZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, i + 1)
				local blockId = get_block(posX, posY, posZ)
				local states = get_block_states(posX, posY, posZ)

				newBlocksData:add({ posX, posY, posZ, newPosX, newPosY, newPosZ, blockId, states })

				i = i - 1
			end
		else
			vox_metadata.setMeta(x, y, z, "isMoving", false)
			return
		end
	end

	local isSticky = block_name(get_block(x, y, z)) == "voxelenergy:sticky_piston_idle"

	local pistonActiveBlockName
	local pistonPusherBlockName

	if isSticky then
		pistonActiveBlockName = "voxelenergy:sticky_piston_active"
		pistonPusherBlockName = "voxelenergy:sticky_piston_pusher"
	else
		pistonActiveBlockName = "voxelenergy:piston_active"
		pistonPusherBlockName = "voxelenergy:piston_pusher"
	end
	
	local frontX, frontY, frontZ = vox_utils.getShiftedPositionRelativeRotation(x, y, z, 1)

	local states = get_block_states(x, y, z)

	set_block(x, y, z, block_index(pistonActiveBlockName), states)

	local lastBlock

	if newBlocksData:size() > 0 then
		lastBlock = newBlocksData:get(0)
	else
		lastBlock = { }
		lastBlock[4] = frontX
		lastBlock[5] = frontY
		lastBlock[6] = frontZ
	end

	local shift = 1

	piston:movePlayer(PlayerID, lastBlock, shift, x, y, z)

	set_block(frontX, frontY, frontZ, block_index(pistonPusherBlockName), states)

	newBlocksData:foreach(function(e, i)
		local newPosX, newPosY, newPosZ = e[4], e[5], e[6]
		local blockId = e[7]

		set_block(newPosX, newPosY, newPosZ, blockId, e[8])

		piston:callMoveEvent(blockId, e[1], e[2], e[3], newPosX, newPosY, newPosZ, frontX, frontY, frontZ)
	end)

	vox_metadata.setMeta(x, y, z, "isActive", true)

	vox_metadata.setMeta(x, y, z, "isMoving", false)
end

function piston:callMoveEvent(blockId, oldX, oldY, oldZ, newX, newY, newZ, frontX, frontY, frontZ)
	local moveEvent = voxelenergy.getPistonMoveEvent(block_name(blockId))

	vox_metadata.moveMeta(oldX, oldY, oldZ, newX, newY, newZ)

	if not vec3.equals(oldX, oldY, oldZ, frontX, frontY, frontZ) then
		set_block(oldX, oldY, oldZ, block_index("core:air"))
	end

	if moveEvent ~= nil then
		moveEvent(oldX, oldY, oldZ, newX, newY, newZ, true)
		return
	end
end

function piston:movePlayer(pid, lastBlock, shift, x, y, z)
	local newX, newY, newZ = lastBlock[4], lastBlock[5], lastBlock[6]
	local px, py, pz = player.get_pos(pid)

	if math.floor(py) == newY and (vec3.equals(newX, 0, newZ, vec3.floor(px, 0, pz)) or vec3.equals(newX, 0, newZ, vec3.ceil(px, 0, pz))) then
		player.set_pos(pid, vec3.add(px, py, pz, vox_utils.getShiftedVectorRelativeRotation(x, y, z, shift)))
	end
end

function piston:getBlocksCount(x, y, z, maxBlocksCount)
	local blocksCount = 0
	local airId = block_index("core:air")
	local bazaltId = block_index("base:bazalt")
	local states = get_block_states(x, y, z)

	for i = 1, maxBlocksCount do

		fx, fy, fz = vox_utils.getShiftedPositionRelativeRotation(x, y, z, i)

		local blockId = get_block(fx, fy, fz)

		if blockId == airId or is_replaceable_at(fx, fy, fz) then
			break
		elseif blockId == bazaltId or activeBlocksList:contains(block_name(blockId)) then
			return maxBlocksCount
		else
			blocksCount = blocksCount + 1
		end
	end

	return blocksCount
end

return piston