enet = require "enet"
json = require "dkjson"

Account = require("serverClasses/Account")
Floor = require("serverClasses/Floor")
Tile = require("serverClasses/Tile")

local host = enet.host_create("0.0.0.0:7777")

local accounts = {}
local monsterList = require "gameData/Monsters/AllMonsters"

local fights = {}

local curID = 1
local curCharID = 1

local floors = 1
local allFloors = {}

local contents, size = love.filesystem.read("map.map")
allFloors = json.decode(contents or "[]")

for floor = 1, floors do
    allFloors[floor] = Floor:new(50)
end

function love.update(dt)
    print(dt)

    local event = host:service(100)
    while event do
        if event.type == "receive" then
            print(event.data)
            local data = json.decode(event.data)
            if data.type == "quit" then
                local account = getAccountByPeer(event.peer)
                if account then
                    account:quit()
                end

            elseif data.type == "login" then
                local found = false
                for _, account in pairs(accounts) do
                    if account.username == data.username then
                        found = true
                        account:login(event, data)
                    end
                end
                if found == false then
                    event.peer:send(json.encode({
                        message = "error",
                        error = "No account with this username"
                    }))
                end

            elseif data.type == "signup" then
                local found = false
                for _, account in pairs(accounts) do
                    print(account.username, _)
                    if account.username == data.username then
                        print("Found")
                        found = true
                    end
                end
                if found == false then
                    local anAccount = Account:new(event, data, curID)
                    if anAccount then
                        table.insert(accounts, anAccount)
                        curID = curID + 1
                    end
                else
                    print("error")
                    event.peer:send(json.encode({
                        message = "error",
                        error = "That name is already taken"
                    }))
                end

            elseif data.type == "loadChar" then
                local account = getAccountByPeer(event.peer)
                if account then
                    account:loadChar(data.charNr)
                end
            elseif data.type == "newChar" then
                local account = getAccountByPeer(event.peer)
                if account then
                    account:newChar(data)
                end
            elseif data.type == "openWithAccount" then
                local account = getAccountByPeer(event.peer)
                if account then
                    if account.chars[data.charNr].name ~= "" then
                        account.openAccount = data.charNr
                        event.peer:send(json.encode({
                            message = "openGame"
                        }))
                    end
                end
            elseif data.type == "sendGlobal" then
                local account = getAccountByPeer(event.peer)
                if account then
                    if data.content ~= "" then
                        for _, account in pairs(accounts) do
                            account.currentUserConnected:send(json.encode({
                                message = "addChat",
                                sender = account:getChar().name,
                                content = data.content
                            }))
                        end
                    end
                end
            elseif data.type == "move" then
                
            end
        end
        event = host:service()
    end
end

function box(x, y, bx, by, bw, bh)
    print(x, y, bx, by, bw, bh)
    if x > bx and x < bx + bw and y > by and y < by + bh then
        return true
    end
    return false
end

function getAccountByPeer(peer)
    for _, account in pairs(accounts) do
        if account.currentUserConnected == peer then
            return account
        end
    end
    return false
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end