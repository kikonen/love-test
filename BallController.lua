--[[
]]

Class = require 'external_modules/hump/class'

BallController = Class{}


function BallController:init(entity, virtual_size)
   self.entity = entity
   self.virtual_size = virtual_size

   self.sounds = {
      wall_hit = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
   }
end

function BallController:update_keydown(dt)
   local entity = self.entity

   if love.keyboard.isDown('+') then
      entity.velocity.x = entity.velocity.x + 1
   elseif love.keyboard.isDown('-') then
      entity.velocity.x = entity.velocity.x - 1
   end
end

function BallController:update_physics(dt)
   local entity = self.entity
   local limits = self.virtual_size
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

   rot.x = rot.x + dt * ang.x * 0.2
   rot.y = rot.y + dt * ang.y
   rot.z = rot.z + dt * ang.z * 0.3

   local max_x = limits.w / 2 - rad * sca.x
   local min_x = -max_x
   local max_y = limits.h / 2 - rad * sca.y
   local min_y = -max_y
   local max_z = -rad * sca.z
   local min_z = -(limits.w - rad * sca.z)

   if pos.x <= min_x then
      pos.x = min_x
      vel.x = -vel.x
      ang.x = -ang.x
      sound = 'wall_hit'
   elseif pos.x >= max_x then
      pos.x = max_x
      vel.x = -vel.x
      ang.x = -ang.x
      sound = 'wall_hit'
   end

   if pos.y <= min_y then
      pos.y = min_y
      vel.y = -vel.y
      ang.y = -ang.y
      sound = 'wall_hit'
   elseif pos.y >= max_y then
      pos.y = max_y
      vel.y = -vel.y
      ang.y = -ang.y
      sound = 'wall_hit'
   end

   if pos.z <= min_z then
      pos.z = min_z
      vel.z = -vel.z
      ang.z = -ang.z
      sound = 'wall_hit'
   elseif pos.z >= max_z then
      pos.z = max_z
      vel.z = -vel.z
      ang.z = -ang.z
      sound = 'wall_hit'
   end

   entity.rotation = rot
   entity.pos = pos
   entity.velocity = vel
   entity.angular = ang

   if sound then
      self.sounds[sound]:play()
   end
end

function BallController:update(dt)
   self:update_keydown(dt)
   self:update_physics(dt)
   self.entity:update(dt)
end
