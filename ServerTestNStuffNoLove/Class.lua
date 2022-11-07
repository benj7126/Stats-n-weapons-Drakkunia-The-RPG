local Class = {}

function Class:new()
    local class = {}
    
    setmetatable(class, self)
    self.__index = self

    return class
end

return Class