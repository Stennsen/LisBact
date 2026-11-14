;; example module mode

(import-macros {: incf} :sample-macros)

(local group_width 100)
(local group_height 100)

(local selected_group nil)

(local body_colors [
    [0.8 0.5 0.8 0.2]
    [0.8 0.8 0.5 0.2]
    [0.4 0.8 0.8 0.2]
])

(local outline_colors [
    [0.8 0.5 0.8 1.0]
    [0.8 0.8 0.5 1.0]
    [0.4 0.8 0.8 1.0]
])

(fn generate_rect_pol [width height]
    (let [
        tenth_w (* width 0.1) 
        tenth_h (* height 0.1)
        p1 [tenth_w tenth_h]
        p2 [0.0 (/ height 2)]
        p3 [tenth_w (- height tenth_h)]
        p4 [(/ width 2) height]
        p5 [(- width tenth_w) (- height tenth_h)]
        p6 [width (/ height 2)]
        p7 [(- width tenth_w) tenth_h]
        p8 [(/ width 2) 0]
        p [p1 p2 p3 p4 p5 p6 p7 p8]
        points []
        ]
        (each [_index value (ipairs p)]
        ; (print (unpack value))
            (each [_index element (ipairs value)]
                (table.insert points element)
            )
        )
        points
    )
)

(fn generate_outline [pol] 
    (let [new_pol [(unpack pol)]]
    (table.insert new_pol (. pol 1))
    (table.insert new_pol (. pol 2))
    new_pol
    )
)

(fn offset_pol [pol offset_x offset_y]
    (let [new_p []]
    (for [i 1 (length pol) 2]
        (table.insert new_p (+ offset_x (. pol i)))
        (table.insert new_p (+ offset_y (. pol (+ i 1))))
    )
    new_p
    )
)

(global Group {:__index "Group"})
(local groups [
    {"name" :group-1 "x" 100 "y" 100 "shape" (generate_rect_pol group_width group_height) "b_color" (. body_colors 1) "o_color" (. outline_colors 1) "__index" :Group}
    {"name" :group-2 "x" 200 "y" 100 "shape" (generate_rect_pol group_width group_height) "b_color" (. body_colors 2) "o_color" (. outline_colors 2) "__index" :Group}
    {"name" :group-3 "x" 300 "y" 100 "shape" (generate_rect_pol group_width group_height) "b_color" (. body_colors 3) "o_color" (. outline_colors 3) "__index" :Group}
])

;; Return boolena if point is in group
;;(fn Group.is_in [self m_x m_y]
;;  PointWithi)
;; TODO: Add function to check, if for a given (x, y) of mouse pointer it collides with group
;; TOOD: Replace group with a convex polygon. :)
;; TODO: Draw group

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
            (each [index value (ipairs groups)]
                (love.graphics.setColor value.b_color )
                (love.graphics.polygon :fill (unpack (offset_pol value.shape value.x value.y)))
                
                ; (print (unpack ( value.shape)))
                (love.graphics.setLineJoin :bevel)
                
                (love.graphics.setColor value.o_color )
                (love.graphics.setLineWidth 10)
                (love.graphics.line (unpack (offset_pol (generate_outline value.shape) value.x value.y)))

                (love.graphics.setColor [0 0 0] )
                (love.graphics.setLineWidth 4)
                (love.graphics.line (unpack (offset_pol (generate_outline value.shape) value.x value.y)))
            )
        ))
 :update (fn _update [state dt _set-mode] state)
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] 
                ;; (each [index value (ipairs groups)]
;; 
                ;; ) 
                state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state) 
 }
