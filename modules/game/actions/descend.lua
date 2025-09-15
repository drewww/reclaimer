local Audio = require "audio"
local DescendTarget = prism.Target():with(prism.components.Stair):range(1)

--- @class Descend : Action
--- @overload fun(owner: Actor, stairs: Actor): Descend
local Descend = prism.Action:extend("Descend")
Descend.targets = { DescendTarget }

function Descend:perform(level)
   level:removeActor(self.owner)

   if self.owner:has(prism.components.Energy) then
      local energy = self.owner:get(prism.components.Energy)
      if energy then
         energy.energy = energy.maxEnergy
      end
   end

   Audio.playSfx("nextLevel")

   level:yield(prism.messages.Descend(self.owner))
end

return Descend
