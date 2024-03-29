local party = {}

local partyIMG = love.graphics.newImage("gameData/ImageAssets/Party.png")
local moving = {false, 0, 0}
local xPos, yPos = w/2, h/4

function party:draw()
    love.graphics.setColor(1, 1, 1)
    if moving[1] then
        love.graphics.draw(partyIMG, gMX+moving[2], gMY+moving[3], 0, 4)
    else
        love.graphics.draw(partyIMG, xPos, yPos, 0, 4)
    end
end

function party:mousepressed(x, y, b)
    if box(x, y, xPos, yPos, 116*4, 3*4) and b == 1 then
        moving = {true, xPos-x, yPos-y}
    end
end

function party:mousereleased(x, y, b)
    if moving[1] then
        xPos, yPos = x+moving[2], y+moving[3]
        moving = {false, 0, 0}
    end
end

return party