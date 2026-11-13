;; wraps love callbacks

(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))

(local scale 1)

;; set the first mode
;; storing the mode and mode-name in state lets you reload this
;; module with ,reload wrap
(local state (require :state))

(local activated-modes {})

(fn set-mode [new-mode-name ...]
  (case (and (. state.mode :leave) (pcall (. state.mode :leave)))
    (false msg) (print state.mode-name "leave error" msg))
  (let [mode (require new-mode-name)]
    (when (and mode.activate (not (. activated-modes mode)))
      (case (pcall mode.activate ...)
        (false msg) (print new-mode-name "activate error" msg)
        _ (tset activated-modes mode true)))
    (case (and mode.enter (pcall mode.enter ...))
      (false msg) (print new-mode-name "enter error" msg))
    (set state.mode mode)
    (set state.mode-name new-mode-name)))

(fn love.load [_args]
  (set-mode :mode-intro)
  ;; the nearest filter allows you to get sharp pixel-art style scaling;
  ;; if you want perfect pixel alignment you can draw to canvas and
  ;; then draw that canvas scaled
  (love.graphics.setDefaultFilter "nearest" "nearest")
  (when (~= :Web (love.system.getOS)) (repl.start)))

(fn safely [f]
  (xpcall f #(set-mode :error-mode state.mode-name $ (fennel.traceback))))

(fn love.draw []
  (love.graphics.scale scale)
  (safely state.mode.draw))

;; you can wrap other love callbacks, such as love.mousepressed
;; love.mousemoved, love.mousereleased, love.keypressed in a similar
;; way to love.update.
(fn love.update [dt]
  ;; put global updates here
  (when state.mode.update
    ;; passing in set-mode to update restricts when you can switch modes
    (safely #(state.mode.update dt set-mode))))

(fn love.keyreleased [key code isrepeat]
  ;; put global keyrelease actions you want here
  (if (and (love.keyboard.isDown "lctrl" "rctrl" "capslock") (= key "q"))
      (love.event.quit)
      ;; add what each keypress should do in each mode
      (not isrepeat)
      (safely #(state.mode.keyreleased key code set-mode))))
