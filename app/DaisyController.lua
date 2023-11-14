Class = require '../external_modules/hump/class'

DaisyController = Class{}


function DaisyController:init(opt)
  self.sprite = opt.sprite
  self.virtual_size = opt.virtual_size
  self.virtual_scale = opt.virtual_scale
  self.sounds = opt.sounds or {}
end

function DaisyController:update_keydown(dt)
  local sprite = self.sprite

  if love.keyboard.isDown('+') then
    sprite.velocity.x = sprite.velocity.x + 1
  elseif love.keyboard.isDown('-') then
    sprite.velocity.x = sprite.velocity.x - 1
  end
end

function DaisyController:update_physics(dt)
  local sprite = self.sprite
  local limits = self.virtual_size
  local vs = self.virtual_scale
  local sound = nil

  sprite.pos.x = sprite.pos.x + dt * sprite.velocity.x * vs.x * sprite.dir.x
  sprite.angle = sprite.angle + dt * sprite.velocity.p * -sprite.dir.x

  if sprite.pos.x <= sprite.center.x * sprite.scale.x * vs.x then
    sprite.pos.x = sprite.center.x * sprite.scale.x * vs.x
    sprite.dir.x = -sprite.dir.x
    sound = 'hit'
  elseif sprite.pos.x >= limits.x - sprite.center.x * sprite.scale.x * vs.x then
    sprite.pos.x = limits.x - sprite.center.x * sprite.scale.x * vs.x
    sprite.dir.x = -sprite.dir.x
    sound = 'hit'
  end

  if sound and self.sounds[sound] then
    --love.audio.stop()
    self.sounds[sound]:play()
  end
end

function DaisyController:update(dt)
  self:update_keydown(dt)
  self:update_physics(dt)
end

function DaisyController:draw()
  local sprite = self.sprite
  love.graphics.draw(sprite.image, sprite:transform(self.virtual_scale))
end
