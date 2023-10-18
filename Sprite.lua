--[[
]]

Class = require 'external_modules/hump/class'

Sprite = Class{}

function Sprite:init(opt)
   self.image = love.graphics.newImage(opt.image)
   self.pos = opt.pos or {
      x = 0,
      y = 0,
   }
   self.velocity = opt.velocity or {
      x = 200 * scale.x,
      y = 0 * scale.y,
      rotate = 0.4
   }
   self.scale = opt.scale or {
      x = 0.5 * scale.x,
      y = 0.5 * scale.y
   }
   self.angle = opt.angle or 0
   self.dir = opt.dir or {
      x = 1,
      y = 1
   }
end

function Sprite:transform()
   local transform = love.math.newTransform()

   transform:translate(self.pos.x, self.pos.y)
   transform:rotate(self.angle)
   transform:scale(self.scale.x, self.scale.y)

   return transform
end
