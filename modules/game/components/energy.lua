--- @class Energy : Component
--- @field maxEnergy number
--- @field energy number
--- @field regenRate number

local Energy = prism.Component:extend("Energy")

function Energy:__new(maxEnergy, regenRate)
   self.maxEnergy = maxEnergy
   self.energy = maxEnergy
   self.regenRate = regenRate
end

function Energy:regen()
   self.energy = math.min(self.energy + self.regenRate, self.maxEnergy)
end

--- @param amount number
function Energy:drain(amount)
   self.energy = self.energy - amount
end

return Energy
