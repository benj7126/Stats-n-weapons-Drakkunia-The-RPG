local account = {} 

local accounts = {
    {},
    {},
    {}
}

local backgroundIMG = love.graphics.newImage("Startup/Chars.png")
resetLable()
addLabel({text = accountName, x = 40*4, y = 54*4, w = 103*4, h = 15*4, limit = 0, writeable = false, color = {1, 1, 1}})

function account:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)

    love.graphics.setFont(font20)

    for i, v in ipairs(accounts) do
        if v.name ~= nil then
            if v.name == "" then
                love.graphics.printf("Create", 172*4, 21*4+(i-1)*37*4+font20:getHeight()/2, 113*4, "center")
            else
                print(v)
                for i2, v2 in pairs(v) do
                    print(i2, v2)
                end
                love.graphics.printf(v.name, 172*4, 21*4+(i-1)*37*4+font20:getHeight()/2, 113*4, "center")
                love.graphics.printf(v.level, 172*4, 33*4+(i-1)*37*4+font20:getHeight()/2, 113*4, "center")
            end
        else
            love.graphics.printf("Load", 172*4, 21*4+(i-1)*37*4+font20:getHeight()/2, 113*4, "center")
        end
    end

    drawLabel(1, "", font40)
end

function account:mousepressed(x, y, b)
    for i, v in ipairs(accounts) do
        if box(x, y, 172*4, 21*4+(i-1)*37*4, 113*4, 23*4) then
            if b == 1 then
                if v.name ~= nil then
                    if v.name == "" then
                        accounts = {
                            {},
                            {},
                            {}
                        }
                        editAccount = i
                        St8.pause(require"Startup.newChar")
                    else
                        serverID:send(json.encode({
                            type = "openWithAccount",
                            charNr = i
                        }))
                    end
                else
                    serverID:send(json.encode({
                        type = "loadChar",
                        charNr = i
                    }))
                end
            end
        end
    end
end

--overideFuction
function onReceive(data)
    if data.message == "loadPlayer" then
        accounts[data.charNr] = {name = data.name, class = data.class, race = data.races, level = data.level}
    elseif data.message == "openGame" then
        St8.remove(account)
        St8.push(require"MainGame")
        serverID:send(json.encode({
            type = "move",
            dir = 0
        }))
    end
end

return account