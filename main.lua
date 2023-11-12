require 'utils'

local ode = require("moonode")
local glmath = require("moonglmath")
ode.glmath_compat(true)

local push = require 'external_modules/push/push'
local dream = require("external_modules/3DreamEngine/3DreamEngine")
local cameraController = require("CameraController")

require 'Game'
require 'WorldContainer'
require 'PhysicsTest'

local VIRTUAL_WIDTH = 432
local VIRTUAL_HEIGHT = 243

local window_size;
local virtual_size;
local virtual_scale;

local game = nil

local fpsFont = nil
local scoreFont = nil

local lights = {}

function love.load()
  if arg[#arg] == "-debug" then
    require("mobdebug").start()
    --io.stdout:setvbuf("no")
  end

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

  -- NOTE KI "direct" get 70 more fps and 60% to 30% GPU usage decrease
  dream.canvases:setMode("direct")
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

  game = Game{
    virtual_size = virtual_size,
    virtual_scale = virtual_scale,
    world_container = WorldContainer{},
    world_delay = 2,
  }
  game:load()

  -- local physicsTest = PhysicsTest()
  -- physicsTest:test()
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  if key == 'f11' then
    love.window.setFullscreen(not love.window.getFullscreen())
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())
  end
  if key == 'f10' then
    game.captureMouse = not game.captureMouse
    love.focus(love.window.hasFocus())
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

  for _, v in pairs(game.controllers) do
    v.virtual_scale = virtual_scale
  end
end

function love.focus(focus)
  if focus and game.captureMouse then
    love.mouse.setGrabbed(true)
    love.mouse.setVisible(false)
    love.mouse.setRelativeMode(true)
  else
    love.mouse.setGrabbed(false)
    love.mouse.setVisible(true)
    love.mouse.setRelativeMode(false)
  end
end

function love.mousemoved(_, _, x, y)
  if not love.window.hasFocus() then
    return
  end

  if game.captureMouse or love.mouse.isDown(1)then
    cameraController:mousemoved(x, y)
  end
end

function love.update(dt)
  cameraController:update(dt)
  game:update(dt)
  dream:update(dt)
end

function love.draw()
  cameraController:setCamera(dream.camera)

  --dbg(game.objects)

  dream:prepare()
  for _, v in pairs(lights) do
    dream:addLight(v)
  end

  for _, v in pairs(game.objects) do
    dream:draw(v)
  end

  dream:present()

  push:start()

  for _, v in pairs(game.controllers) do
    v:draw()
  end

  love.graphics.setFont(scoreFont)

  love.graphics.printf(
    'Hello Daisy',
    0,
    VIRTUAL_HEIGHT / 2 - scoreFont:getHeight(),
    VIRTUAL_WIDTH,
    'center')

  love.drawFps()

  push:finish()
end

function love.drawFps()
  love.graphics.setFont(fpsFont)
  love.graphics.setColor(0, 1.0, 0.0, 1.0)
  love.graphics.printf(
    tostring(love.timer.getFPS()) .. " - f10 capture mouse, f11 fullscreen",
    2,
    2,
    VIRTUAL_WIDTH - 2,
    'left')
end
