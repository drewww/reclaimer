--- @class TickSystem : System
local TickSystem = prism.System:extend("TickSystem")

function TickSystem:onTurn(level, actor)
   -- try to tick the actor
   -- prism.logger.info("tick on actor " .. actor:getName())
   level:tryPerform(prism.actions.Tick(actor))
end

return TickSystem
