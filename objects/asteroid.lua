asteroid = {}

-- Callbacks --
function asteroid:created(args)
	if args[2] then self.radius = args[2] end
	if args[3] then self.pos.x = args[3] end
	if args[4] then self.pos.y = args[4] end
	if args[5] then self.density = args[5] end

	self.volume = math.getSphereVolume(self.radius)
	self.mass = math.getMass(self.density, self.volume)
	debug.log(self.volume, self.density, self.mass, self.radius)
end

function asteroid:update(dt)
	if love.keyboard.isDown("s") then
		object.destroyObject(self)
	end

	local mx, my = love.mouse.getX(), love.mouse.getY()
	local mdist = math.dist(self.pos.x, self.pos.y, mx, my)
	if mdist <= self.radius then self.isActive = true else self.isActive = false end

	for key, par in pairs(self.par) do
		if par then
			local dist = math.dist(self.pos.x, self.pos.y, par.pos.x, par.pos.y)*1000
			--debug.log(dist/1000)
			local dir = {x=par.pos.x - self.pos.x, y=par.pos.y - self.pos.y}
			local mag = math.sqrt((dir.x * dir.x)+(dir.y * dir.y))
			local g = physics.G
			local f = g * ((self.mass * par.mass)/(dist*dist))
			local aSelf, aPar = ((g*self.mass)/(dist*dist))*10000000000000, ((g*par.mass)/(dist*dist))*10000000000000 --THe /1000 converts it from meters per second to kilometers per second
			debug.log(aSelf, aPar)
			dir.x = dir.x / mag
			dir.y = dir.y / mag
			self.vel.x = self.vel.x + ((dir.x*aPar))*ps.speed
			self.vel.y = self.vel.y + ((dir.y*aPar))*ps.speed
			par.vel.x = par.vel.x - ((dir.x*aSelf))*ps.speed
			par.vel.y = par.vel.y - ((dir.y*aSelf))*ps.speed

			if dist/1000 <= par.radius + self.radius then if par.mass > self.mass then self:crash() else par:crash() end end
		end
	end

	self.pos.x = self.pos.x + (self.vel.x*dt*ps.speed)
	self.pos.y = self.pos.y + (self.vel.y*dt*ps.speed)

	if self.trailTimer > 0.1 then

		self.lastPos = {x=self.pos.x, y=self.pos.y}

		local last = self.lastPos
		for i=1, 30 do
			local holdTrail = self.trails[i]
			if holdTrail then
				local holdLast = {x=holdTrail.x, y=holdTrail.y}
				self.trails[i] = {x=last.x, y=last.y}
				last = holdLast
			else
				self.trails[i] = {x=self.pos.x, y=self.pos.y}
			end
		end
		self.trailTimer = 0
	end

	if self.pos.x < 0 or self.pos.x > love.graphics.getWidth() then object.destroyObject(self) end
	if self.pos.y < 0 or self.pos.y > love.graphics.getHeight() then object.destroyObject(self) end

	self.trailTimer = self.trailTimer + dt*math.abs(ps.speed)
end

function asteroid:draw()
	if ps.showTrails then
		local holdLast = {x=self.pos.x,y=self.pos.y}
		local lng = table.getn(self.trails)
		for i=1, lng do
			local val = self.trails[i]
			if val then
				local amp = (-i + lng)*(255/lng)
				love.graphics.setColor(255,255,255,amp)
				love.graphics.line(val.x, val.y, holdLast.x, holdLast.y)
				holdLast.x = val.x
				holdLast.y = val.y
			end
		end
	end

	love.graphics.setColor(0,255,255,255)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)

	if self.isActive then
		love.graphics.print("Radius: "..self.radius, self.pos.x - ps.font:getWidth("Radius: ")/2, self.pos.y - self.radius - ps.font:getHeight()*3)
		love.graphics.print("Mass: "..math.floor(self.mass), self.pos.x - ps.font:getWidth("Mass: ")/2, self.pos.y - self.radius - ps.font:getHeight()*2)
		love.graphics.print("Temp: "..math.floor(self.temp), self.pos.x - ps.font:getWidth("Temp: ")/2, self.pos.y - self.radius - ps.font:getHeight())
	end
end

-- Functions --
function asteroid:removeParents()
	self.par = {}
end

function asteroid:addParent(parent)
	if parent then
		self.parCount = self.parCount + 1
		self.par[self.parCount] = parent
	end
end

function asteroid:crash()
	if self.radius/2 >= 2 then
		self.radius = self.radius / 2
		self.volume = math.getSphereVolume(self.radius)
		self.density = self.density
		self.mass = math.getMass(self.density, self.volume)
	else
		object.destroyObject(self)
	end
end

function asteroid:new()
	local obj = {}
	obj.pos = {x=0, y=0}
	obj.vel = {x=0, y=0}
	obj.radius = 100
	obj.volume = math.getSphereVolume(obj.radius)
	obj.density = 50
	obj.mass = math.getMass(obj.density, obj.volume)
	obj.temp = 0

	obj.trails = {}
	obj.lastPos = {x=0, y=0}
	obj.trailTimer = 1
	obj.isActive = false

	obj.par = {}
	obj.parCount = 0
	return obj
end

return asteroid