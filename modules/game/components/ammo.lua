--- @class Ammo : Component
local Ammo = prism.Component:extend("Ammo")

--- @param type string
function Ammo:__new(type)
   self.type = type
end

return Ammo
