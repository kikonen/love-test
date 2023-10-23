--[[
]]

local push = require 'external_modules/push/push'
local dream = require("external_modules/3DreamEngine/3DreamEngine")
local physics = require("external_modules/3DreamEngine/extensions/physics/init")
local cameraController = require("external_modules/3DreamEngine/extensions/utils/cameraController")

require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'EntityController'

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local window_size;
local virtual_size;
local virtual_scale;

local arena = {
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

local meshes = {}
local objects = {}

local fpsFont = nil
local scoreFont = nil

local controllers = {}

local lights = {}
local world = nil

function loadMeshes()
   local meshes = {}

--   loadQuad(meshes)
--   loadWall(meshes)

   return meshes
end

function setupObjects(meshes)
   return {
      cube = setupCube(),
      ball_1 = setupBall1(),
      ball_2 = setupBall2(),

      paddle = setupPaddle(),
      arene = setupArena(),
   }
end

-- function loadQuad(meshes)
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

function loadWall()
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

function setupCube()
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

function setupBall1()
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

function setupBall2()
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

function setupPaddle()
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

function setupArena()
   local quad = loadWall()
   local arenaMesh = dream:newObject()

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

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')

   window_size = {
      w = love.graphics.getWidth(),
      h = love.graphics.getHeight(),
   }

   virtual_size = {
      w = VIRTUAL_WIDTH,
      h = VIRTUAL_HEIGHT,
   }

   virtual_scale = {
      w = virtual_size.w / window_size.w,
      h = virtual_size.h / window_size.h,
   }

   if true then
      push:setupScreen(
         VIRTUAL_WIDTH, VIRTUAL_HEIGHT, window_size.w, window_size.h,
         {
            resizable = true
      })
   end

   fpsFont = love.graphics.newFont('assets/fonts/font.ttf', 8)
   scoreFont = love.graphics.newFont('assets/fonts/font.ttf', 32)

   do
      local controller = DaisyController(
         Sprite({
               image = 'assets/images/daisy.png',
               pos = {
                  x = virtual_size.w / 2,
                  y = virtual_size.h / 4
               },
               scale = {
                  x = 0.25,
                  y = 0.25
               }
         }),
         virtual_size,
         virtual_scale
      )
      table.insert(controllers, controller)
   end

   dream:init()

   if false then
      local pos = dream.vec3(0, 0, arena.pos.z - arena.size.d / 2)
      local light = dream:newLight(
         "point",
         pos,
         dream.vec3(1.0, 0.75, 0.2),
         50.0)
      light:addNewShadow()
      table.insert(lights, light)
   end
   if true then
      local light = dream:newLight(
         "sun",
         dream.vec3(0, 0, 0),
         dream.vec3(1.0, 0.75, 0.2),
         50.0)
      light:setDirection(-0.5, 1.5, 1)
      light:addNewShadow()
      table.insert(lights, light)
   end
   dream.camera:setFov(45)

   do
      world = physics:newWorld()
   end

   love.setupEntities()
end

function love.setupEntities()
   meshes = loadMeshes()
   objects = setupObjects(meshes)

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
         controllers,
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
         controllers,
         EntityController(
            entity,
            arena
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
         controllers,
         EntityController(
            entity,
            arena
      ))
   end

   do
      local mesh = objects.paddle
      local shape = physics:newObject(mesh)
      local entity = Entity({
            mesh = mesh,
            shape = shape,
            pos = {
               x = arena.pos.x + arena.size.w / 2 - 0.1 - 0.001,
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
         controllers,
         EntityController(
            entity,
            arena
      ))
   end
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
   if key == 'f11' then
      love.window.setFullscreen(not love.window.getFullscreen())
   end
end

function love.resize(w, h)
   push:resize(w, h)
   dream:resize(w, h)

   window_size = {
      w = w,
      h = h,
   }

   virtual_scale = {
      w = virtual_size.w / window_size.w,
      h = virtual_size.h / window_size.h,
   }

   for k, v in pairs(controllers) do
      v.virtual_scale = virtual_scale
   end
end

function love.focus(focus)
   if focus then
      love.mouse.setGrabbed(true)
      love.mouse.setVisible(false)
   else
      love.mouse.setGrabbed(false)
      love.mouse.setVisible(true)
   end
end

function love.mousemoved(_, _, x, y)
   if not love.window.hasFocus() then
      return
   end

   cameraController:mousemoved(x, y)
end

function love.update(dt)
   cameraController:update(dt)

   for k, v in pairs(controllers) do
      print(v.entity)
      v:update(dt)
   end

   world:update(dt)
   dream:update(dt)

end

function love.draw()
   cameraController:setCamera(dream.camera)

   dream:prepare()
   for k, v in pairs(lights) do
      dream:addLight(v)
   end

   for k, v in pairs(objects) do
      dream:draw(v)
   end

   dream:present()

   push:start()

   for k, v in pairs(controllers) do
      v:draw(dt)
   end

   love.graphics.setFont(scoreFont)

   love.graphics.printf(
      'Hello Daisy',
      0,
      VIRTUAL_HEIGHT / 2 - scoreFont:getHeight(),
      VIRTUAL_WIDTH,
      'center')

   drawFps()

   push:finish()
end

function drawFps()
   love.graphics.setFont(fpsFont)
   love.graphics.setColor(0, 1.0, 0.0, 1.0)
   love.graphics.printf(
      --.tostring(love.timer.getFPS()) .. ' - ' .. tostring(window_size.w),
      tostring(love.timer.getFPS()),
      2,
      2,
      VIRTUAL_WIDTH - 2,
      'left')
end
