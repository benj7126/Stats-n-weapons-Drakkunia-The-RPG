enet = require "enet"
json = require "dkjson"

Account = require("serverClasses/Account")
Floor = require("serverClasses/Floor")
Tile = require("serverClasses/Tile")
Fight = require("serverClasses/Fight")

local host = enet.host_create("0.0.0.0:7777")

local monsterList = require "gameData/Monsters/AllMonsters"

local curID = 1
local curCharID = 1

local floors = 1
local allFloors = {}

local contents, size = love.filesystem.read("map.map")
allFloors = json.decode(contents or "[]")
fights = {}
accounts = {}

for floor = 1, floors do
    allFloors[floor] = Floor:new(50, floor)
end

function love.update(dt)

    for _, fight in pairs(fights) do
        fight:updateFight()
    end

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
                for _, accountLoop in pairs(accounts) do
                    if accountLoop.username == data.username then
                        found = true
                        accountLoop:login(event, data)
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
                for _, accountLoop in pairs(accounts) do
                    print(accountLoop.username, _)
                    if accountLoop.username == data.username then
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
                        for _, accountLoop in pairs(accounts) do
                            accountLoop:send(json.encode({
                                message = "addChat",
                                sender = account:getChar().name,
                                content = data.content
                            }))
                        end
                    end
                end
            elseif data.type == "move" then
                local account = getAccountByPeer(event.peer)
                if account then
                    local char = account:getChar()
                    if char and char.inCombat == false then
                        local move = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
                        local floor = char.pos.floor

                        if data.dir ~= 0 and data.dir ~= -1 then
                            local tile = allFloors[floor]:getTile(char.pos.x+move[data.dir][1], char.pos.y+move[data.dir][2])
                            if tile then
                                if tile.passable then
                                    local tileStand = allFloors[floor]:getTile(char.pos.x, char.pos.y)
                                    for i, charFromTile in pairs(tileStand.plrsOnTile) do
                                        if account:getCharId() == charFromTile then
                                            table.remove(tileStand.plrsOnTile, i)
                                        end
                                    end
                                    table.insert(tile.plrsOnTile, account:getCharId())
                                    char.pos.x = char.pos.x+move[data.dir][1]
                                    char.pos.y = char.pos.y+move[data.dir][2]
                                    tile:enter(account:getCharId())
                                end
                            end
                        end

                        local TilesToSend = {}

                        for x = -4, 4 do
                            for y = -4, 4 do
                                local tile = allFloors[floor]:getTile(char.pos.x+x, char.pos.y+y)
                                if tile then
                                    table.insert(TilesToSend, {x=char.pos.x+x, y=char.pos.y+y, tile=tile})
                                    if data.dir ~= 0 and data.dir ~= -1 then
                                        for _, player in pairs(tile.plrsOnTile) do
                                            local strSplit = split(player, "-")
                                            local accountSendTo = AccountByID(strSplit[1])
                                            if accountSendTo then
                                                if accountSendTo.currentUserConnected and tonumber(accountSendTo.currentChar) == tonumber(strSplit[2]) and account.id ~= accountSendTo.id then
                                                    accountSendTo:send(json.encode({
                                                        message = "updateMove"
                                                    }))
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        account:send(json.encode({
                            message = "move",
                            tiles = TilesToSend,
                            pos = {x=char.pos.x, y=char.pos.y}
                        }))
                    end
                end
            end
        end
        event = host:service()
    end
end

function AccountByID(id)
    for _,accountLoop in pairs(accounts) do
        if tonumber(accountLoop.id) == tonumber(id) then
            return accountLoop
        end
    end
    return nil
end

function CharByID(id)
    local strSplit = split(player, "-")
    local account = AccountByID(strSplit[1])
    local char = account.chars[strSplit[2]]
    return char
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function box(x, y, bx, by, bw, bh)
    print(x, y, bx, by, bw, bh)
    if x > bx and x < bx + bw and y > by and y < by + bh then
        return true
    end
    return false
end

function getAccountByPeer(peer)
    for _, accountLoop in pairs(accounts) do
        if accountLoop.currentUserConnected == peer then
            return accountLoop
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