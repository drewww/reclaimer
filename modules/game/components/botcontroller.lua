local BotController = prism.components.Controller:extend("BotController")
BotController.name = "BotController"

local WeaponUtil = require "util.weapons"

function BotController:act(level, actor)
   local senses = actor:get(prism.components.Senses)
   if not senses then return prism.actions.Wait(actor) end

   local mover = actor:get(prism.components.Mover)
   if not mover then return prism.actions.Wait(actor) end

   local alert = actor:get(prism.components.Alert)
   if not alert then return prism.actions.Wait(actor) end

   local inventory = actor:get(prism.components.Inventory)
   local weapon, weaponComponent = WeaponUtil.getActive(inventory)


   if actor:has(prism.components.Targeting) then
      prism.logger.info("FIRE!")
      -- return shoot


      -- decrement targeted for all the cells we're targeting
      local targeting = actor:get(prism.components.Targeting)

      local targetPositions = WeaponUtil.getTargetPoints(level, actor, targeting.target)

      for i, p in ipairs(targetPositions) do
         -- set targeting on these cells
         local cell = level:getCell(p.x, p.y)
         local targeted = cell:get(prism.components.Targeted)

         if targeted then
            targeted.times = targeted.times - 1
            if targeted.times == 0 then
               cell:remove(targeted)
            end
         end
      end

      actor:remove(prism.components.Targeting)

      prism.logger.info("Shooting at ", targeting.target)
      return prism.actions.Shoot(targeting.target)
   end


   local player = senses:query(level, prism.components.PlayerController):first()

   ---@type Vector2
   local destination

   if player then
      if not actor:has(prism.components.Targeting) then
         local targeted = prism.components.Targeting(player:getPosition())

         -- enter targeted mode
         actor:give(targeted)

         if weaponComponent and actor:getPosition():distance(player:getPosition()) <= weaponComponent.range then
            -- if we're in range then target
            local targetPositions = WeaponUtil.getTargetPoints(level, actor, player:getPosition())

            for i, p in ipairs(targetPositions) do
               -- set targeting on these cells
               local cell = level:getCell(p.x, p.y)
               local targetedComponent = cell:get(prism.components.Targeted())

               if targetedComponent then
                  targetedComponent.times = targetedComponent.times + 1
               else
                  cell:give(prism.components.Targeted(1))
               end
            end

            return prism.actions.Wait(actor)
         end
      end
      -- if the actor sees the player, enter targeting mode
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
