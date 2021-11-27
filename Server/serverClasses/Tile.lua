local Tile = {}

function Tile:new(imageID, npcID, passable, tileID)
    local o = {
        tileID = tileID,
        passable = passable, -- can you go onto this feild
        battleID = 0, -- will be assigned when a battle stats so folks can join
        battleActive = false, -- set to true when battle starts
        fightOnThisTile = nil,
        imageID = imageID, -- only important for client, cuz... who need the server to show the map..?
        npc = npcID, -- if there should be an npc, like maby an shop or a quest or anything along the lines...
        monstersOnTle = {1}, -- for the 1-3 monsters when the battle starts
        itemsOnTile = {}, -- idea is to use this for quests, like, generate the quest when the npc gets generated
        plrsOnTile = {} -- the players on the tile
        --fx go get my family ring, and then you get a ring if you enter, only if you have the quest thou. could also be something like, draw a map.
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Tile:enter(charID)
    if self.battleActive == false then
        if #self.monstersOnTle ~= 0 then
            table.insert(fights, Fight:new(charID, self.monstersOnTle, self.tileID))
            self.battleActive = true
            self.fightOnThisTile = fights[#fights]

            local strSplit = split(charID, "-")
            AccountByID(strSplit[1]):startFight(self.tileID)
        end
    else
        if self.fightOnThisTile:addPlr(charID) then
            local strSplit = split(charID, "-")
            AccountByID(strSplit[1]):startFight(self.tileID)
        end
    end
end

return Tile