local fight = {}
local backgroundIMG = love.graphics.newImage("FightBack.png")

local feildUpdated = false

local feild = {
    nil, nil, nil,
    nil, nil, nil,
    nil, nil, nil
}

local usableSkills = {}

local myPos = 0

function fight:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)
    love.graphics.setColor(0, 0, 0)

    for i = 1,3 do
        love.graphics.print(feild[i] or "empty", 200+(i-1)*150, 50)
    end

    for i = 4,6 do
        love.graphics.print(feild[i] or "empty", 200+(i-4)*150, 250)
    end

    for i = 7,9 do
        love.graphics.print(feild[i] or "empty", 200+(i-7)*150, 300)
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

function updateFight(fightData)
    feild = fightData[1]
end

return fight