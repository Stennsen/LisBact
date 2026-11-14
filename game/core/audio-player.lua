local AudioPlayer = {}
AudioPlayer.__index = AudioPlayer

function AudioPlayer:newMusicPlayer(filePath)
  local music = AudioPlayer:new(filePath,"stream")
  music.source:setLooping(true)
  return music
end

function AudioPlayer:newSoundPlayer(filePath)
  return AudioPlayer:new(filePath,"static")
end

--[[
sourceType = "static" or "stream"
A good rule of thumb is to use stream for music files and static for all short sound effects. 
Basically, you want to avoid loading large files into memory at once. 
--]]
function AudioPlayer:new (filePath, sourceType)
  local audioPlayer = setmetatable({}, self)

  audioPlayer.filePath = filePath
  audioPlayer.sourceType = sourceType
  audioPlayer.source = love.audio.newSource(filePath, sourceType)

  return audioPlayer
end

-- Play the sound only when the source is currently not playing something --
function AudioPlayer:play(randomPitch)
  if self.source:isPlaying() then 
    return 
  end

  if randomPitch then
    self:randomizePitch()
  end

  self.source:play()
  print("Start playing '" .. self.filePath .. "' with sourceType '" .. self.sourceType .."'")
end

-- Play the sound whether regardless of the current playing state of the source --
function AudioPlayer:playOneShot(randomPitch)
  if self.source:isPlaying() then 
    self.source:stop()
  end
  self:play(randomPitch)
end

function AudioPlayer:stop()
  if not self.source:isPlaying() then 
    return 
  end
  self.source:stop()
  print("Stop playing '" .. self.filePath .. "' with sourceType '" .. self.sourceType .."'")
end

function AudioPlayer:pause()
  if not self.source:isPlaying() then 
    return 
  end
  self.source:pause()
  print("Paused playing '" .. self.filePath .. "' with sourceType" )
end

function AudioPlayer:isPlaying()
  return self.source:isPlaying()
end

-- Stops playback and frees the underlying LÖVE source right away instead of
-- waiting for the garbage collector. The player must not be used afterwards.
function AudioPlayer:release()
  if self.source == nil then
    return
  end
  self.source:stop()
  self.source:release()
  self.source = nil
end

function AudioPlayer:randomizePitch()
  self.source:setPitch(1 + math.random())
end

function AudioPlayer:resetPtich()
  self.source:setPitch(1)
end

return AudioPlayer

