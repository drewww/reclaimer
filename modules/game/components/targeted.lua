--- @class Targeted : Component
local Targeted = prism.Component:extend("Targeted")

--- @param times integer
function Targeted:__new(times)
   self.times = times or 0
end

return Targeted
