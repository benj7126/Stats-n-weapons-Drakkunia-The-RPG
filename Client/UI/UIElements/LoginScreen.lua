local LoginScreen = require("UI.Element"):new()

local button = require("UI.UIElements.UtilityElements.Button")
local label = require("UI.UIElements.UtilityElements.Label")
local img = love.graphics.newImage("gameData/ImageAssets/LoginScreen.png")

function LoginScreen:load()
    local user = label:new(self, 40, 54, 104, 16, "left", 10)
    user.default = "Username"
    local pass = label:new(self, 40, 74, 104, 16, "left", 10)
    pass.default = "Password"

    local login = button:new(self, 40, 100, 48, 16)
    local create = button:new(self, 96, 100, 48, 16)

    table.insert(login.onClick, function ()
        Server:send(Json.encode({
            type = "login",
            username = user.text,
            password = pass.text
        }))
    end)

    table.insert(create.onClick, function ()
        Server:send(Json.encode({
            type = "signup",
            username = user.text,
            password = pass.text
        }))
    end)

    self:append(user)
    self:append(pass)

    self:append(login)
    self:append(create)
end

function LoginScreen:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 0, 0, 0, 4, 4)
end

function LoginScreen:GlobalData(d)
    if d.message == "login" then
        LocalPlayer.account = d.id
        LocalPlayer.accountName = d.name

        UIManager:remove(self)
        UIManager:append(require("UI.UIElements.AccountScreen"):new())
    end
end

return LoginScreen