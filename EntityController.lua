Class = require 'external_modules/hump/class'

EntityController = Class{}


function EntityController:init(opt)
  self.entity = opt.entity
  self.arena = opt.arena
  self.sounds = opt.sounds or {}
end

function EntityController:update_physics(dt)
  local entity = self.entity
  local sound = nil

  local sca = entity.scale
  local rad = entity.radius
  local vel = entity.velocity
  local ang = entity.angular
  local pos = entity.pos
  local rot = entity.rotation

  pos.x = pos.x + dt * vel.x
  pos.y = pos.y + dt * vel.y
  pos.z = pos.z + dt * vel.z

  rot.x = rot.x + dt * ang.x
  rot.y = rot.y + dt * ang.y
  rot.z = rot.z + dt * ang.z

  local arena = self.arena
  local max_x = arena.pos.x + arena.size.w / 2 - rad * sca.x
  local min_x = arena.pos.x + -max_x
  local max_y = arena.pos.y + arena.size.h / 2 - rad * sca.y
  local min_y = arena.pos.y +  -max_y
  local max_z = arena.pos.z + -rad * sca.z
  local min_z = arena.pos.z + -(arena.size.d - rad * sca.z)

  if pos.x <= min_x then
    pos.x = min_x
    vel.x = -vel.x
    ang.x = -ang.x
    sound = 'hit'
  elseif pos.x >= max_x then
    pos.x = max_x
    vel.x = -vel.x
    ang.x = -ang.x
    sound = 'hit'
  end

  if pos.y <= min_y then
    pos.y = min_y
    vel.y = -vel.y
    ang.y = -ang.y
    sound = 'hit'
  elseif pos.y >= max_y then
    pos.y = max_y
    vel.y = -vel.y
    ang.y = -ang.y
    sound = 'hit'
  end

  if pos.z <= min_z then
    pos.z = min_z
    vel.z = -vel.z
    ang.z = -ang.z
    sound = 'hit'
  elseif pos.z >= max_z then
    pos.z = max_z
    vel.z = -vel.z
    ang.z = -ang.z
    sound = 'hit'
  end

  entity.rotation = rot
  entity.pos = pos
  entity.velocity = vel
  entity.angular = ang

  if sound and self.sounds[sound] then
    love.audio.stop()
    self.sounds[sound]:play()
  end

  entity:update(dt)
end

function EntityController:update_collisions(dt)
  if not collider then return end

  local body = collider.body
  local x, z = body:getPosition()
  local pos = {
    x = x,
    y = collider.y,
    z = z,
  }

  if pos.y < -10 or pos.y > 3 then
    x = 0
    print(string.format("(%f, %f, %f)", pos.x, pos.y, pos.z))
    debug.debug()
  end

  self.entity.pos = pos
end

function EntityController:update(dt)
  self:update_physics(dt)
end

function EntityController:draw()
end
