local Fight = {}

function Fight:new(charID, monsterList, tileID)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.plrsInFight = {charID}
    o.tileID = tileID

    o.fightBoard = {
        {nil, nil, nil,
        nil, nil, nil,
        nil, charID, nil}
    }
    
    if monsterList[1] then
        o.fightBoard[1][2] = monsterList[1]
    end
    if monsterList[2] then
        o.fightBoard[1][1] = monsterList[2]
    end
    if monsterList[3] then
        o.fightBoard[1][3] = monsterList[3]
    end
    CharByID(charID).stamina = 0
    return o
end

function Fight:addPlr(charID)
    if #self.plrsInFight ~= 3 then
        local placed = false
        for i = 4, 9 do
            if self.fightBoard[i] == nil then
                self.fightBoard[i] = charID
                placed = true
                break
            end
        end
        if placed then
            table.insert(self.plrsInFight, charID)
            return true
        end
    end
    return false
end

function Fight:updateFight(dt)
    for _,charID in pairs(self.plrsInFight) do
        print("sendTo: "..charID)
        local strSplit = split(charID, "-")
        local acc = AccountByID(strSplit[1])
        local char = acc.chars[strSplit[2]]
        char.hp = math.min(char.hp+char.hpRegen, char.maxHp)
        char.mp = math.min(char.mp+char.mpRegen, char.maxHp)
        char.stamina = math.min(char.stamina+char.staminaRegen, char.maxStamina)
        acc:send(json.encode({
            message = "updateFight",
            fightData = self.fightBoard,
            selfStats = {char.hp, char.mp, char.stamina, char.xp, char.maxHp, char.maxMp, char.maxStamina, char.level}
        }))
    end
end

return Fight