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
  (let [mode (require new-mode-name)]
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

(fn safely [f]
  (xpcall f (lambda [d] (print d))))

(fn love.draw []
  (love.graphics.scale scale)
  (safely (lambda [] (state-mode.draw state-state))))

;; you can wrap other love callbacks, such as love.mousepressed
;; love.mousemoved, love.mousereleased, love.keypressed in a similar
;; way to love.update.
(fn love.update [dt]
  (set-state (state-mode.update state-state dt set-mode)))

(fn love.keyreleased [key code isrepeat] (print "KEY RELEASED"))

(set-mode :mode-intro)
