local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format
local Game = require "game"

local WeaponUtil = require "util.weapons"
local knockback = require "util.knockback"

-- don't apply range here, because it's weapon dependent. check in `canPerform` instead.
local ShootTarget = prism.Target():isPrototype(prism.Vector2)

local Shoot = prism.Action:extend("ShootAction")
Shoot.name = "Shoot"
Shoot.targets = { ShootTarget }
Shoot.requireComponents = {
   prism.components.Controller,
}

--- @param target Vector2
function Shoot:canPerform(level, target)
   -- TODO check for ammo
   local inventory = self.owner:get(prism.components.Inventory)
   if inventory then
      local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)
      if not weapon then
         prism.logger.info("No weapon selected.")
         return false
      end


      -- local ammo = inventory:getStack(prism.actors.AmmoStack)
      local availableAmmo = false

      -- if ammo per shot is 0, don't check for ammo at all.
      if weapon.ammopershot == 0 then
         availableAmmo = true
      elseif weapon.ammo >= weapon.ammo then
         availableAmmo = true
      end

      -- now check range
      local range = self.owner:getPosition():getRange(target)
      local inRange = false
      if range <= weapon.range then
         inRange = true
      end

      return inRange and availableAmmo
   else
      return false
   end
end

--- @param target Vector2
function Shoot:perform(level, target)
   local inventory = self.owner:get(prism.components.Inventory)

   local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)
   assert(weapon)

   local targetPoints = WeaponUtil.getTargetPoints(level, self.owner, target)

   -- TODO different animations for different weapons
   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Projectile(self.owner, target),
      blocking = true
   })

   if weapon.template == "aoe" then
      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Explode(target, weapon.aoe),
         blocking = true
      })
   end

   -- because the enemy moves immediately after this, if you just move one space
   -- it appears like they're not moving.
   local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }


   weapon.ammo = weapon.ammo - weapon.ammopershot

   -- Move the target to final position
   for i, p in ipairs(targetPoints) do
      -- test for actors for each of thet arget points
      local targetActor = level:query():at(p:decompose()):first()
      if targetActor then
         local startPos = p

         local direction = (target - self.owner:getPosition())
         if weapon.template == "aoe" then
            -- update knockback parameters if it's AOE; you need to knockback
            -- relative to target position
            direction = p - target
         end

         local finalPos, hitWall, cellsMoved = knockback(level, startPos, direction, weapon.push, mask)

         level:moveActor(targetActor, finalPos)

         -- Calculate damage based on whether they hit a wall
         local damageValue = hitWall and WALL_COLLIDE_DAMAGE + weapon.damage or weapon.damage

         local damage = prism.actions.Damage(targetActor, damageValue)

         -- Why do I need to ask first? I guess this is type protection more or less.
         if level:canPerform(damage) then level:perform(damage) end

         local shotName = Name.lower(targetActor)
         local ownerName = Name.lower(self.owner)
         local dmgstr = ""

         -- TODO increment this even if you miss. especially if we support shooting random spots.
         if damage.dealt then
            if self.owner:has(prism.components.PlayerController) then
               Game.stats:increment("shots")
            end
         end

         if damage.dealt then dmgstr = sf("%i damage.", damage.dealt) end
         Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
         Log.addMessage(targetActor, sf("The %s shot you! %s", ownerName, dmgstr))
         Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))
      end
   end
end

return Shoot
