--[[
]]

Class = require 'external_modules/hump/class'

DaisyController = Class{}


function DaisyController:init(sprite)
   self.sprite = sprite

   self.sounds = {
      wall_hit = love.audio.newSource('assets/sounds/wall_hit.wav', 'static')
   }
end

function DaisyController:update_keydown(dt)
   local sprite = self.sprite

   if love.keyboard.isDown('+') then
      sprite.velocity.x = sprite.velocity.x + 1
   elseif love.keyboard.isDown('-') then
      sprite.velocity.x = sprite.velocity.x - 1
   end
end

function DaisyController:update_physics(dt)
   local sprite = self.sprite
   local sound = nil

   sprite.pos.x = sprite.pos.x + dt * sprite.velocity.x * sprite.dir.x
   sprite.angle = sprite.angle + dt * sprite.velocity.rotate * sprite.dir.x

   if sprite.pos.x <= sprite.center.x * sprite.scale.x then
      sprite.pos.x = sprite.center.x * sprite.scale.x
      sprite.dir.x = -sprite.dir.x
      sound = 'wall_hit'
   elseif sprite.pos.x >= VIRTUAL_WIDTH - sprite.center.x * sprite.scale.x then
      sprite.pos.x = VIRTUAL_WIDTH - sprite.center.x * sprite.scale.x
      sprite.dir.x = -sprite.dir.x
      sound = 'wall_hit'
   end

   if sound then
      self.sounds[sound]:play()
   end
end

function DaisyController:update(dt)
   self:update_keydown(dt)
   self:update_physics(dt)
end

function DaisyController:draw()
   local sprite = self.sprite
   love.graphics.draw(sprite.image, sprite:transform())
end
