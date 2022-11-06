local Skill = {
    levelRequirement = 0,
    SkillLevel = 0,
    maxSkillLevel = 1,
    skillType = "Active",

    staminaCost = 10,
    cooldown = 0,
    duration = 0,
    isActive = false,

    --fight, as in current fight, selected spot, as in the pos that is cur selected (so you always have one spot selected, and shortcuts could be shift + nr 1-9 or something), plrSpot is where the player casting is
    onActivate = function(fight, account, target)
        local charID = account:getCharId()
        if target > 3 then
            if fight.fightBoard[target] == nil then
                for i = 4, 9 do
                    if fight.fightBoard[i] == charID then
                        fight.fightBoard[target] = charID
                        fight.fightBoard[i] = nil
                        break
                    end
                end
            end
        end
        return fight
    end
}

return Skill