--- @class WeaponOptions
--- @field damage integer
--- @field push integer
--- @field range integer
--- @field ammo integer
--- @field maxAmmo integer
--- @field ammopershot integer
--- @field aoe number
--- @field template string
--- @field hotkey string|integer
--- @field active boolean
--- @field ammoType string
local WeaponOptions = {}
WeaponOptions.__index = WeaponOptions

function WeaponOptions:new(options)
   local opts = options or {}
   local self = setmetatable({}, WeaponOptions)

   -- Set defaults
   self.damage = opts.damage or 1
   self.push = opts.push or 0
   self.range = opts.range or 1
   self.ammo = opts.ammo or 1
   self.maxAmmo = opts.maxAmmo or 1
   self.ammopershot = opts.ammopershot or 1
   self.aoe = opts.aoe or 0
   self.template = opts.template or "point"
   self.hotkey = opts.hotkey or 1
   self.active = opts.active or false
   self.ammoType = opts.ammoType or "Pistol"
   return self
end

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
--- @field ammoType string
local Weapon = prism.Component:extend("Weapon")

-- TODO add ammo type
function Weapon:__new(options)
   local opts

   if getmetatable(options) == WeaponOptions then
      opts = options
   else
      -- Treat as options table
      opts = WeaponOptions:new(options)
   end

   self.damage = opts.damage
   self.push = opts.push
   self.range = opts.range
   self.template = opts.template
   self.hotkey = opts.hotkey
   self.ammopershot = opts.ammopershot
   self.ammo = opts.ammo
   self.maxAmmo = opts.maxAmmo
   self.active = opts.active
   self.aoe = opts.aoe
   self.ammoType = opts.ammoType
end

-- Export both classes
Weapon.Options = WeaponOptions

return Weapon
