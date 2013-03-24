require("src.Config")
require("src.Game")

function love.load()
	love.graphics.setMode(gameConfig.screen.width, gameConfig.screen.height, true)
    game = Game.create()
    game:setDemoMode(false)
    game:setMenu("title")
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function restart()
    game:destroy()
    game = Game.create()
end
