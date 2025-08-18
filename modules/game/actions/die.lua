--- @class Die : Action
--- @overload fun(owner: Actor): Die
local Die = prism.Action:extend("Die")
local Game = require "game"

function Die:perform(level)
   -- check if the dying actor has an inventory. if it does, drop the first item
   -- from its inventory at this position.
   local inventory = self.owner:get(prism.components.Inventory)
   if inventory and inventory.totalCount > 0 then
      -- TODO how to make this random? might be a nice bit of query suger
      local item = inventory:query(prism.components.Item):first()
      level:addActor(item, self.owner:getPosition():decompose())
   end

   if not self.owner:has(prism.components.PlayerController) then
      Game.stats:increment("kills")
   end

   level:removeActor(self.owner)

   if self.owner:has(prism.components.Unstable) then
      level:addActor(prism.actors.BarrelExploding(), self.owner:getPosition():decompose())
   end

   -- if there are no players left, game is over.
   if not level:query(prism.components.PlayerController):first() then level:yield(prism.messages.Lose()) end
end

return Die
