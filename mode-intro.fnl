(import-macros {: incf} :sample-macros)

(var counter 0)
(var time 0)

(love.graphics.setNewFont 30)

{:draw (fn draw [message]
         (local (w h _flags) (love.window.getMode))
         (love.graphics.printf
          (: "This window should close in %0.1f seconds"
             :format (math.max 0 (- 3 time)))
          0 (- (/ h 2) 15) w :center))
 :update (fn update [dt set-mode]
             (if (< counter 65535)
                 (set counter (+ counter 1))
                 (set counter 0))
             (incf time dt)
             (when (> time 3)
               (love.event.quit)))
 :keypressed (fn keypressed [key set-mode]
                 (love.event.quit))}
