planet = {}

-- Callbacks --
function planet:created(args)
	if args[2] then self.mass = args[2] end
	if args[3] then self.radius = args[3] end
	if args[4] then self.pos.x = args[4] end
	if args[5] then self.pos.y = args[5] end

	self.volume = math.getSphereVolume(self.radius)
	self.density = 500
	self.mass = math.getMass(self.density, self.volume)
end
function planet:update(dt)
	if love.keyboard.isDown("w") then
		object.destroyObject(self)
	end
	self.pos.x = self.pos.x + (self.vel.x*dt)
	self.pos.y = self.pos.y + (self.vel.y*dt)
end

function planet:draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
end


-- Functions --
function planet:new()
	local obj = {}
	obj.pos = {x=0, y=0}
	obj.vel = {x=0, y=0}
	obj.radius = 100
	obj.volume = math.getSphereVolume(obj.radius)
	obj.density = 500
	obj.mass = math.getMass(obj.density, obj.volume)
	return obj
end

return planet