--- @class Targeting : Component
local Targeting = prism.Component:extend("Targeting")

--- @param target Vector2
function Targeting:__new(target)
   self.target = target
end

return Targeting
