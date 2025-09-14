--- @class Die : Action
--- @overload fun(owner: Actor): Die
local Die = prism.Action:extend("Die")
local Game = require "game"
local Audio = require "audio"

function Die:perform(level)
   -- check if the dying actor has an inventory. if it does, drop the first item
   -- from its inventory at this position.
   --
   if self.owner:has(prism.components.BotController) then
      level:addActor(prism.actors.Scrap(), self.owner:getPosition():decompose())
   end
   -- local inventory = self.owner:get(prism.components.Inventory)
   -- if inventory and inventory.totalCount > 0 then
   --    -- TODO how to make this random? might be a nice bit of query suger
   --    local item = inventory:query(prism.components.Item):first()
   --    level:addActor(item, self.owner:getPosition():decompose())

   --    if item then
   --       prism.logger.info("Adding inventory item on death: " .. item:getName())
   --    end
   -- end

   if not self.owner:has(prism.components.PlayerController) then
      Game.stats:increment("kills")
   end

   if self.owner:has(prism.components.Unstable) then
      prism.logger.info("EXPLODE AT " .. tostring(self.owner:getPosition()))

      Audio.playSfx("explode")

      level:yield(prism.messages.Animation {
         animation = spectrum.animations.Explode(self.owner:getPosition(), 4.0),
         blocking = true
      })
      local source = self.owner:getPosition()
      level:removeActor(self.owner)

      for actor, component in level:query(prism.components.Health):iter() do
         if actor:getPosition():distanceChebyshev(source) <= 3 then
            level:tryPerform(prism.actions.Damage(actor, BARREL_EXPLODE_DAMAGE))
         end
      end
   else
      prism.logger.info("Actor died: " .. self.owner:getName())

      if self.owner:has(prism.components.Targeting) then
         local targeting = self.owner:get(prism.components.Targeting)
         assert(targeting)

         for i, p in ipairs(targeting.cells) do
            -- set targeting on these cells
            local cell = level:getCell(p.x, p.y)
            local targeted = cell:get(prism.components.Targeted)

            if targeted then
               targeted.times = targeted.times - 1
               if targeted.times == 0 then
                  cell:remove(targeted)
               end
            end
         end
      end

      if not self.owner:has(prism.components.PlayerController) then
         Audio.playSfx("killEnemy")
      end

      level:removeActor(self.owner)

      if not level:query(prism.components.PlayerController):first() then level:yield(prism.messages.Lose()) end
   end


   -- if there are no players left, game is over.
end

return Die
