local WeaponUtil = {}

--- @param inventory Inventory
--- @return boolean
WeaponUtil.setActive = function(inventory, hotkey)
   -- loop through all items with weapon, set to false except one matching the hotkey.
   if not inventory then return false end

   local didSet = false
   inventory:query(prism.components.Weapon):each(
   ---@param component Weapon
      function(actor, component --[[@as Weapon]])
         component.active = hotkey == component.hotkey

         if component.active then didSet = true end
      end
   )

   return didSet
end

--- @param inventory Inventory
--- @return Actor?
WeaponUtil.getActive = function(inventory)
   -- loop through all items until we hit one with a true active flag

   local activeWeapon = nil
   inventory:query(prism.components.Weapon):each(
   ---@param component Weapon
      function(actor, component --[[@as Weapon]])
         if component.active then activeWeapon = actor end
      end
   )

   return activeWeapon
end

return WeaponUtil
