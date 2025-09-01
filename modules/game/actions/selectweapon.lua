local WeaponHotkey = prism.Target():isType("number")
local WeaponUtil = require "util/weapons"

--- @class SelectWeapon : Action
--- @overload fun(owner: Actor, stairs: Actor): SelectWeapon
local SelectWeapon = prism.Action:extend("SelectWeapon")
SelectWeapon.targets = { WeaponHotkey }

function SelectWeapon:canPerform(level, hotkey)
   local weapon = WeaponUtil.getWeaponForHotkey(self.owner:get(prism.components.Inventory), hotkey)

   -- don't let the action continue if it's a no-op because the weapon is already
   -- selected.
   if weapon and weapon:get(prism.components.Weapon).active then
      return false
   end

   return weapon
end

function SelectWeapon:perform(level, hotkey)
   prism.logger.info("Switching to weapon: " .. tostring(hotkey))
   local didSet = WeaponUtil.setActive(self.owner:get(prism.components.Inventory), hotkey)
   prism.logger.info("didset: " .. tostring(didSet))

   local activeWeapon = WeaponUtil.getActive(self.owner:get(prism.components.Inventory))
   if activeWeapon then
      prism.logger.info("activeWeapon: " .. tostring(activeWeapon:getName()))
   else
      prism.logger.info("activeWeapon: nil")
   end
end

return SelectWeapon
