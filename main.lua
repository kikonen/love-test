--[[
]]

local push = require 'external_modules/push/push'
local dream = require("external_modules/3DreamEngine/3DreamEngine")

require 'Sprite'
require 'Entity'
require 'DaisyController'
require 'BallController'

local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

function loadMeshes()
   local meshes = {}

   -- Cube
   do
      local material = dream:newMaterial()
      material:setAlbedoTexture("assets/models/textures/brick_01.png")
      material:setNormalTexture("assets/models/textures/brick_01_NRM.png")
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

   return meshes
end

function love.conf(t)
   t.console = true
end

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')

   love.window.setTitle('Hello Daisy')

   window_size = {
      w = WINDOW_WIDTH,
      h = WINDOW_HEIGHT,
   }

   virtual_size = {
      w = VIRTUAL_WIDTH,
      h = VIRTUAL_HEIGHT,
   }

   virtual_scale = {
      w = virtual_size.w / window_size.w,
      h = virtual_size.h / window_size.h,
   }

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

   do
      local ball = Entity({
            mesh = meshes.ball,
            pos = {
               x = 0,
               y = -1,
               z = -6
            },
      })

      ball_controller = BallController(
         ball,
         {
            w = 8,
            h = 4,
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

   ball_controller.virtual_size = window_size
   ball_controller.virtual_scale = {
      w = 1,
      h = 1
   }
end

function love.update(dt)
   daisy_controller:update(dt)
   ball_controller:update(dt)
   dream:update(dt)
end

function love.draw()
   dream:prepare()
   dream:addLight(light)

   do
      local mesh = meshes.cube
      mesh:resetTransform()
      mesh:translate(0, 0, -10)
      mesh:rotateY(love.timer.getTime())
      dream:draw(mesh)
   end

   do
      dream:draw(meshes.ball)
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
