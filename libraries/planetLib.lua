planetLib = {}

function printTable(table,params,ind,it,txt)
	if ind == nil then ind = 0 end
	if txt == nil then txt = "" end
	if params and params.name and it == nil then txt=txt..tostring(params.name).." = " end
	txt=txt.."{\n"
	for key, val in pairs(table) do
		for i=0, ind do txt=txt.."|   " end
		txt=txt..tostring(key).." = "
		if type(val) ~= "table" then
			txt=txt..tostring(val)..",\n"
		elseif type(val) == "table" then
			txt = printTable(val,params,ind+1,true,txt)
		end
	end
	if it ~= nil then for i=1, ind do txt=txt.."|   " end end
	txt=txt.."}\n"

	if it == nil and params and params.name and params.toFile == true then
		if not love.filesystem.isFile(params.name) then
			love.filesystem.newFile(params.name..".printTable", "a")
		end
		if love.filesystem.isFile(params.name..".printTable") then
			if params.force == true then
				love.filesystem.write(params.name..".printTable", txt)
			else
				love.filesystem.append(params.name..".printTable", txt)
			end
		end
	end
	if it == nil then io.write(txt) end
	return txt
end

-- Math Functions
function math.dist(ax, az, bx, bz) 
    return math.sqrt((bx - ax)*(bx - ax) + (bz - az)*(bz - az));
end

function math.getSphereVolume(radius) --Returns the volume in the same format
	return (4/3)*math.pi*(radius^3)
end

function math.getMass(dens,volume)
	debug.log(dens, volume, "Test")
	return dens * volume
end

return planetLib