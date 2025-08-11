--- @class Tickable : Component
local Tickable = prism.Component:extend("Tickable")

--- @param type string
--- @param duration integer
function Tickable:__new(type, duration)
   self.type = type
   self.duration = duration
end

return Tickable
