
local Player = require "Player"

local NextID = 1

local Account = {
    username = "",
    password = "", -- use sha256 for this (client side)

    players = {}, -- list of player refferences
    id = 0,
}

function Account:new(username, password)
    local account = {}
    
    account.username = username
    account.password = password

    account.id = NextID
    NextID = NextID + 1

    setmetatable(account, self)
    self.__index = self

    return account
end

function Account:CreatePlayer(index, PlayerList, World, name, race, class)
    if index > 0 and index < 4 then
        local player = Player:new(name, race, class)
        PlayerList["id"..player.id] = player
        self.players[index] = player

        player.tile = World.layers[1].grid[0][0]
        World.layers[1].grid[0][0].entities[player] = player
    end
end

return Account