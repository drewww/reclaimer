--- @class Alert : Component
local Alert = prism.Component:extend("Alert")

--- @param lastseen Vector2
function Alert:__new(lastseen)
   self.lastseen = lastseen
end

return Alert
