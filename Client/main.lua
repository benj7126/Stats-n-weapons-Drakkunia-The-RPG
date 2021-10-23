enet = require "enet"
json = require "dkjson"
St8 = require "st8"

host = enet.host_create()
server = host:connect("localhost:7777")
serverID = nil
doQuit = false

labels = {}
curLabel = 0

accountName = ""

local availibleKeys = "abcdefghijklmnopqrstuvxyzæøå1234567890w-"
local availibleKeysBig = "ABCDEFGHIJKLMNOPQRSTUVXYZÆØÅ1234567890W_"
local ShiftActive = false
local Deleting = false
local blink = 0

accountNr = 0
account = 0 

awaitingHadleFunction = nil

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(1200, 600, {vsync = false})
    St8.hook()
    St8.push(require "Startup.login")
    St8.order("draw", "bottom")
    St8.order("keypressed", "bottom")
    font = love.graphics.getFont()
    font20 = love.graphics.newFont(20)
    font40 = love.graphics.newFont(40)
    font60 = love.graphics.newFont(60)
    w, h = love.graphics.getWidth(), love.graphics.getHeight()
end

function love.update(dt)
    blink = blink + dt
    if blink > 0.4 then
        blink = 0
    end
    if Deleting == true then
        if curLabel ~= 0 then
            labels[curLabel].text = string.sub(labels[curLabel].text, 1, #labels[curLabel].text-1)
        end
    end
    if doQuit then
        love.event.quit()
    end
    event = host:service(100)
    while event do
        if event.type == "receive" then 
            data = json.decode(event.data)
            if data.message == "kick" then
                doQuit = true
            end
            onReceive(data)
        elseif event.type == "connect" then
            serverID = event.peer
        end
        event = host:service()
    end
end

function onReceive(data)
    
end

function box(x, y, bx, by, bw, bh)
    if x > bx and x < bx + bw and y > by and y < by + bh then
        return true
    end
    return false
end

function love.keypressed(key)
    if key == "lshift" then
        ShiftActive = true
    elseif key == "backspace" then
        Deleting = true
    end
    if curLabel ~= 0 then
        if labels[curLabel].limit > #labels[curLabel].text then
            for i = 1,#availibleKeys do
                if key == string.sub(availibleKeys, i, i) then
                    if ShiftActive == false then
                        labels[curLabel].text = labels[curLabel].text..string.sub(availibleKeys, i, i)
                    else
                        labels[curLabel].text = labels[curLabel].text..string.sub(availibleKeysBig, i, i)
                    end
                end
            end
        end
    end
end

function love.keyreleased(key)
    if key == "lshift" then
        ShiftActive = false
    elseif key == "backspace" then
        Deleting = false
    end
end

function resetLable()
    labels = {}
    curLabel = 0
end

function drawLabel(labelID, alternativeTEXT, useFont, addCommand)
    local label = labels[labelID]

    love.graphics.setFont(useFont or font)
    
    local usingFont = love.graphics.getFont()

    love.graphics.setColor(label.color)
    if label.text ~= "" then
        local text = label.text
        if addCommand then
            if addCommand == "hide" then
                textLen = #text
                text = ""
                for i = 1, textLen do
                    text = text.."*"
                end
            end
        end
        if curLabel == labelID then
            text = text.."|"
        end
        love.graphics.printf(text, label.x, label.y-usingFont:getHeight()/2*(math.floor(usingFont:getWidth(text)/label.w)+1)+label.h/2, label.w, "center")
    else
        love.graphics.printf(alternativeTEXT, label.x, label.y-usingFont:getHeight()/2+label.h/2, label.w, "center")
    end

    love.graphics.setFont(font)
end

function love.mousepressed(x, y, b)
    local hit = false
    if b == 1 then
        for i, v in pairs(labels) do
            if v.writeable == true then
                if box (x, y, v.x, v.y, v.w, v.h) then
                    print(i)
                    curLabel = i
                    hit = true
                end
            end
        end
    end
    if hit == false then
        curLabel = 0
    end
end

function addLabel(label)
    table.insert(labels, label)
    return #labels
end

function love.quit()
    if not doQuit then
        serverID:send(json.encode({
            type = "quit"
        }))
        doQuit = true
        return true
    end
end