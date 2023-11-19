local dream = require("../external_modules/3DreamEngine/3DreamEngine")
local glmath = require('moonglmath')

local vec3 = glmath.vec3
local mat4 = glmath.mat4

Class = require '../external_modules/hump/class'

Entity = Class{}

function Entity:init(opt)
  self.id = opt.id
  self.object = opt.object
  self.geom = opt.geom
  self.body = opt.geom:get_body()

  self.sounds = opt.sounds

  self.translate_matrix = mat4()
  self.rotation_matrix = mat4()
  self.scale_matrix = mat4()

  self.hits = {}

  local s = opt.scale
  if opt.scale then
    local sm = self.scale_matrix
    sm[1][1] = s.x
    sm[2][2] = s.y
    sm[3][3] = s.z
  end
end

function Entity:update_from_ode(dt)
  local body = self.body

  local p = body:get_position()
  local tm = self.translate_matrix

  tm[1][4] = p.x
  tm[2][4] = p.y
  tm[3][4] = p.z

  self.rotation_matrix = mat4(body:get_rotation())
  self.rotation_matrix[4][4] = 1
end

function Entity:update(dt)
  local object = self.object

  self:update_from_ode(dt)

  --print("T", self.translate_matrix)
  local tm = self.translate_matrix * self.rotation_matrix * self.scale_matrix
  --print(tm)
  object.transform = to_dream_mat4(tm)

  object:setDirty()
end
