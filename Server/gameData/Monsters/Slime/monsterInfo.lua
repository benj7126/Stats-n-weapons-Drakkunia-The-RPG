local monster = {
    level = 1,
    maxHp = 50,
    maxMp = 0,
    maxStamina = 50,
    staminaRegen = 5,
    hpRegen = 0,
    mpRegen = 0,
    physicalDefence = 0,
    magicalDefence = 0,
    image = love.graphics.newImage("gameData/ImageAssets/Slime.png"),
    newMonster = function (self, index)
        local monster = {}
        monster.hp = self.maxHp
        monster.mp = self.maxMp
        monster.stamina = 0
        monster.index = index
        monster.aggro = {}
        monster.skills = {}
        monster.lastSkill = 0
        monster.skillMargin = 0
        for i = 1, #self.skills do
            table.insert(monster.skills, 0)
        end
        return monster
    end,
    takeDamage = function(self, monster, damage, type, plrID)
        local damageDone
        if type == "Physical" then
            monster.hp = hp-math.max(damage-self.physicalDefence, 0)
            damageDone = math.max(damage-self.physicalDefence, 0)
        else -- magical
            monster.hp = hp-math.max(damage-self.magicalDefence, 0)
            damageDone = math.max(damage-self.magicalDefence, 0)
        end

        if not self.aggro[plrID] then
            self.aggro[plrID] = 0
        end

        self.aggro[plrID] = self.aggro[plrID] + damageDone

        return damageDone
    end,
    findPlayer = function(monster, feild) -- to attack
        local name = ""
        local aggroLevel = 0

        for i, v in pairs(monster.aggro) do
            local addAggro = 0
            for i = 4, 6 do
                if feild[i] == monster.aggro[i] then
                    addAggro = addAggro + v*0.5
                end
            end
            if v + addAggro > aggroLevel then
                aggroLevel = v + addAggro
                name = monster.aggro[i]
            end
        end

        if name ~= "" then
            for i = 4, 9 do
                if feild[i] == name then
                    return i
                end
            end
        end
        for i = 4, 9 do
            if feild[i] ~= nil then
                return i
            end
        end
    end,
    skills = {
        {
            name = "attack",
            description = function(damage, player)
                return "The slime jumps foward and hugs "..player.name.." it deals "..damage.." damage"
            end,
            damageType = "Acidic",
            damage = function(player)
                local defenceApplied = math.max(5-player.stats.PhysicalDefence, 2,5)
                return math.max(defenceApplied-defenceApplied*player.stats.DamageReduction, 0)
            end,
            staminaCost = 30,
            cooldown = 3,
        },
        {
            name = "nothing",
            description = function(damage, player)
                return "The slime smiles at you, then jumps a couple of times, it hits you right in your heart 1 damage"
            end,
            damageType = "",
            damage = function(player)
                return 1
            end,
            staminaCost = 30,
            cooldown = 5,
        }
    }
}

return monster