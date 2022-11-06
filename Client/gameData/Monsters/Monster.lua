local Monster = {
    level = 0,
    maxHp = 0,
    maxMp = 0,
    hp = 0,
    mp = 0,
    maxStamina = 0,
    stamina = 0,
    staminaRegen = 0,
    hpRegen = 0,
    mpRegen = 0,
    physicalDefence = 0,
    magicalDefence = 0,
    aggro = {},
    skills = {},

    fight = nil, -- the fight that is ongoing
}

function Monster:new(fight)
    local monster = {}
    
    self.fight = fight
    self.hp = self.maxHp
    self.mp = self.maxMp
    self.stamina = self.maxStamina

    setmetatable(monster, self)
    self.__index = self
    return monster
end

-- to be fixed

-- function Monster:takeDamage(damage, type, plrID)
--     local damageDone
--     if type == "Physical" then
--         monster.hp = hp-math.max(damage-self.physicalDefence, 0)
--         damageDone = math.max(damage-self.physicalDefence, 0)
--     else -- magical
--         monster.hp = hp-math.max(damage-self.magicalDefence, 0)
--         damageDone = math.max(damage-self.magicalDefence, 0)
--     end

--     if not self.aggro[plrID] then
--         self.aggro[plrID] = 0
--     end

--     self.aggro[plrID] = self.aggro[plrID] + damageDone

--     return damageDone
-- end

-- function Monster:findPlayer(monster)
--     local name = ""
--     local aggroLevel = 0

--     for i, v in pairs(monster.aggro) do
--         local addAggro = 0
--         for i = 4, 6 do
--             if feild[i] == monster.aggro[i] then
--                 addAggro = addAggro + v*0.5
--             end
--         end
--         if v + addAggro > aggroLevel then
--             aggroLevel = v + addAggro
--             name = monster.aggro[i]
--         end
--     end

--     if name ~= "" then
--         for i = 4, 9 do
--             if feild[i] == name then
--                 return i
--             end
--         end
--     end
--     for i = 4, 9 do
--         if feild[i] ~= nil then
--             return i
--         end
--     end
-- end

return Monster