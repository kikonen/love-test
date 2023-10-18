--[[
]]

Class = require 'external_modules/hump/class'

DaisyController = Class{}


function DaisyController:init(sprite)
   self.sprite = sprite
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

   sprite.pos.x = sprite.pos.x + dt * sprite.velocity.x * sprite.dir.x
   sprite.angle = sprite.angle + dt * sprite.velocity.rotate * sprite.dir.x

   if sprite.pos.x <= 0 then
      sprite.pos.x = 0
      sprite.dir.x = -  sprite.dir.x
   elseif sprite.pos.x >= VIRTUAL_WIDTH - sprite.image:getWidth() * sprite.scale.x then
      sprite.pos.x = VIRTUAL_WIDTH - sprite.image:getWidth() * sprite.scale.x
      sprite.dir.x = -  sprite.dir.x
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
