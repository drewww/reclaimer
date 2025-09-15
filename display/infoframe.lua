local InfoFrame = prism.Object:extend("InfoFrame")
local Game = require("game")

--- @param level Level
--- @param display Display
function InfoFrame:__new(level, display)
   self.level = level
   self.display = display
end

function InfoFrame:draw()
   self.display:putFilledRect(1, 1, 81, 1, 1, prism.Color4.TRANSPARENT, prism.Color4.NAVY)

   -- now draw health over integer
   self.display:putString(1, 1, "HP", prism.Color4.WHITE, prism.Color4.NAVY)

   local player = self.level:query(prism.components.PlayerController):first()
   local health = player and player:get(prism.components.Health)

   -- function self.display:putString(x, y, str, fg, bg, layer, align, width)

   if health then
      self.display:putFilledRect(4, 1, health.maxHP, 1, " ", prism.Color4.WHITE, prism.Color4.NAVY)
      self.display:putFilledRect(4, 1, health.hp, 1, HEART, prism.Color4.WHITE, prism.Color4.NAVY)
   end

   local energy = player and player:get(prism.components.Energy)
   if energy then
      self.display:put(24, 1, "»", prism.Color4.WHITE, prism.Color4.NAVY)
      self.display:putString(25, 1, tostring(math.floor(energy.energy)) .. "/" .. tostring(energy.maxEnergy),
         prism.Color4.WHITE,
         prism.Color4.NAVY)
   end

   local dashColor = prism.Color4.WHITE
   if player and player:has(prism.components.Dashing) then
      dashColor = prism.Color4.BLUE
   end
   self.display:putString(29, 1, "DASH", dashColor, prism.Color4.NAVY)

   self.display:putString(41, 1, "LVL", prism.Color4.WHITE, prism.Color4.NAVY)
   self.display:putString(44, 1, tostring(Game.depth), prism.Color4.WHITE, prism.Color4.NAVY)

   local inventory = player and player:get(prism.components.Inventory)
   if inventory then
      local bits = inventory:getStack(prism.actors.Loot)
      local amount = 0

      if bits then
         amount = bits:get(prism.components.Item).stackCount
      end

      self.display:put(49, 1, CENTS, prism.Color4.WHITE, prism.Color4.NAVY)
      self.display:putString(50, 1, tostring(amount), prism.Color4.WHITE, prism.Color4.NAVY)
   end

   if Game.turnsInLevel > MAX_TURNS_IN_LEVEL then
      self.display:putString(55, 1, "DESTRUCT", prism.Color4.WHITE, prism.Color4.NAVY)
   else
      self.display:putString(55, 1, "T-" .. tostring(MAX_TURNS_IN_LEVEL - Game.turnsInLevel), prism.Color4.WHITE,
         prism.Color4.NAVY)
   end
end

return InfoFrame
