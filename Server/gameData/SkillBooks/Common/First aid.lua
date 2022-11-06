local Skill = { -- just flat out +10 hp
    levelRequirement = 0,
    SkillLevel = 0,
    maxSkillLevel = 1,
    skillType = "Active",

    staminaCost = 10,
    cooldown = 0,
    duration = 0,
    isActive = false,

    onActivate = function(fight, account, target)
        if target > 3 then
            if fight.fightBoard[target] ~= nil then
                local char = CharByID(fight.fightBoard[target])
                char.hp = char.hp + 10
            end
        end
        return fight
    end
}

return Skill