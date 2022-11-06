local Player = {}

function Player:new()
    local player = {}

    player.account = 0; -- the id
    player.accountName = ""; -- the name

    setmetatable(player, self)
    self.__index = self
    return player
end

return Player