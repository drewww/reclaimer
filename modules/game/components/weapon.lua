--- @class Weapon : Component
--- @field damage integer
--- @field push integer
--- @field range integer
--- @field template string
--- @field active boolean
--- @field hotkey string
--- @field ammopershot integer
--- @field ammo integer
--- @field maxAmmo integer
--- @field aoe number
local Weapon = prism.Component:extend("Weapon")

-- TODO add ammo type
function Weapon:__new(damage, push, range, ammo, maxAmmo, ammopershot, aoe, template, hotkey, active)
   self.damage = damage
   self.push = push
   self.range = range
   self.template = template
   self.hotkey = hotkey
   self.ammopershot = ammopershot
   self.ammo = ammo
   self.maxAmmo = maxAmmo
   self.active = active or false
   self.aoe = aoe
end

return Weapon
