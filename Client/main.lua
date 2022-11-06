Enet = require "enet"
Json = require "dkjson"
UIManager = require("UI.UIManager"):new()
LocalPlayer = require("playerClass"):new()

local host = Enet.host_create()
Server = host:connect("localhost:7777")

W, H = 1200, 600
local activeW, activeH = love.graphics.getWidth(), love.graphics.getHeight()

love.graphics.setDefaultFilter("nearest", "nearest")

local monsterList = require "gameData/Monsters/AllMonsters"
Monsters = {}
for i = 1, #monsterList do
    Monsters[i] = require("gameData/Monsters/"..monsterList[i].."/Info")
    Monsters[i].name = monsterList[i]
    Monsters[i].image = love.graphics.newImage("gameData/Monsters/"..monsterList[i].."/Icon.png")
end

UIManager:append(require("UI.UIElements.LoginScreen"):new())

function love.resize(w, h)
    activeW, activeH = w, h
end

function love.load()
    love.keyboard.setKeyRepeat(true)
end

function love.update(dt)
    local event = host:service() --host:service(100)
    while event do
        if event.type == "receive" then
            local data = Json.decode(event.data)
            print(event.data)

            if data.message == "kick" then
                love.event.quit()
            else
                UIManager:GlobalDataFull(data)
            end
        end
        event = host:service()
    end

    UIManager:update(dt)
end

function love.draw()
    FixScale()

    love.graphics.stencil(function ()
        love.graphics.rectangle("fill", 0, 0, W, H)
    end, "replace", 1)

    love.graphics.setStencilTest("greater", 0)

    UIManager:draw() -- do the main draw thing

    love.graphics.setStencilTest()
end

function FixScale()
    local wScale = activeW/W
    local hScale = activeH/H

    local wRest = 0
    local hRest = 0

    if wScale > hScale then
        wRest = wScale - hScale
        wScale = hScale
    else
        hRest = hScale - wScale
        hScale = wScale
    end

    love.graphics.translate(W*wRest/2, H*hRest/2)
    love.graphics.scale(wScale, hScale)
end

function onReceive(data)
    
end

function love.textinput(t)
    UIManager:textinput(t)
end

function love.keypressed(key)
    if key == "f11" then
        local bool = love.window.getFullscreen()
        
        love.window.setFullscreen(not bool)

        if bool then
            love.resize(love.graphics.getWidth(), love.graphics.getHeight()) -- only when it goes out of fullscreen, because it dosent call it automatically
        end
    end
    UIManager:keypressed(key)
end

function love.keyreleased(key)
    UIManager:keyreleased(key)
end

function love.mousepressed(x, y, b)
    x, y = GetScaledMousePosition()
    UIManager:mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
    x, y = GetScaledMousePosition()
    UIManager:mousereleased(x, y, b)
end

function love.quit()
    if Server then
        Server:send(Json.encode({
            type = "quit"
        }))
    end
end

function GetScaledMousePosition()
    local wScale = activeW/W
    local hScale = activeH/H

    local wRest = 0
    local hRest = 0

    if wScale > hScale then
        wRest = wScale - hScale
        wScale = hScale
    else
        hRest = hScale - wScale
        hScale = wScale
    end

    -- love.graphics.translate(, H*hRest/2)
    -- love.graphics.scale(wScale, hScale)

    local x, y = love.mouse.getPosition()

    x, y = x-W*wRest/2, y-H*hRest/2
    x, y = x/wScale, y/hScale

    return x, y
end

function Box(x, y, bx, by, bw, bh)
    if x > bx and x < bx + bw and y > by and y < by + bh then
        return true
    end
    return false
end

Fonts = {
    ["Default"] = {[12] = love.graphics.getFont()},
}

function GetFont(fontName, size)
    if fontName == "" or fontName == nil then
        fontName = "Default"
    end
    if size == nil then
        size = 12
    end

    if Fonts[fontName] then
        if Fonts[fontName][size] then
            return Fonts[fontName][size]
        else
            if fontName == "Default" then
                Fonts[fontName][size] = love.graphics.newFont(size)
            else
                Fonts[fontName][size] = love.graphics.newFont(fontName..".oft", size)
            end

            return Fonts[fontName][size]
        end
    else
        Fonts[fontName] = {}

        if fontName == "Default" then
            Fonts[fontName][size] = love.graphics.newFont(size)
        else
            Fonts[fontName][size] = love.graphics.newFont(fontName..".oft", size)
        end

        return Fonts[fontName][size]
    end
end