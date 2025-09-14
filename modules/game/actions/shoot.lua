local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format
local Game = require "game"
local Audio = require "audio"

local WeaponUtil = require "util.weapons"
local knockback = require "util.knockback"
local constants = require "util.constants"

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
   prism.logger.info("SHOOT CAN PERFORM")
   -- TODO check for ammo

   local inventory = self.owner:get(prism.components.Inventory)
   if inventory then
      prism.logger.info("...has inventory")
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
      elseif weapon.ammo >= weapon.ammopershot then
         availableAmmo = true
      end

      -- now check range
      local range = self.owner:getPosition():getRange(target)
      local inRange = false
      if range <= weapon.range then
         inRange = true
      end

      if range == 0 then
         return false
      end

      prism.logger.info("Available ammo: ", availableAmmo)

      return availableAmmo
   else
      return false
   end
end

--- @param target Vector2
function Shoot:perform(level, target)
   local inventory = self.owner:get(prism.components.Inventory)
   local direction = target - self.owner:getPosition()

   local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)
   assert(weapon)

   local targetPoints = WeaponUtil.getTargetPoints(level, self.owner, target)

   weapon.ammo = math.max(weapon.ammo - weapon.ammopershot, 0)

   if weapon.ammo < weapon.ammopershot and self.owner:has(prism.components.PlayerController) then
      Audio.playSfx("click")
      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Notice("EMPTY"),
         blocking = false
      })
   end

   if weapon.template == "aoe" then
      local angle = math.atan2(direction.y, direction.x)
      -- Convert angle to sprite offset: 0=up, 1=right, 2=down, 3=left
      local spriteOffset = math.floor((angle + math.pi * 2.5) / (math.pi * 0.5)) % 4

      Audio.playSfx("rocketLaunch")
      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Projectile(self.owner, target, ROCKET_BASE + spriteOffset),
         blocking = true
      })

      Audio.playSfx("explode")
      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Explode(target, weapon.aoe, targetPoints),
         blocking = true
      })
   elseif weapon.template == "cone" then
      Audio.playSfx("shotgun")
      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Explode(self.owner:getPosition(), weapon.range + 1, targetPoints, prism.Color4.WHITE),
         blocking = true
      })
   elseif weapon.template == "melee" then
      Audio.playSfx("cyclone")

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Melee(self.owner:getPosition()),
         blocking = true
      })
   elseif weapon.template == "line" then
      Audio.playSfx("laser")

      local laserColor = prism.Color4.LIME

      if not self.owner:has(prism.components.PlayerController) then
         laserColor = prism.Color4.RED
      end

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Laser(self.owner:getPosition(), target, laserColor, weapon.range),
         blocking = true,
         -- skippable = true
      })
   else
      Audio.playSfx("bullet")

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Projectile(self.owner, targetPoints[1], BULLET_BASE),
         blocking = true,
         -- skippable = true,
      })
   end
   -- Move the target to final position
   for i, p in ipairs(targetPoints) do
      -- test for actors for each of the target points
      local targetActor = level:query():at(p:decompose()):first()
      if targetActor then
         local startPos = p

         local source = self.owner:getPosition()
         if weapon.template == "aoe" then
            -- update knockback parameters if it's AOE; you need to knockback
            -- relative to target position
            source = target
         end

         local push = prism.actions.Push(targetActor, weapon.push, source)
         -- local error = push:validateTargets()
         -- if error then
         --    prism.logger.error(error)
         -- end
         level:tryPerform(push)

         -- Calculate damage based on whether they hit a wall
         local damageValue = weapon.damage

         local damage = prism.actions.Damage(targetActor, damageValue)

         -- -- -- Why do I need to ask first? I guess this is type protection more or less.
         if level:canPerform(damage) then level:perform(damage) end

         -- local shotName = Name.lower(targetActor)
         -- local ownerName = Name.lower(self.owner)
         -- local dmgstr = ""

         -- -- TODO increment this even if you miss. especially if we support shooting random spots.
         -- -- if damage.dealt then
         if self.owner:has(prism.components.PlayerController) then
            Game.stats:increment("shots")
         end
         -- -- end

         -- if damage.dealt then dmgstr = sf("%i damage.", damage.dealt) end
         -- Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
         -- Log.addMessage(targetActor, sf("The %s shot you! %s", ownerName, dmgstr))
         -- Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))
      end
   end
end

return Shoot
