local Tile = {}

function Tile:new()
    local o = {
        passable = true, -- can you go onto this feild
        battleID = 0, -- will be assigned when a battle stats so folks can join
        battleActive = false, -- set to true when battle starts
        imageID = 1, -- only important for client, cuz... who need the server to show the map..?
        npc = 0, -- if there should be an npc, like maby an shop or a quest or anything along the lines...
        monstersOnTle = {}, -- for the 1-3 monsters when the battle starts
        itemsOnTile = {} -- idea is to use this for quests, like, generate the quest when the npc gets generated
        --fx go get my family ring, and then you get a ring if you enter, only if you have the quest thou. could also be something like, draw a map.
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

return Tile