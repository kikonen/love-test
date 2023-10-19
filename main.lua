--[[
]]

local push = require 'external_modules/push/push'
local dream = require("external_modules/3DreamEngine/3DreamEngine")

require 'Sprite'
require 'DaisyController'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function loadModels()
   local models = {}

   local material = dream:newMaterial()

   -- Configure it
   material:setAlbedoTexture("assets/models/textures/brick_01.png")
   material:setNormalTexture("assets/models/textures/brick_01_NRM.png")
   material:setMetallic(1.0)
   material:setRoughness(0.5)

   dream:registerMaterial(material, "brick")
   cube = dream:loadObject(
      "assets/models/texture_cube",
      {
         ignoreMissingMaterials = false
      }
   )
   --   cube = dream:loadObject("external_modules/3DreamEngine/examples/monkey/object")
   models.cube = cube

   return models
end

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')

   love.window.setTitle('Hello Daisy')

   scale = {
      x = VIRTUAL_WIDTH / WINDOW_WIDTH,
      y = VIRTUAL_HEIGHT / WINDOW_HEIGHT
   }

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

   scoreFont = love.graphics.newFont('assets/fonts/font.ttf', 32)

   daisyController = DaisyController(
      Sprite({
            image = 'assets/images/daisy.png',
            pos = {
               x = VIRTUAL_WIDTH / 2,
               y = VIRTUAL_HEIGHT / 2
            }
   }))

   dream:init()

   light = dream:newLight(
      "point",
      dream.vec3(3, 2, 1),
      dream.vec3(1.0, 0.75, 0.2),
      50.0)
   light:addNewShadow()

   models = loadModels()
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.resize(w, h)
   push:resize(w, h)
   dream:resize(w, h)
end

function love.update(dt)
   daisyController:update(dt)
   dream:update(dt)
end

function love.draw()
   dream:prepare()
   dream:addLight(light)

   local cube = models.cube
   cube:resetTransform()
   cube:translate(0, 0, -3)
   cube:rotateY(love.timer.getTime())
   dream:draw(cube)

   dream:present()

   push:start()

   daisyController:draw()
   love.graphics.setFont(scoreFont)

   love.graphics.printf(
      'Hello Daisy!',
      0,
      VIRTUAL_HEIGHT / 2 - scoreFont:getHeight(),
      VIRTUAL_WIDTH,
      'center')

   push:finish()
end
