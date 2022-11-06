local Skill = {
    LevelRequirement = 0,
    SkillLevel = 0,
    MaxSkillLevel = 1,
    skillType = "Active",

    staminaCost = 10,
    cooldown = 0,
    duration = 5,
    isActive = false,

    --fight, as in current fight, selected spot, as in the pos that is cur selected
    onActivate = function(fight, selectedSpot, plrSpot)
        if fight.team[selectedSpot].occupied == false then
            local save = fight.team[selectedSpot]
            fight.team[selectedSpot] = fight.team[plrSpot]
            fight.team[plrSpot] = save
        end
    end,

    onDamagedTake = function(fight, account, target)
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