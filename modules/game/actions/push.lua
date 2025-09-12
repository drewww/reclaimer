-- local PushTarget = prism.Target(prism.components.Position)
local PushAmount = prism.Target():isType("number")
local PushFrom = prism.Target():isPrototype(prism.Vector2)

local knockback = require "util.knockback"

---@class Push : Action
---@overload fun(owner: Actor, amount: number, from: Vector2): Push
local Push = prism.Action:extend("Push")

Push.requiredComponents = {
   prism.components.Position
}

Push.targets = {
   PushAmount,
   PushFrom
}

function Push:perform(level, amount, from)
   local target = self.owner
   prism.logger.info("target: ", target)
   prism.logger.info("amount: ", amount)
   prism.logger.info("from: ", from)


   local direction = (target:getPosition() - from)

   prism.logger.info("direction: ", direction)



   local mask = prism.Collision.createBitmaskFromMovetypes { "walk" }

   local finalPos, hitWall, cellsMoved, path = knockback(level, target:getPosition(), direction, amount, mask)

   if hitWall and target:has(prism.components.Health) then
      local damage = prism.actions.Damage(target, WALL_COLLIDE_DAMAGE)
      level:perform(damage)
   end


   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Push(self.owner, path),
      blocking = true,
      skipptable = true
   })

   -- animate in here
   level:moveActor(target, finalPos)
end

return Push
