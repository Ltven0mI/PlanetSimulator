debug = {}
	
function debug.log(...)
	local args = {...}
	for key, val in pairs(args) do
		io.write(val.." ")
	end
	io.write("\n")
end

function debug.write(...)
	local args = {...}
	for key, val in pairs(args) do
		io.write(val.." ")
	end
end

return debug