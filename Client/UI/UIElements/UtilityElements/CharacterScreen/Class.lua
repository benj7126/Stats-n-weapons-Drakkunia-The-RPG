local Class = require("UI.Element"):new()

local button = require("UI.UIElements.UtilityElements.Account.AccountButton")
local label = require("UI.UIElements.UtilityElements.Label")
local img = love.graphics.newImage("gameData/ImageAssets/ClassCharCreate.png")

function Class:load()
    
end

function Class:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 0, 0, 0, 4, 4)
end

return Class