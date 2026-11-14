(local stats (require :core/swarm-stats))
(local stat (stats:new))

(local worldPowerUpManager (require :core/world-power-up-manager))
(local manager (worldPowerUpManager:new 5))

(fn randomStateChange []
  "Picks one of the drawn stats at random and raises or lowers it by 1."
  (let [target (. stat.drawnStats (love.math.random (length stat.drawnStats)))
        delta (if (= (love.math.random 2) 1) 1 -1)]
    (target:setAmount (+ (target:getAmount) delta))))

{:activate (fn _activate [])
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
    (let [[x y] [(love.mouse.getPosition)]]
    (manager:draw)
    (stat:draw x y))
 )
 :update (fn _update [state dt _set-mode]
    (manager:update dt)
    state)
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] 
     (if (= _key :space) (randomStateChange))
     (if (= _key :p) (manager:consumeRandomPowerUp stat))
 state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode]
 state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state) }
