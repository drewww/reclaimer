--- @class TickSystem : System
local TickSystem = prism.System:extend("TickSystem")

function TickSystem:onTurnEnd(level, actor)
    -- try to tick the actor
    level:tryPerform(prism.actions.Tick(actor))
end

return TickSystem
