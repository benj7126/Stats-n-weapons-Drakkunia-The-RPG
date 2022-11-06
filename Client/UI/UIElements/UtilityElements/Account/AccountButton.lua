local AccountButton = require("UI.UIElements.UtilityElements.Button"):new()

function AccountButton:load()
    self.id = 0
    self.name = "#"
    self.class = ""
    self.race = ""
    self.level = 0

    self.size.x = 114*4
    self.size.y = 24*4

    self.onClick = {
        function (self)
            if self.name == "#" then
                Server:send(Json.encode({
                    type = "loadChar",
                    charNr = self.id
                }))
            elseif self.name == "" then
                -- create char
                UIManager:remove(self.parent)
                UIManager:append(require("UI.UIElements.CharacterScreen"):new())
            end
        end
    }
end

function AccountButton:draw()
    love.graphics.setFont(GetFont("Default", 20))
    if self.name == "#" then
        love.graphics.printf("Load", self.pos.x + 108, self.pos.y + 8, 240, "center")
    elseif self.name == "" then
        love.graphics.printf("Create", self.pos.x + 108, self.pos.y + 8, 240, "center")
    else
        love.graphics.printf(self.name, self.pos.x + 108, self.pos.y + 8, 240, "center")
        love.graphics.setFont(GetFont("Default", 16))
        love.graphics.printf(self.race, self.pos.x, self.pos.y + 48, 152, "center")
        love.graphics.printf(tostring(self.level), self.pos.x + 108, self.pos.y + 48, 240, "center")
        love.graphics.printf(self.class, self.pos.x + 304, self.pos.y + 48, 152, "center")
    end
end

function AccountButton:GlobalData(d)
    if d.message == "loadPlayer" then
        if d.charNr == self.id then
            self.name = d.char.name
            self.class = d.char.class
            self.race = d.char.race
            self.level = d.char.level
        end
    end
end

return AccountButton