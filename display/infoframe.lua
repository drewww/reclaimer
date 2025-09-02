local InfoFrame = prism.Object:extend("InfoFrame")

--- @param level Level
function InfoFrame:__new(level)
   self.level = level
end

--- @param display  Display
function InfoFrame:draw(display)
   display:putFilledRect(1, 1, 81, 1, 1, prism.Color4.TRANSPARENT, prism.Color4.NAVY)

   -- now draw health over integer
   display:putString(1, 1, "HP", prism.Color4.WHITE, prism.Color4.NAVY)

   local player = self.level:query(prism.components.PlayerController):first()
   local health = player and player:get(prism.components.Health)

   -- function Display:putString(x, y, str, fg, bg, layer, align, width)

   if health then
      display:putFilledRect(4, 1, health.maxHP, 1, " ", prism.Color4.WHITE, prism.Color4.NAVY)
      display:putFilledRect(4, 1, health.hp, 1, (15 * 32) + 4, prism.Color4.WHITE, prism.Color4.NAVY)
   end

   local inventory = player and player:get(prism.components.Inventory)
   if inventory then
      local bits = inventory:getStack(prism.actors.Loot)
      local amount = 0

      if bits then
         amount = bits:get(prism.components.Item).stackCount
      end

      display:put(30, 1, 636, prism.Color4.WHITE, prism.Color4.NAVY)
      display:putString(31, 1, tostring(amount), prism.Color4.WHITE, prism.Color4.NAVY)
   end

   local energy = player and player:get(prism.components.Energy)
   if energy then
      display:put(20, 1, "E", prism.Color4.WHITE, prism.Color4.NAVY)
      display:putString(22, 1, tostring(energy.energy) .. "/" .. tostring(energy.maxEnergy), prism.Color4.WHITE,
         prism.Color4.NAVY)
   end
end

return InfoFrame
