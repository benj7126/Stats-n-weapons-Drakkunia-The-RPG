local party = {}

local partyIMG = love.graphics.newImage("gameData/Party.png")
moving = {false, 0, 0}

function party:draw()
    print("draw")
    x, y = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    if moving[1] then
        love.graphics.draw(partyIMG, x+moving[2], y+moving[3], 0, 4)
    else
        love.graphics.draw(partyIMG, xPosP, yPosP, 0, 4)
    end
end

function party:mousepressed(x, y, b)
    if box(x, y, xPosP, yPosP, 116*4, 3*4) and b == 1 then
        moving = {true, xPosP-x, yPosP-y}
    end
end

function party:mousereleased(x, y, b)
    if moving[1] then
        xPosP, yPosP = x+moving[2], y+moving[3]
        moving = {false, 0, 0}
    end
end

return party