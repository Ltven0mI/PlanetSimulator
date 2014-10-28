loader = {}

loader.sys = {}		--Loader Systems
loader.sys.cb = {}		--Loader Callbacks
loader.sys.cb.load = {}
loader.sys.cb.update = {}
loader.sys.cb.draw = {}

loader.systemCount = 0
loader.sortedSystems = {}

loader.lib = {}		--Loader Libraries

-- Callbacks --
function loader.load()
	print("Loader Load")
	loader.getLibraries("/libraries")
	loader.getSystems("/systems")

	for priority, sys in pairs(loader.sys.cb.load) do
		if sys.load then sys.load() end
	end
end

function loader.update(dt)
	for priority, sys in pairs(loader.sys.cb.update) do
		if sys.update then sys.update(dt) end
	end
end

function loader.draw()
	for priority, sys in pairs(loader.sys.cb.draw) do
		if sys.draw then sys.draw() end
	end
end

-- Functions --
function loader.getSystems(dir,isrepeat,systems)
	if isrepeat == nil then isrepeat = false end
	if systems == nil then systems = {} end
	local files = love.filesystem.getDirectoryItems(dir)
	local lng = table.getn(files)
	for i=1, lng do
		local item = files[i]
		local key = string.gsub(item, ".lua", "")
		if key then
			if love.filesystem.isFile(dir.."/"..item) then
				local holdSys = require(dir.."/"..key)
				if holdSys and type(holdSys) == "table" then
					if holdSys.systemKey and holdSys.systemKey ~= "" then
						loader.systemCount = loader.systemCount + 1
						systems[loader.systemCount] = holdSys
						print("[LOADER] Added system '"..key.."' from directory '"..dir.."' to unsorted list")
					end
				end
			elseif love.filesystem.isDirectory(dir.."/"..item) then
				loader.getSystems(dir.."/"..item, true, systems)
			end
		end
	end
	if not isrepeat then print(""); loader.sortSystems(systems) end
end

function loader.sortSystems(systems)
	if systems ~= nil then
		local lng = table.getn(systems)
		for i=1, lng do
			local sys = systems[i]
			if sys then
				local priority = sys.runPriority
				local key = sys.systemKey
				if priority and key then
					if type(priority) == "number" then
						local holdSys = loader.sortedSystems[priority]
						if not holdSys then
							print("[LOADER] Giving system '"..key.."' priority '"..priority.."'")
							loader.sortedSystems[priority] = sys
						else
							local holdKey = holdSys.systemKey
							local holdNewPri = priority
							local holdNewSys = holdSys
							print("[LOADER] Tried giving system '"..key.."' priority '"..priority.."'")
							print("[LOADER] System '"..holdKey.."' with priority '"..priority.."' already exsits")
							while holdNewSys do
								holdNewPri = holdNewPri + 0.1
								holdNewSys = loader.sortedSystems[holdNewPri]
							end
							print("[LOADER] Giving system '"..key.."' priority '"..holdNewPri.."'")
							loader.sortedSystems[holdNewPri] = sys
						end
					elseif type(priority) == "table" then

					end
				end
			end
		end
		print("")
		loader.filterSystems()
	end
end

function loader.filterSystems()
	if loader.sortedSystems then
		for priority, sys in pairs(loader.sortedSystems) do
			if sys then
				local priority = sys.runPriority
				local key = sys.systemKey
				if priority and key then
					if sys.load then loader.sys.cb.load[priority] = sys; print("[LOADER] System '"..key.."' added to Callbacks 'Load'") end
					if sys.update then loader.sys.cb.update[priority] = sys; print("[LOADER] System '"..key.."' added to Callbacks 'Update'") end
					if sys.draw then loader.sys.cb.draw[priority] = sys; print("[LOADER] System '"..key.."' added to Callbacks 'Draw'") end
				end
			end
		end
		print("")
	end
end

function loader.getLibraries(dir,isrepeat)
	if isrepeat == nil then isrepeat = false end

	local files = love.filesystem.getDirectoryItems(dir)
	local lng = table.getn(files)
	for i=1, lng do
		local item = files[i]
		local key = string.gsub(item, ".lua", "")
		if key then
			if love.filesystem.isFile(dir.."/"..item) then
				local holdLib = require(dir.."/"..key)
				if holdLib and type(holdLib) == "table" then
					print("[LOADER] Adding lib '"..key.."' from directory '"..dir.."'")
					loader.lib[key] = holdLib
				end
			elseif love.filesystem.isDirectory(dir.."/"..item) then
				loader.getLibraries(dir.."/"..item, true)
			end
		end
	end
	if not isrepeat then print("") end
end

return loader