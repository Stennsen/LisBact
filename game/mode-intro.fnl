;; example module mode

(import-macros {: incf} :sample-macros)

(local countdown-time 300)

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.printf (: "This window should close in %0.1f seconds"
                                    :format (math.max 0 (- countdown-time state.time)))
                                 0 (- (/ h 2) 15) w :center)))
 :update (fn _update [state dt _set-mode]
            (local new-time (+ state.time dt))
            (if (< countdown-time new-time) 
              (do (love.event.quit) { :time 0 }) { :time new-time }))
 :keyreleased (fn _keyreleased [_key _code _set-mode]) }
