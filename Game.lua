local dream = require("external_modules/3DreamEngine/3DreamEngine")

require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'EntityController'
require 'PaddleController'

Class = require 'external_modules/hump/class'

Game = Class{}

local pi = math.pi

function Game:init(opt)
   self.meshes = {}
   self.objects = {}
   self.controllers = {}
   self.virtual_size = opt.virtual_size
   self.virtual_scale = opt.virtual_scale
   self.world_container = opt.world_container
   self.world_delay = opt.world_delay

   self.captureMouse = false

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

   self.entities = {}
end

function Game:load()
   if true then
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

function Game:update(dt)
   self.delay = (self.delay or 0) + dt

   if self.delay > self.world_delay then
      self.world_container:update(dt)
   end

   for _, v in pairs(self.controllers) do
      v:update(dt)
   end

   for _, v in pairs(self.entities) do
      v:update(dt)
   end
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
   local world = self.world_container.world
   local space = self.world_container.space
   local ode = self.world_container.ode

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

   -- Create a static terrain using a triangle mesh that we can collide with:
   local plane_data = nil
   do
      local meshdata = require("meshdata.world_bottom")
      local positions = ode.pack('float', meshdata.positions)
      local indices = ode.pack('uint', meshdata.indices)
      printf("positions: %d, indices: %d\n", #meshdata.positions/3, #meshdata.indices)
      meshdata = nil -- don't need this any more
      plane_data = ode.create_tmdata('float', positions, indices)
   end

   -- back
   if true then
      local pos = {
         x = x + 0,
         y = y + 0,
         z = z + -d
      }
      local scale = {
         x = w / 2,
         y = h / 2,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateY(math.rad(0))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[1] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({1, 0, 0}, pi / 2))
      end
   end
   -- front
   if true then
      local pos = {
         x = x + 0,
         y = y + 0,
         z = z + 0
      }
      local scale = {
         x = w / 2,
         y = h / 2,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateY(math.rad(180))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[2] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({1, 0, 0}, -pi / 2))
      end
   end
   -- left
   if true then
      local pos = {
         x = x + -w / 2,
         y = y + 0,
         z = z + -d / 2
      }
      local scale = {
         x = d / 2,
         y = h / 2,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateY(math.rad(270))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[3] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({0, 0, 1}, -pi / 2))
      end
   end
   -- right
   if true then
      local pos = {
         x = x + w / 2,
         y = y + 0,
         z = z + -d / 2
      }
      local scale = {
         x = d / 2,
         y = h / 2,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateY(math.rad(90))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[4] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({0, 0, 1}, pi / 2))
      end
   end
   -- top
   if true then
      local pos = {
         x = x + 0,
         y = y + h / 2,
         z = z + -d / 2
      }
      local scale = {
         x = (w / 2) * 1,
         y = (d / 2) * 1,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateX(math.rad(90))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[5] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({1, 0, 0}, pi))
      end
   end
   -- bottom
   if true then
      local pos = {
         x = x + 0,
         y = y + -h / 2,
         z = z + -d / 2
      }
      local scale = {
         x = (w / 2) * 1,
         y = (d / 2) * 1,
         z = 1
      }
      local transform = dream.mat4.getIdentity()
      transform = transform:translate(pos.x, pos.y, pos.z)
      transform = transform:rotateX(math.rad(270))
      transform = transform:scale(scale.x, scale.y, scale.z)

      local object = quad:clone()
      object:setTransform(transform)
      arenaMesh.objects[6] = object

      if true then
         local terrain = ode.create_trimesh(space, plane_data)
         terrain:set_position({pos.x, pos.y, pos.z})
         terrain:set_rotation(ode.r_from_axis_and_angle({0, 1, 0}, 0.0))
      end
   end

   return arenaMesh
end

function Game:setupEntities()
   local world = self.world_container.world
   local space = self.world_container.space
   local ode = self.world_container.ode

   local objects = self.objects
   local arena = self.arena

   -- daisy
   if true then
      local mesh = objects.daisy
      local entity = Entity({
            name = "Daisy",
            mesh = mesh,
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

      table.insert(self.entities, entity)
   end

   -- cube
   if true then
      local mesh = objects.cube
      local pos = {
         x = 0,
         y = 0,
         z = arena.pos.z - arena.size.d / 2
      }
      local vel = {
         x = 1,
         y = 4,
         z = 6,
      }
      local ang = {
         x = 35,
         y = 40,
         z = 35,
      }
      local scale = {
         x = 0.25,
         y = 0.25,
         z = 0.25,
      }

      local shape = ode.create_box(nil, scale.x * 2, scale.y * 2, scale.z * 2)
      local body = ode.create_body(world)
      body:set_mass(ode.mass_box(1, scale.x * 2, scale.y * 2, scale.z * 2, 1))
      shape:set_body(body)
      space:add(shape)

      local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
      body:set_position({pos.x, pos.y, pos.z})
      body:set_linear_vel({vel.x, vel.y, vel.z})
      body:set_angular_vel({ang.x, ang.y, ang.z})
      body:set_quaternion(q)

      local entity = Entity({
            name = "Cube",
            shape = shape,
            mesh = mesh,
            pos = pos,
            velocity = vel,
            angular = ang,
            scale = scale,
      })
      table.insert(self.entities, entity)

      -- table.insert(
      --    self.controllers,
      --    EntityController(
      --       entity,
      --       arena
      -- ))
   end

   -- ball 1
   if true then
      local mesh = objects.ball_1
      local pos = {
         x = 0,
         y = 0,
         z = arena.pos.z - arena.size.d / 2 + 1
      }
      local entity = Entity({
            name = "Ball 1",
            mesh = mesh,
            pos = pos,
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

      table.insert(self.entities, entity)
   end

   -- ball 2
   if true then
      local mesh = objects.ball_2
      local entity = Entity({
            name = "Ball 2",
            mesh = mesh,
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

      table.insert(self.entities, entity)
   end

   -- paddle
   if true then
      local mesh = objects.paddle
      local entity = Entity({
            name = "Paddle",
            mesh = mesh,
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

      table.insert(self.entities, entity)
   end
end
