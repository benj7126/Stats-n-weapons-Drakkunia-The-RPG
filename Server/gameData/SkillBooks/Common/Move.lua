local Skill = {
    levelRequirement = 0,
    statPoints = 0,
    maxSkillLevel = 1
    --how to do the fucking effects...
    --let's give it a try...
    skillType = "Active"

    staminaCost = 
    cooldown = 1

    --fight, as in current fight, selected spot, as in the pos that is cur selected (so you always have one spot selected, and shortcuts could be shift + nr 1-9 or something), plrSpot is where the player casting is
    onActivate = function(fight, selectedSpot, plrSpot)
        if fight.team[selectedSpot].occupied == false then
            local save = fight.team[selectedSpot]
            fight.team[selectedSpot] = fight.team[plrSpot]
            fight.team[plrSpot] = save
        end
    end
}

return Skill