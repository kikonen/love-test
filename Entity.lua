--[[
]]

Class = require 'external_modules/hump/class'

Entity = Class{}

function Entity:init(opt)
   self.mesh = opt.mesh
   self.pos = opt.pos or {
      x = 0,
      y = 0,
      z = -3,
   }
   self.radius = 1.0
   self.velocity = opt.velocity or {
      x = 1,
      y = 0.5,
      z = 0,
      a = -0.9
   }
   self.scale = opt.scale or {
      x = 0.5,
      y = 0.5,
      z = 0.5,
   }
   self.rotation = opt.rotation or {
      x = 0,
      y = 0,
      z = 0
   }
end

function Entity:update(dt)
   local mesh = self.mesh
   mesh:resetTransform()
   mesh:translate(self.pos.x, self.pos.y, self.pos.z)
   mesh:scale(self.scale.x, self.scale.y, self.scale.z)
   mesh:rotateX(self.rotation.x)
   mesh:rotateY(self.rotation.y)
   mesh:rotateZ(self.rotation.z)
end
