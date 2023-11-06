Class = require 'external_modules/hump/class'

PaddleController = Class{}


function PaddleController:init(entity, speed)
   self.entity = entity
   self.speed = speed

   self.sounds = {
      wall_hit = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
   }
end

function PaddleController:update_physics(dt)
   local entity = self.entity
end

function PaddleController:update(dt)
   local entity = self.entity
   local pos = entity.pos

   local dir = { x = 0, y = 0, z = 0 }

   if love.keyboard.isDown('up') then
      dir.y = 1
   end
   if love.keyboard.isDown('down') then
      dir.y = -1
   end
   if love.keyboard.isDown('left') then
      dir.z = -1
   end
   if love.keyboard.isDown('right') then
      dir.z = 1
   end

   pos.x = pos.x + dir.x * self.speed * dt
   pos.y = pos.y + dir.y * self.speed * dt
   pos.z = pos.z + dir.z * self.speed * dt

   entity.pos = pos
end

function PaddleController:draw()
end
