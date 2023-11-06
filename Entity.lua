Class = require 'external_modules/hump/class'

Entity = Class{}

function Entity:init(opt)
   self.mesh = opt.mesh
   self.shape = opt.shape

   -- NOTE KI default just a bit front of camera to avoid "lost" entity
   self.pos = opt.pos or {
      x = 0,
      y = 0,
      z = -3,
   }
   self.radius = 1.0
   self.velocity = opt.velocity or {
      x = 0,
      y = 0,
      z = 0,
   }
   self.angular = opt.angular or {
      x = 0,
      y = 0,
      z = 0,
   }
   self.scale = opt.scale or {
      x = 1,
      y = 1,
      z = 1,
   }
   self.rotation = opt.rotation or {
      x = 0,
      y = 0,
      z = 0
   }
end

function Entity:updateShape(dt)
   local shape = self.shape
   local p = shape:get_position()

--   printf("pos: {%f, %f, %f}\n", p[1], p[2], p[3])

   self.pos.x = p[1]
   self.pos.y = p[2]
   self.pos.z = p[3]

   if self.pos.y < -10 then
      p[2] = 2
      shape:set_position(p)
   end
end

function Entity:update(dt)
   local mesh = self.mesh

   if self.shape then
      self:updateShape()
   end

   mesh:resetTransform()
      :translate(self.pos.x, self.pos.y, self.pos.z)
      :rotateY(self.rotation.y)
      :rotateX(self.rotation.x)
      :rotateZ(self.rotation.z)
      :scale(self.scale.x, self.scale.y, self.scale.z)
end
