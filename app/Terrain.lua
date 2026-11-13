local dream = require("../external_modules/3DreamEngine/3DreamEngine")

local ode = require('moonode')
local glmath = require('moonglmath')
local mi = require("moonimage")

local ffi = require("ffi")
local bit = require('bit')

local vec3 = glmath.vec3
local mat4 = glmath.mat4

Class = require '../external_modules/hump/class'

Terrain = Class{}

function Terrain:init(opt)
  self.filename = opt.filename or "assets/textures/black_wallpaper.jpg"
end

function Terrain:load()
  local filename, req_channels, req_channel_type = self.filename, "y", 'u16'
  --filename = "assets/textures/black_wallpaper.jpg"

  local w, h, channels = mi.info(filename)
  print("info", w, h, channels)

  local data, w, h, channels = mi.load(filename, req_channels, req_channel_type)
  print("data", #data, type(data), w, h, channels)

  self.data = data
  self.w = w
  self.h = h
  self.channels = channels

  local ptr = ffi.cast("uint16_t*", ffi.new("char[?]", #data, data))

  print("-----------")
  for y=0, 10 do
    for x=0, 10 do
      local i = y * w + x
      local v = ptr[i]
      printf(" %0x", v)
    end
    printf("\n")
  end
  print("-----------")
end
