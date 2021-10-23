local chat = {}

local chatIMG = love.graphics.newImage("gameData/Chat.png")

local availibleKeys = "abcdefghijklmnopqrstuvxyzw1234567890- .,'"
local availibleKeysBig = 'ABCDEFGHIJKLMNOPQRSTUVXYZW!"####/()=_ :;*'
local ShiftActive = false
local Deleting = false


local lifeQuialityDel = 0
local lifeQuialityDelSpeed = 0

function chat:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(chatIMG, 0, 0, 0, 4)

    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0)
    local h = math.floor(font:getWidth(chatText.."h")/(32*4))
    if h == 2 then
        local found = false
        for i = #chatText, 1, -1 do
            if string.sub(chatText, i, i) == " " then
                found = true
                table.insert(textArchive, string.sub(chatText, 1, i))
                chatText = string.sub(chatText, i+1, #chatText)
                break
            end
        end
        if not found then
            table.insert(textArchive, chatText)
            chatText = ""
        end
    end
    if selectedChat then
        love.graphics.printf(chatText.."|", 8*4, 129*4, 32*4, "left")
    else
        love.graphics.printf(chatText, 8*4, 129*4, 32*4, "left")
    end
    love.graphics.printf("x"..#textArchive, 8*4, 124*4, 32*4, "left")

    --DrawChat

    local yPos = 115*4
    local xPos = 7*4
    local width = 47*4
    local tHeight = font:getHeight()
    local tHeight20 = font20:getHeight()

    for i = #theChat, 1, -1 do
        love.graphics.setFont(font)
        local curMSG = theChat[i]
        local h = math.floor(font:getWidth(curMSG[2])/width)

        yPos = yPos - tHeight*(h+1)
        love.graphics.printf(curMSG[2], xPos, yPos, width, "left")

        love.graphics.setFont(font20)
        yPos = yPos - 0 - tHeight20 -- 0 cuz i dont know if i need space :/
        love.graphics.printf(curMSG[1], xPos, yPos, width, "left")
        yPos = yPos - 10
    end
    love.graphics.rectangle("fill", 7*4, 0, 47*4, 2)
end

function chat:update(dt)
    print(chatText)
    if Deleting then
        lifeQuialityDel = lifeQuialityDel - dt
        if lifeQuialityDel <= 0 then
            chatText = string.sub(chatText, 1, #chatText-1)
            lifeQuialityDel = lifeQuialityDelSpeed
            lifeQuialityDelSpeed = lifeQuialityDelSpeed*0.9
            if #chatText == 0 then
                if #textArchive ~= 0 then
                    chatText = textArchive[#textArchive]
                    chatText = string.sub(chatText, 1, #chatText-1)
                    table.remove(textArchive, #textArchive)
                end
            end
        end
    end
end

function chat.send()
    if chatText ~= "" then
        local contentToSend = ""
        for i, v in pairs(textArchive) do
            contentToSend = contentToSend..v
        end
        contentToSend = contentToSend .. chatText
        serverID:send(json.encode({
            type = "sendGlobal",
            content = contentToSend
        }))
        chatText = ""
        textArchive = {}
    end
end

function chat:keypressed(key)
    if key == "space" then key = " " end
    if selectedChat == false then
        -- if key == "t" then
        --     print("t a")
        --     St8.remove(chat)
        --     OpenChat = not OpenChat
        -- end
    else
        if key == "lshift" then
            ShiftActive = true
        elseif key == "backspace" then
            chatText = string.sub(chatText, 1, #chatText-1)
            Deleting = true

            lifeQuialityDel = 0.3
            lifeQuialityDelSpeed = lifeQuialityDel
            if #chatText == 0 then
                if #textArchive ~= 0 then
                    chatText = textArchive[#textArchive]
                    chatText = string.sub(chatText, 1, #chatText-1)
                    table.remove(textArchive, #textArchive)
                end
            end
        elseif key == "return" then
            chat.send()
        end
        for i = 1,#availibleKeys do
            if key == string.sub(availibleKeys, i, i) then
                if ShiftActive == false then
                    chatText = chatText..string.sub(availibleKeys, i, i)
                else
                    chatText = chatText..string.sub(availibleKeysBig, i, i)
                end
            end
        end
    end
end

function chat:keyreleased(key)
    if key == "lshift" then
        ShiftActive = false
    elseif key == "backspace" then
        Deleting = false
    end
end

function chat:mousepressed(x, y, b)
    if b == 1 then
        if box(x, y, 8*4, 129*4, 32*4, 13*4) then
            selectedChat = true
        else
            selectedChat = false
        end
    end
    if b == 1 then
        if box(x, y, 43*4, 130*4, 11*4, 11*4) then
            chat.send()
        end
    end
end

return chat