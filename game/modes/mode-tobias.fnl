;; example module mode

(import-macros {: incf} :sample-macros)

(local group_width 100)
(local group_height 100)

(local groups [
    {"name" :group-1 "x" 100 "y" 100 "width" group_width "height" group_height "color" [0.8 0.5 0.8 1.0] }
    {"name" :group-2 "x" 200 "y" 100 "width" group_width "height" group_height "color" [0.8 0.8 0.5 1.0] }
    {"name" :group-3 "x" 300 "y" 100 "width" group_width "height" group_height "color" [0.5 0.8 0.8 1.0] }
])

(var elapsed_time 0)

;; TODO: Add function to check, if for a given (x, y) of mouse pointer it collides with group
;; TOOD: Replace group with a convex polygon. :)
;; TODO: Draw group

(fn print_state [state]
    (each [key value (pairs state)]
    (print key value)    
    )
)


{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
            (each [index value (ipairs groups)]
                (love.graphics.setColor value.color )
                (love.graphics.rectangle :fill value.x value.y value.width value.height)
                
            )
        )
        (print elapsed_time)
        )
 :update (fn _update [state dt _set-mode]
          (set elapsed_time (+ elapsed_time dt))
                ; (print_state state) 
          state           
         )
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] 
                (print _x _y) state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode]
                ; (print state)
                (print_state state) 
                (love.event.quit)
                state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state) }
