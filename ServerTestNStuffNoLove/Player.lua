local Entity = require "Entity"
local Player = Entity:new()

function Player:new()
    local player = {}
    
    setmetatable(player, self)
    self.__index = self

    return player
end

return Player