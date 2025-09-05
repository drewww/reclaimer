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
   local source = actor:getPosition()
   if not source then return points end

   local inventory = actor:get(prism.components.Inventory)
   if not inventory then return points end
   local weaponActor = WeaponUtil.getActive(inventory)
   if not weaponActor then return points end
   local weapon = weaponActor:get(prism.components.Weapon)

   if weapon and weapon.template == "point" then
      -- we could range-limit this
      table.insert(points, target)
   elseif weapon and weapon.template == "line" then
      local line, found = prism.Bresenham(source.x, source.y, target.x, target.y)

      for i, p in ipairs(line) do
         local point = prism.Vector2(p[1], p[2])
         if source:distance(point) <= weapon.range then
            table.insert(points, point)
         end
      end
   elseif weapon and weapon.template == "cone" then
      local range = weapon.range
      local angle = math.pi / 2 -- or whatever angle you want

      local startPos = actor:getPosition()
      assert(startPos)

      local direction = (target - startPos):normalize()
      local baseAngle = math.atan2(direction.y, direction.x)
      local halfAngle = angle / 2

      -- Test all points in a square grid around the start position
      for dx = -range, range do
         for dy = -range, range do
            local testPoint = startPos + prism.Vector2(dx, dy)
            local toPoint = testPoint - startPos
            local distance = toPoint:length()

            -- Check if point is within range (but not at the start position)
            if distance > 0.1 and distance <= range then
               local pointAngle = math.atan2(toPoint.y, toPoint.x)

               -- Calculate angle difference
               local angleDiff = pointAngle - baseAngle

               -- Normalize to [-π, π]
               if angleDiff > math.pi then
                  angleDiff = angleDiff - 2 * math.pi
               elseif angleDiff < -math.pi then
                  angleDiff = angleDiff + 2 * math.pi
               end

               -- Check if within cone angle
               if math.abs(angleDiff) <= halfAngle then
                  table.insert(points, testPoint)
               end
            end
         end
      end
   end

   return points
end

return WeaponUtil
