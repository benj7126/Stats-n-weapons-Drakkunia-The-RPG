enet = require "enet"
json = require "dkjson"

Account = require("serverClasses/Account")

host = enet.host_create("0.0.0.0:7777")

accounts = {}
monsterList = require "gameData/Monsters/AllMonsters"

fights = {}

curID = 1
curCharID = 1

floors = 1

contents, size = love.filesystem.read("map.map")
map = json.decode(contents or "[]")

if #map == 0 then
    for floor = 1, floors do
        map[floor] = {}
        for x = -50, 50 do
            map[floor][x] = {}
            for y = -50, 50 do
                map[floor][x][y] = {
                    battleID = 0, -- will be assigned when a battle stats so folks can join
                    battleActive = false, -- set to true when battle starts
                    imageID = 1, -- only important for client, cuz... who need the server to show the map..?
                    npc = 0, -- if there should be an npc, like maby an shop or a quest or anything along the lines...
                    monsters = {}, -- for the 1-3 monsters when the battle starts
                    questItemsOnEnter = {} -- idea is to use this for quests, like, generate the quest when the npc gets generated
                    --fx go get my family ring, and then you get a ring if you enter, only if you have the quest thou. could also be something like, draw a map.
                }
                if math.random(1, 5) == 1 then
                    for i = 1,math.random(1, 3) do
                        table.insert(map[floor][x][y].monsters, 1)
                    end
                end
            end
        end
    end
end

map[1][0][0].monsters = {}

print(host)

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