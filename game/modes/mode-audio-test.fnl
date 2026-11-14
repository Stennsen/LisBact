(local audioPlayer (require :core/audio-player))
(local backgroundMusic (audioPlayer:newMusicPlayer "assets/audiofiles/example-music.ogg"))
(local sound (audioPlayer:newSoundPlayer "assets/audiofiles/example-effect.wav"))

(local big-font (love.graphics.setNewFont 48))
(local small-font (love.graphics.setNewFont 16))

{:activate (fn _activate [])
 :enter (fn _enter [state] 
    (backgroundMusic:play)
    state)
 :leave (fn _leave [state] 
    (backgroundMusic:stop)
    state)
 :draw (fn _draw [state]
         (let [[w h] [(love.window.getMode)]]
           (love.graphics.setFont big-font)
           (love.graphics.print "Audio test" 200 150)
           (love.graphics.setFont small-font)
           (love.graphics.print "Pressy SPACE to play a sound" 200 250)) )
 :update (fn _update [state dt _set-mode] state)
 :keyreleased (fn _keyreleased [state _key _code _is-repeat _set-mode] state)
 :keypressed (fn _keypressed [state _key _code _is-repeat _set-mode] 
    (if (= _key :space) (sound:playOneShot true))
    state)
 :mousemoved (lambda [state _x _y _dx _dy _set-mode] state)
 :mousepressed (lambda [state _key _scancode _is-repeat _set-mode] state)
 :mousereleased (lambda [state _key _scancode _is-repeat _set-mode] state) }
