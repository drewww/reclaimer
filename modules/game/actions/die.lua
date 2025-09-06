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

      if item then
         prism.logger.info("Adding inventory item on death: " .. item:getName())
      end
   end

   if not self.owner:has(prism.components.PlayerController) then
      Game.stats:increment("kills")
   end

   if self.owner:has(prism.components.Unstable) then
      prism.logger.info("EXPLODE AT " .. tostring(self.owner:getPosition()))

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Explode(self.owner:getPosition(), 4.0),
         blocking = true
      })
      local source = self.owner:getPosition()
      level:removeActor(self.owner)

      for actor, component in level:query(prism.components.Health):iter() do
         if actor:getPosition():distanceChebyshev(source) <= 3 then
            level:tryPerform(prism.actions.Damage(actor, 5))
         end
      end
   else
      prism.logger.info("Actor died: " .. self.owner:getName())

      if not level:query(prism.components.PlayerController):first() then level:yield(prism.messages.Lose()) end

      level:removeActor(self.owner)
   end


   -- if there are no players left, game is over.
end

return Die
