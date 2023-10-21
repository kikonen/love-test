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

local meshes = {}
local instancedMeshes = {}

local fpsFont = nil
local scoreFont = nil

local daisy_controller = nil
local ball_controller = nil
local ball2_controller = nil
local light = nil


function loadMeshes()
   local meshes = {}

   -- Quad
   do
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

   -- Cube
   do
      local material = dream:newMaterial()
      material:setAlbedoTexture("assets/textures/brick_01.png")
      material:setNormalTexture("assets/textures/brick_01_NRM.png")
      material:setMetallic(1.0)
      material:setRoughness(0.5)
      dream:registerMaterial(material, "brick")

      meshes.cube = dream:loadObject(
         "assets/models/texture_cube",
         {
            -- materialLibrary = {
            --    brick = material,
            -- },
         }
      )
   end

   -- Ball
   do
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

   -- Ball 2
   do
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

   do
      local quad = meshes.quad
      local arena = dream:newObject()

      local r = 3
      local w = 8
      local h = 4

      -- back
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(0, 0, -w)
         transform = transform:rotateY(math.rad(0))
         transform = transform:scale(w / 2, h / 2, 1)

         arena.objects[1] = quad:clone()
         arena.objects[1]:setTransform(transform)
      end
      -- front
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(0, 0, 0)
         transform = transform:rotateY(math.rad(180))
         transform = transform:scale(w / 2, h / 2, 1)

         arena.objects[2] = quad:clone()
         arena.objects[2]:setTransform(transform)
      end
      -- left
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(-w / 2, 0, -w / 2)
         transform = transform:rotateY(math.rad(270))
         transform = transform:scale(w / 2, h / 2, 1)

         arena.objects[3] = quad:clone()
         arena.objects[3]:setTransform(transform)
      end
      -- right
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(w / 2, 0, -w / 2)
         transform = transform:rotateY(math.rad(90))
         transform = transform:scale(w / 2, h / 2, 1)

         arena.objects[4] = quad:clone()
         arena.objects[4]:setTransform(transform)
      end
      -- top
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(0, h / 2, -w / 2)
         transform = transform:rotateX(math.rad(90))
         transform = transform:scale(w / 2, w / 2, 1)

         arena.objects[5] = quad:clone()
         arena.objects[5]:setTransform(transform)
      end
      -- bottom
      do
         local transform = dream.mat4.getIdentity()
         transform = transform:translate(0, -h / 2, -w / 2)
         transform = transform:rotateX(math.rad(270))
         transform = transform:scale(w / 2, w / 2, 1)

         arena.objects[6] = quad:clone()
         arena.objects[6]:setTransform(transform)
      end

      meshes.arena = arena
   end

   return meshes
end

function love.conf(t)
   t.console = true
end

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')

   love.window.setTitle('Hello Daisy')

   love.mouse.setGrabbed(true)
   love.mouse.setVisible(false)

   meshes = loadMeshes()

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
               z = -4
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
         {
            w = 8,
            h = 4,
            d = 8
         }
      )
   end

   -- ball 2
   do
      local ball = Entity({
            mesh = meshes.ball_2,
            pos = {
               x = -1,
               y = 1.5,
               z = -1
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
         {
            w = 8,
            h = 4,
            d = 8
         }
      )
   end

   dream:init()

   light = dream:newLight(
      "point",
      dream.vec3(3, 2, 1),
      dream.vec3(1.0, 0.75, 0.2),
      50.0)
   light:addNewShadow()

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

function love.mousemoved(_, _, x, y)
   cameraController:mousemoved(x, y)
end

function love.update(dt)
   cameraController:update(dt)
   daisy_controller:update(dt)
   ball_controller:update(dt)
   ball2_controller:update(dt)
   dream:update(dt)
end

function love.draw()
   cameraController:setCamera(dream.camera)

   dream:prepare()
   dream:addLight(light)

   do
      local mesh = meshes.cube
      mesh:resetTransform()
      mesh:translate(0, 0, -10)
      mesh:rotateY(love.timer.getTime())
--      dream:draw(mesh)
   end

--   drawArena()
   dream:draw(meshes.arena)

   do
      dream:draw(meshes.ball)
      dream:draw(meshes.ball_2)
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
end

function drawArena()
--   local mesh = meshes.quad
--   mesh:resetTransform()
--   mesh:translate(0, 0, 0)
   -- pos = {
   --    x = 0,
   --    y = -1,
   --    z = -6
   -- },
   --            w = 8,
   --            h = 4,

   -- back
--   mesh:resetTransform()
--   mesh:translate(0, 0, -6)
   --      mesh:scale(20, 20, 1)
   --      dream:draw(mesh)

   -- left
   if false then
--      print("left")
      local mesh = instancedMeshes.left
      left:translate(0, 0, -6)
--      transform:rotateY(math.rad(90))
--      transform:scale(5, 2, 1)
--      mesh:translate(0, 0, -6)
      dream:draw(mesh, transform)
   end

   -- right
   if false then
      local transform = _3DreamEngine.mat4.getIdentity()
      transform:translate(4, 0, -6)
      transform:rotateY(math.rad(90))
      transform:scale(5, 2, 1)
      dream:draw(mesh, transform)
   end
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

   push:finish()
end
