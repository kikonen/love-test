--[[
]]

push = require 'external_modules/push/push'

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

   daisy = {
      image = love.graphics.newImage("images/daisy.png"),
      pos = {
         x = 0,
         y = 0,
      },
      velocity = {
         x = 200 * scale.x,
         y = 0 * scale.y,
         rotate = 0.4
      },
      scale = {
         x = 0.5 * scale.x,
         y = 0.5 * scale.y
      },
      angle = 0,
      dir = 1
   }
end

function love.keypressed(key)
   if key == 'escape' then
      love.event.quit()
   end
end

function love.resize(w, h)
   push:resize(w, h)
end

function update_keydown(dt)
   if love.keyboard.isDown('+') then
      daisy.velocity.x = daisy.velocity.x + 1
   elseif love.keyboard.isDown('-') then
      daisy.velocity.x = daisy.velocity.x - 1
   end
end

function update_daisy(dt)
   daisy.pos.x = daisy.pos.x + dt * daisy.velocity.x * daisy.dir
   daisy.angle = daisy.angle + dt * daisy.velocity.rotate * daisy.dir

   if daisy.pos.x <= 0 then
      daisy.pos.x = 0
      daisy.dir = -  daisy.dir
   elseif daisy.pos.x >= VIRTUAL_WIDTH - daisy.image:getWidth() * daisy.scale.x then
      daisy.pos.x = VIRTUAL_WIDTH - daisy.image:getWidth() * daisy.scale.x
      daisy.dir = -  daisy.dir
   end
end

function love.update(dt)
   update_keydown(dt)
   update_daisy(dt)
end

function love.draw()
   push:apply('start')

   local transform = love.math.newTransform()

   transform:translate(daisy.pos.x, daisy.pos.y)
   transform:rotate(daisy.angle)
   transform:scale(daisy.scale.x, daisy.scale.y)

   love.graphics.draw(daisy.image, transform)

   --love.graphics.print('Hello World!', 400, 300)

   love.graphics.setFont(scoreFont)

   love.graphics.printf(
      'Hello Daisy!',
      0,
      VIRTUAL_HEIGHT / 2 - scoreFont:getHeight(),
      VIRTUAL_WIDTH,
      'center')

   push:apply('end')
end
