local Race = require("UI.Element"):new()

local button = require("UI.UIElements.UtilityElements.Button")
local tbutton = require("UI.UIElements.UtilityElements.ButtonWithText")
local label = require("UI.UIElements.UtilityElements.Label")
local img = love.graphics.newImage("gameData/ImageAssets/RaceCharCreate.png")

function Race:load()
    
end

function Race:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 0, 0, 0, 4, 4)
end

return Race