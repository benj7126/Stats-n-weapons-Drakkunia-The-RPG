local utf8 = require("utf8")

local UIManager = {
    UIElements = {},
    selectedLabel = nil
}

function UIManager:new()
    local manager = {}
    setmetatable(manager, self)
    self.__index = self
    return manager
end

function UIManager:append(element)
    table.insert(self.UIElements, element)
end

function UIManager:remove(element)
    for i, v in pairs(self.UIElements) do
        if v == element then
            table.remove(self.UIElements, i)
        end
    end
end

function UIManager:draw()
    for i, v in pairs(self.UIElements) do
        v:drawFull()
    end
end

function UIManager:GlobalDataFull(d)
    for i, v in pairs(self.UIElements) do
        v:GlobalDataFull(d)
    end
end

function UIManager:update(dt)
    for i, v in pairs(self.UIElements) do
        v:updateFull(dt)
    end
end

function UIManager:textinput(t)
    for i, v in pairs(self.UIElements) do
        v:textinputFull(t)
    end

    if self.selectedLabel then
        if #self.selectedLabel.text < self.selectedLabel.textLimit then
            self.selectedLabel.text = self.selectedLabel.text .. t
        end
    end
end

function UIManager:keypressed(k)
    for i, v in pairs(self.UIElements) do
        v:keypressedFull(k)
    end

    if self.selectedLabel then
        if k == "return" then
            for i, v in pairs(self.selectedLabel.onEnter) do
                v()
            end

            if self.selectedLabel.clearOnEnter then
                self.selectedLabel.text = ""
                self.selectedLabel = nil
            end
        elseif k == "escape" then
            self.selectedLabel = nil
        elseif k == "backspace" then
            local byteoffset = utf8.offset(self.selectedLabel.text, -1)
            if byteoffset then
                self.selectedLabel.text = string.sub(self.selectedLabel.text, 1, byteoffset - 1)
            end
        end
    end
end

function UIManager:keyreleased(k)
    for i, v in pairs(self.UIElements) do
        v:keyreleasedFull(k)
    end
end

function UIManager:mousepressed(x, y, b)
    for i, v in pairs(self.UIElements) do
        v:mousepressedFull(x, y, b)
    end
end

function UIManager:mousereleased(x, y, b)
    self.selectedLabel = nil
    for i, v in pairs(self.UIElements) do
        v:mousereleasedFull(x, y, b)
    end
end

return UIManager