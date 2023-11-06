Class = require 'external_modules/hump/class'

DaisyController = Class{}


function DaisyController:init(sprite, virtual_size, virtual_scale)
   self.sprite = sprite
   self.virtual_size = virtual_size
   self.virtual_scale = virtual_scale

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
   local limits = self.virtual_size
   local vs = self.virtual_scale
   local sound = nil

   sprite.pos.x = sprite.pos.x + dt * sprite.velocity.x * vs.w * sprite.dir.x
   sprite.angle = sprite.angle + dt * sprite.velocity.rotate * -sprite.dir.x

   if sprite.pos.x <= sprite.center.x * sprite.scale.x * vs.w then
      sprite.pos.x = sprite.center.x * sprite.scale.x * vs.w
      sprite.dir.x = -sprite.dir.x
      sound = 'wall_hit'
   elseif sprite.pos.x >= limits.w - sprite.center.x * sprite.scale.x * vs.w then
      sprite.pos.x = limits.w - sprite.center.x * sprite.scale.x * vs.w
      sprite.dir.x = -sprite.dir.x
      sound = 'wall_hit'
   end

   if sound then
--      self.sounds[sound]:play()
   end
end

function DaisyController:update(dt)
   self:update_keydown(dt)
   self:update_physics(dt)
end

function DaisyController:draw()
   local sprite = self.sprite
   love.graphics.draw(sprite.image, sprite:transform(self.virtual_scale))
end
