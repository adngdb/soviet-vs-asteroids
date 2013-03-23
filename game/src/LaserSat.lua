-----------------------------------------------------------------------------------------
--
-- LaserSat.lua
--
-- A satellite firing lasers.
--
-----------------------------------------------------------------------------------------

module("LaserSat", package.seeall)
local Class = LaserSat
Class.__index = Class

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the station
function Class.create(options)
    -- Create object
    self = {}
    setmetatable(self, Class)

    -- Initialize attributes
    self.pos = options.position
    self.angle = options.angle
    self.fireAngle = 0
    self.isFiring = false
    self.debug = gameConfig.debug.all or gameConfig.debug.shapes 

    return self
end

-- Destroy the station
function Class:destroy()
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Update the missile
--
-- Parameters:
--  dt: The time in seconds since last frame
function Class:update(dt)
    self.isFiring = false
end

-- Draw the game
function Class:draw()
    if (not self.debug) then
        return
    end

    love.graphics.setColor(255, 255, 0)
    love.graphics.circle('fill', self.pos.x , self.pos.y , 10, 32)
    love.graphics.setLineWidth(3);
    love.graphics.line(self.pos.x, self.pos.y, self.pos.x + 20 * math.cos( -self.angle), self.pos.y + 20 * math.sin( -self.angle) )

    if(self.isFiring) then
        love.graphics.setColor(255, 127, 0)
        love.graphics.line(self.pos.x, self.pos.y, self.pos.x + 2000 * math.cos( -self.fireAngle), self.pos.y + 2000 * math.sin( -self.fireAngle) )
    end
end

function Class:fire(angle)
    self.fireAngle = angle
    self.isFiring = true

end
