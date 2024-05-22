-- TEXT CENTERING
local component = require("component")
local gpu = component.gpu

local w, h = gpu.getResolution()

function centerText(y, text, color)
    local x = math.floor(w / 2 - #text / 2)
    gpu.setForeground(color)
    gpu.set(x, y, text)
end

return centerText