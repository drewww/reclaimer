-- local PushTarget = prism.Target(prism.components.Position)
local PushAmount        = prism.Target():isType("number")
local PushFrom          = prism.Target():isPrototype(prism.Vector2)

local knockback         = require "util.knockback"
local Audio             = require "audio"

---@class Push : Action
---@overload fun(owner: Actor, amount: number, from: Vector2): Push
local Push              = prism.Action:extend("Push")

Push.requiredComponents = {
   prism.components.Position
}

Push.targets            = {
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




   level:yield(prism.messages.Animation {
      animation = spectrum.animations.Push(self.owner, path),
      actor = target,
      blocking = true,
      skipptable = true
   })

   -- animate in here
   level:moveActor(target, finalPos)

   if hitWall and target:has(prism.components.Health) then
      local damageAmount = target:has(prism.components.PlayerController) and PLAYER_WALL_COLLIDE_DAMAGE or
          WALL_COLLIDE_DAMAGE

      local damage = prism.actions.Damage(target, damageAmount)
      level:perform(damage)

      Audio.playSfx("hitWall")
   end
end

return Push
