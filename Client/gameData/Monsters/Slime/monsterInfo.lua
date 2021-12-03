local monster = {
    level = 1,
    name = "Slime",
    hp = 100,
    maxHp = 100,
    mp = 0,
    physicalDefence = 0,
    magicalDefence = 0,
    maxMp = 0,
    stamina = 0,
    maxStamina = 10,
    staminaRegen = 1,
    image = love.graphics.newImage("gameData/ImageAssets/Slime.png"),
    aggro = {},
    takeDamage = function(damage, type, player)
        local damageDone
        if type == "Physical" then
            hp = hp-math.max(damage-self.physicalDefence, 0)
            damageDone = math.max(damage-self.physicalDefence, 0)
        else -- magical
            hp = hp-math.max(damage-magicalDefence, 0)
            damageDone = math.max(damage-magicalDefence, 0)
        end

        if not aggro[player.name] then
            aggro[player.name] = 0
        end

        aggro[player.name] = aggro[player.name] + damageDone

        return damageDone
    end,
    findPlayer = function(self, feild) -- to attack
        print(self.stamina)
        local name = ""
        local aggroList = {}

        for i, v in pairs(self.aggro) do
            print(v)
        end

        for i = 4, 9 do
            feild[i] = 0
        end
    end,
    skills = {
        {
            name = "attack",
            description = function(damage, player)
                return "The slime jumps foward and hugs "..player.name.." and deals "..damage.." damage"
            end,
            damageType = "Acidic",
            damage = function(player)
                local defenceApplied = (10-player.stats.PhysicalDefence)
                return math.max(defenceApplied-defenceApplied*player.stats.DamageReduction, 0)
            end,
            staminaCost = 2,
            cooldown = 1,
            curCooldown = 1
        }
    }
}

return monster