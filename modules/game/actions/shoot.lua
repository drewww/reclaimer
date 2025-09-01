local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format
local Game = require "game"

local knockback = require "util/knockback"

local ShootTarget = prism.Target():with(prism.components.Collider):range(10):sensed()

local Shoot = prism.Action:extend("ShootAction")
Shoot.name = "Shoot"
Shoot.targets = { ShootTarget }
Shoot.requireComponents = {
   prism.components.Controller,
}

function Shoot:canPerform(level)
   return true
end

function Shoot:perform(level, shot)
   local direction = (shot:getPosition() - self.owner:getPosition())

   print("direction: " .. tostring(direction))

   local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }

   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Projectile(self.owner, shot:getPosition()),
      -- actor = self.owner
      -- blocking = true -- causes screen to go black
   })

   -- because the enemy moves immediately after this, if you just move one space
   -- it appears like they're not moving.
   local startPos = shot:getPosition()
   local finalPos, hitWall, cellsMoved = knockback(level, startPos, direction, 2, mask)

   -- Move the target to final position
   if level:hasActor(shot) then
      level:moveActor(shot, finalPos)
   end

   -- Calculate damage based on whether they hit a wall
   local damageValue = hitWall and 5 or 1

   local damage = prism.actions.Damage(shot, damageValue)

   -- Why do I need to ask first? I guess this is type protection more or less.
   if level:canPerform(damage) then level:perform(damage) end

   local shotName = Name.lower(shot)
   local ownerName = Name.lower(self.owner)
   local dmgstr = ""

   if damage.dealt then
      if self.owner:has(prism.components.PlayerController) then
         Game.stats:increment("shots")
      end
   end

   if damage.dealt then dmgstr = sf("%i damage.", damage.dealt) end
   Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
   Log.addMessage(shot, sf("The %s shot you! %s", ownerName, dmgstr))
   Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))
end

return Shoot
