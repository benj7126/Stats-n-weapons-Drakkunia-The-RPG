enet = require "enet"
json = require "dkjson"

host = enet.host_create("0.0.0.0:7777")

accounts = {}

activeChar = {}

monsterList = require "gameData/Monsters/AllMonsters"

fights = {}

curID = 1
curCharID = 1
charIndex = 1

contents, size = love.filesystem.read("map.map")
map = json.decode(contents or "[]")

if #map == 0 then
    for x = -50, 50 do
        map[x] = {}
        for y = -50, 50 do
            map[x][y] = {
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
                    table.insert(map[x][y].monsters, 1)
                end
            end
        end
    end
end

map[0][0].monsters = {}

curConnections = {}

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

    --print("ConnectedPeers")
    for i, v in pairs(curConnections) do
        v.actionTimer = v.actionTimer + dt
        --print(v.peer, math.ceil(v.actionTimer*10)/10)

        if v.actionTimer > 1800 then
            --print("Removing "..tostring(v).." at pos "..i.." timeout")
            local accountThing
            for i2, v2 in pairs(accounts) do
                if v2.id == v.accountID then
                    accountThing = v2
                end
            end
            if accountThing then
                if accountThing.openAccount ~= 0 then
                    for i2, v2 in pairs(activeChar) do
                        if v2[1] == accountThing.id then
                            table.remove(activeChar, i2)
                        end
                    end
                end
            end
            v.peer:send(json.encode({
                message = "kick"
            }))
            table.remove(curConnections, i)
        end
    end
    --print("\nOnline chars")

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
            local curPeer
            local account
            local char
            for i, v in pairs(curConnections) do
                if v.peer == event.peer then
                    curPeer = v
                    v.actionTimer = 0
                    for i2, v2 in pairs(accounts) do
                        if v2.id == v.accountID then
                            account = v2
                        end
                    end
                end
            end
            if account then
                if account.openAccount ~= 0 then
                    for i2, v2 in pairs(activeChar) do
                        if v2[1] == account.id then
                            char = account.plrs[v2[2]]
                        end
                    end
                end
            end

            if curPeer then
                print("foundPeer", curPeer.accountID)
            end

            print(event.data)
            local data = json.decode(event.data)
            if data.type == "quit" then
                for i, v in pairs(curConnections) do
                    if v.peer == event.peer then
                        print("Removing "..tostring(v).." at pos "..i)
                        if account then
                            if account.openAccount ~= 0 then
                                for i2, v2 in pairs(activeChar) do
                                    if v2[1] == account.id then
                                        table.remove(activeChar, i2)
                                    end
                                end
                            end
                        end
                        table.remove(curConnections, i)
                    end
                end
            elseif data.type == "login" then
                local found = false
                for i, v in pairs(accounts) do
                    if v.username == data.username then
                        found = true
                        if v.password == data.password then
                            for i2, v2 in pairs(curConnections) do
                                if v2.accountID == v.id then
                                    print("Removing "..tostring(v2).." at pos "..i2.." login override")
                                    local accountThing

                                    for i3, v3 in pairs(accounts) do
                                        if v3.id == v2.accountID then
                                            accountThing = v3
                                        end
                                    end
                                    
                                    if accountThing then
                                        if accountThing.openAccount ~= 0 then
                                            for i3, v3 in pairs(activeChar) do
                                                if v3[1] == accountThing.id then
                                                    table.remove(activeChar, i3)
                                                end
                                            end
                                        end
                                    end
                                    v2.peer:send(json.encode({
                                        message = "kick"
                                    }))
                                    table.remove(curConnections, i2)
                                end
                            end
                            event.peer:send(json.encode({
                                message = "login",
                                id = v.id
                            }))
                            curPeer.accountID = v.id
                        else
                            event.peer:send(json.encode({
                                message = "error",
                                error = "Wrong password"
                            }))
                        end
                    end
                end
                if found == false then
                    event.peer:send(json.encode({
                        message = "error",
                        error = "No account with this username"
                    }))
                end
            elseif data.type == "signup" then
                local pass = true

                if #data.username < 4 then
                    pass = false
                    event.peer:send(json.encode({
                        message = "error",
                        error = "Username minimum 4 characters long"
                    }))
                elseif #data.password < 4 then
                    pass = false
                    event.peer:send(json.encode({
                        message = "error",
                        error = "Password minimum 4 characters long"
                    }))
                end
                
                if pass then
                    local found = false
                    for i, v in pairs(accounts) do
                        if v.username == data.username then
                            found = true
                        end
                    end
                    if found == false then
                        table.insert(accounts, {username = data.username, openAccount = 0, password = data.password, id = curID, plrs = {
                            {name = ""},
                            {name = ""},
                            {name = ""}
                        }})
                        event.peer:send(json.encode({
                            message = "login",
                            id = curID
                        }))
                        curPeer.accountID = curID

                        curID = curID + 1
                    else
                        event.peer:send(json.encode({
                            message = "error",
                            error = "Name already taken m8, 2 bad..."
                        }))
                    end
                end
            elseif data.type == "loadChar" then
                event.peer:send(json.encode({
                    message = "loadPlayer",
                    charNr = data.charNr,
                    name = account.plrs[data.charNr].name,
                    class = account.plrs[data.charNr].class,
                    race = account.plrs[data.charNr].race,
                    level = account.plrs[data.charNr].level
                }))
            elseif data.type == "newChar" then
                print(data.name)
                account.plrs[data.accountNr] = {
                    name = data.name,
                    class = data.class,
                    race = data.race,
                    stats = require("gameData/Races/"..data.race.."/raceStats").StartingStats,

                    hp = 0,
                    mp = 0,
                    stamina = 0,
                    xp = 0,
                    level = 0, -- use this to indicate if this is first launch (and therefore set it to 1 on launch, and alos update hp, mp, stamina to their max versions)

                    id = curCharID,
                    accountForPlrID = account.id,
                    pos = {
                        x = 0,
                        y = 0,
                        floor = 0
                    },

                    inCombat = false,

                    skills = {},
                    inv = {},
                    equipped = {
                        mainHand = 0,
                        offHand = 0,
                        chest = 0,
                        trousers = 0,
                        accessory1 = 0,
                        accessory2 = 0
                    }
                }
                curCharID = curCharID + 1
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
                if data.content ~= "" then
                    if char then
                        for i, v in pairs(curConnections) do
                            v.peer:send(json.encode({
                                message = "addChat",
                                sender = char.name,
                                content = data.content
                            }))
                        end
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
        elseif event.type == "connect" then
            table.insert(curConnections, {peer = event.peer, accountID = 0, actionTimer = 0})
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