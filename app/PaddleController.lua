local ode = require('moonode')
local glmath = require('moonglmath')

local vec3 = glmath.vec3
local mat3 = glmath.mat3

Class = require '../external_modules/hump/class'

PaddleController = Class{}

local MAX_SPEED = 1000
local NO_ROTATION = ode.q_from_axis_and_angle({0, 1, 0}, 0)

function PaddleController:init(opt)
  self.entity = opt.entity
  self.speed = opt.speed or 200
  self.world_container = opt.world_container
  self.sounds = opt.sounds or {}
end

function PaddleController:get_dir()
  local dir = vec3()

  local kb = love.keyboard
  if kb.isDown('up') then
    dir.z = -1
  end
  if kb.isDown('down') then
    dir.z = 1
  end
  if kb.isDown('left') then
    dir.x = -1
  end
  if kb.isDown('right') then
    dir.x = 1
  end
  if kb.isDown('home') then
    dir.y = 1
  end
  if kb.isDown('end') then
    dir.y = -1
  end

  return dir
end

function PaddleController:update(dt)
  local body = self.entity.body

  local dir = self:get_dir()

  local f = nil
  if false and dir * dir == 0 then
    v = body:get_linear_vel()
    f = -v * 200
  else
    f = vec3(
      dir.x * self.speed * dt,
      dir.y * self.speed * dt,
      dir.z * self.speed * dt)
  end

  --body:add_force(f)
  body:set_linear_vel(f)

  -- NOTE KI enforce that paddle remains always straight
  body:set_quaternion(NO_ROTATION)
  body:set_angular_vel(vec3())
end

function PaddleController:draw()
end
