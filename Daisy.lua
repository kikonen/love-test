--[[
]]

Class = require 'external_modules/hump/class'

Daisy = Class{}

function Daisy:init()
   self.image = love.graphics.newImage("images/daisy.png")
   self.pos = {
      x = 0,
      y = 0,
   }
   self.velocity = {
      x = 200 * scale.x,
      y = 0 * scale.y,
      rotate = 0.4
   }
   self.scale = {
      x = 0.5 * scale.x,
      y = 0.5 * scale.y
   }
   self.angle = 0
   self.dir = 1
end

function Daisy:transform()
   local transform = love.math.newTransform()

   transform:translate(daisy.pos.x, daisy.pos.y)
   transform:rotate(daisy.angle)
   transform:scale(daisy.scale.x, daisy.scale.y)

   return transform
end
