local WeaponFrame = prism.Object:extend("WeaponFrame")

--- @param level Level
function WeaponFrame:__new(level)
   self.level = level
end

--- @param display Display
function WeaponFrame:draw(display)
   -- start by painting a background
   local originX, originY = display.width - 14, 2

   -- display:putFilledRect(originX, originY, 15, 6, " ", prism.Color4.TRANSPARENT, prism.Color4.RED)

   -- okay now we want to rotate through weapons in the inventory, two rows per weapon.

   -- we don't know the sort order. so go off the hotkeys to position it.
   -- we could also run this as 1-9 and create all the empty spaces also with numbers
   local player = self.level:query(prism.components.PlayerController):first()

   if player then
      local inventory = player:get(prism.components.Inventory)
      for weaponActor in player:get(prism.components.Inventory):query(prism.components.Weapon):iter() do
         local weapon = weaponActor:get(prism.components.Weapon)
         assert(weapon)

         local baseRow = (tonumber(weapon.hotkey) - 1) * 2
         -- prism.logger.info("weapon: " .. weapon.hotkey .. " " .. weaponActor:getName() .. " at row " .. tostring(baseRow))

         local bg = prism.Color4.BLACK
         local fg = prism.Color4.WHITE
         if weapon.active then
            bg = prism.Color4.WHITE
            fg = prism.Color4.BLACK
         end

         display:putFilledRect(originX, originY + baseRow, 15, 2, " ", prism.Color4.TRANSPARENT, bg)

         -- prism.logger.info("ammoType: ", weapon.ammoType)
         if (weapon.ammopershot ~= 0) then
            local totalAmmo = 0
            if inventory and inventory:getStack(AMMO_TYPES[weapon.ammoType]) then
               -- prism.logger.info(" found inventory and ammo")
               local ammoStack = inventory:getStack(AMMO_TYPES[weapon.ammoType]):get(prism.components.Item)
               if ammoStack then
                  totalAmmo = ammoStack.stackCount
               else
                  totalAmmo = 0
               end
            end

            display:putString(originX, originY + baseRow, tostring(weapon.ammo) .. "/" .. tostring(totalAmmo),
               fg, bg,
               math.huge, "right", 15)
         end

         display:putString(originX, originY + baseRow, tostring(weapon.hotkey) .. " " .. weaponActor:getName(),
            fg, bg,
            math.huge, "left", 15)

         -- now list weapon stats
         display:putString(originX + 3, originY + baseRow + 1, tostring(weapon.damage), fg, bg)
         display:putString(originX + 6, originY + baseRow + 1, tostring(weapon.push), fg, bg)

         display:putString(originX + 9, originY + baseRow + 1, tostring(math.floor(weapon.range)), fg, bg)
         display:put(originX + 2, originY + baseRow + 1, 484, fg, bg)
         display:put(originX + 5, originY + baseRow + 1, 656, fg, bg)
         display:put(originX + 8, originY + baseRow + 1, 510, fg, bg)
      end
   end
end

return WeaponFrame
