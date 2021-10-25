local Floor = {}

function Floor:new(size)
    local o = {}

    for x = -size/2, size/2 do
        o[x] = {}
        for y = -size/2, size/2 do
            o[x][y] = Tile:new()
        end
    end
    
    setmetatable(o, self)
    self.__index = self
    return o
end

return Floor