--- @class DestructSystem : System
local DestructSystem = prism.System:extend("DestructSystem")
local Game = require "game"
local Audio = require "audio"

function DestructSystem:onTurnEnd(level, actor)
   if actor:has(prism.components.PlayerController) then
      Game:turn()
      local player = actor

      -- for now, start randomly converting floor tiles into impassable fire tiles

      local turnsRemaining = MAX_TURNS_IN_LEVEL - Game.turnsInLevel
      -- prism.logger.info("turnsRemaining: ", turnsRemaining)

      if turnsRemaining % 25 == 0 and turnsRemaining <= 100 and turnsRemaining > 0 then
         -- prism.logger.info("triggering destruction close message: ", turnsRemaining)
         level:yield(prism.messages.Animation {
            animation = spectrum.animations.SelfDestruct(turnsRemaining),
            blocking = false,
            skippable = false
         })

         return
      end

      if turnsRemaining <= 0 then
         if turnsRemaining == 0 then
            level:yield(prism.messages.Animation {
               animation = spectrum.animations.SelfDestruct(0),
               blocking = false,
               skippable = false
            })
         end

         if turnsRemaining == 0 or turnsRemaining % 2 == 0 then
            Audio.playSfx("selfDestruct")
            for x, y, cell in level:eachCell() do
               local target = prism.Vector2(x, y)

               if math.random() < 0.07 then
                  level:setCell(x, y, prism.cells.Fire())
               end
            end
         end
      end
   end
end

return DestructSystem
