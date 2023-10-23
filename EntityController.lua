--[[
]]

Class = require 'external_modules/hump/class'

EntityController = Class{}


function EntityController:init(entity, arena, opt)
   opt = opt or {}
   self.entity = entity
   self.arena = arena
   self.sound = opt.sound or false

   self.sounds = {
      wall_hit = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
   }
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

   if sound and self.sound then
      self.sounds[sound]:play()
   end
end

function EntityController:update(dt)
   self:update_physics(dt)
   self.entity:update(dt)
end

function EntityController:draw()
end
