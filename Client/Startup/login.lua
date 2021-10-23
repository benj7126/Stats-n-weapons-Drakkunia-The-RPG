local loginScreen = {} 

local errorMessage = ""
local backgroundIMG = love.graphics.newImage("Startup/LoginScreen.png")

resetLable()
addLabel({text = "", x = 40*4, y = 54*4, w = 103*4, h = 15*4, limit = 12, writeable = true, color = {1, 1, 1}})
addLabel({text = "", x = 40*4, y = 74*4, w = 103*4, h = 15*4, limit = 12, writeable = true, color = {1, 1, 1}})
addLabel({text = "", x = 40*4, y = 125*4, w = 103*4, h = 15*4, limit = 0, writeable = false, color = {1, 0, 0}})

function loginScreen:update(dt)
    
end

function loginScreen:draw()
    local x, y = love.mouse.getPosition()
    local b1 = love.mouse.isDown(1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)

    drawLabel(1, "Username", font40)
    drawLabel(2, "Password", font40, "hide")
    drawLabel(3, "", font)
end

function loginScreen:mousepressed(x, y, b)
    if box(x, y, 96*4, 100*4, 47*4, 15*4) then
        if b == 1 then
            serverID:send(json.encode({
                type = "signup",
                username = labels[1].text,
                password = labels[2].text
            }))
        end
    elseif box(x, y, 40*4, 100*4, 47*4, 15*4) then
        if b == 1 then
            serverID:send(json.encode({
                type = "login",
                username = labels[1].text,
                password = labels[2].text
            }))
        end
    end
end

--overideFuction
function onReceive(data)
    print(data.message)
    if data.message == "login" then
        account = data.id
        accountName = labels[1].text
        St8.push(require"Startup.account")
        St8.remove(loginScreen)
    elseif data.message == "error" then
        labels[3].text = data.error
    end
end

return loginScreen