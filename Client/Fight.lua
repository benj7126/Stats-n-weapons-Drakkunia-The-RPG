local fight = {}
local backgroundIMG = love.graphics.newImage("FightBack.png")
local empty = love.graphics.newImage("gameData/ImageAssets/Empty.png")
local defaultImgPlrNoLogo = love.graphics.newImage("gameData/ImageAssets/NonPFP.png")

local convertStuff = {"hp", "mp", "stamina", "xp", "maxHp", "maxMp", "maxStamina", "level"}

local selectedTarget = 2

local feildUpdated = false

local myStats = {
    hp = 0,
    mp = 0,
    stamina = 0,
    xp = 0,
    maxHp = 0,
    maxMp = 0,
    maxStamina = 0,
    level = 0
}

local myLog = {}

local feild = {
    nil, nil, nil,
    nil, nil, nil,
    nil, nil, nil
}

local usableSkills = {}

local myPos = 0

function fight:draw()
    local xm, ym = love.mouse.getPosition()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, w, h)

    love.graphics.setColor(230/255, 8/255, 8/255)
    love.graphics.rectangle("fill", 17*4, 16*4, 73*4/myStats.maxHp*myStats.hp, 4*4)
    love.graphics.setColor(18/255, 0, 138/255)
    love.graphics.rectangle("fill", 17*4, 29*4, 73*4/myStats.maxHp*myStats.mp, 4*4)
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", 17*4, 41*4, 73*4/myStats.maxStamina*myStats.stamina, 4*4)
    love.graphics.setColor(133/255, 13/255, 1)
    love.graphics.rectangle("fill", 17*4, 54*4, 73*4/(myStats.level*100)*myStats.xp, 4*4) -- do xp calc for lvl

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4) -- its more like a middle gound, but whatever...

    love.graphics.setColor(1, 1, 1)
    for i = 1,3 do
        if feild[i] then
            drawImg(monsters[feild[i].index].image, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", 108*4+(i-1)*32*4, 11*4, 20*4/monsters[feild[i].index].maxHp*feild[i].hp, 4)
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("fill", 108*4+(i-1)*32*4, 11*4+4, 20*4/monsters[feild[i].index].maxStamina*feild[i].stamina, 4)
            love.graphics.setColor(1, 1, 1)
            if box(xm, ym, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4) then
                love.graphics.printf(monsters[feild[i].index].name, 18*4, 65*4, 69*4, "left")
            end
        else
            drawImg(empty, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4)
        end
        if selectedTarget == i then
            love.graphics.rectangle("line", 108*4+(i-1)*32*4, 11*4, 20*4, 20*4)
        end
    end

    for i = 4,6 do
        if feild[i] then
            drawImg(defaultImgPlrNoLogo, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4)
            if box(xm, ym, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4) then
                love.graphics.printf("Thats a player...", 18*4, 65*4, 69*4, "left")
            end
        else
            drawImg(empty, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4)
        end
        if selectedTarget == i then
            love.graphics.rectangle("line", 108*4+(i-4)*32*4, 59*4, 20*4, 20*4)
        end
    end

    for i = 7,9 do
        if feild[i] then
            drawImg(defaultImgPlrNoLogo, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4)
            if box(xm, ym, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4) then
                love.graphics.printf("Thats a player...", 18*4, 65*4, 69*4, "left")
            end
        else
            drawImg(empty, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4)
        end
        if selectedTarget == i then
            love.graphics.rectangle("line", 108*4+(i-7)*32*4, 91*4, 20*4, 20*4)
        end
    end
    
    love.graphics.setColor(1, 1, 1)
    for i,str in pairs(myLog) do
        love.graphics.printf(str, 209*4, 104*4-(i*32), 75*4, "left")
    end
end

function fight:update(dt)
    
end

function fight:keypressed(key)
    
end

function fight:keyreleased(key)

end

function fight:mousepressed(xm, ym, b)
    if b == 1 then
        for i = 1,3 do
            if box(xm, ym, 108*4+(i-1)*32*4, 11*4, 20*4, 20*4) then
                selectedTarget = i
            end
        end
        for i = 4,6 do
            if box(xm, ym, 108*4+(i-4)*32*4, 59*4, 20*4, 20*4) then
                selectedTarget = i
            end
        end
        for i = 7,9 do
            if box(xm, ym, 108*4+(i-7)*32*4, 91*4, 20*4, 20*4) and love.mouse.isDown(1) then
                selectedTarget = i
            end
        end
    end
end

function updateFight(data)
    feild = data.board
    for i,v in pairs(data.selfStats) do
        myStats[convertStuff[i]] = v
    end
    for _,log in pairs(data.insertLog) do
        table.insert(myLog, 0, log)
        if #myLog == 11 then
            table.remove(myLog, #myLog)
        end
    end
end

return fight