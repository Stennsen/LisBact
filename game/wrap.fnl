;; wraps love callbacks

(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))

(local scale 1)

(var state-mode nil)
(var state-mode-name :mode-intro)

(local state (require :state))
(var state-state (state.init))

(local activated-modes {})

(fn set-state [new-state] (set state-state new-state))

(fn set-mode [new-mode-name ...]
  (print new-mode-name)
  (if state-mode (set-state ((. state-mode :leave) state-state)))
  (let [mode (require (.. :modes. new-mode-name))]
    (when (not (. activated-modes mode))
      (mode.activate)
      (tset activated-modes mode true))
    (set-state ((. mode :enter) state-state))
    (set state-mode mode)
    (set state-mode-name new-mode-name)))

(fn love.load [_args]
  (set-mode :mode-intro)
  ;; the nearest filter allows you to get sharp pixel-art style scaling;
  ;; if you want perfect pixel alignment you can draw to canvas and
  ;; then draw that canvas scaled
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (when (~= :Web (love.system.getOS)) (repl.start)))

(fn love.draw []
  (love.graphics.scale scale)
  (state-mode.draw state-state))

;; you can wrap other love callbacks, such as love.mousepressed
;; love.mousemoved, love.mousereleased, love.keypressed in a similar
;; way to love.update.
(fn love.update [dt]
  (set-state (state-mode.update state-state dt set-mode)))

(fn love.keyreleased [key code isrepeat] (set-state (state-mode.keyreleased state-state key code isrepeat set-mode)))

(fn love.keypressed [key code isrepeat] (set-state (state-mode.keypressed state-state key code isrepeat set-mode)))

(fn love.mousemoved [x y dx dy _is-touch] (set-state (state-mode.mousemoved state-state x y dx dy set-mode)))

(fn love.mousepressed [key scancode isrepeat] (set-state (state-mode.mousepressed state-state key scancode isrepeat set-mode)))

(fn love.mousereleased [key scancode isrepeat] (set-state (state-mode.mousereleased state-state key scancode isrepeat set-mode)))

(set-mode :mode-intro)
