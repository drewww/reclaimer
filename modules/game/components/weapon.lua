--- @class Weapon : Component
--- @field damage integer
--- @field push integer
--- @field range integer
--- @field template string
--- @field active boolean
local Weapon = prism.Component:extend("Weapon")

-- TODO add ammo type
function Weapon:__new(damage, push, range, ammopershot, template, hotkey)
   self.damage = damage
   self.push = push
   self.range = range
   self.template = template
   self.hotkey = hotkey
   self.ammopershot = ammopershot
   self.active = false
end

return Weapon
