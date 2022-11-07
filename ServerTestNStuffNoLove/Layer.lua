local Layer = {
    z = 0, grid = {}
}

function Layer:new(z)
    local layer = {}

    layer.z = z

    local w, h = 100, 100

    layer.grid = {}
    for x = 0,w do
        layer.grid[x-50] = {}
        for y = 0,h do
            layer.grid[x-50][y-50] = require "Tile" : new()
        end
    end
    
    setmetatable(layer, self)
    self.__index = self

    return layer
end

return Layer