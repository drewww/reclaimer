--- @class EnergySystem : System
local EnergySystem = prism.System:extend("EnergySystem")

function EnergySystem:onTurnEnd(level, actor)
   -- try to tick the actor
   -- level:tryPerform(prism.actions.Tick(actor))
   if actor:has(prism.components.Energy) and not actor:has(prism.components.Dashing) then
      local energy = actor:get(prism.components.Energy)
      assert(energy)

      energy:regen()
   end
end

return EnergySystem
