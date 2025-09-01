local WeaponUtil = require "util/weapons"
-- local ReloadTarget = prism.Target():isPrototype(prism.Actor):with(prism.components.Weapon)
-- local ReloadTarget = prism.Target():isPrototype(prism.Actor)

--- @class Reload : Action
--- @field name string
--- @field targets Target[]
local Reload = prism.Action:extend("Reload")
Reload.name = "reload"
-- Reload.targets = { ReloadTarget }
Reload.targets = {}

Reload.requiredComponents = {
   prism.components.Inventory
}

--- @param level Level
function Reload:canPerform(level)
   -- check if there is any relevant ammo available
   local inventory = self.owner:get(prism.components.Inventory)
   assert(inventory)

   local weapon = WeaponUtil.getActive(inventory)
   assert(weapon)

   -- don't allow reloads on non-ammo weapons
   if weapon then
      if weapon:get(prism.components.Weapon).ammopershot then
         return false
      end
   end

   local ammo = inventory:getStack(prism.actors.AmmoStack)
   if ammo then
      local ammoComponent = ammo:get(prism.components.Item)
      if ammoComponent then
         if ammoComponent.stackCount > 0 then
            return true
         else
            return false
         end
      end
   end
end

function Reload:perform(level)
   -- move as much ammo from inventory to weapon as we can fit, and can fund
   -- from the inventory.

   local inventory = self.owner:get(prism.components.Inventory)
   assert(inventory)

   local weapon = WeaponUtil.getActive(inventory)
   assert(weapon)

   local ammo = inventory:getStack(prism.actors.AmmoStack)
   local weaponComponent = weapon:get(prism.components.Weapon)
   if ammo and weaponComponent then
      local totalAmmo = ammo:get(prism.components.Item).stackCount

      local missingAmmo = weaponComponent.maxAmmo - weaponComponent.ammo

      -- load as much as we can. typically this will be all the missing ammo, but
      -- don't overload more ammo than exists in inventory.
      local ammoToLoad = math.min(missingAmmo, totalAmmo)
      inventory:removeQuantity(ammo, ammoToLoad)
      weaponComponent.ammo = weaponComponent.ammo + ammoToLoad
   end
end

return Reload
