local World = {
    layers = {}
}

for i = 1, 1 do
    World.layers[i] = require "Layer" : new(i)
end

return World