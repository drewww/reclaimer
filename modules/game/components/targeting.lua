--- @class Targeting : Component
--- @field cells Vector2[]
local Targeting = prism.Component:extend("Targeting")

--- @param target Vector2
function Targeting:__new(target)
   self.target = target
   self.cells = {}
end

return Targeting
