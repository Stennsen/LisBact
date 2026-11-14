; swarm {
;   # public
;   :background_cell_count int
;   :background_color color
;   :background_cell_color color
;   :blur_shader_radius int
;   :background_cell_speed int
;   # private
;   :mainCanvas canvas
;   :blurCanvas canvas
;   :blurShader shader
;   :background_cells cells
;   # data types
;   :background_cell
;   # frunctions
;   :draw state
;   :update state dt _set-mode
; }

(import-macros {: init-require!} :mod)

(local background_cell {
  
  :new (fn [self x y angle size speed cell_color]
               (local obj {:angle (math.rad angle) : size : speed : x : y : cell_color})
               (setmetatable obj self)
               (set self.__index self)
               obj)

  :update (fn [self dt]
            (let [[w h] [(love.window.getMode)]]
                  (set self.x (% (+ self.x (* (math.cos self.angle) self.speed dt)) w))
                  (set self.y (% (+ self.y (* (math.sin self.angle) self.speed dt)) h))
            )
                  )

  :draw (fn [self] 
    (love.graphics.setColor (unpack self.cell_color))
    (love.graphics.circle :fill self.x self.y self.size)
    )
})

(fn generate_background_cells [count cell_speed background_cell_color]
  (let [list []]
    (for [_ 1 count]
    (let [[w h] [(love.window.getMode)]]
      (let [
        x (math.floor (math.random 0 w)) 
        y (math.floor (math.random 0 h))
        angle (math.floor (math.random 0 360))
        size (math.floor (math.random 30 50))
        ]
      (table.insert list (background_cell:new x y angle size cell_speed background_cell_color))
      )
    )
    )
  list)
)

(fn new [background_cell_count background_color background_cell_color blur_shader_radius background_cell_speed]
  "creates a new background with given parameters"
  (let [background_cell_count (if (not background_cell_count) 100 background_cell_count)
        background_color (if (not background_color) [(love.math.colorFromBytes 235 245 151)] background_color)
        background_cell_color (if (not background_cell_color) [(love.math.colorFromBytes 195 233 150)] background_cell_color)
        blur_shader_radius (if (not blur_shader_radius) 16 blur_shader_radius)
        background_cell_speed (if (not background_cell_speed) 20 background_cell_speed)
        mainCanvas (love.graphics.newCanvas)
        blurShader (love.graphics.newShader "assets/shaders/blur.fs")
        blurCanvas (love.graphics.newCanvas)
        ] (let [background_cells (generate_background_cells background_cell_count background_cell_speed background_cell_color)]
            (blurShader:send :Radius background_cell_speed)
            {: background_cell_count : background_color : background_cell_color 
    : blur_shader_radius : background_cell_speed : mainCanvas : blurShader : blurCanvas : background_cells}
        )
    ))

(fn draw [bg _state]
    (let [[w h] [(love.window.getMode)]]
          ;; Solid background color
          (love.graphics.setCanvas bg.mainCanvas)
          (love.graphics.clear (unpack bg.background_color))
          (each [_ value (ipairs bg.background_cells)]
            (value:draw)
          )
          (love.graphics.setCanvas)

          ;; Blur shader
          (love.graphics.setBlendMode :alpha :premultiplied)
          (love.graphics.setShader bg.blurShader)

          
          ;; Blur X
          (love.graphics.setCanvas bg.blurCanvas)
          (love.graphics.clear)
          (bg.blurShader:send "Offset" [ 1.0 0.0 ])
          (love.graphics.draw bg.mainCanvas)
          
          (love.graphics.setCanvas bg.mainCanvas)
          (love.graphics.clear)

          ;; Blur Y
          (bg.blurShader:send "Offset" [ 0.0 1.0 ])
          (love.graphics.draw bg.blurCanvas)

          (love.graphics.setCanvas)
          (love.graphics.setShader)
          (love.graphics.draw bg.mainCanvas)
          (love.graphics.setBlendMode "alpha")
    )
)

(fn update [bg _state dt _set-mode] 
    (each [_ value (ipairs bg.background_cells)]
        (value:update dt)
    )
)

{: new : draw : update}
