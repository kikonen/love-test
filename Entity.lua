local dream = require("external_modules/3DreamEngine/3DreamEngine")
local glmath = require('moonglmath')

local vec3 = glmath.vec3
local mat4 = glmath.mat4

Class = require 'external_modules/hump/class'

Entity = Class{}

function Entity:init(opt)
  self.id = opt.id
  self.object = opt.object
  self.shape = opt.shape

  self.sounds = opt.sounds

  self.translate_matrix = mat4()
  self.rotation_matrix = mat4()
  self.scale_matrix = mat4()

  local s = opt.scale
  if opt.scale then
    local sm = self.scale_matrix
    sm[1][1] = s.x
    sm[2][2] = s.y
    sm[3][3] = s.z
  end
end

function Entity:updateShape(dt)
  local shape = self.shape
  if not shape then return end

  local p = shape:get_position()
  local tm = self.translate_matrix

  tm[1][4] = p.x
  tm[2][4] = p.y
  tm[3][4] = p.z

  self.rotation_matrix = mat4(shape:get_rotation())
  self.rotation_matrix[4][4] = 1
end

function Entity:update(dt)
  local object = self.object

  self:updateShape(dt)

  --print("T", self.translate_matrix)
  local tm = self.translate_matrix * self.rotation_matrix * self.scale_matrix
  --print(tm)
  object.transform = to_dream_mat4(tm)

  object:setDirty()
end
