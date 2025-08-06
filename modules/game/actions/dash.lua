--- @class Dash : Action
local Dash = prism.Action:extend("Dash")

function Dash:perform(level)
    if self.owner:has(prism.components.Dashing) then
        self.owner:remove(prism.components.Dashing)
    else
        self.owner:give(prism.components.Dashing())
    end
end

return Dash
