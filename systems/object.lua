-- System Settings --
object = {}
object.systemKey = "object"
object.runPriority = 1

-- Variables --
object.objects = {}
object.createdObjects = {}
object.objCount = 0

-- Callbacks --
function object.load()
	object.getObjects("/objects")
end

function object.update(dt)
	for uid, obj in pairs(object.createdObjects) do
		if obj.update then obj:update(dt) end
	end
end

function object.draw()
	for uid, obj in pairs(object.createdObjects) do
		if obj.draw then obj:draw() end
	end
end

-- Functions --
function object.new(...)
	local args = {...}
	local objType = args[1]
	if objType then
		local holdType = object.objects[objType]
		args[1] = nil
		if holdType then
			local holdObject = {}
			if holdType.new then holdObject = holdType:new() end
			local uid = object.createUID()
			holdObject.uid = uid
			object.createdObjects[uid] = holdObject
			setmetatable(holdObject, { __index = holdType })
			if holdObject.created then holdObject:created(args) end
			return object.createdObjects[uid]
		end
	end
end

function object.getObjects(dir,isrepeat)
	if isrepeat == nil then isrepeat = false end

	local files = love.filesystem.getDirectoryItems(dir)
	local lng = table.getn(files)
	for i=1, lng do
		local item = files[i]
		local key = string.gsub(item, ".lua", "")
		if key then
			if love.filesystem.isFile(dir.."/"..item) then
				local holdObj = require(dir.."/"..key)
				if holdObj and type(holdObj) == "table" then
					print("[OBJECT] Adding object '"..key.."' from directory '"..dir.."'")
					object.objects[key] = holdObj
				end
			elseif love.filesystem.isDirectory(dir.."/"..item) then
				object.getObjects(dir.."/"..item, true)
			end
		end
	end
	if not isrepeat then print("") end
end

function object.createUID()
	object.objCount = object.objCount + 1
	return object.objCount
end

function object.getObject(uid)
	if object.createdObjects[uid] then
		return object.createdObjects[uid]
	else
		return nil
	end
end

function object.destroyObject(arg)
	if arg then
		if type(arg) == "number" then
			if object.createdObjects[arg] then
				object.createdObjects[arg] = nil
			end
		elseif type(arg) == "table" then
			if arg.uid then
				if object.createdObjects[arg.uid] then
					object.createdObjects[arg.uid] = nil
				end
			end
		end
	end
end

return object