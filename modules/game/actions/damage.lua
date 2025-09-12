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

   -- use absolute positions because the owner may be dead by the time this finishes
   local x, y = self.owner:getPosition():decompose()
   prism.logger.info("triggering damage anim at ", x, y)
   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Damage(damage),
      -- actor = self.owner,
      x = x,
      y = y - 1,
      blocking = false,
      skippable = true,
   })

   if health.hp <= 0 then
      level:perform(prism.actions.Die(self.owner))
   end
end

return Damage
