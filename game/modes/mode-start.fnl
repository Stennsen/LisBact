;; example module mode

(import-macros {: incf} :sample-macros)

(import-macros {: init-require!} :mod)
(local require-mod! (init-require! :modes.mode-game))

(local background (require-mod! :core.background))

(local set-mode :set-mode)

(local lume (require :lib.lume))

(local countdown-time 300)

(local big-font (love.graphics.setNewFont 48))
(local small-font (love.graphics.setNewFont 16))

(local bg (background.new 1600 900))
(love.graphics.setDefaultFilter :nearest)
(local logo (love.graphics.newImage "assets/logo.png"))

(var title-offset-x 0)

; (fn switch-mode [mode] (love.op mode))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (background.predraw bg)
           (background.draw bg)
           (love.graphics.setColor 0 0 0)
           (love.graphics.setFont big-font)
                                (love.graphics.setColor 1 1 1)
                                
          (love.graphics.draw logo
                                (+ (/ w 8) 150 (* (math.sin (love.timer.getTime)) 100)) 0
                                0 2 2)
           (love.graphics.setFont small-font)
           (love.graphics.print "Pressy SPACE to start!" (+ (/ w 3) (* (math.cos (love.timer.getTime)) 100)) 550)))
 :update (fn _update [state dt _set-mode]
           (background.update bg 1600 900 dt)
           state)
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state key _code _is-repeat set-mode]
               (if (= key :space)
                   (do
                     (print :KEY)
                     (set-mode :mode-game)))
               state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (fn [state _key _scancode _is-repeat _set-mode] state)}
