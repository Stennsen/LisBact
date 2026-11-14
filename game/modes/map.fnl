(import-macros {: init-require!} :mod)

(local require-mod! (init-require! :modes.map))

(local {: pprint : render} (require :core.utils))
(local {: merge} (require :lib.lume))

{:activate (fn _activate []
             ;; only called called once. Useful for loading in large assets
             ;; like images and music
             (love.graphics.setNewFont 30))
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
         (each [_ swarm (ipairs state.swarms)]
           (render swarm)))
 :update (fn _update [state dt _set-mode]
           (merge state
                  {:swarms (icollect [_ swarm (ipairs state.swarms)]
                             (swarm:move (* 50 dt) (* 50 dt)))}))
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state)}
