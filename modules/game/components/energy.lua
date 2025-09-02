--- @class Energy : Component
--- @field maxEnergy number
--- @field energy number
--- @field regen number

local Energy = prism.Component:extend("Energy")

function Energy:__new(maxEnergy, regen)
   self.maxEnergy = maxEnergy
   self.energy = maxEnergy
   self.regen = regen
end

function Energy:regen()
   self.energy = self.energy + self.regen
end

--- @param amount number
function Energy:drain(amount)
   self.energy = self.energy - amount
end

return Energy
