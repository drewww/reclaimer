--- @class DestructSystem : System
local DestructSystem = prism.System:extend("DestructSystem")
local Game = require "game"

function DestructSystem:onTurnEnd(level, actor)
   if actor:has(prism.components.PlayerController) then
      Game:turn()
      local player = actor

      if Game.turnsInLevel > MAX_TURNS_IN_LEVEL then
         -- for now, start randomly converting floor tiles into impassable fire tiles

         prism.logger.info("EXPLODE")
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
