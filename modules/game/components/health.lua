--- @class Health : Component
--- @field maxHP integer
--- @field hp integer

local Health = prism.Component:extend("Health")

-- TODO figure out how to make components take argument lists
function Health:__new(maxHP)
    self.maxHP = maxHP
    self.hp = maxHP
end

return Health
