--[[
]]

local push = require 'external_modules/push/push'
local dream = require("external_modules/3DreamEngine/3DreamEngine")
local cameraController = require("external_modules/3DreamEngine/extensions/utils/cameraController")

require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'BallController'

local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local window_size = {
   w = WINDOW_WIDTH,
   h = WINDOW_HEIGHT,
}

local virtual_size = {
   w = VIRTUAL_WIDTH,
   h = VIRTUAL_HEIGHT,
}

local virtual_scale = {
   w = virtual_size.w / window_size.w,
   h = virtual_size.h / window_size.h,
}

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
local instancedMeshes = {}

local fpsFont = nil
local scoreFont = nil

local daisy_controller = nil
local paddle_controller = nil
local ball_controller = nil
local ball2_controller = nil
local lights = {}

function setupMeshes()
   local meshes = {}

   setupQuad(meshes)
   setupCube(meshes)
   setupBall1(meshes)
   setupBall2(meshes)

   setupPaddle(meshes)
   setupWall(meshes)
   setupArena(meshes)

   return meshes
end

function setupQuad(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Color.png")
   material:setNormalTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Roughness.png")
   dream:registerMaterial(material, "rusty_metal")

   meshes.quad = dream:loadObject(
      "assets/models/quad"
   )
   meshes.quad:setMaterial(material)
end

function setupCube(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/brick_01.png")
   material:setNormalTexture("assets/textures/brick_01_NRM.png")
   material:setMetallic(1.0)
   material:setRoughness(0.5)
   dream:registerMaterial(material, "brick")

   meshes.cube = dream:loadObject(
      "assets/models/texture_cube"
   )
end

function setupBall1(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/images/daisy.png")
   material:setMetallic(1.0)
   material:setRoughness(0.5)
   dream:registerMaterial(material, "marble")

   meshes.ball = dream:loadObject(
      "assets/models/texture_ball",
      {
         -- materialLibrary = {
         --    brick = material,
         -- },
      }
   )
end

function setupBall2(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_Color.png")
   material:setNormalTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/Metal007_1K-PNG/Metal007_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/Metal007_1K/Metal007_1K_Roughness.png")
   dream:registerMaterial(material, "gold")

   meshes.ball_2 = dream:loadObject(
      "assets/models/texture_ball",
      {
         -- materialLibrary = {
         --    brick = material,
         -- },
      }
   )
   meshes.ball_2:setMaterial(material)
end

function setupPaddle(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/images/daisy.png")

   meshes.paddle = dream:loadObject(
      "assets/models/texture_cube"
   )
   meshes.paddle:setMaterial(material)
end

function setupWall(meshes)
   local material = dream:newMaterial()
   material:setAlbedoTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Color.png")
   material:setNormalTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_NormalGL.png")
   material:setMetallicTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Metalness.png")
   material:setRoughnessTexture("assets/textures/Metal022_1K-PNG/Metal022_1K_Roughness.png")
   material:throwsShadow(false)
   --dream:registerMaterial(material, "rusty_metal")

   meshes.wall = dream:loadObject(
      "assets/models/quad"
   )
   meshes.wall:setMaterial(material)
end

function setupArena(meshes)
   local quad = meshes.wall
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

   meshes.arena = arenaMesh
end

function love.conf(t)
   t.console = true
end

function love.load()
   --love.graphics.setDefaultFilter('nearest', 'nearest')

   love.window.setTitle('Hello Daisy')

   meshes = setupMeshes()

   if false then
      love.window.setMode(
         WINDOW_WIDTH, WINDOW_HEIGHT,
         {
            fullscreen = false,
            resizable = false,
            vsync = true
      })
   else
      push:setupScreen(
         VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
         {
            fullscreen = false,
            resizable = true,
            vsync = true
      })
   end

   --love.window.setVSync(0)

   fpsFont = love.graphics.newFont('assets/fonts/font.ttf', 8)
   scoreFont = love.graphics.newFont('assets/fonts/font.ttf', 32)

   daisy_controller = DaisyController(
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

   -- ball 1
   do
      local ball = Entity({
            mesh = meshes.ball,
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

      ball_controller = BallController(
         ball,
         arena
      )
   end

   -- ball 2
   do
      local ball = Entity({
            mesh = meshes.ball_2,
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

      ball2_controller = BallController(
         ball,
         arena
      )
   end

   do
      local daisy = Entity({
            mesh = meshes.paddle,
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
      paddle_controller = BallController(
         daisy,
         arena
      )
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
      light:setDirection(0.0, 1.5, 1)
      light:addNewShadow()
      table.insert(lights, light)
   end
   dream.camera:setFov(45)
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
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

   daisy_controller.virtual_scale = virtual_scale
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
   daisy_controller:update(dt)
   paddle_controller:update(dt)
   ball_controller:update(dt)
   ball2_controller:update(dt)
   dream:update(dt)

   update_cube(dt)
end

function update_cube(dt)
   local mesh = meshes.cube
   mesh:resetTransform()
   mesh:translate(0, 0, arena.pos.z - arena.size.d / 2)
   mesh:scale(0.25, 0.25, 0.25)
   mesh:rotateY(love.timer.getTime())
end

function love.draw()
   cameraController:setCamera(dream.camera)

   dream:prepare()
   for k, v in pairs(lights) do
      dream:addLight(v)
   end

   do
      dream:draw(meshes.cube)
      dream:draw(meshes.arena)
      dream:draw(meshes.ball)
      dream:draw(meshes.ball_2)
      dream:draw(meshes.paddle)
   end

   dream:present()

   push:start()

   daisy_controller:draw()
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
