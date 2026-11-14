;; example module mode

(import-macros {: incf} :sample-macros)

(import-macros {: init-require!} :mod)
(local require-mod! (init-require! :modes.mode-game))

(local background (require-mod! :core.background))

(local bg (background.new))

{:activate (fn _activate []
             (love.graphics.setNewFont 30)
             (love.window.setTitle "Lisbee - Swarm Survival Game")
)
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
      (background.draw bg state)
 )
         
 :update (fn _update [state dt _set-mode]
            (background.update bg state dt _set-mode)
           )
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (fn [state _x _y _dx _dy _set-mode] state)
 :mousepressed (fn [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (fn [state _key _scancode _is-repeat _set-mode] state) }
