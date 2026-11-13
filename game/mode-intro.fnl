;; example module mode

(import-macros {: incf} :sample-macros)

(local countdown-time 300)

;; variables stored in other modules will not be reset when this module is.
;; i.e. store things in state you want to persist accross hot reloads
;; this would also be a good place to store data that is required accross several
;; modes
(local state (require :state))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (set state.version [(love.getVersion)])
             (love.graphics.setNewFont 30))
 :enter (fn _enter [])
 :leave (fn _leave [])
 :draw (fn _draw [_message]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.printf (: "Love Version: %s.%s.%s" :format
                                    (unpack state.version))
                                 0 10 w :center)
           (love.graphics.printf (: "This window should close in %0.1f seconds"
                                    :format (math.max 0 (- countdown-time state.time)))
                                 0 (- (/ h 2) 15) w :center)))
 :update (fn _update [dt _set-mode]
           (if (< state.counter 65535)
               (set state.counter (+ state.counter 1))
               (set state.counter 0))
           (incf state.time dt)
           (when (< countdown-time state.time)
             (set state.time 0)
             (love.event.quit)))
 :keyreleased (fn _keyreleased [_key _code _set-mode])}
