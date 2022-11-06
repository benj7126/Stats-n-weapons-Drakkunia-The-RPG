local CharacterScreen = require("UI.Element"):new()

local button = require("UI.UIElements.UtilityElements.Button")
local label = require("UI.UIElements.UtilityElements.Label")

local img = love.graphics.newImage("gameData/ImageAssets/CreateChar.png")
local class = require("UI.UIElements.UtilityElements.CharacterScreen.Class"):new()
local race = require("UI.UIElements.UtilityElements.CharacterScreen.Race"):new()
local done = love.graphics.newImage("gameData/ImageAssets/DoneCharCreate.png")

local currentState = ""

function CharacterScreen:load()
    local name = label:new(self, 40, 54, 104, 16, "left", 10)
    name.default = "Name"

    local raceB = button:new(self, 62, 74, 60, 16)
    local classB = button:new(self, 62, 92, 60, 16)

    table.insert(raceB.onClick, function ()
        self:append(race)
        self:remove(class)
    end)

    table.insert(classB.onClick, function ()
        self:append(class)
        self:remove(race)
    end)

    self:append(raceB)
    self:append(classB)

    self:append(name)
end

function CharacterScreen:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(img, 0, 0, 0, 4, 4)

    if currentState == "race" then
        love.graphics.draw(race, 0, 0, 0, 4, 4)
    elseif currentState == "class" then
        love.graphics.draw(class, 0, 0, 0, 4, 4)
    end
end

function CharacterScreen:GlobalData(d)
    
end

return CharacterScreen