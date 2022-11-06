local Skill = {
    LevelRequirement = 0,
    SkillLevel = 0,
    MaxSkillLevel = 1,
    skillType = "Active",

    staminaCost = 10,
    cooldown = 0,
    duration = 0,
    isActive = false,

    --fight, as in current fight, selected spot, as in the pos that is cur selected
    onActivate = function(fight, selectedSpot, plrSpot)
        if fight.team[selectedSpot].occupied == false then
            local save = fight.team[selectedSpot]
            fight.team[selectedSpot] = fight.team[plrSpot]
            fight.team[plrSpot] = save
        end
    end,

    --fight, as in current fight, selected spot, as in the pos that is cur selected
    onUseAbility = function(fight, selectedSpot, plrSpot)
        if fight.team[selectedSpot].occupied == false then
            local save = fight.team[selectedSpot]
            fight.team[selectedSpot] = fight.team[plrSpot]
            fight.team[plrSpot] = save
        end
    end
}

return Skill