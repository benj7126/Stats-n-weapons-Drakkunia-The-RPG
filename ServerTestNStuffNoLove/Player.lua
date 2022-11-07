local NextID = 1
local Entity = require "Entity"
local Player = Entity:new()

function Player:new(name, race, class)
    local player = {}

    player.name = name
    player.class = class
    Player.race = race

    player.tags = {race, class}

    player.id = NextID
    NextID = NextID + 1
    
    setmetatable(player, self)
    self.__index = self

    return player
end

return Player