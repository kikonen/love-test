local WINDOW_WIDTH = 1280
local WINDOW_HEIGHT = 720

function love.conf(t)
   t.console = true

   t.window.title = 'Hello Daisy'
   t.window.width = WINDOW_WIDTH
   t.window.height = WINDOW_HEIGHT

   t.window.fullscreen = false
   t.window.resizable = true
   t.window.vsync = 1
end
