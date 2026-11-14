;; wraps love callbacks

(local fennel (require :lib.fennel))
(local repl (require :lib.stdio))

(local { : get-dependencies : reset-dependencies } (require :mod-reflect))

(local scale 1)

;; Used for defining start scene
(var initial-state-mode-name :map)

(var state-mode nil)
(var state-mode-name initial-state-mode-name)

(local state (require :state))
(var state-state (state.init))
(var state-error nil)

(local activated-modes {})

(local debug-font (love.graphics.setNewFont 16))

(fn set-state [new-state] (set state-state new-state))

(fn set-error [err] (set state-error err))

(fn reset-error [] (set-error nil))

(fn mode-name [mn] (.. :modes. mn))

(macro call-mode-with-state [method & params]
  (let [fcall `(pcall ,(sym (.. :state-mode. method)) state-state ,(unpack params))]
    `(let [(ret# val#) ,fcall] (if ret# val# (do (set-error val#) state-state)))))

(macro not-in-web [expr]
  `(when (~= :Web (love.system.getOS)) ,expr))

(fn set-mode [new-mode-name ...]
  (print new-mode-name)
  (if state-mode (set-state ((. state-mode :leave) state-state)))
  (let [mode (require (mode-name new-mode-name))]
    (when (not (. activated-modes new-mode-name))
      (mode.activate)
      (tset activated-modes new-mode-name true))
    (set-state ((. mode :enter) state-state))
    (set state-mode mode)
    (set state-mode-name new-mode-name)))

(fn reload-module! [mod]
    (print (string.format "Reloading module %s" mod))
    (reset-dependencies mod)
    (let [old (require mod)
        _ (tset package.loaded mod nil)
        new (require mod)]
    (when (= (type new) :table)
      (each [k v (pairs new)]
        (tset old k v))
      (each [k _v (pairs old)]
        (when (not (. new k))
          (tset old k nil)))
      (tset package.loaded mod old))))

(fn reload-mode! [mode]
  (let [mn (mode-name mode)]
    (each [k _v (pairs (get-dependencies mn))] (reload-module! k))
    (reload-module! mn)))

(fn draw-error [] (love.graphics.setFont debug-font)
  (love.graphics.clear 0.5 0.5 0.5)
  (love.graphics.setColor 1.0 0 0)
  (love.graphics.print "Caught error:" 15 10)
  (love.graphics.print state-error 30 30)
  (love.graphics.setColor 1 1 1)
  (not-in-web (love.graphics.print "r to reload current mode" 15 70))
  (love.graphics.print "i to ignore the error" 15 90)
  (love.graphics.print "q to quit" 15 110))

(fn keyreleased-error [key _code]
  (case key
    "q" (love.event.quit)
    "r" (reload-mode! state-mode-name)
    "i" (reset-error)))

(fn love.load [_args]
  (set-mode initial-state-mode-name)
  ;; the nearest filter allows you to get sharp pixel-art style scaling;
  ;; if you want perfect pixel alignment you can draw to canvas and
  ;; then draw that canvas scaled
  (love.graphics.setDefaultFilter "nearest" "nearest"))

(fn love.draw []
  (love.graphics.scale scale)
  (if state-error (draw-error)
    (call-mode-with-state :draw)))

;; you can wrap other love callbacks, such as love.mousepressed
;; love.mousemoved, love.mousereleased, love.keypressed in a similar
;; way to love.update.
(fn love.update [dt]
  (set-state (call-mode-with-state :update dt set-mode)))

(fn love.keyreleased [key code isrepeat]
  (if state-error (keyreleased-error key code)
    (do
      (not-in-web (if (and (love.keyboard.isDown "lctrl" "rctrl") (= key "r")) (reload-mode! state-mode-name)))
      (set-state (state-mode.keyreleased state-state key code isrepeat set-mode)))))

(fn love.keypressed [key code isrepeat] (set-state (call-mode-with-state :keypressed key code isrepeat set-mode)))

(fn love.mousemoved [x y dx dy _is-touch] (set-state (call-mode-with-state :mousemoved x y dx dy set-mode)))

(fn love.mousepressed [key scancode isrepeat] (set-state (call-mode-with-state :mousepressed key scancode isrepeat set-mode)))

(fn love.mousereleased [key scancode isrepeat] (set-state (call-mode-with-state :mousereleased key scancode isrepeat set-mode)))

(set-mode initial-state-mode-name)
