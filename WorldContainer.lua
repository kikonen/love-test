local ode = require("moonode")

Class = require 'external_modules/hump/class'

WorldContainer = Class{}

-- simulation step (seconds)
local STEP = 0.001

local GRAVITY = {0, 0, 0}

-- group id for contact joints
local TERRAIN_GROUP_ID = 0

-- Prepare surface parameters for joint contacts. Since they are always the same,
-- for efficiency we do it only once before starting the simulation:
local terrain_surface = ode.pack_surfaceparameters{
  mu = 50.0,
  slip1 = 0.7,
  slip2 = 0.7,
  soft_erp = 0.96,
  soft_cfm = 0.94,
  approx1 = true,
}


function WorldContainer:init(opt)
  self.ode = ode
  self.world = ode.create_world()
  self.space = ode.create_hash_space()

  self.world:set_gravity(GRAVITY)
  self.world:set_quick_step_num_iterations(12)

  -- Set the 'near callback', invoked when two geoms are potentially colliding:
  ode.set_near_callback(function(o1, o2)
      local collide, contact_points = ode.collide(o1, o2, 8)
      if not collide then return end

      if #contact_points > 0 then
        local e1 = self.shape_to_entity[o1]
        local e2 = self.shape_to_entity[o2]

        --trace("collide", 2, e1, e2)
        if e1 then
          e1.hit = true
        end
        if e2 then
          e2.hit = true
        end
      end

      for _, cp in ipairs(contact_points) do
        local joint = ode.create_contact_joint(
          self.world,
          TERRAIN_GROUP_ID,
          cp,
          terrain_surface)
        joint:attach(o1:get_body(), o2:get_body())
      end
  end)

  self.shape_to_entity = {}
end

function WorldContainer:register(body, entity)
  self.shape_to_entity[body] = entity
end

function WorldContainer:update(dt)
  local n, remainder = 0, (self.remainder or 0)

  -- Compute the number n of time steps to be do at this iteration,
  -- and the remainder to be accounted for at the next one:
  local tot_dt = dt + remainder
  n, remainder = tot_dt / STEP, tot_dt % STEP
  --print(n, remainder)

  for i = 1, n do
    ode.space_collide(self.space)
    self.world:quick_step(STEP)
    ode.destroy_joint_group(TERRAIN_GROUP_ID)
  end

  self.remainder = remainder
end
