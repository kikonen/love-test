local ode = require('moonode')

Class = require 'external_modules/hump/class'

PaddleController = Class{}

local MAX_SPEED = 500

function PaddleController:init(opt)
  self.entity = opt.entity
  self.speed = opt.speed
  self.world_container = opt.world_container
  self.sounds = opt.sounds or {}
end

function PaddleController:update_physics(dt)
  local entity = self.entity
end

function PaddleController:update(dt)
  local world = self.world_container.world
  local space = self.world_container.space
  local ode = self.world_container.ode

  local body = self.entity.shape:get_body()
  local v = body:get_linear_vel()
  local x, y, z = v[1], v[2], v[3]
  local x, y, z = 0, 0, 0

  local dir = { x = 0, y = 0, z = 0 }

  if love.keyboard.isDown('up') then
    dir.z = -1
  end
  if love.keyboard.isDown('down') then
    dir.z = 1
  end
  if love.keyboard.isDown('left') then
    dir.x = -1
  end
  if love.keyboard.isDown('right') then
    dir.x = 1
  end
  if love.keyboard.isDown('home') then
    dir.y = 1
  end
  if love.keyboard.isDown('end') then
    dir.y = -1
  end

  x = x + dir.x * self.speed * dt
  y = y + dir.y * self.speed * dt
  z = z + dir.z * self.speed * dt

  x = math.min(math.max(x, -MAX_SPEED), MAX_SPEED)
  y = math.min(math.max(y, -MAX_SPEED), MAX_SPEED)
  z = math.min(math.max(z, -MAX_SPEED), MAX_SPEED)

  local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)

  body:set_quaternion(q)
  body:set_linear_vel({x, y, z})
end

function PaddleController:draw()
end
