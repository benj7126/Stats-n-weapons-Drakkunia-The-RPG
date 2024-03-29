local Account = {}

function Account:new(event, data, id)
    local o = {}

    if #data.username < 4 or #data.password < 4 then
        event.peer:send(json.encode({
            message = "error",
            error = "Password and Username both needs to be at least 4 characters long"
        }))
        return nil
    end

    o.username = data.username
    o.password = data.password
    o.currentChar = 0
    o.id = id
    o.chars = {
        {name = ""},
        {name = ""},
        {name = ""}
    }
    o.currentUserConnected = event.peer

    o.currentUserConnected:send(json.encode({ -- and login
        message = "login",
        id = id,
        name = data.username,
    }))

    setmetatable(o, self)
    self.__index = self
    return o
end

function Account:login(event, data)
    if self.password == data.password then
        if self.currentUserConnected then
            self:send(json.encode({ -- kick current user
                message = "kick"
            }))
        end

        self.currentUserConnected = event.peer -- and set it to the new one
        
        self:send(json.encode({ -- and login
            message = "login",
            id = self.id,
            name = self.username,
        }))
    else
        event.peer:send(json.encode({ -- wrong password
            message = "error",
            error = "Wrong password"
        }))
    end
end

function Account:quit()
    self:send(json.encode({ -- kick current user
        message = "kick"
    }))
    self.currentUserConnected = nil
end

function Account:getCharId()
    return self.id.."-"..self.currentChar
end

function Account:send(data) -- try to send
    if self.currentUserConnected ~= nil then
        self.currentUserConnected:send(data)
        return true
    end
    return false
end

function Account:getChar()
    return self.chars[self.currentChar]
end

function Account:loadChar(charNr)
    self.currentChar = charNr
    self:send(json.encode({
        message = "loadPlayer",
        charNr = charNr,
        char = self:getConvertedChar(charNr)
    }))
    self:send(json.encode({
        message = "updateMove"
    }))
end

function Account:getConvertedChar(charIndex) -- ready for send so it dosent send any userdata
    local char = {}
    for key, value in pairs(self.chars[charIndex]) do
        if key ~= "accountForChar" then
            char[key] = value
        end
    end
    return char
end

function Account:startFight(tileID)
    print("interFIght")
    local char = self:getChar()
    char.combatTileID = tileID
    char.inCombat = true
    self:send(json.encode({
        message = "fight"
    }))

    for _,fight in pairs(fights) do
        if fight.tileID == tileID then
            print("updating fight")
            fight:updateFight() 
        end
    end
end

function Account:newChar(data)
    print(data.charNr)
    self.chars[data.charNr] = {
        name = data.name,
        class = data.class,
        race = data.race,
        stats = require("gameData/Races/"..data.race.."/raceStats").StartingStats,

        hp = 100,
        mp = 100,
        stamina = 0,
        maxHp = 100,
        maxMp = 100,
        maxStamina = 100,
        hpRegen = 0,
        mpRegen = 0,
        staminaRegen = 10,
        xp = 0,
        level = 0, -- use this to indicate if this is first launch (and therefore set it to 1 on launch, and alos update hp, mp, stamina to their max versions)

        accountForChar = self,
        pos = {
            x = 0,
            y = 0,
            floor = 1
        },

        inCombat = false,
        combatTileID = "",

        skills = {}, -- the skill books that you have access to fx {5, 6, 10}
        equippedSkills = {}, -- the skils you have equipped (max 11)
        inv = {}, -- all the items you have fx {152, 31, 52}
        equipped = { -- the items that you currently have equipped for all this stuff...
            mainHand = 0,
            offHand = 0,
            chest = 0,
            trousers = 0,
            accessory1 = 0,
            accessory2 = 0
        }
    }
end

return Account