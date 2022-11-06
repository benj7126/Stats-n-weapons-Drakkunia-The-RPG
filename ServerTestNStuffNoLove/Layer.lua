local Layer = {
    z = 0, grid = {}
}

function Layer:new(z)
    local layer = {}

    layer.z = z

    local w, h = 100, 100

    layer.grid = {}
    for x = 1,w do
        layer.grid[x] = {}
        for y = 1,h do
            layer.grid[x][y] = require "Tile" : new()
        end
    end
    
    setmetatable(layer, self)
    self.__index = self

    return layer
end

return Layer