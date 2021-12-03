local fight = {}
local backgroundIMG = love.graphics.newImage("FightBack.png")
local empty = love.graphics.newImage("gameData/ImageAssets/Empty.png")
local defaultImgPlrNoLogo = love.graphics.newImage("gameData/ImageAssets/NonPFP.png")

local feildUpdated = false

local myStatsProcent = {
    hp = 100,
    mp = 100,
    s = 100, -- stamina/energy
    xp = 0
}

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

    love.graphics.setColor(230/255, 8/255, 8/255)
    love.graphics.rectangle("fill", 17*4, 16*4, 73*4/100*myStatsProcent.hp, 4*4)
    love.graphics.setColor(18/255, 0, 138/255)
    love.graphics.rectangle("fill", 17*4, 29*4, 73*4/100*myStatsProcent.hp, 4*4)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", 17*4, 41*4, 73*4/100*myStatsProcent.s, 4*4)
    love.graphics.setColor(133/255, 13/255, 1)
    love.graphics.rectangle("fill", 17*4, 54*4, 73*4/100*myStatsProcent.xp, 4*4)

    love.graphics.setColor(1, 1, 1)
    for i = 1,3 do
        if feild[i] then
            drawImg(monsters[feild[i]].image, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4)
        else
            drawImg(empty, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4)
        end
    end

    for i = 4,6 do
        if feild[i] then
            drawImg(defaultImgPlrNoLogo, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4)
        else
            drawImg(empty, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4)
        end
    end

    for i = 7,9 do
        if feild[i] then
            drawImg(defaultImgPlrNoLogo, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4)
        else
            drawImg(empty, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4) -- its more like a middle gound, but whatever...
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
    feild = fightData
end

return fight