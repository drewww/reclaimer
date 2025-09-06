-- what is this? not sure yet
local DamageTarget = prism.Target():isType("number")

--- @class Damage : Action
--- @overload fun(owner: Actor, damage: number): Damage

local Damage = prism.Action:extend("Damage")
Damage.name = "Damage"
Damage.targets = { DamageTarget }
Damage.requiredComponents = { prism.components.Health }

function Damage:perform(level, damage)
   local health = self.owner:expect(prism.components.Health)
   health.hp = health.hp - damage
   self.dealt = damage

   -- if health.hp > 0 then
   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Damage(damage),
      actor = self.owner,
      y = -1
   })
   -- end

   if health.hp <= 0 then level:perform(prism.actions.Die(self.owner)) end
end

return Damage
