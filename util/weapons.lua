local WeaponUtil = {}

--- @param inventory Inventory
--- @return boolean
WeaponUtil.setActive = function(inventory, hotkey)
   local selectedWeapon = WeaponUtil.getWeaponForHotkey(inventory, hotkey)

   -- unselect the currently active weapon
   local activeWeapon = WeaponUtil.getActive(inventory)
   if activeWeapon then
      activeWeapon:get(prism.components.Weapon).active = false
   end

   -- prism.logger.info("setting weapon active for hotkey " .. tostring(hotkey) .. " " .. tostring(selectedWeapon:getName()))
   if selectedWeapon then
      selectedWeapon:get(prism.components.Weapon).active = true
      return true
   else
      return false
   end
end

--- @return Actor?
WeaponUtil.getWeaponForHotkey = function(inventory, hotkey)
   -- loop through all items with weapon, set to false except one matching the hotkey.
   if not inventory then return nil end

   local selectedWeapon = nil
   inventory:query(prism.components.Weapon):each(
   ---@param component Weapon
      function(actor, component --[[@as Weapon]])
         if hotkey == component.hotkey then
            selectedWeapon = actor
         end
      end
   )

   return selectedWeapon
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


--- @param actor Actor
--- @param target Vector2
--- @return Vector2[]
function WeaponUtil.getTargetPoints(actor, target)
   local points = {}

   if not actor then return points end
   local inventory = actor:get(prism.components.Inventory)
   if not inventory then return points end
   local weaponActor = WeaponUtil.getActive(inventory)
   if not weaponActor then return points end
   local weapon = weaponActor:get(prism.components.Weapon)

   if weapon and weapon.template == "point" then
      -- we could range-limit this
      table.insert(points, target)
   end

   return points
end

return WeaponUtil
