local glmath = require('moonglmath')

local vec2 = glmath.vec2
local vec3 = glmath.vec3

Class = require 'external_modules/hump/class'

Sprite = Class{}

function Sprite:init(opt)
  self.image = love.graphics.newImage(opt.image)
  self.center = vec2(
    self.image:getWidth() * 0.5,
    self.image:getHeight() * 0.5)
  self.pos = opt.pos or vec2(0, 0)
  self.velocity = opt.velocity or vec3(0, 0, 0)
  self.scale = opt.scale or vec2(0.5, 0.5)
  self.angle = opt.angle or 0
  self.dir = opt.dir or vec2(1, 1)
end

function Sprite:transform(virtual_scale)
  local transform = love.math.newTransform()

  transform:translate(self.pos.x, self.pos.y)
  transform:scale(self.scale.x * virtual_scale.w, self.scale.y * virtual_scale.h)
  transform:rotate(self.angle)
  transform:translate(-self.image:getWidth() * 0.5, -self.image:getHeight() * 0.5)

  return transform
end
