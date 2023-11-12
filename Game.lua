local dream = require("external_modules/3DreamEngine/3DreamEngine")

--require 'Terrain'
require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'PaddleController'

Class = require 'external_modules/hump/class'

Game = Class{}

local pi = math.pi

function Game:init(opt)
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
  self.sounds = self:loadSounds()
  self:setupObjects()
  self:setupDaisySprite()

  self:setupJoints()
end

function Game:setupDaisySprite()
  if true then
    local controller = DaisyController{
      sprite = Sprite{
        image = 'assets/images/daisy.png',
        pos = {
          x = self.virtual_size.w / 2,
          y = self.virtual_size.h / 4
        },
        scale = {
          x = 0.25,
          y = 0.25
        }
      },
      virtual_size = self.virtual_size,
      virtual_scale = self.virtual_scale,
      sounds = {
        hit = self.sounds.wall_hit:clone(),
      },
    }
    table.insert(self.controllers, controller)
  end
end

function Game:loadSounds()
  local assets = {
    wall_hit = 'wall_hit.wav',
    hollow_impact = 'Hollow Impact 1_7B5F5EA0_normal.ogg',
    short_impact_1 = 'Short Impact  08_F0C9A944_normal.ogg',
    short_impact_2 = 'Short Impact  07_11453D7E_normal.ogg'
  }

  local sounds = {}

  for k, v in pairs(assets) do
    sounds[k] = love.audio.newSource('assets/sounds/' .. v, 'static')
  end

  return sounds
end

function Game:register(entity)
  -- NOTE KI entity without shape not supported for now
  if not entity.shape then return end
  self.entities[entity.id] = entity
  self.world_container:register(entity.shape, entity)
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

    if v.hit then
      v.hit = false
      if v.sounds and v.sounds.hit then
        --love.audio.stop()
        v.sounds.hit:play()
      end
    end
  end
end

function Game:setupObjects()
  self.objects = {
    cube = self:setupCube(),
    ball_1 = self:setupBall1(),
    ball_2 = self:setupBall2(),

    paddle = self:setupPaddle(),
    arena = self:setupArena(),
    ball_chain = self:setupBallChain(),

    daisy = self:setupDaisy(),
  }

  return self.objects
end

function Game:setupJoints()
  local world = self.world_container.world
  local space = self.world_container.space
  local ode = self.world_container.ode

  if true then
    local o1 = self.entities.cube.shape
    local o2 = self.entities.ball_2.shape
    local o3 = self.entities.ball_1.shape
    local joint1 = ode.create_ball_joint(world)
    -- joint1:set_anchor1({0, 0.5, 0})
    -- joint1:set_anchor2({0, 0, 0})
    joint1:attach(o1:get_body(), o2:get_body())

    local joint2 = ode.create_ball_joint(world)
    -- joint2:set_anchor1({0, 0.5, 0})
    -- joint2:set_anchor2({0, 0, 0})
    joint2:attach(o2:get_body(), o3:get_body())
  end
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
  material.cullMode = "none"

  local object = dream:loadObject(
    "assets/models/quad"
  )
  object:setMaterial(material)

  -- daisy
  do
    local world = self.world_container.world
    local space = self.world_container.space
    local ode = self.world_container.ode

    local arena = self.arena

    local pos = {
      x = 0,
      y = 0,
      z = arena.pos.z - 0.3
    }
    local vel = {
      x = 2,
      y = 0,
      z = 0,
    }
    local ang = {
      x = 0,
      y = 0,
      z = 0,
    }
    local scale = {
      x = 0.25,
      y = 0.25,
      z = 0.01,
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

    local entity = Entity{
      id = "daisy",
      object = object,
      shape = shape,
      scale = scale,
      sounds = {
        hit = self.sounds.hollow_impact:clone(),
      }
    }
    self:register(entity)
  end

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

  -- cube
  do
    local world = self.world_container.world
    local space = self.world_container.space
    local ode = self.world_container.ode

    local arena = self.arena

    local pos = {
      x = 0,
      y = 0,
      z = arena.pos.z - arena.size.d / 2
    }
    local vel = {
      x = 2,
      y = 1,
      z = 2,
    }
    local ang = {
      x = 3,
      y = 4,
      z = 3,
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

    local entity = Entity{
      id = "cube",
      shape = shape,
      object = object,
      scale = scale,
      sounds = {
        hit = self.sounds.hollow_impact:clone(),
      }
    }
    self:register(entity)
  end

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

  -- ball 1
  do
    local world = self.world_container.world
    local space = self.world_container.space
    local ode = self.world_container.ode

    local arena = self.arena

    local pos = {
      x = 0,
      y = 0,
      z = arena.pos.z - arena.size.d / 2 + 1
    }
    local vel = {
      x = 1,
      y = 0.5,
      z = 0.3,
    }
    local ang = {
      x = -0.9,
      y = -0.3,
      z = -0.4,
    }
    scale = {
      x = 0.5,
      y = 0.5,
      z = 0.5,
    }

    local shape = ode.create_sphere(nil, scale.x)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_sphere(1, scale.x))
    shape:set_body(body)
    space:add(shape)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "ball_1",
      object = object,
      shape = shape,
      scale = scale,
      sounds = {
        hit = self.sounds.short_impact_1:clone(),
      },
    }
    self:register(entity)
  end

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

  -- ball 2
  do
    local world = self.world_container.world
    local space = self.world_container.space
    local ode = self.world_container.ode

    local arena = self.arena

    local pos = {
      x = -1,
      y = 1.5,
      z = arena.pos.z - arena.size.d / 2
    }
    local vel = {
      x = 1,
      y = -0.5,
      z = -0.4,
    }
    local ang = {
      x = -0.9,
      y = -0.3,
      z = -0.4,
    }
    scale = {
      x = 0.25,
      y = 0.25,
      z = 0.25,
    }

    local shape = ode.create_sphere(nil, scale.x)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_sphere(5, scale.x))
    shape:set_body(body)
    space:add(shape)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "ball_2",
      object = object,
      shape = shape,
      scale = scale,
      sounds = {
        hit = self.sounds.short_impact_2:clone(),
      },
    }
    self:register(entity)
  end

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

  -- paddle
  do
    local world = self.world_container.world
    local space = self.world_container.space
    local ode = self.world_container.ode

    local arena = self.arena

    local pos = {
      x = arena.pos.x + arena.size.w / 2 - 0.2,
      y = arena.pos.y,
      z = arena.pos.z - arena.size.d / 4
    }
    local vel = {
      x = 0,
      y = 0,
      z = 0,
    }
    local ang = {
      x = 0,
      y = 0,
      z = 0,
    }
    local scale = {
      x = 0.1,
      y = 0.5,
      z = 0.5,
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

    local entity = Entity{
      id = "paddle",
      shape = shape,
      object = object,
      scale = scale,
      sounds = {
        --hit = self.sounds.wall_hit
      }
    }

    table.insert(
      self.controllers,
      PaddleController{
        entity = entity,
        speed = 200,
        world_container = self.world_container,
    })
    self:register(entity)
  end

  return object
end

function Game:setupArena()
  local world = self.world_container.world
  local space = self.world_container.space
  local ode = self.world_container.ode

  local quad = self:loadWall()
  local arenaObject = dream:newObject()

  local arena = self.arena

  local r = 3
  local x = arena.pos.x
  local y = arena.pos.y
  local z = arena.pos.z
  local w = arena.size.w
  local h = arena.size.h
  local d = arena.size.d

  -- Create a static terrain using a triangle mesh that we can collide with:
  -- local plane_data = nil
  -- do
  --    local mesh_data = require("meshdata.world_bottom")
  --    local positions = ode.pack('float', mesh_data.positions)
  --    local indices = ode.pack('uint', mesh_data.indices)
  --    printf("positions: %d, indices: %d\n", #mesh_data.positions/3, #mesh_data.indices)
  --    mesh_data = nil -- don't need this any more
  --    plane_data = ode.create_tmdata('float', positions, indices)
  -- end

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
    arenaObject.objects[1] = object

    if true then
      ode.create_plane(space, 0, 0, 1, pos.z);
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
    arenaObject.objects[2] = object

    if true then
      ode.create_plane(space, 0, 0, -1, -pos.z);
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
    arenaObject.objects[3] = object

    if true then
      ode.create_plane(space, 1, 0, 0, pos.x);
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
    arenaObject.objects[4] = object

    if true then
      -- local terrain = ode.create_trimesh(space, plane_data)
      -- terrain:set_position({pos.x, pos.y, pos.z})
      -- terrain:set_rotation(ode.r_from_axis_and_angle({0, 0, 1}, pi / 2))
      ode.create_plane(space, -1, 0, 0, -pos.x);
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
    arenaObject.objects[5] = object

    if true then
      ode.create_plane(space, 0, -1, 0, -pos.y);
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
    arenaObject.objects[6] = object

    if true then
      ode.create_plane(space, 0, 1, 0, pos.y);
    end
  end

  return arenaObject
end

function Game:setupBallChain()
  local world = self.world_container.world
  local space = self.world_container.space
  local ode = self.world_container.ode

  local material = dream:newMaterial()
  material:setMetallic(1.0)
  material:setRoughness(0.5)

  local ball = dream:loadObject(
    "assets/models/texture_ball"
  )
  ball:setMaterial(material)

  local chainObject = dream:newObject()

  local arena = self.arena

  local r = 3
  local x = arena.pos.x
  local y = arena.pos.y
  local z = arena.pos.z
  local w = arena.size.w
  local h = arena.size.h
  local d = arena.size.d

  local prev = nil

  local radius = 0.05
  local ball_count = 40
  local spacer = radius / 2
  local step_y = 0.1

  for i = 1, ball_count do
    local pos = {
      x = x + 0,
      y = y + h / 2 - radius - i * step_y,
      z = z + -d / 2 + i * (2 * radius) + i * spacer
    }

    local transform = dream.mat4.getIdentity()
    transform = transform:translate(pos.x, pos.y, pos.z)
    transform = transform:scale(radius, radius, radius)

    local object = ball:clone()
    object:setTransform(transform)
    chainObject.objects[i] = object

    local shape = nil
    if true then
      shape = ode.create_sphere(nil, radius)
      local body = ode.create_body(world)
      body:set_mass(ode.mass_sphere(0.1, radius))
      if not prev or i == ball_count then
        body:set_kinematic()
      end
      shape:set_body(body)
      space:add(shape)

      body:set_position({pos.x, pos.y, pos.z})
    end

    local entity = Entity{
      id = "chain_" .. tostring(i),
      object = object,
      shape = shape,
      scale = {
        x = radius,
        y = radius,
        z = radius,
      }
    }
    self:register(entity)

    if true and prev then
      local o1 = prev.shape
      local joint = ode.create_ball_joint(world)
      joint:attach(o1:get_body(), shape:get_body())
    end

    prev = entity
  end

  return chainObject
end
