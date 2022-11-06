local Element = {}

function Element:new(parent)
    local element = {}

    element.parent = parent
    element.moveable = false
    element.moving = false
    element.mmp = {x=0, y=0}
    element.pos = {x=0, y=0}
    element.size = {x=0, y=0}
    element.parent = nil
    element.subElements = {}

    setmetatable(element, self)
    self.__index = self
    
    if element.load then
        element:load()
    end

    return element
end

function Element:load()
    
end

function Element:append(element)
    table.insert(self.subElements, element)
end

function Element:remove(element)
    for i, v in pairs(self.subElements) do
        if v == element then
            table.remove(self.subElements, i)
        end
    end
end

function Element:drawFull()
    self:draw()
    for i, v in pairs(self.subElements) do
        v:drawFull()
    end
end

function Element:GlobalDataFull(d)
    self:GlobalData(d)
    for i, v in pairs(self.subElements) do
        v:GlobalDataFull(d)
    end
end

function Element:updateFull(dt)
    self:update(dt)
    for i, v in pairs(self.subElements) do
        v:updateFull(dt)
    end
end

function Element:textinputFull(t)
    self:textinput(t)
    for i, v in pairs(self.subElements) do
        v:textinputFull(t)
    end
end

function Element:keypressedFull(k)
    self:keypressed(k)
    for i, v in pairs(self.subElements) do
        v:keypressedFull(k)
    end
end

function Element:keyreleasedFull(k)
    self:keyreleased(k)
    for i, v in pairs(self.subElements) do
        v:keyreleasedFull(k)
    end
end

function Element:mousepressedFull(x, y, b)
    self:mousepressed(x, y, b)
    for i, v in pairs(self.subElements) do
        v:mousepressedFull(x, y, b)
    end
end

function Element:mousereleasedFull(x, y, b)
    self:mousereleased(x, y, b)
    for i, v in pairs(self.subElements) do
        v:mousereleasedFull(x, y, b)
    end
end

function Element:draw()
    
end

function Element:GlobalData(d)
    
end

function Element:update(dt)
    
end

function Element:textinput(t)
    
end

function Element:keypressed(k)
    
end

function Element:keyreleased(k)
    
end

function Element:mousepressed(x, y, b)
    
end

function Element:mousereleased(x, y, b)
    
end

function Element:getWorldPos()
    if self.parent ~= nil then
        local worldPos = self.parent:getWorldPos()
        return {x=worldPos.x+self.pos.x, y=worldPos.y+self.pos.y}
    else
        return {x = 0, y = 0}
    end
end

return Element