local Fight = {}

function Fight:new(charID, monsterList, tileID)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.plrsInFight = {charID}
    o.tileID = tileID

    o.fightBoard = {
        nil, nil, nil,
        nil, nil, nil,
        nil, charID, nil
    }
    
    if monsterList[1] then
        o.fightBoard[2] = monsterList[1]
    end
    if monsterList[2] then
        o.fightBoard[1] = monsterList[2]
    end
    if monsterList[3] then
        o.fightBoard[3] = monsterList[3]
    end
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
    for i = 1, 3 do
        
    end
    for _,charID in pairs(self.plrsInFight) do
        print("sendTo: "..charID)
        local strSplit = split(charID, "-")
        AccountByID(strSplit[1]):send(json.encode({
            message = "updateFight",
            fightData = self.fightBoard
        }))
    end
end

return Fight