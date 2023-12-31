local c = {
  x = 0,
  y = 0,
  z = 0,
  vx = 0,
  vy = 0,
  vz = 0,
  rx = 0,
  ry = 0,
}

function c:update(dt, speed, speed_up)
  local d = love.keyboard.isDown
  speed = (speed or 10) * speed_up * dt

  --move
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  self.z = self.z + self.vz * dt

  --accelerate
  if d("w") then
    self.vx = self.vx + math.cos(self.ry - math.pi / 2) * speed
    self.vz = self.vz + math.sin(self.ry - math.pi / 2) * speed
  end
  if d("s") then
    self.vx = self.vx + math.cos(self.ry + math.pi - math.pi / 2) * speed
    self.vz = self.vz + math.sin(self.ry + math.pi - math.pi / 2) * speed
  end
  if d("a") then
    self.vx = self.vx + math.cos(self.ry - math.pi / 2 - math.pi / 2) * speed
    self.vz = self.vz + math.sin(self.ry - math.pi / 2 - math.pi / 2) * speed
  end
  if d("d") then
    self.vx = self.vx + math.cos(self.ry + math.pi / 2 - math.pi / 2) * speed
    self.vz = self.vz + math.sin(self.ry + math.pi / 2 - math.pi / 2) * speed
  end
  if d("pageup") then
    self.vy = self.vy + speed
  end
  if d("pagedown") then
    self.vy = self.vy - speed
  end

  local speedH = 0.01 * speed_up
  local speedV = 0.01 * speed_up
  if d("e") then
    self.ry = self.ry + speedH
  end
  if d("q") then
    self.ry = self.ry - speedH
  end

  --air resistance
  self.vx = self.vx * (1 - dt * 5)
  self.vy = self.vy * (1 - dt * 5)
  self.vz = self.vz * (1 - dt * 5)

  --print("cam", self.vx, self.vy, self.vz)
end

function c:setCamera(cam)
  cam:resetTransform()
  cam:translate(self.x, self.y, self.z)
  cam:rotateY(self.ry)
  cam:rotateX(self.rx)
end

function c:lookAt(cam, position, distance)
  self.x = position.x
  self.y = position.y
  self.z = position.z

  cam:resetTransform()
  cam:translate(position)
  cam:rotateY(self.ry)
  cam:rotateX(self.rx)
  cam:translate(0, 0, distance)
end

function c:mousemoved(x, y)
  local speedH = 0.005
  local speedV = 0.005
  self.ry = self.ry + x * speedH
  self.rx = math.max(-math.pi / 2 + 0.01, math.min(math.pi / 2 - 0.01, self.rx - y * speedV))
end

return c
