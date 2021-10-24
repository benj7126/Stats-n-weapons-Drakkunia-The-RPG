enet = require "enet"
json = require "dkjson"

Account = require("Account")

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
    print("UpdateFights")
    for i = 1,9999 do
        if fights[i] then
            print("Fight with id "..i)
                        
            for i2, v2 in pairs(fights[i].feild) do
                if i2 < 4 then -- on monster side
                    if v2.level ~= nil then -- if there is something there | level is just for some value, dosent matter what val
                        print(v2.staminaRegen, v2.stamina)
                        v2.stamina = v2.stamina + dt*v2.staminaRegen

                        -- simple dumb monster ai :P
                        for _,skill in pairs(v2.skills) do
                            skill.curCooldown = skill.curCooldown + dt
                            if skill.curCooldown > skill.cooldown then
                                if v2.stamina >= skill.staminaCost then
                                    v2.stamina = v2.stamina - skill.staminaCost
                                    local damage = skill.damage(v2:findPlayer(fights[i].feild))
                                    table.insert(fights[i].log, skill.description())
                                end
                            end
                        end
                    end
                else -- is player (in future maby other things)
                    if v2.char then
                        v2.char.peer:send(json.encode({
                            message = "updateFight",
                            feild = fights[i].feild
                        }))
                    end
                end
            end
        end
    end

    for i, v in pairs(activeChar) do
        for i2, v2 in pairs(accounts) do
            if v[1] == v2.id then
                local char = v2.plrs[v[2]]
                --print(char.name)
            end
        end
    end
    --print("----------\n")

    local event = host:service(100)
    while event do
        if event.type == "receive" then
            print(event.data)
            local data = json.decode(event.data)
            if data.type == "quit" then
                local account = getAccountByPeer(event.peer)
                if account then
                    accounts:quit()
                end

            elseif data.type == "login" then
                local found = false
                for i, v in pairs(accounts) do
                    if v.username == data.username then
                        found = true
                        v:login(event, data)
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
                for i, v in pairs(accounts) do
                    if v.username == data.username then
                        found = true
                    end
                end
                if found == false then
                    local anAccount = Account:new(event, data, curID)
                    if anAccount then
                        table.insert(account, anAccount)
                        curID = curID + 1
                    end
                else
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
                if account then
                    if account.plrs[data.charNr].name ~= "" then
                        account.openAccount = data.charNr
                        table.insert(activeChar, {account.id, data.charNr})
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
            elseif data.type == "move" then
                if char then
                    if char.inCombat == false then
                        if data.dir == -1 or data.dir == 0 then
                            tiles = {}
                            for x = -5, 5 do
                                for y = -5, 5 do
                                    if x + char.pos.x < 51 and x + char.pos.x > -51 and y + char.pos.y < 51 and y + char.pos.y > -51 then
                                        table.insert(tiles, {
                                            tile = {
                                                battleActive = map[x + char.pos.x][y + char.pos.y].battleActive,
                                                imageID = map[x + char.pos.x][y + char.pos.y].imageID,
                                                npc = map[x + char.pos.x][y + char.pos.y].npc,
                                                monsters = map[x + char.pos.x][y + char.pos.y].monsters
                                            },
                                            x = x + char.pos.x,
                                            y = y + char.pos.y
                                        })
                                    end
                                end
                            end
                            
                            local plrsSave = {}
                            for _, v in pairs(activeChar) do
                                for _, accountE in pairs(accounts) do
                                    if accountE.id == v[1] and accountE.id ~= account.id then
                                        if accountE.plrs[v[2]].pos.floor == char.pos.floor then
                                            if box(accountE.plrs[v[2]].pos.x, accountE.plrs[v[2]].pos.y, char.pos.x-5, char.pos.y-5, 10, 10) then                                                
                                                print("add to table")
                                                table.insert(plrsSave, {pos = accountE.plrs[v[2]].pos, name = accountE.plrs[v[2]].name, class = accountE.plrs[v[2]].class, race = accountE.plrs[v[2]].race, level = accountE.plrs[v[2]].level})
                                            end
                                        end
                                    end
                                end
                            end
                            event.peer:send(json.encode({
                                message = "move",
                                pos = {
                                    x = char.pos.x,
                                    y = char.pos.y,
                                    floor = char.pos.floor
                                },
                                tiles = tiles,
                                plrs = plrsSave
                            }))
                        else

                            moved = true
                            if data.dir == 1 then
                                if char.pos.y ~= -50 then
                                    char.pos.y = char.pos.y - 1
                                end
                            elseif data.dir == 2 then
                                if char.pos.x ~= 50 then
                                    char.pos.x = char.pos.x + 1
                                end
                            elseif data.dir == 3 then
                                if char.pos.y ~= 50 then
                                    char.pos.y = char.pos.y + 1
                                end
                            elseif data.dir == 4 then
                                if char.pos.x ~= -50 then
                                    char.pos.x = char.pos.x - 1
                                end
                            else
                                moved = false
                            end

                            if moved then
                                if #map[char.pos.x][char.pos.y].monsters ~= 0 then
                                    local found = false
                                    local id = 0
                                    while found == false do
                                        id = love.math.random(1, 9999)
                                        if not fights[id] then
                                            found = true
                                        end
                                    end
                                    map[char.pos.x][char.pos.y].battleActive = true
                                    map[char.pos.x][char.pos.y].battleID = id
                                    fights[id] = {
                                        feild = {
                                            {}, {}, {},
                                            {}, {char = {accountID = char.accountForPlrID, charID = char.id, peer = curPeer.peer}}, {}, 
                                            {}, {}, {}
                                        },
                                        plrsHere = 1,
                                        log = {}
                                    }
                                    for i, v in pairs(map[char.pos.x][char.pos.y].monsters) do
                                        fights[id][i] = require("gameData/Monsters/"..monsterList[v].."/monsterInfo")
                                        fights[id][i].monsterIndex = monsterList[v]
                                        print(fights[id][i].level)
                                    end
                                    char.inCombat = true
                                
                                    event.peer:send(json.encode({
                                        message = "fight"--...
                                    }))
                                end

                                tiles = {}
                                for x = -5, 5 do
                                    for y = -5, 5 do
                                        if x + char.pos.x < 51 and x + char.pos.x > -51 and y + char.pos.y < 51 and y + char.pos.y > -51 then
                                            table.insert(tiles, {
                                                tile = {
                                                    battleActive = map[x + char.pos.x][y + char.pos.y].battleActive,
                                                    imageID = map[x + char.pos.x][y + char.pos.y].imageID,
                                                    npc = map[x + char.pos.x][y + char.pos.y].npc,
                                                    monsters = map[x + char.pos.x][y + char.pos.y].monsters
                                                },
                                                x = x + char.pos.x,
                                                y = y + char.pos.y
                                            })
                                        end
                                    end
                                end

                                local plrsSave = {}
                                
                                for _, v in pairs(activeChar) do
                                    for _, accountE in pairs(accounts) do
                                        if accountE.id == v[1] and accountE.id ~= account.id then
                                            if accountE.plrs[v[2]].pos.floor == char.pos.floor then
                                                if box(accountE.plrs[v[2]].pos.x, accountE.plrs[v[2]].pos.y, char.pos.x-6, char.pos.y-6, 12, 12) then -- might want to change range, dont know (server faster)
                                                    for _, con in pairs(curConnections) do
                                                        if con.accountID == accountE.id then
                                                            print("heMove")
                                                            con.peer:send(json.encode({
                                                                message = "updateMove"
                                                            }))
                                                        end
                                                    end
                                                    
                                                    print("add to table2")
                                                    table.insert(plrsSave, {pos = accountE.plrs[v[2]].pos, name = accountE.plrs[v[2]].name, class = accountE.plrs[v[2]].class, race = accountE.plrs[v[2]].race, level = accountE.plrs[v[2]].level})
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                event.peer:send(json.encode({
                                    message = "move",
                                    pos = {
                                        x = char.pos.x,
                                        y = char.pos.y,
                                        floor = char.pos.floor
                                    },
                                    tiles = tiles,
                                    plrs = plrsSave
                                }))
                            end
                        end
                    end
                end
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