local Slime = require("gameData.Monsters.Monster"):new(nil)

Slime.level = 1
Slime.maxHp = 50
Slime.maxMp = 0
Slime.maxStamina = 50
Slime.stamina = 0
Slime.staminaRegen = 5
Slime.hpRegen = 0
Slime.mpRegen = 0
Slime.physicalDefence = 0
Slime.magicalDefence = 0



-- skills = {
--     {
--         name = "attack",
--         description = function(damage, player)
--             return "The slime jumps foward and hugs "..player.name.." it deals "..damage.." damage"
--         end,
--         damageType = "Acidic",
--         damage = function(player)
--             local defenceApplied = math.max(5-player.stats.PhysicalDefence, 2,5)
--             return math.max(defenceApplied-defenceApplied*player.stats.DamageReduction, 0)
--         end,
--         staminaCost = 30,
--         cooldown = 3,
--     },
--     {
--         name = "nothing",
--         description = function(damage, player)
--             return "The slime smiles at you, then jumps a couple of times, it hits you right in your heart 1 damage"
--         end,
--         damageType = "",
--         damage = function(player)
--             return 1
--         end,
--         staminaCost = 30,
--         cooldown = 5,
--     }
-- }

return Slime