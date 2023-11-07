local dream = require("external_modules/3DreamEngine/3DreamEngine")

Class = require 'external_modules/hump/class'

local vec3, mat4 = dream.vec3, dream.mat4

Entity = Class{}

function Entity:init(opt)
   self.object = opt.object or opt.mesh
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

   self.rotationMatrix = mat4.getIdentity()
end

function Entity:updateShape(dt)
   local shape = self.shape
   local p = shape:get_position()
   local r = shape:get_rotation()

   local t = mat4.getIdentity()

   --print("----------------")
   for i,row in ipairs(r) do
      --printf("%i: ", i)
      for j,k in ipairs(row) do
         --printf("%f ", k)
         t[(i - 1) * 4 + j] = k
      end
      --printf("\n")
   end
   --print("----------------")

   self.rotationMatrix = t

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
   local object = self.object

   if self.shape then
      self:updateShape()
   end

   object:resetTransform()
      :translate(self.pos.x, self.pos.y, self.pos.z)
      :rotateY(self.rotation.y)
      :rotateX(self.rotation.x)
      :rotateZ(self.rotation.z)

   object.transform = object.transform * self.rotationMatrix

   object:scale(self.scale.x, self.scale.y, self.scale.z)
end
