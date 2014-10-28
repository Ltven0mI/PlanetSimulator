debug = {}

function debug(...)

end

function debug.log(...)
	if ps.debugMode then
		for k, v in pairs({...}) do io.write(v.." ") end
		io.write("\n")
	end
end

function debug.write(...)
	if ps.debugMode then
		for k, v in pairs({...}) do io.write(v.." ") end
	end
end

return debug