local Account = {}

function Account:new(event, data, id)
    local o = {}   -- create object if user does not provide one

    if #data.username < 5 or #data.password < 5 then
        event.peer:send(json.encode({
            message = "error",
            error = "That name is already taken"
        }))
        return nil
    end

    o.username = data.username
    o.password = data.password
    o.currentChar = 0
    o.id = id
    o.chars = {}
    o.currentUserConnected = event.peer

    setmetatable(o, self)
    self.__index = self
    return o
end

function Account:login(event, data)
    if self.password == data.password then
        self.currentUserConnected:send(json.encode({ -- kick current user
            message = "kick"
        }))

        self.currentUserConnected = event.peer -- and set it to the new one
        
        self.currentUserConnected:send(json.encode({ -- and login
            message = "login",
            id = self.id
        }))
    else
        event.peer:send(json.encode({ -- wrong password
            message = "error",
            error = "Wrong password"
        }))
    end
end

function Account:quit()
    self.currentUserConnected:send(json.encode({ -- kick current user
        message = "kick"
    }))
    self.currentUserConnected = nil
end

function Account:getChar()
    return self.chars[self.currentChar]
end

function Account:loadChar(charNr)
    self.currentChar = charNr
    event.peer:send(json.encode({
        message = "loadPlayer",
        charNr = charNr,
        char = self.chars[charNr]
    }))
end

function Account:newChar(data)
    self.chars[data.accountNr] = {
        name = data.name,
        class = data.class,
        race = data.race,
        stats = require("gameData/Races/"..data.race.."/raceStats").StartingStats,

        hp = 0,
        mp = 0,
        stamina = 0,
        xp = 0,
        level = 0, -- use this to indicate if this is first launch (and therefore set it to 1 on launch, and alos update hp, mp, stamina to their max versions)

        accountForChar = self,
        pos = {
            x = 0,
            y = 0,
            floor = 1
        },

        inCombat = false,

        skills = {}, -- the skill books that you have access to fx {5, 6, 10}
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