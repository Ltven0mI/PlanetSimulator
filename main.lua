ps = {}
ps.loader = require "loader"

-- Variables --
ps.planets = {}
ps.asteroids = {}
ps.holdPos = nil
ps.holdPos2 = nil

ps.speed = 0.1
ps.showTrails = false
ps.debugMode = true

ps.font = love.graphics.getFont()

-- Callbacks --
function love.load()
	math.randomseed(os.time())

	ps.loader.load()
end

function love.update(dt)
	ps.loader.update(dt)
	ps.setAsteroidParents()
end

function love.draw()
	ps.loader.draw()

	if ps.holdPos and ps.holdPos.x and ps.holdPos.y then
		local x, y = love.mouse.getX(), love.mouse.getY()
		local x1, y1 = ps.holdPos.x, ps.holdPos.y
		love.graphics.setColor(255,255,255,150)
		love.graphics.line(x, y, x1, y1)
	end
	if ps.holdPos2 and ps.holdPos2.x and ps.holdPos2.y then
		local x, y = love.mouse.getX(), love.mouse.getY()
		local x1, y1 = ps.holdPos2.x, ps.holdPos2.y
		love.graphics.setColor(255,255,255,150)
		love.graphics.line(x, y, x1, y1)
	end

	love.graphics.setColor(255,255,255,255)
	if ps.speed < 0 or ps.speed > 0 then love.graphics.print(""..ps.speed, 0, 0) else love.graphics.print("0", 0, 0) end
end

function love.mousepressed(x,y,btn)
	local lng = table.getn(ps.asteroids)
	if btn == "l" then
		ps.holdPos = {x=x, y=y}
	elseif btn == "r" then
		ps.holdPos2 = {x=x, y=y}
	else
		local closest = ps.getClosestBody({x=x,y=y},50)
		if closest then
			local r = math.dist(x, y, closest.pos.x, closest.pos.y)*1000
			local time = math.sqrt((4*math.pi^2*r^3)/(physics.G*closest.mass))
			local holdVel = math.sqrt((physics.G*closest.mass)/r)*(10^3)
			debug.log(((2*math.pi*r)/(time/60))*1000,"ORBIT")
			ps.addAsteroid(x, y, 5, 50, 0, -((2*math.pi*r)/(time/60))*13000)
		end
	end
end

function love.mousereleased(x,y,btn)
	if btn == "l" then
		if ps.holdPos and ps.holdPos.x and ps.holdPos.y then
			local hx, hy = ps.holdPos.x, ps.holdPos.y
			ps.addAsteroid(hx, hy, math.random(5,10), 50, (hx-x)*5, (hy-y)*5)
			ps.holdPos = nil
		end
	else
		if ps.holdPos2 and ps.holdPos2.x and ps.holdPos2.y then
			local hx, hy = ps.holdPos2.x, ps.holdPos2.y
			ps.addAsteroid(hx, hy, 100, 500, (hx-x)*5, (hy-y)*5)
			ps.holdPos2 = nil
		end
	end
end

function love.keypressed(key)
	if key == "up" then
		ps.speed = ps.speed + 0.1
	elseif key == "down" then
		ps.speed = ps.speed - 0.1
	elseif key == "return" then
		ps.showTrails = not ps.showTrails
	end
end

-- Functions --
function ps.getClosestBody(point,minRad,maxRad)
	local holdBody = nil
	local shortest = math.huge

	if not minRad then minRad = 1 end
	if not maxRad then maxRad = math.huge end

	if point and point.x and point.y then
		for key, val in pairs(ps.asteroids) do
			if val.radius >= minRad and val.radius <= maxRad then
				local dist = math.dist(point.x, point.y, val.pos.x, val.pos.y)
				if dist < shortest then
					holdBody = val
					shortest = dist
				end
			end
		end
		if holdBody then return holdBody end
	end

	return false
end

function ps.addAsteroid(x,y,r,d,vx,vy)
	if not vx then vx = 0 end
	if not vy then vy = 0 end
	if x and y and r and d then
		local lng = table.getn(ps.asteroids)
		ps.asteroids[lng+1] = object.new("asteroid", r, x, y, d)
		ps.asteroids[lng+1].vel = {x=vx, y=vy}
	end
end

function ps.setAsteroidParents()
	local holdObjects = {}

	for key, val in pairs(ps.asteroids) do
		ps.asteroids[key] = object.getObject(val.uid)
		holdObjects[key] = ps.asteroids[key]
	end

	for akey, aval in pairs(holdObjects) do
		aval:removeParents()
		for pkey, pval in pairs(holdObjects) do
			local holdD = math.dist(aval.pos.x, aval.pos.y, pval.pos.x, pval.pos.y)
			if pkey ~= akey then
				aval:addParent(pval)
			end
		end
		holdObjects[akey] = nil
	end
end