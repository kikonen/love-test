--[[
]]

local dream = require("external_modules/3DreamEngine/3DreamEngine")
local physics = require("external_modules/3DreamEngine/extensions/physics/init")

require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'EntityController'
require 'PaddleController'

Class = require 'external_modules/hump/class'

Game = Class{}

function Game:init(opt)
   self.meshes = {}
   self.objects = {}
   self.controllers = {}
   self.virtual_size = opt.virtual_size
   self.virtual_scale = opt.virtual_scale

   self.arena = {
      size = {
         w = 6,
         h = 4,
         d = 10,
      },
      pos = {
         x = 0,
         y = 0,
         z = -4
      }
   }
end

function Game:load()
   do
      local controller = DaisyController(
         Sprite({
               image = 'assets/images/daisy.png',
               pos = {
                  x = self.virtual_size.w / 2,
                  y = self.virtual_size.h / 4
               },
               scale = {
                  x = 0.25,
                  y = 0.25
               }
         }),
         self.virtual_size,
         self.virtual_scale
      )
      table.insert(self.controllers, controller)
   end

   self.meshes = self:loadMeshes()
   self.objects = self:setupObjects(meshes)

   self:setupEntities()
end

function Game:loadMeshes()
   local meshes = {}
--   loadQuad(meshes)
--   loadWall(meshes)

   return meshes
end

function Game:setupObjects(meshes)
   return {
      cube = self:setupCube(),
      ball_1 = self:setupBall1(),
      ball_2 = self:setupBall2(),

      paddle = self:setupPaddle(),
      arena = self:setupArena(),

      daisy = self:setupDaisy(),
   }
end

-- function Game:loadQuad(meshes)
--    local material = dream:newMaterial()
--    material:setAlbedoTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Color.png")
--    material:setNormalTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_NormalGL.png")
--    material:setMetallicTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Metalness.png")
--    material:setRoughnessTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Roughness.png")
--    dream:registerMaterial(material, "rusty_metal")

--    meshes.quad = dream:loadObject(
--       "assets/models/quad"
--    )
--    meshes.quad:setMaterial(material)
-- end

function Game:loadWall()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Color.png")
   material:setNormalTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Roughness.png")
   material:throwsShadow(false)
   --dream:registerMaterial(material, "rusty_metal")

   local object = dream:loadObject(
      "assets/models/quad"
   )
   object:setMaterial(material)

   return object
end

function Game:setupDaisy()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/images/daisy.png")

   local object = dream:loadObject(
      "assets/models/quad"
   )
   object:setMaterial(material)

   return object
end

function Game:setupCube()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/brick_01.png")
   material:setNormalTexture("assets/textures/brick_01_NRM.png")
   material:setMetallic(1.0)
   material:setRoughness(0.5)

   local object = dream:loadObject(
      "assets/models/texture_cube"
   )
   object:setMaterial(material)

   return object
end

function Game:setupBall1()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/images/daisy.png")
   material:setMetallic(1.0)
   material:setRoughness(0.5)

   local object = dream:loadObject(
      "assets/models/texture_ball"
   )
   object:setMaterial(material)

   return object
end

function Game:setupBall2()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_Color.png")
   material:setNormalTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/Metal007_1K/Metal007_1K_Roughness.png")
   dream:registerMaterial(material, "gold")

   local object = dream:loadObject(
      "assets/models/texture_ball"
   )
   object:setMaterial(material)

   return object
end

function Game:setupPaddle()
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/MetalPlates001_1K-PNG/MetalPlates001_1K_Color.png")
   material:setNormalTexture("assets/textures/MetalPlates001_1K-PNG/MetalPlates001_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/MetalPlates001/MetalPlates001_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/MetalPlates001_1K-PNG/MetalPlates001_1K_Roughness.png")

   local object = dream:loadObject(
      "assets/models/texture_cube"
   )
   object:setMaterial(material)

   return object
end

function Game:setupArena()
   local quad = self:loadWall()
   local arenaMesh = dream:newObject()

   local arena = self.arena

   local r = 3
   local x = arena.pos.x
   local y = arena.pos.y
   local z = arena.pos.z
   local w = arena.size.w
   local h = arena.size.h
   local d = arena.size.d

   -- back
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + 0, y + 0, z + -d)
      transform = transform:rotateY(math.rad(0))
      transform = transform:scale(w / 2, h / 2, 1)

      arenaMesh.objects[1] = quad:clone()
      arenaMesh.objects[1]:setTransform(transform)
   end
   -- front
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + 0, y + 0, z + 0)
      transform = transform:rotateY(math.rad(180))
      transform = transform:scale(w / 2, h / 2, 1)

      arenaMesh.objects[2] = quad:clone()
      arenaMesh.objects[2]:setTransform(transform)
   end
   -- left
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + -w / 2, y + 0, z + -d / 2)
      transform = transform:rotateY(math.rad(270))
      transform = transform:scale(d / 2, h / 2, 1)

      arenaMesh.objects[3] = quad:clone()
      arenaMesh.objects[3]:setTransform(transform)
   end
   -- right
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + w / 2, y + 0, z + -d / 2)
      transform = transform:rotateY(math.rad(90))
      transform = transform:scale(d / 2, h / 2, 1)

      arenaMesh.objects[4] = quad:clone()
      arenaMesh.objects[4]:setTransform(transform)
   end
   -- top
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + 0, y + h / 2, z + -d / 2)
      transform = transform:rotateX(math.rad(90))
      transform = transform:scale(w / 2, d / 2, 1)

      arenaMesh.objects[5] = quad:clone()
      arenaMesh.objects[5]:setTransform(transform)
   end
   -- bottom
   do
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(x + 0, y + -h / 2, z + -d / 2)
      transform = transform:rotateX(math.rad(270))
      transform = transform:scale(w / 2, d / 2, 1)

      arenaMesh.objects[6] = quad:clone()
      arenaMesh.objects[6]:setTransform(transform)
   end

   return arenaMesh
end

function Game:setupEntities()
   local objects = self.objects
   local arena = self.arena

   -- daisy
   do
      local mesh = objects.daisy
      local shape = physics:newCapsule(0.25, 0.25, 0.25)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = 0,
               y = 0,
               z = self.arena.pos.z - 0.3
            },
            radius = 0.5,
            velocity = {
               x = 1,
               y = 0,
               z = 0,
            },
            angular = {
               x = 0,
               y = 0,
               z = 0,
            },
            scale = {
               x = 0.25,
               y = 0.25,
               z = 0.25,
            },
      })

      table.insert(
         self.controllers,
         EntityController(
            entity,
            arena,
            {
               sound = 'Hollow Impact 1_7B5F5EA0_normal.ogg'
            }
      ))
   end

   -- cube
   do
      local mesh = objects.cube
      local shape = physics:newCapsule(0.5, 0.5, 0.5)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = 0,
               y = 0,
               z = arena.pos.z - arena.size.d / 2
            },
            velocity = {
               x = 0,
               y = 0,
               z = 0,
            },
            angular = {
               x = 0,
               y = 1,
               z = 0,
            },
            scale = {
               x = 0.25,
               y = 0.25,
               z = 0.25,
            },
      })
      table.insert(
         self.controllers,
         EntityController(
            entity,
            arena
      ))
   end

   -- ball 1
   do
      local mesh = objects.ball_1
      local shape = physics:newCapsule(0.5, 0.5, 0.5)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = 0,
               y = 0,
               z = arena.pos.z - arena.size.d / 2
            },
            velocity = {
               x = 1,
               y = 0.5,
               z = 0.3,
            },
            angular = {
               x = -0.9,
               y = -0.3,
               z = -0.4,
            },
            scale = {
               x = 0.5,
               y = 0.5,
               z = 0.5,
            },
      })

      table.insert(
         self.controllers,
         EntityController(
            entity,
            arena,
            {
               sound = 'Short Impact  08_F0C9A944_normal.ogg'
            }
      ))
   end

   -- ball 2
   do
      local mesh = objects.ball_2
      local shape = physics:newCapsule(0.25, 0.25, 0.25)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = -1,
               y = 1.5,
               z = arena.pos.z - arena.size.d / 2
            },
            velocity = {
               x = 1,
               y = -0.5,
               z = -0.4,
            },
            angular = {
               x = -0.9,
               y = -0.3,
               z = -0.4,
            },
            scale = {
               x = 0.25,
               y = 0.25,
               z = 0.25,
            },
      })

      table.insert(
         self.controllers,
         EntityController(
            entity,
            arena,
            {
               sound = 'Short Impact  07_11453D7E_normal.ogg'
            }
      ))
   end

   do
      local mesh = objects.paddle
      local shape = physics:newObject(mesh)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = arena.pos.x + arena.size.w / 2 - 0.2,
               y = arena.pos.y,
               z = arena.pos.z - arena.size.d / 4
            },
            velocity = {
               x = 0,
               y = 0,
               z = 0,
            },
            rotation = {
               x = 0,
               y = 0,
               z = 0
            },
            scale = {
               x = 0.1,
               y = 0.5,
               z = 0.5,
            },
      })

      table.insert(
         self.controllers,
         PaddleController(
            entity,
            5
      ))

      table.insert(
         self.controllers,
         EntityController(
            entity,
            arena
      ))
   end
end
