local dream = require("../external_modules/3DreamEngine/3DreamEngine")
local ode = require('moonode')
local glmath = require('moonglmath')

local vec2 = glmath.vec2
local vec3 = glmath.vec3

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

  do
    local camera_offset = 4
    local size = vec3(
      6,
      4,
      10)
    self.arena = {
      pos = vec3(0, 0, -size.z / 2 - camera_offset),
      size = size
    }
  end

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
        pos = vec2(
          self.virtual_size.x / 2,
          self.virtual_size.y / 4),
        scale = vec2(0.25, 0.25),
        velocity = vec3(200, 0, 0.4)
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
  -- NOTE KI entity without geom not supported for now
  if not entity.geom then return end
  self.entities[entity.id] = entity
  self.world_container:register(entity.geom, entity)
end

function Game:update(dt)
  self.delay = (self.delay or 0) + dt

  if self.delay > self.world_delay then
    self.world_container:update(dt)
  end

  for _, v in ipairs(self.controllers) do
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
    --origo = self:setupOrigo(),

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

  if true then
    local o1 = self.entities.cube.geom
    local o2 = self.entities.ball_2.geom
    local o3 = self.entities.ball_1.geom
    local joint1 = ode.create_ball_joint(world)
    -- joint1:set_anchor1({0, 0.5, 0})
    -- joint1:set_anchor2({0, 0, 0})
    joint1:attach(o1:get_body(), o2:get_body())

    --local joint2 = ode.create_ball_joint(world)
    -- joint2:set_anchor1({0, 0.5, 0})
    -- joint2:set_anchor2({0, 0, 0})
    --joint2:attach(o2:get_body(), o3:get_body())
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

function Game:setupOrigo()
  local arena = self.arena

  local material = dream:newMaterial()
  material.color = { 1.0, 1.0, 0.0, 1.0 }

  local template = dream:loadObject(
    "assets/models/ball_volume"
  )
  template:setMaterial(material)

  local origoObject = dream:newObject()

  local x1 = arena.pos.x - arena.size.x / 2
  local x2 = arena.pos.x + arena.size.x / 2
  local y1 = arena.pos.y - arena.size.y / 2
  local y2 = arena.pos.y + arena.size.y / 2
  local z1 = arena.pos.z - arena.size.z / 2
  local z2 = arena.pos.z + arena.size.z / 2

  local idx = 1
  for x = x1, x2 do
    for y = y1, y2 do
      for z = z1, z2 do
        do
          local object = template:clone()
          origoObject.objects[idx] = object

          local transform = dream.mat4.getIdentity()
          transform = transform:translate(x, y, z)
          transform = transform:scale(0.01, 0.01, 0.01)

          object:setTransform(transform)
        end

        idx = idx + 1
      end
    end
  end

  return origoObject
end

function Game:loadWall()
  local material = dream:newMaterial()
  material:setAlbedoTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Color.png")
  material:setNormalTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_NormalGL.png")
  material:setMetallicTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Metalness.png")
  material:setRoughnessTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Roughness.png")
  material:throwsShadow(false)
  --dream:registerMaterial(material, "rusty_metal")

  --material.cullMode = "none"

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

    local arena = self.arena

    local pos = vec3(0, 0, arena.pos.z - 0.3)
    local vel = vec3(2, 0, 0)
    local ang = vec3(0, 0, 0)
    local scale = vec3(0.25, 0.25, 0.01)

    local geom = ode.create_box(nil, scale.x * 2, scale.y * 2, scale.z * 2)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_box(1, scale.x * 2, scale.y * 2, scale.z * 2, 1))
    geom:set_body(body)
    space:add(geom)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "daisy",
      object = object,
      geom = geom,
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

    local arena = self.arena

    local scale = vec3(0.25, 0.25, 0.25)
    local pos = vec3(
      0,
      0,
      arena.pos.z - arena.size.z / 2 + scale.z * 2)
    local vel = vec3(2, 1, 2)
    local ang = vec3(3, 4, 3)

    local geom = ode.create_box(nil, scale.x * 2, scale.y * 2, scale.z * 2)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_box(1, scale.x * 2, scale.y * 2, scale.z * 2, 1))
    geom:set_body(body)
    space:add(geom)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "cube",
      geom = geom,
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

    local arena = self.arena

    local pos = vec3(
      arena.pos.x + 0,
      arena.pos.y + 0,
      arena.pos.z + 0)-- - arena.size.z / 2 + 1)

    print(arena.pos, arena.size, pos)

    local vel = vec3(1, 0.5, 0.3)
    local ang = vec3(-0.9, -0.3, -0.4)
    local scale = vec3(0.5, 0.5, 0.5)

    local geom = ode.create_sphere(nil, scale.x)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_sphere(1, scale.x))
    geom:set_body(body)
    space:add(geom)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)
    --body:set_kinematic()

    local entity = Entity{
      id = "ball_1",
      object = object,
      geom = geom,
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

    local arena = self.arena

    local scale = vec3(0.25, 0.25, 0.25)
    local pos = vec3(
      -1,
      1.5,
      arena.pos.z - arena.size.z / 2 + scale.x)
    local vel = vec3(1, -0.5, -0.4)
    local ang = vec3(-0.9, -0.3, -0.4)

    local geom = ode.create_sphere(nil, scale.x)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_sphere(5, scale.x))
    geom:set_body(body)
    space:add(geom)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "ball_2",
      object = object,
      geom = geom,
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

    local arena = self.arena

    local pos = vec3(
      arena.pos.x + arena.size.x / 2 - 0.2,
      arena.pos.y,
      arena.pos.z - arena.size.z / 4)
    local vel = vec3(0, 0, 0)
    local ang = vec3(0, 0, 0)
    local scale = vec3(0.1, 0.5, 0.5)

    local geom = ode.create_box(nil, scale.x * 2, scale.y * 2, scale.z * 2)
    local body = ode.create_body(world)
    body:set_mass(ode.mass_box(1, scale.x * 2, scale.y * 2, scale.z * 2, 1))
    geom:set_body(body)
    space:add(geom)

    local q = ode.q_from_axis_and_angle({0, 1, 0}, 0)
    body:set_position({pos.x, pos.y, pos.z})
    body:set_linear_vel({vel.x, vel.y, vel.z})
    body:set_angular_vel({ang.x, ang.y, ang.z})
    body:set_quaternion(q)

    local entity = Entity{
      id = "paddle",
      geom = geom,
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

  local quad = self:loadWall()
  local arenaObject = dream:newObject()

  local arena = self.arena

  --local r = 3
  local x = arena.pos.x
  local y = arena.pos.y
  local z = arena.pos.z
  local w = arena.size.x
  local h = arena.size.y
  local d = arena.size.z

  -- back
  if true then
    local pos = vec3(
      x + 0,
      y + 0,
      z + -d / 2)
    local scale = vec3(
      w / 2,
      h / 2,
      1)

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
    local pos = vec3(
      x + 0,
      y + 0,
      z + d / 2)
    local scale = vec3(
      w / 2,
      h / 2,
      1)

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
    local pos = vec3(
      x + -w / 2,
      y + 0,
      z + 0)
    local scale = vec3(
      d / 2,
      h / 2,
      1)

    print("left", pos, scale)
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
    local pos = vec3(
      x + w / 2,
      y + 0,
      z + 0)
    local scale = vec3(
      d / 2,
      h / 2,
      1)

    local transform = dream.mat4.getIdentity()
    transform = transform:translate(pos.x, pos.y, pos.z)
    transform = transform:rotateY(math.rad(90))
    transform = transform:scale(scale.x, scale.y, scale.z)

    local object = quad:clone()
    object:setTransform(transform)
    arenaObject.objects[4] = object

    if true then
      ode.create_plane(space, -1, 0, 0, -pos.x);
    end
  end
  -- top
  if true then
    local pos = vec3(
      x + 0,
      y + h / 2,
      z + 0)
    local scale = vec3(
      (w / 2) * 1,
      (d / 2) * 1,
      1)

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
    local pos = vec3(
      x + 0,
      y + -h / 2,
      z + 0)
    local scale = vec3(
      (w / 2) * 1,
      (d / 2) * 1,
      1)

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
  local w = arena.size.x
  local h = arena.size.y
  local d = arena.size.z

  local prev = nil

  local radius = 0.05
  local ball_count = 40
  local spacer = radius / 2
  local step_y = 0.1

  for i = 1, ball_count do
    -- local pos = vec3(
    --   x + 0,
    --   y + h / 2 - radius - i * step_y,
    --   z + -d / 2 + i * (2 * radius) + i * spacer)

    local pos = vec3(
      x + 0,
      y + h / 4,
      z + radius + -d / 2 + (i - 1) * (2 * radius) + (i - 1) * spacer)

    print(pos)

    local transform = dream.mat4.getIdentity()
    transform = transform:translate(pos.x, pos.y, pos.z)
    transform = transform:scale(radius, radius, radius)

    local object = ball:clone()
    object:setTransform(transform)
    chainObject.objects[i] = object

    local geom = nil
    if true then
      geom = ode.create_sphere(nil, radius)
      local body = ode.create_body(world)
      body:set_mass(ode.mass_sphere(0.1, radius))
      if not prev or i == ball_count then
        body:set_kinematic()
      end
      geom:set_body(body)
      space:add(geom)

      body:set_position({pos.x, pos.y, pos.z})
    end

    local entity = Entity{
      id = "chain_" .. tostring(i),
      object = object,
      geom = geom,
      scale = vec3(
        radius,
        radius,
        radius)
    }
    self:register(entity)

    if prev then
      local o1 = prev.geom
      local joint = ode.create_ball_joint(world)
      joint:attach(o1:get_body(), geom:get_body())

      do
        local p1 = prev.geom:get_position()
        p1.z  = p1.z + radius

        local p2 = geom:get_position()
        p2.z  = p2.z - radius

        joint:set_anchor1(p1)
        joint:set_anchor2({0, 0, -radius - spacer})
      end

      local p1 = prev.geom:get_position()
      local p2 = geom:get_position()

      local a1 = joint:get_anchor1()
      local a2 = joint:get_anchor2()
      print(i, radius, spacer, a1, a2, p1, p2)
    end

    prev = entity
  end

  print(arena.pos, arena.size)

  local pos = vec3(
    x + 0,
    y - h / 4 + radius,
    z + d / 2 - radius)
  prev.geom:set_position(pos)

  print(pos)

  return chainObject
end