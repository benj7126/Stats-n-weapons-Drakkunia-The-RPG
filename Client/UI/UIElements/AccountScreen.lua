local AccountScreen = require("UI.Element"):new()

local button = require("UI.UIElements.UtilityElements.Account.AccountButton")
local label = require("UI.UIElements.UtilityElements.Label")
local img = love.graphics.newImage("gameData/ImageAssets/AccountScreen.png")

function AccountScreen:load()
    local name = label:new(self, 40, 54, 103, 15, "center", nil, false)
    name.text = LocalPlayer.accountName

    self:append(name)
    
    local b = button:new(self, 172, 21)
    b.id = 1
    self:append(b)
    b = button:new(self, 172, 58)
    b.id = 2
    self:append(b)
    b = button:new(self, 172, 95)
    b.id = 3
    self:append(b)
end

function AccountScreen:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 0, 0, 0, 4, 4)
end

function AccountScreen:GlobalData(d)
    if d.message == "openGame" then
        -- St8.remove(account)
        -- St8.push(require"MainGame")
        Server:send(json.encode({
            type = "move",
            dir = 0
        }))
    end
end

return AccountScreen