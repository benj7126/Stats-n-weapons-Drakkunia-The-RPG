local Floor = {}

function Floor:new(size, floorNR)
    local o = {}

    for x = -size/2, size/2 do
        o[x] = {}
        for y = -size/2, size/2 do
            o[x][y] = Tile:new(imageID or 1, npcID or 0, love.math.random(1, 9)~=1, floorNR.."-"..x.."-"..y)
        end
    end

    o[0][0].passable = true
    
    setmetatable(o, self)
    self.__index = self
    return o
end

function Floor:getTile(x, y)
    if self[x] then
        if self[x][y] then
            return self[x][y]
        end
    end
end

return Floor