local fight = {}
local backgroundIMG = love.graphics.newImage("FightBack.png")

local feildUpdated = false

local feild = {
    {}, {}, {},
    {}, {}, {}, 
    {}, {}, {}
}

local usableSkills = {}

local myPos = 0

function fight:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)

    if feildUpdated == true then
        
    end
end

function fight:update(dt)
    
end

function fight:keypressed(key)
    
end

function fight:keyreleased(key)
    
end

function fight:mousepressed(x, y, b)
    
end

function updateFight(data)
    print(data)
end

return fight