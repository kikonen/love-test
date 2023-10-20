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
   local pos = entity.pos
   local rot = entity.rotation

   pos.x = pos.x + dt * vel.x
   pos.y = pos.y + dt * vel.y
   pos.z = pos.z + dt * vel.z

   rot.x = rot.x + dt * vel.a * 0.2
   rot.y = rot.y + dt * vel.a
   rot.z = rot.z + dt * vel.a * 0.3

   local limit_x = limits.w / 2 - rad * sca.x
   local limit_y = limits.h / 2 - rad * sca.y

   if pos.x <= -limit_x then
      pos.x = -limit_x
      vel.x = -vel.x
      vel.a = -vel.a
      sound = 'wall_hit'
   elseif pos.x >= limit_x then
      pos.x = limit_x
      vel.x = -vel.x
      vel.a = -vel.a
      sound = 'wall_hit'
   end

   if pos.y >= limit_y then
      pos.y = limit_y
      vel.y = -vel.y
      vel.a = -vel.a
      sound = 'wall_hit'
   elseif pos.y <= -limit_y then
      pos.y = -limit_y
      vel.y = -vel.y
      vel.a = -vel.a
      sound = 'wall_hit'
   end

   entity.rotation = rot
   entity.pos = pos
   entity.velocity = vel

   if sound then
      self.sounds[sound]:play()
   end
end

function BallController:update(dt)
   self:update_keydown(dt)
   self:update_physics(dt)
   self.entity:update(dt)
end
