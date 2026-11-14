(local stats (require :core/swarm-stats))
(local stat (stats:new))

{:activate (fn _activate [])
 :enter (fn _enter [state] state)
 :leave (fn _leave [state] state)
 :draw (fn _draw [state]
    (let [[x y] [(love.mouse.getPosition)]]
    (stat:draw (+ x 10) (+ y 10)))
 )
 :update (fn _update [state dt _set-mode] state)
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] 
     (if (= _key :up) (stat:setAttack (+ (stat:getAttack) 100)))
     (if (= _key :down) (stat:setAttack (- (stat:getAttack) 100)))
 state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode]
 state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state) }
