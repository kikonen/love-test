local dream = require("external_modules/3DreamEngine/3DreamEngine")
local glmath = require('moonglmath')

local vec3 = glmath.vec3

Class = require 'external_modules/hump/class'

local IM = dream.mat4.getIdentity()

Entity = Class{}

function Entity:init(opt)
  self.id = opt.id
  self.object = opt.object
  self.shape = opt.shape

  self.scale = opt.scale or { 1, 1, 1 }

  self.sounds = opt.sounds

  self.positionMatrix = dream.mat4.getIdentity()
  self.rotationMatrix = dream.mat4.getIdentity()
end

function Entity:updateShape(dt)
  local shape = self.shape
  if not shape then return end

  local p = shape:get_position()
  local r = shape:get_rotation()

  local pm = dream.mat4.getIdentity()
  local tm = dream.mat4.getIdentity()

  if p[2] < -10 then
    p[2] = 2
    shape:set_position(p)
  end

  pm[4 * 1] = p[1]
  pm[4 * 2] = p[2]
  pm[4 * 3] = p[3]

  for i, row in ipairs(r) do
    for j, k in ipairs(row) do
      tm[(i - 1) * 4 + j] = k
    end
  end

  self.positionMatrix = pm
  self.rotationMatrix = tm
end

function Entity:update(dt)
  local object = self.object

  self:updateShape(dt)

  object.transform = self.positionMatrix * self.rotationMatrix

  object:scale(self.scale.x, self.scale.y, self.scale.z)

  object:setDirty()
end
