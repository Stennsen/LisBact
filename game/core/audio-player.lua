local AudioPlayer = {}
AudioPlayer.__index = AudioPlayer

function AudioPlayer:newMusicPlayer(filePath)
  return AudioPlayer:new(filePath,"stream")
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

function AudioPlayer:randomizePitch()
  self.source:setPitch(1 + math.random())
end

function AudioPlayer:resetPtich()
  self.source:setPitch(1)
end

return AudioPlayer

