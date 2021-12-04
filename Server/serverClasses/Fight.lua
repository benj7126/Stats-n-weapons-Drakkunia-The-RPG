local Fight = {}

function Fight:new(charID, monsterList, tileID)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.plrsInFight = {charID}
    o.tileID = tileID

    o.logAdd = {}

    o.fightBoard = {
        nil, nil, nil,
        nil, nil, nil,
        nil, charID, nil
    }
    
    if monsterList[1] then
        o.fightBoard[2] = monsters[monsterList[1]]:newMonster(monsterList[1])
    end
    if monsterList[2] then
        o.fightBoard[1] = monsters[monsterList[2]]:newMonster(monsterList[2])
    end
    if monsterList[3] then
        o.fightBoard[3] = monsters[monsterList[3]]:newMonster(monsterList[3])
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

function Fight:handleAction(char, data)
    if data.actionType == "useSkill" then
        
    end
end

function Fight:updateFight(dt)
    dt = dt or 0
    for _,charID in pairs(self.plrsInFight) do
        local strSplit = split(charID, "-")
        local acc = AccountByID(strSplit[1])
        local char = acc.chars[tonumber(strSplit[2])]
        char.hp = math.min(char.hp+char.hpRegen*dt, char.maxHp)
        char.mp = math.min(char.mp+char.mpRegen*dt, char.maxHp)
        char.stamina = math.min(char.stamina+char.staminaRegen*dt, char.maxStamina)
    end
    for i = 1, 3 do
        if self.fightBoard[i] ~= nil then
            local monster = self.fightBoard[i]
            local monsterType = monsters[self.fightBoard[i].index]
            monster.hp = math.min(monster.hp+monsterType.hpRegen*dt, monsterType.maxHp)
            monster.mp = math.min(monster.mp+monsterType.mpRegen*dt, monsterType.maxHp)
            monster.stamina = math.min(monster.stamina+monsterType.staminaRegen*dt, monsterType.maxStamina)
            for i, skillCD in pairs(monster.skills) do
                monster.skills[i] = monster.skills[i] - dt
                if skillCD <= 0 then
                    if monster.stamina > monsterType.skills[i].staminaCost then
                        if monster.lastSkill ~= i or #monsterType.skills == 1 or monster.skillMargin < 0 then
                            monster.skillMargin = 0.5
                            monster.lastSkill = i
                            monster.skills[i] = monsterType.skills[i].cooldown
                            monster.stamina = monster.stamina - monsterType.skills[i].staminaCost
                            local target = self.fightBoard[monsterType.findPlayer(monster, self.fightBoard)]
                            local plr = CharByID(target)
                            if plr then
                                local dam = monsterType.skills[i].damage(plr)
                                table.insert(self.logAdd, monsterType.skills[i].description(dam, plr))
                                plr.hp = plr.hp - dam
                            end
                        else
                            monster.skillMargin = monster.skillMargin - dt
                        end
                    end
                end
            end
        end 
    end
    for _,charID in pairs(self.plrsInFight) do
        local strSplit = split(charID, "-")
        local acc = AccountByID(strSplit[1])
        local char = acc.chars[tonumber(strSplit[2])]
        acc:send(json.encode({
            message = "updateFight",
            board = self.fightBoard,
            selfStats = {char.hp, char.mp, char.stamina, char.xp, char.maxHp, char.maxMp, char.maxStamina, char.level},
            insertLog = self.logAdd
        }))
    end
    self.logAdd = {}
end

return Fight