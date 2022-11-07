local Tile = {
    entities = {}
}

function Tile:new()
    local tile = {}
    
    setmetatable(tile, self)
    self.__index = self

    return tile
end

return Tile