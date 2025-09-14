local WeaponUtil          = require "util.weapons"
local Audio               = require "audio"

--- @class Reload : Action
--- @field name string
--- @field targets Target[]
local Reload              = prism.Action:extend("Reload")
Reload.name               = "reload"

Reload.targets            = {}

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
      --- @type Weapon
      local weaponComponent = weapon:get(prism.components.Weapon)
      prism.logger.info(" canPerform-RELOAD has weapon, c? ", weaponComponent)
      if weaponComponent then
         prism.logger.info(" canPerform-RELOAD has weaponComponent")
         if weaponComponent.ammopershot == 0 then
            do
               return false
            end
         end

         prism.logger.info("ammo check ", weaponComponent.ammoType, weaponComponent.maxAmmo, weaponComponent.ammo)
         if weaponComponent.maxAmmo == weaponComponent.ammo then
            return false
         end

         -- If we're currently reloading, allow continuing the reload
         prism.logger.info("reload check ", weaponComponent.reload)
         if weaponComponent.reload > 0 then
            return true
         end

         local ammo = inventory:getStack(AMMO_TYPES[weaponComponent.ammoType])
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

      if weapon:get(prism.components.Weapon).ammopershot == 0 then
         return false
      end
   else
      return false
   end
end

function Reload:perform(level)
   -- Multi-turn reload system based on reloadTurns
   local inventory = self.owner:get(prism.components.Inventory)
   assert(inventory)

   local weapon = WeaponUtil.getActive(inventory)
   assert(weapon)

   local weaponComponent = weapon:get(prism.components.Weapon)
   assert(weaponComponent)

   -- If reloadTurns is 1, reload immediately (original behavior)
   if weaponComponent.reloadTurns == 1 then
      local ammo = inventory:getStack(AMMO_TYPES[weaponComponent.ammoType])

      if ammo then
         local totalAmmo = ammo:get(prism.components.Item).stackCount
         local missingAmmo = weaponComponent.maxAmmo - weaponComponent.ammo

         prism.logger.info("reloading: avail: " .. tostring(totalAmmo) .. " missing: " .. tostring(missingAmmo))

         if missingAmmo == 0 then return end

         -- load as much as we can. typically this will be all the missing ammo, but
         -- don't overload more ammo than exists in inventory.
         local ammoToLoad = math.min(missingAmmo, totalAmmo)

         prism.logger.info("ammo, ammoToLoad totalAmmo", ammo, ammoToLoad, totalAmmo)
         inventory:removeQuantity(ammo, ammoToLoad)
         weaponComponent.ammo = weaponComponent.ammo + ammoToLoad

         -- if it's the player, show reload animation at cursor
         -- otherwise next to the actor
         local x, y = nil, nil
         if not self.owner:has(prism.components.PlayerController) then
            x, y = self.owner:getPosition():decompose()
            x = x + 1
         else
            -- if it IS the player, play reload sound
            Audio.playSfx("reload")
         end

         level:yield(prism.messages.Animation {
            animation = spectrum.animations.Notice("RELOAD", x, y),
            blocking = false
         })
      end
   else
      -- Multi-turn reload system
      if weaponComponent.reload == 0 then
         -- Start the reload process
         prism.logger.info("Starting reload: ", weaponComponent.reloadTurns)
         weaponComponent.reload = weaponComponent.reloadTurns - 1

         local x, y = nil, nil
         if not self.owner:has(prism.components.PlayerController) then
            x, y = self.owner:getPosition():decompose()
            x = x + 1
         else
            Audio.playSfx("reload")
         end

         level:yield(prism.messages.Animation {
            animation = spectrum.animations.Notice("RELOAD " .. weaponComponent.reload, x, y),
            blocking = false
         })
      else
         -- Continue the reload countdown
         weaponComponent.reload = weaponComponent.reload - 1

         if weaponComponent.reload == 0 then
            -- Reload is complete, actually reload the weapon
            local ammo = inventory:getStack(AMMO_TYPES[weaponComponent.ammoType])

            if ammo then
               local totalAmmo = ammo:get(prism.components.Item).stackCount
               local missingAmmo = weaponComponent.maxAmmo - weaponComponent.ammo

               if missingAmmo > 0 then
                  local ammoToLoad = math.min(missingAmmo, totalAmmo)
                  inventory:removeQuantity(ammo, ammoToLoad)
                  weaponComponent.ammo = weaponComponent.ammo + ammoToLoad
               end
            end

            local x, y = nil, nil
            if not self.owner:has(prism.components.PlayerController) then
               x, y = self.owner:getPosition():decompose()
               x = x + 1
            end

            level:yield(prism.messages.Animation {
               animation = spectrum.animations.Notice("READY", x, y),
               blocking = false
            })
         else
            -- Show countdown
            local x, y = nil, nil
            if not self.owner:has(prism.components.PlayerController) then
               x, y = self.owner:getPosition():decompose()
               x = x + 1
            end

            level:yield(prism.messages.Animation {
               animation = spectrum.animations.Notice("RELOAD " .. weaponComponent.reload, x, y),
               blocking = false
            })
         end
      end
   end
end

return Reload
