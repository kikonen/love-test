--[[
]]

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

function love.load()
   love.window.setMode(
      WINDOW_WIDTH, WINDOW_HEIGHT,
      {
         fullscreen = false,
         resizable = false,
         vsync = true
   })

   daisy = {
      image = love.graphics.newImage("images/daisy.png"),
      pos = {
         x = 0,
         y = 0,
      },
      velocity = {
         x = 200,
         y = 0,
         rotate = 0.4
      },
      scale = {
         x = 0.5,
         y = 0.5
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
   elseif daisy.pos.x >= WINDOW_WIDTH - daisy.image:getWidth() * daisy.scale.x then
      daisy.pos.x = WINDOW_WIDTH - daisy.image:getWidth() * daisy.scale.x
      daisy.dir = -  daisy.dir
   end
end

function love.update(dt)
   update_keydown(dt)
   update_daisy(dt)
end

function love.draw()
   local transform = love.math.newTransform()

   transform:translate(daisy.pos.x, daisy.pos.y)
   transform:rotate(daisy.angle)
   transform:scale(daisy.scale.x, daisy.scale.y)

   love.graphics.draw(daisy.image, transform)

   --love.graphics.print('Hello World!', 400, 300)

   love.graphics.printf(
      'Hello Daisy!',
      0,
      WINDOW_HEIGHT / 2 - 6,
      WINDOW_WIDTH,
      'center')
end
