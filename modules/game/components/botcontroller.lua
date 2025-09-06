local BotController = prism.components.Controller:extend("BotController")
BotController.name = "BotController"

function BotController:act(level, actor)
   local senses = actor:get(prism.components.Senses)
   if not senses then return prism.actions.Wait(actor) end

   local mover = actor:get(prism.components.Mover)
   if not mover then return prism.actions.Wait(actor) end

   local alert = actor:get(prism.components.Alert)
   if not alert then return prism.actions.Wait(actor) end

   local player = senses:query(level, prism.components.PlayerController):first()

   ---@type Vector2
   local destination

   if player then
      destination = player:getPosition()
      alert.lastseen = player:getPosition()
   elseif alert.lastseen then
      destination = alert.lastseen
   else
      return prism.actions.Wait(actor)
   end

   local path = level:findPath(actor:getPosition(), destination, actor, mover.mask, 1)

   if path then
      local move = prism.actions.Move(actor, path:pop())
      if level:canPerform(move) then return move end
   end

   local attack = prism.actions.Attack(actor, player)
   if level:canPerform(attack) then level:perform(attack) end

   return prism.actions.Wait(actor)
end

return BotController
