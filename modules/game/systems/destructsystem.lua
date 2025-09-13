--- @class DestructSystem : System
local DestructSystem = prism.System:extend("DestructSystem")
local Game = require "game"

function DestructSystem:onTurnEnd(level, actor)
   if actor:has(prism.components.PlayerController) then
      Game:turn()
      local player = actor

      -- for now, start randomly converting floor tiles into impassable fire tiles

      local turnsRemaining = MAX_TURNS_IN_LEVEL - Game.turnsInLevel
      prism.logger.info("turnsRemaining: ", turnsRemaining)
      if turnsRemaining == 0 then
         level:yield(prism.messages.Animation {
            animation = spectrum.animations.SelfDestruct(0),
            blocking = true,
            skippable = true
         })
      elseif turnsRemaining % 25 == 0 and turnsRemaining <= 100 then
         prism.logger.info("triggering destruction close message: ", turnsRemaining)
         level:yield(prism.messages.Animation {
            animation = spectrum.animations.SelfDestruct(turnsRemaining),
            blocking = true,
            skippable = true
         })
      end

      if turnsRemaining < 0 then
         for x, y, cell in level:eachCell() do
            local target = prism.Vector2(x, y)

            if math.random() < 0.05 then
               if player:getPosition():getRange(target) < 2 then
                  local damage = prism.actions.Damage(player, 1)
                  level:tryPerform(damage)
               end

               level:setCell(x, y, prism.cells.Fire())
            end
         end
      end
   end
end

return DestructSystem
