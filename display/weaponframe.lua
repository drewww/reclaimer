local WeaponFrame = prism.Object:extend("WeaponFrame")

--- @param level Level
function WeaponFrame:__new(level)
   self.level = level
end

--- @param display Display
function WeaponFrame:draw(display)
   -- start by painting a background
   local originX, originY = display.width - 14, 2

   display:putFilledRect(originX, originY, 15, 6, " ", prism.Color4.TRANSPARENT, prism.Color4.RED)

   -- okay now we want to rotate through weapons in the inventory, two rows per weapon.

   -- we don't know the sort order. so go off the hotkeys to position it.
   local player = self.level:query(prism.components.PlayerController):first()
   if player then
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
         display:putFilledRect(originX, originY + baseRow, 15, 2, " ", prism.Color4.TRANSPARENT, prism.Color4.BLACK)


         display:putString(originX, originY + baseRow, tostring(weapon.hotkey) .. " " .. weaponActor:getName(),
            fg, bg,
            math.huge, "left", 15)
      end
   end
end

return WeaponFrame
