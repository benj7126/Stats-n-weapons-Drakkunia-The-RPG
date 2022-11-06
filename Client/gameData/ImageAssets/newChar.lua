local newChar = {}

local backgroundIMG = love.graphics.newImage("Startup/CreateChar.png")
local raceIMG = love.graphics.newImage("Startup/RaceCharCreate.png")
local classIMG = love.graphics.newImage("Startup/ClassCharCreate.png")
local doneIMG = love.graphics.newImage("Startup/DoneCharCreate.png")
local selectedIMG = love.graphics.newImage("Startup/selected.png")

local class = 0
local race = 0
local racePage = 0

local racesDir = love.filesystem.getDirectoryItems("gameData/Races")
local races = {}
local classesDir = love.filesystem.getDirectoryItems("gameData/Classes/Stage1")
local classes = {}

for i, v in pairs(racesDir) do
    table.insert(races, require("gameData/Races/"..v.."/raceStats"))
end
for i, v in pairs(classesDir) do
    table.insert(classes, require("gameData/Classes/Stage1/"..v.."/classData"))
end

local page = 0

resetLable()
addLabel({text = "", x = 40*4, y = 54*4, w = 103*4, h = 15*4, limit = 12, writeable = true, color = {1, 1, 1}})
addLabel({text = "", x = 172*4, y = 88*4, w = 113*4, h = 45*4, limit = 0, writeable = false, color = {1, 1, 1}})


function newChar:draw()
    local x, y = gMX, gMY
    local b = love.mouse.isDown(1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)
    
    if page == 1 then
        love.graphics.draw(raceIMG, 0, 0, 0, 4)

        local lHeight = 23*4
        local lWidth = 53*4
        local xPos, yPos = 0, 0

        for i = 1,4 do
            if #races >= racePage*4+i then
                if i == 1 then
                    xPos, yPos = 172*4, 21*4
                elseif i == 2 then
                    xPos, yPos = 232*4, 21*4
                elseif i == 3 then
                    xPos, yPos = 172*4, 52*4
                elseif i == 4 then
                    xPos, yPos = 232*4, 52*4
                end
                if box(x, y, xPos, yPos, lWidth, lHeight) then
                    labels[2].text = races[racePage*4+i].Lore
                end

                if race == racePage*4+i then
                    love.graphics.draw(selectedIMG, xPos, yPos, 0, 4)
                end
                
                if font40:getWidth(races[racePage*4+i].Name) > lWidth then
                    love.graphics.setFont(font20)
                    love.graphics.printf(races[racePage*4+i].Name, xPos, yPos-font20:getHeight()/2+lHeight/2, lWidth, "center")
                else
                    love.graphics.setFont(font40)
                    love.graphics.printf(races[racePage*4+i].Name, xPos, yPos-font40:getHeight()/2+lHeight/2, lWidth, "center")
                end
            end
        end
    elseif page == 2 then
        local lHeight = 23*4
        local lWidth = 53*4
        local xPos, yPos = 0, 0

        love.graphics.setFont(font40)
        love.graphics.draw(classIMG, 0, 0, 0, 4)

        if box(x, y, 172*4, 30*4, lWidth, lHeight) then
            labels[2].text = classes[1].Lore
        elseif box(x, y, 232*4, 30*4, lWidth, lHeight) then
            labels[2].text = classes[2].Lore
        end

        xPos, yPos = 172*4, 30*4
        if class == 1 then
            love.graphics.draw(selectedIMG, xPos, yPos, 0, 4)
        end
        love.graphics.printf(classes[1].Name, xPos, yPos-font40:getHeight()/2+lHeight/2, lWidth, "center")
        xPos, yPos = 232*4, 30*4
        if class == 2 then
            love.graphics.draw(selectedIMG, xPos, yPos, 0, 4)
        end
        love.graphics.printf(classes[2].Name, xPos, yPos-font40:getHeight()/2+lHeight/2, lWidth, "center")
    end

    if class ~= 0 and race ~= 0 and #labels[1].text > 2 then
        love.graphics.draw(doneIMG, 0, 0, 0, 4)
    end

    drawLabel(2, "", font)
    labels[2].text = ""
    drawLabel(1, "Name", font40)
end

function newChar:mousepressed(x, y, b)
    if page == 1 then
        local lHeight = 23*4
        local lWidth = 53*4
        local xPos, yPos = 0, 0

        for i = 1,4 do
            if #races >= racePage*4+i then
                if i == 1 then
                    xPos, yPos = 172*4, 21*4
                elseif i == 2 then
                    xPos, yPos = 232*4, 21*4
                elseif i == 3 then
                    xPos, yPos = 172*4, 52*4
                elseif i == 4 then
                    xPos, yPos = 232*4, 52*4
                end
                if b then
                    if box(x, y, xPos, yPos, lWidth, lHeight) then
                        race = racePage*4+i
                    end
                end
            end
        end
    elseif page == 2 then
        if box(x, y, 172*4, 30*4, 53*4, 23*4) then
            class = 1
        elseif box(x, y, 232*4, 30*4, 53*4, 23*4) then
            class = 2
        end
    end
    if box(x, y, 62*4, 74*4, 59*4, 15*4) then
        page = 1
    elseif box(x, y, 62*4, 92*4, 59*4, 15*4) then
        page = 2
    elseif box(x, y, 246*4, 5*4, 25*4, 12*4) then
        racePage = racePage + 1
        if not (#races >= racePage*4) then
            racePage = 0 
        end
    elseif box(x, y, 186*4, 5*4, 25*4, 12*4) then
        racePage = racePage - 1
        if racePage == -1 then
            repeat
                racePage = racePage + 1
            until not (#races >= racePage*4)
            racePage = racePage - 1
        end
    end
    
    if class ~= 0 and race ~= 0 and #labels[1].text > 2 then
        if box(x, y, 62*4, 114*4, 59*4, 15*4) then
            serverID:send(json.encode({
                type = "newChar",
                charNr = editAccount,
                name = labels[1].text,
                class = classes[class].Name,
                race = races[race].Name
            }))
            St8.remove(newChar)
            St8.resume()
            editAccount = nil
            resetLable()
            addLabel({text = accountName, x = 40*4, y = 54*4, w = 103*4, h = 15*4, limit = 0, writeable = false, color = {1, 1, 1}})
        end
    end
end

return newChar