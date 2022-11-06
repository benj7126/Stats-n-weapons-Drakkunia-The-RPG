local party = {}

local bookIMG = love.graphics.newImage("gameData/ImageAssets/books.png")
local moving = {false, 0, 0}
local xPos, yPos = w/2, h/4

function party:draw()
    love.graphics.setColor(1, 1, 1)
    if moving[1] then
        love.graphics.draw(bookIMG, gMX+moving[2], gMY+moving[3], 0, 4)
    else
        love.graphics.draw(bookIMG, xPos, yPos, 0, 4)
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