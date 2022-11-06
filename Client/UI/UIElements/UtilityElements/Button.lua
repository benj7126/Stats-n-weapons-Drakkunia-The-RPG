local Button = require("UI.Element"):new()

function Button:new(parent, x, y, w, h)
    local element = {}

    element.parent = parent
    
    element.pos = {x=(x or 0)*4, y=(y or 0)*4} -- auto x4 cuz images scale with x4
    element.size = {x=(w or 0)*4, y=(h or 0)*4}

    element.onClick = {}
    element.onRelease = {}
    element.onPress = {}
    
    element.moveable = false
    element.moving = false
    element.mmp = {x=0, y=0}
    element.subElements = {}

    element.pressThis = false

    setmetatable(element, self)
    self.__index = self
    
    if element.load then
        element:load()
    end

    return element
end

function Button:mousepressed(x, y, b)
    if b == 1 then
        local T = self:getWorldPos()
        local Wx, Wy = T.x, T.y

        if Box(x, y, Wx, Wy, self.size.x, self.size.y) then
            self.pressThis = true

            for i, v in pairs(self.onPress) do
                v(self)
            end
        end
    end
end

function Button:mousereleased(x, y, b)
    if b == 1 then
        local T = self:getWorldPos()
        local Wx, Wy = T.x, T.y

        if Box(x, y, Wx, Wy, self.size.x, self.size.y) then
            if self.pressThis == true then
                for i, v in pairs(self.onClick) do
                    v(self)
                end
            end

            for i, v in pairs(self.onRelease) do
                v(self)
            end
        end
    end
    
    self.pressThis = false
end

return Button