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

local Sprite = require("lib.Sprite")

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local spriteSheet = love.graphics.newImage("assets/graphics/lasersat.png")
local laserSpriteSheet = love.graphics.newImage("assets/graphics/laser_boule.png")
local laserBeamSpriteSheet = love.graphics.newImage("assets/graphics/laser_jet.png")

-----------------------------------------------------------------------------------------
-- Imports
-----------------------------------------------------------------------------------------

require("src.SoundManager")

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the station
function Class.create(options)
    -- Create object
    self = {}
    setmetatable(self, Class)

    -- Initialize attributes

    self.angle = options.angle
    self.displayAngle = options.angle
    self.isFiring = false
    self.isDoingDamage = false
    self.targetAsteroid = nil
    self.debug = gameConfig.debug.all or gameConfig.debug.shapes
    self.beamScale = 0.1
    self:updatePosition()

    self.debugText = ""

    self.sprite = Sprite.create{
        pos = self.pos,
        angle = self.displayAngle,
        spriteSheet = spriteSheet,
        frameCount = 1,
        frameRate = 1,
        scale = 0.3
    }

    self.laserOriginSprite = Sprite.create{
        pos = self.pos,
        angle = self.displayAngle,
        spriteSheet = laserSpriteSheet,
        frameCount = 2,
        frameRate = 0.1,
        scale = 0.25
    }

    self.laserImpactSprite = Sprite.create{
        pos = self.pos,
        angle = self.displayAngle,
        spriteSheet = laserSpriteSheet,
        frameCount = 2,
        frameRate = 0.1,
        scale = 0.25
    }

    self.laserBeamSprite = Sprite.create{
        pos = self.pos,
        angle = self.displayAngle,
        spriteSheet = laserBeamSpriteSheet,
        frameCount = 2,
        frameRate = 0.1,
        scale = 0.25
    }
    return self
end

-- Destroy the station
function Class:destroy()
    self.laserBeamSprite:destroy()
    self.laserBeamSprite = nil
    self.laserImpactSprite:destroy()
    self.laserImpactSprite = nil
    self.laserOriginSprite:destroy()
    self.laserOriginSprite = nil
    self.sprite:destroy()
    self.sprite = nil
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Update the missile
--
-- Parameters:
--  dt: The time in seconds since last frame
function Class:update(dt)
    self.laserOriginSprite:update(dt)
    self.laserImpactSprite:update(dt)
    self.laserBeamSprite:update(dt)

    self.isDoingDamage = false

    if self.beamScale < 1 and self.isFiring then
        self.beamScale = math.min(self.beamScale + gameConfig.laser.beamSpeed * dt, 1)
    elseif self.isFiring then
        self.beamScale = 1
        self.isDoingDamage = true
    end
end

-- Draw the game
function Class:draw()
    love.graphics.setColor(255,255,255)

    self.sprite.angle = self.displayAngle
    self.sprite.pos = self.pos + vec2(-18, -18):rotateRad(-self.displayAngle)
    self.sprite:draw()

    if(self.isFiring and not( self.targetAsteroid == nil)) then
        norm = math.sqrt(math.pow( self.targetAsteroid.pos.x - self.pos.x, 2 ) + math.pow( self.targetAsteroid.pos.y - self.pos.y, 2 ))
        self.laserBeamSprite.scaleX = self.beamScale * (norm - self.targetAsteroid.radius * 0.7 - 48) / 256
        self.laserBeamSprite.angle = self.displayAngle
        self.laserBeamSprite.pos = self.pos + vec2( 32, -16):rotateRad(-self.displayAngle)
        self.laserBeamSprite:draw()

        self.laserOriginSprite.angle = self.displayAngle
        self.laserOriginSprite.pos = self.pos + vec2( 20, -16):rotateRad(-self.displayAngle)
        self.laserOriginSprite:draw()

        if self.beamScale >= 1 then
            self.laserImpactSprite.angle = self.displayAngle
            self.laserImpactSprite.pos = self.targetAsteroid.pos + vec2( -16, -16):rotateRad(-self.displayAngle)
            self.laserImpactSprite.pos = self.laserImpactSprite.pos + vec2( self.targetAsteroid.radius * 0.7, self.targetAsteroid.radius * 0.7 ):rotateRad(-self.displayAngle + 0.75* math.pi)
            self.laserImpactSprite:draw()
        end
        if self.debug then
            -- love.graphics.setLineWidth(3);
           -- local offset = vec2(15, 0):rotateRad(-self.displayAngle)
          --  love.graphics.setColor(255, 0, 0)
         --   love.graphics.line(self.pos.x + offset.x , self.pos.y + offset. y, self.targetAsteroid.pos.x, self.targetAsteroid.pos.y )
        end
    end


   -- love.graphics.setColor(255, 255, 0)
 --   love.graphics.circle('fill', self.pos.x , self.pos.y , 10, 32)

    --love.graphics.line(self.pos.x, self.pos.y, self.pos.x + 20 * math.cos( -self.displayAngle), self.pos.y + 20 * math.sin( -self.displayAngle) )


    --love.graphics.print("Debug : " ..self.debugText, 200, 200)

end

function Class:inFrontOf(fireAngle)
    shiftedAngle = fireAngle - self.angle
     if (shiftedAngle < -4.71) then
        shiftedAngle = 1 + shiftedAngle + 4.71
    end

    if (shiftedAngle > 4.71) then
        shiftedAngle =  shiftedAngle - 4.71
    end

    if ( shiftedAngle > -1.57 and shiftedAngle < 1.57 ) then
        return true
    else
        return false
    end
end

function Class:fire(fireAngle, asteroid)
    -- Check if the lasetSat is oriented in the direction of the fireAngle
    if (self:inFrontOf(fireAngle)) then
        local deltaX = asteroid.pos.x - self.pos.x
        local deltaY = asteroid.pos.y - self.pos.y
        asteroidAngle = - math.atan2(deltaY, deltaX)

        -- Check if the lasetSat can shot the target
        if (self:inFrontOf(asteroidAngle)) then
            self.targetAsteroid = asteroid
            self.isFiring = true
            self.displayAngle = asteroidAngle
        else
            self.targetAsteroid = nil
            self.isFiring = false
            self.displayAngle = self.angle
        end
    else
        self.isFiring = false
        self.displayAngle = self.angle
    end

    return self.isFiring
end

function Class:stopFire()
    self.isFiring = false
    self.targetAsteroid = nil
    self.displayAngle = self.angle
    self.beamScale = 0.1
end

function Class:updatePosition()
    self.pos = gameConfig.station.shieldOffset
        + vec2(math.cos(self.displayAngle), math.sin(-self.displayAngle))
        * gameConfig.station.radius * gameConfig.laserSat.offOrbitRatio
end

function Class:setAngle(angle)
    self.angle = angle
    self.displayAngle = angle
    self:updatePosition()
end
