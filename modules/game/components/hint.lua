--- @class Hint : Component
local Hint = prism.Component:extend("Hint")

--- @param type string
function Hint:__new(type)
   self.type = type
end

return Hint
