local Skill = {
    LevelRequirement = 0,
    StatPoints = 0,
    MaxSkillLevel = 1
    --how to do the fucking effects...
    --let's give it a try...
    skillType = "Active"

    --fight, as in current fight, selected spot, as in the pos that is cur selected
    onActivate = function(fight, selectedSpot, plrSpot)
        if fight.team[selectedSpot].occupied == false then
            local save = fight.team[selectedSpot]
            fight.team[selectedSpot] = fight.team[plrSpot]
            fight.team[plrSpot] = save
        end
    end
}

return Skill