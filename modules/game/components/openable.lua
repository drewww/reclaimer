--- @class Openable : Component
local Openable = prism.Component:extend("Openable")

function Openable:__new(delay)
   self.delay = delay
   self.open = false
end

return Openable
