;; example module mode

(import-macros {: incf} :sample-macros)

(local lume (require :lib.lume))

(local countdown-time 300)

(local background_color [(love.math.colorFromBytes 235 245 151)])
(local background_cell_color [(love.math.colorFromBytes 195 233 150)])
(local background_cell_count 80)

(local screen_size_x 1600)
(local screen_size_y 900)

(local mainCanvas (love.graphics.newCanvas))
;; Shader
(local blurShader (love.graphics.newShader "assets/shaders/blur.fs"))
(blurShader:send :Radius 16)
(local blurCanvas (love.graphics.newCanvas))


(local background_cell {
  
  :new (fn [self x y angle size]
               (local obj {:angle (math.rad angle) : size :speed 20 : x : y})
               (setmetatable obj self)
               (set self.__index self)
               obj)

  :update (fn [self dt]
                  (set self.x (% (+ self.x (* (math.cos self.angle) self.speed dt)) screen_size_x))
                  (set self.y (% (+ self.y (* (math.sin self.angle) self.speed dt)) screen_size_y))
                  
                  )

  :draw (fn [self] 
    (love.graphics.setColor (unpack background_cell_color))
    (love.graphics.circle :fill self.x self.y self.size)
    )
})

(fn generate_background_cells [count]
  (let [list []]
    (for [_ 1 count]
      (let [
        x (math.floor (math.random 0 screen_size_x)) 
        y (math.floor (math.random 0 screen_size_y))
        angle (math.floor (math.random 0 360))
        size (math.floor (math.random 30 50))
        ]
      (table.insert list (background_cell:new x y angle size))
      )
    )
  list)
)

(local background_cells (generate_background_cells background_cell_count))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30)
             (love.window.setTitle "Lisbee - Swarm Survival Game")
             (love.window.setMode screen_size_x screen_size_y)
)
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
          ;; Solid background color
          (love.graphics.setCanvas mainCanvas)
          (love.graphics.clear (unpack background_color))
          (each [_ value (ipairs background_cells)]
            (value:draw)
          )
          (love.graphics.setCanvas)

          ;; Blur shader
          (love.graphics.setBlendMode :alpha :premultiplied)
          (love.graphics.setShader blurShader)

          
          ;; Blur X
          (love.graphics.setCanvas blurCanvas)
          (love.graphics.clear)
          (blurShader:send "Offset" [ 1.0 0.0 ])
          (love.graphics.draw mainCanvas)
          
          (love.graphics.setCanvas mainCanvas)
          (love.graphics.clear)

          ;; Blur Y
          (blurShader:send "Offset" [ 0.0 1.0 ])
          (love.graphics.draw blurCanvas)

          (love.graphics.setCanvas)
          (love.graphics.setShader)
          (love.graphics.draw mainCanvas)
          (love.graphics.setBlendMode "alpha")


                                 ))
 :update (fn _update [state dt _set-mode]
            (each [_ value (ipairs background_cells)]
            (value:update dt)
           ))
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (fn [state _key _scancode _is-repeat _set-mode] state) }
