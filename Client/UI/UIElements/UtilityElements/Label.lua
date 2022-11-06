local Label = require("UI.Element"):new()

function Label:new(parent, x, y, w, h, alignment, textLimit, writeable, font, size)
    local element = {}

    element.parent = parent
    
    element.pos = {x=x*4, y=y*4} -- auto x4 cuz images scale with x4
    element.size = {x=w*4, y=h*4}
    element.limit = w*4

    element.onEnter = {}

    element.isALabel = writeable or true
    element.alignment = alignment or "center"

    element.text = ""
    element.default = ""
    
    element.clearOnEnter = false

    element.textLimit = textLimit or w/(size or 40)

    element.font = font or "Default"
    element.fSize = size or 40
    
    element.moveable = false
    element.moving = false
    element.mmp = {x=0, y=0}
    element.subElements = {}

    element.pressThis = false

    setmetatable(element, self)
    self.__index = self
    return element
end

function Label:draw()
    love.graphics.setFont(GetFont(self.font, self.fSize))
    local t = self.text
    if t == "" then
        t = self.default
    end

    love.graphics.printf(t, self.pos.x+self.fSize/4, self.pos.y+self.fSize/4, self.limit-(self.fSize/2), self.alignment)
end

function Label:mousepressed(x, y, b)
    if b == 1 and self.isALabel then
        local T = self:getWorldPos()
        local Wx, Wy = T.x, T.y

        if Box(x, y, Wx, Wy, self.size.x, self.size.y) then
            self.pressThis = true
        end
    end
end

function Label:mousereleased(x, y, b)
    if b == 1 and self.isALabel then
        local T = self:getWorldPos()
        local Wx, Wy = T.x, T.y

        if Box(x, y, Wx, Wy, self.size.x, self.size.y) then
            if self.pressThis == true then
                UIManager.selectedLabel = self
            end
        end
    end
    
    self.pressThis = false
end

return Label