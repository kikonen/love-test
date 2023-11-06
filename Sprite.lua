Class = require 'external_modules/hump/class'

Sprite = Class{}

function Sprite:init(opt)
   self.image = love.graphics.newImage(opt.image)
   self.center = {
      x = self.image:getWidth() * 0.5,
      y = self.image:getHeight() * 0.5
   }
   self.pos = opt.pos or {
      x = 0,
      y = 0,
   }
   self.velocity = opt.velocity or {
      x = 200,
      y = 0,
      rotate = 0.4
   }
   self.scale = opt.scale or {
      x = 0.5,
      y = 0.5,
   }
   self.angle = opt.angle or 0
   self.dir = opt.dir or {
      x = 1,
      y = 1
   }
end

function Sprite:transform(virtual_scale)
   local transform = love.math.newTransform()

   transform:translate(self.pos.x, self.pos.y)
   transform:scale(self.scale.x * virtual_scale.w, self.scale.y * virtual_scale.h)
   transform:rotate(self.angle)
   transform:translate(-self.image:getWidth() * 0.5, -self.image:getHeight() * 0.5)

   return transform
end
