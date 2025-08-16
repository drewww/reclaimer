local InfoFrame = prism.Object:extend("InfoFrame")

--- @param level Level
function InfoFrame:__new(level)
   self.level = level
end

--- @param display : Display
function InfoFrame:draw(display)
   display:putFilledRect(1, 1, 81, 1, 1, prism.Color4.TRANSPARENT, prism.Color4.BLUE)

   -- now draw health over integer
   display:putString(1, 1, "HP", prism.Color4.WHITE, prism.Color4.BLUE)

   local player = self.level:query(prism.components.PlayerController):first()
   local health = player and player:get(prism.components.Health)

   -- function Display:putString(x, y, str, fg, bg, layer, align, width)

   if health then
      display:putFilledRect(4, 1, health.maxHP, 1, (15 * 32) + 5, prism.Color4.WHITE, prism.Color4.BLUE)
      display:putFilledRect(4, 1, health.hp, 1, (15 * 32) + 4, prism.Color4.WHITE, prism.Color4.BLUE)
   end
end

return InfoFrame
