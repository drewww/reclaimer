local Log = prism.components.Log
local Name = prism.components.Name
local sf = string.format
local Game = require "game"

local WeaponUtil = require "util/weapons"
local knockback = require "util/knockback"

local ShootTarget = prism.Target():with(prism.components.Collider):sensed()

local Shoot = prism.Action:extend("ShootAction")
Shoot.name = "Shoot"
Shoot.targets = { ShootTarget }
Shoot.requireComponents = {
   prism.components.Controller,
}

function Shoot:canPerform(level, shot)
   -- TODO check for ammo
   local inventory = self.owner:get(prism.components.Inventory)
   if inventory then
      local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)
      if not weapon then
         prism.logger.info("No weapon selected.")
         return false
      end

      local ammo = inventory:getStack(prism.actors.AmmoStack)
      local availableAmmo = false
      if ammo then
         local ammoItem = ammo:get(prism.components.Item)
         prism.logger.info("ammo: " .. tostring(ammoItem.stackCount))
         if ammoItem and ammoItem.stackCount > 0 then
            availableAmmo = true
         end
      end

      -- now check range
      local range = self.owner:getRange(shot)
      local inRange = false
      if range < weapon.range then
         inRange = true
      end

      return inRange and availableAmmo
   else
      return false
   end
end

function Shoot:perform(level, shot)
   local inventory = self.owner:get(prism.components.Inventory)

   local weapon = WeaponUtil.getActive(inventory):get(prism.components.Weapon)
   assert(weapon)

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
   local finalPos, hitWall, cellsMoved = knockback(level, startPos, direction, weapon.push, mask)

   -- Move the target to final position
   if level:hasActor(shot) then
      level:moveActor(shot, finalPos)
   end

   -- Calculate damage based on whether they hit a wall
   local damageValue = hitWall and WALL_COLLIDE_DAMAGE + weapon.damage or weapon.damage

   local damage = prism.actions.Damage(shot, damageValue)

   -- Why do I need to ask first? I guess this is type protection more or less.
   if level:canPerform(damage) then level:perform(damage) end

   local shotName = Name.lower(shot)
   local ownerName = Name.lower(self.owner)
   local dmgstr = ""

   -- TODO increment this even if you miss. especially if we support shooting random spots.
   if damage.dealt then
      if self.owner:has(prism.components.PlayerController) then
         Game.stats:increment("shots")
      end

      if inventory then
         local ammoUsed = inventory:getStack(prism.actors.AmmoStack)

         if ammoUsed then
            inventory:removeQuantity(ammoUsed, 1)
         end
      end
   end

   if damage.dealt then dmgstr = sf("%i damage.", damage.dealt) end
   Log.addMessage(self.owner, sf("You shot the %s. %s", shotName, dmgstr))
   Log.addMessage(shot, sf("The %s shot you! %s", ownerName, dmgstr))
   Log.addMessageSensed(level, self, sf("The %s shoots the %s. %s", ownerName, shotName, dmgstr))
end

return Shoot
