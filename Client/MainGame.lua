local MainGame = {}

OpenChat = false
OpenParty = false
local backgroundIMG = love.graphics.newImage("GameBackScreen.png")
chatText = ""
theChat = {}
plrsLastPos = {}
party = {}
textArchive = {}
selectedChat = false
plrPos = {0, 0}
blockSize = 32

contents, size = love.filesystem.read("map.map")
map = json.decode(contents or "[]")

if #map == 0 then
    for x = -50, 50 do
        map[x] = {}
        for y = -50, 50 do
            map[x][y] = {
                battleActive = false,
                imageID = 0, -- only important for client, cuz... who need the server to show the map..?
                npc = 0, -- if there should be an npc, like maby an shop or a quest or anything along the lines...
                monsters = {} -- for the 1-3 monsters when the battle starts
            }
        end
    end
end

xPosP, yPosP = w/2, h/4

function MainGame:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundIMG, 0, 0, 0, 4)
    
    for x = -10, 10 do
        for y = -10, 10 do
            if map[plrPos[1]+x][plrPos[2]+y].imageID ~= 0 then
                local xP, yP = x*blockSize+w/2-blockSize/2, y*blockSize+h/2-blockSize/2
                love.graphics.setColor(1, 1, 1)
                if #map[plrPos[1]+x][plrPos[2]+y].monsters > 0 then
                    love.graphics.setColor(1, 0, 0)
                end
                if map[plrPos[1]+x][plrPos[2]+y].battleActive == true then
                    love.graphics.setColor(0, 1, 0)
                end
                love.graphics.rectangle("fill", xP, yP, blockSize, blockSize)
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("line", xP, yP, blockSize, blockSize)
            else
                local xP, yP = x*blockSize+w/2-blockSize/2, y*blockSize+h/2-blockSize/2
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("fill", xP, yP, blockSize, blockSize)
            end
        end
    end

    love.graphics.setColor(0, 0, 0)
    for i, v in pairs(plrsLastPos) do
        love.graphics.circle("fill", (v.pos.x-plrPos[1])*blockSize+w/2, (v.pos.y-plrPos[2])*blockSize+h/2, 10)
        print(v.name, v.pos.x, v.pos.y)
    end

    
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", w/2, h/2, 10)
    love.graphics.setColor(0, 0.8, 0)
    love.graphics.rectangle("line", w/2-blockSize*4.5, h/2-blockSize*4.5, blockSize*9, blockSize*9)
end

function MainGame:keypressed(key)
    if key == "t" and selectedChat == false then
        if not OpenChat then
            St8.push(require"gameData.Chat")
            OpenChat = true
        else
            St8.remove(require"gameData.Chat")
            OpenChat = false
        end
    elseif key == "p" then
        if not OpenParty and selectedChat == false then
            St8.push(require"gameData.Party")
            OpenParty = true
        else
            St8.remove(require"gameData.Party")
            OpenParty = false
        end
    end
    if selectedChat == false then
        if key == "w" then
            serverID:send(json.encode({
                type = "move",
                dir = 1
            }))
        elseif key == "d" then
            serverID:send(json.encode({
                type = "move",
                dir = 2
            }))
        elseif key == "s" then
            serverID:send(json.encode({
                type = "move",
                dir = 3
            }))
        elseif key == "a" then
            serverID:send(json.encode({
                type = "move",
                dir = 4
            }))
        end
    end
end
function onReceive(data)
    if data.message == "addChat" then
        table.insert(theChat, {data.sender, data.content})
        if #theChat > 20 then
            table.remove(theChat, 1)
        end
    elseif data.message == "move" then
        for i, v in pairs(data.tiles) do
            map[v.x][v.y] = v.tile
        end
        plrPos[1] = data.pos.x
        plrPos[2] = data.pos.y
        plrsLastPos = data.plrs
    elseif data.message == "updateMove" then
        print("MOVEUPDATEHÆLP")
        serverID:send(json.encode({
            type = "move",
            dir = -1
        }))
    elseif data.message == "fight" then
        St8.push(require"Fight")
    elseif data.message == "updateFight" then
        if updateFight then
            updateFight(data)
        end
    end
end

return MainGame

-- next is party, i pressume :/