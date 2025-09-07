local WeaponUtil = require "util.weapons"

--- @class Reload : Action
--- @field name string
--- @field targets Target[]
local Reload = prism.Action:extend("Reload")
Reload.name = "reload"

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

   -- don't allow reloads on non-ammo weapons, or if there is no missing ammo
   if weapon then
      local weaponComponent = weapon:get(prism.components.Weaopn)

      if weaponComponent then
         if weaponComponent.ammopershot == 0 then
            do
               return false
            end
         end

         prism.logger.info("ammo check ", weaponComponent.maxAmmo, weaponComponent.ammo)
         if weaponComponent.maxAmmo == weaponComponent.ammo then
            return false
         end
      end


      if weapon:get(prism.components.Weapon).ammopershot == 0 then
         return false
      end
   else
      return false
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

      prism.logger.info("reloading: avail: " .. tostring(totalAmmo) .. " missing: " .. tostring(missingAmmo))

      if missingAmmo == 0 then return end

      -- load as much as we can. typically this will be all the missing ammo, but
      -- don't overload more ammo than exists in inventory.
      local ammoToLoad = math.min(missingAmmo, totalAmmo)
      inventory:removeQuantity(ammo, ammoToLoad)
      weaponComponent.ammo = weaponComponent.ammo + ammoToLoad

      -- if it's the player, show reload animation at cursor
      -- otherwise next to the actor
      local x, y = nil, nil
      if not self.owner:has(prism.components.PlayerController) then
         x, y = self.owner:getPosition():decompose()
         x = x + 1
      end

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Notice("RELOAD", x, y),
         blocking = false
      })
   end
end

return Reload
