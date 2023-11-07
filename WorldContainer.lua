local ode = require("moonode")

Class = require 'external_modules/hump/class'

WorldContainer = Class{}

-- simulation step (seconds)
local STEP = 0.001

local GRAVITY = {0, -9.8, 0}

-- group id for contact joints
local TERRAIN_GROUP_ID = 0

-- Prepare surface parameters for joint contacts. Since they are always the same,
-- for efficiency we do it only once before starting the simulation:
local terrainSurface = ode.pack_surfaceparameters({
      mu = 50.0,
      slip1 = 0.7,
      slip2 = 0.7,
      soft_erp = 0.96,
      soft_cfm = 0.94,
      approx1 = true,
})


function WorldContainer:init(opt)
   self.ode = ode
   self.world = ode.create_world()
   self.space = ode.create_hash_space()

   self.world:set_gravity(GRAVITY)
   self.world:set_quick_step_num_iterations(12)

   -- Set the 'near callback', invoked when two geoms are potentially colliding:
   ode.set_near_callback(function(o1, o2)
         local collide, contactpoints = ode.collide(o1, o2, 32)
         if not collide then return end

         -- print("collide")
         for _, contactpoint in ipairs(contactpoints) do
            --print(self.world, TERRAIN_GROUP_ID, contactpoint, terrainSurface)
            --debug.debug()
            local joint = ode.create_contact_joint(self.world, TERRAIN_GROUP_ID, contactpoint, terrainSurface)
            joint:attach(o1:get_body(), o2:get_body())
         end
   end)
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
