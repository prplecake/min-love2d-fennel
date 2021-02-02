 local repl = require("lib.stdio")
 local canvas = nil do local w, h = love.window.getMode()
 canvas = love.graphics.newCanvas(w, h) end local scale = 1




 local mode = require("mode-intro")

 local function set_mode(mode_name, ...)
 mode = require(mode_name)
































































 if mode.activate then return mode.activate(...) end end love.load = function() canvas:setFilter("nearest", "nearest") return repl.start() end love.draw = function() love.graphics.setCanvas(canvas) love.graphics.clear() love.graphics.setColor(1, 1, 1) mode.draw() love.graphics.setCanvas() love.graphics.setColor(1, 1, 1) return love.graphics.draw(canvas, 0, 0, 0, scale, scale) end love.update = function(dt) return mode.update(dt, set_mode) end love.keypressed = function(key) if (love.keyboard.isDown("lctrl", "rctrl", "capslock") and (key == "q")) then return love.event.quit() else return mode.keypressed(key, set_mode) end end return love.keypressed
