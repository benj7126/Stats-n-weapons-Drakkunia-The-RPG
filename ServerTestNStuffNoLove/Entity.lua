local Entity = {
    x = 0, y = 0,
    tile = nil,

    buffs = {}, -- all buffs and debuffs
}

function Entity:new()
    local entity = {}
    
    setmetatable(entity, self)
    self.__index = self

    return entity
end

return Entity