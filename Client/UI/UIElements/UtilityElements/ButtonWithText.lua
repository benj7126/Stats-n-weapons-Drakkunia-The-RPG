local Button = require("UI.UIElements.UtilityElements.Button"):new()

function Button:load()
    self.text = ""
    self.font = "Default"
    self.fSize = 16
end

function Button:draw()
    love.graphics.printf(self.text, self.pos.x+self.fSize/4, self.pos.y+self.fSize/4, self.limit-(self.fSize/2), self.alignment)
end

return Button