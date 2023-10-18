--[[
]]

push = require 'external_modules/push/push'

require 'Sprite'
require 'DaisyController'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
   love.graphics.setDefaultFilter('nearest', 'nearest')

   love.window.setTitle('Hello Daisy')

   scale = {
      x = VIRTUAL_WIDTH / WINDOW_WIDTH,
      y = VIRTUAL_HEIGHT / WINDOW_HEIGHT
   }

   -- love.window.setMode(
   --    WINDOW_WIDTH, WINDOW_HEIGHT,
   --    {
   --       fullscreen = false,
   --       resizable = false,
   --       vsync = true
   -- })
   push:setupScreen(
      VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT,
      {
         fullscreen = false,
         resizable = true,
         vsync = true
   })

   scoreFont = love.graphics.newFont('fonts/font.ttf', 32)

   daisyController = DaisyController(
      Sprite({
            image = 'images/daisy.png',
            pos = {
               x = VIRTUAL_WIDTH / 2,
               y = VIRTUAL_HEIGHT / 2
            }
   }))
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.resize(w, h)
   push:resize(w, h)
end

function love.update(dt)
   daisyController:update(dt)
end

function love.draw()
   push:start()

   daisyController:draw()

   --love.graphics.print('Hello World!', 400, 300)

   love.graphics.setFont(scoreFont)

   love.graphics.printf(
      'Hello Daisy!',
      0,
      VIRTUAL_HEIGHT / 2 - scoreFont:getHeight(),
      VIRTUAL_WIDTH,
      'center')

   push:finish()
end
