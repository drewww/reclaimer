local BotController = prism.components.Controller:extend("BotController")
BotController.name = "BotController"

local WeaponUtil = require "util.weapons"
local sf = string.format


--- @param level Level
--- @param actor Actor
function BotController:act(level, actor)
   local senses = actor:get(prism.components.Senses)
   if not senses then return prism.actions.Wait(actor) end

   local mover = actor:get(prism.components.Mover)
   if not mover then return prism.actions.Wait(actor) end

   local alert = actor:get(prism.components.Alert)
   if not alert then return prism.actions.Wait(actor) end

   local inventory = actor:get(prism.components.Inventory)
   local weapon, weaponComponent = WeaponUtil.getActive(inventory)
   assert(weaponComponent)
   assert(inventory)

   prism.logger.info(sf("ammo: %d ammopershot: %d", weaponComponent.ammo, weaponComponent.ammopershot))
   local weaponLoaded = weaponComponent.ammopershot == 0 or
       (weaponComponent.ammo >= weaponComponent.ammopershot)

   local hasAmmo = false
   local ammoStack = inventory:getStack(AMMO_TYPES[weaponComponent.ammoType])
   if ammoStack then
      local ammoStackC = ammoStack:get(prism.components.Item)
      if ammoStackC then
         hasAmmo = ammoStackC.stackCount > weaponComponent.ammopershot
      end
   end

   prism.logger.info(sf("hasAmmo: %s weaponLoaded: %s infiniteAmmo: %s", hasAmmo, weaponLoaded,
      weaponComponent.ammopershot == 0))
   -- if you're out of ammo, the weapon is not loaded, and your weapon doesn't have infinite ammo THEN
   -- switch to melee
   if not weaponLoaded and weaponComponent.ammopershot > 0 and not hasAmmo then
      -- switch to melee
      prism.logger.info("Weapon unloaded, and no ammo to reload. Switch to melee.")
      WeaponUtil.setActive(inventory, 1)
   end

   if actor:has(prism.components.Targeting) then
      prism.logger.info("FIRE! - Actor has targeting component")
      -- return shoot


      -- decrement targeted for all the cells we're targeting
      local targeting = actor:get(prism.components.Targeting)
      assert(targeting)

      for i, p in ipairs(targeting.cells) do
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
      return prism.actions.Shoot(actor, targeting.target)
   end


   local player = senses:query(level, prism.components.PlayerController):first()

   ---@type Vector2
   local destination

   if player then
      prism.logger.info(" considering targeting ")
      local inRange = actor:getPosition():distance(player:getPosition()) <= weaponComponent.range

      -- if you're out of ammo and the weapon is not loaded but you DO have ammo in your inventory AND you can see the player, then reload.
      -- then reload!
      if hasAmmo and not weaponLoaded and weaponComponent.ammopershot > 0 then
         prism.logger.info("reloading")
         return prism.actions.Reload(actor)
      end

      if weaponComponent.template == "melee" then
         local distance = actor:getPosition():distanceChebyshev(player:getPosition())
         inRange = distance <= weaponComponent.range
         prism.logger.info("checking melee range: ", inRange, distance, weaponLoaded)
      end

      if not actor:has(prism.components.Targeting) and weaponLoaded and inRange then
         prism.logger.info("BEGINING TARGETING")
         -- set the target. draw a line from actor:getPosition

         local targetDirection = player:getPosition() - actor:getPosition()

         local target = targetDirection:normalize() * weaponComponent.range + actor:getPosition()

         if weaponComponent.template == "aoe" then
            target = player:getPosition()
         end

         target.x = math.floor(target.x)
         target.y = math.floor(target.y)

         local targeting = prism.components.Targeting(target)

         prism.logger.info("FOUND TARGET: ", target)

         -- enter targeted mode
         actor:give(targeting)

         -- if we're in range then target
         local targetPositions = WeaponUtil.getTargetPoints(level, actor, target)

         for i, p in ipairs(targetPositions) do
            -- set targeting on these cells
            local cell = level:getCell(p.x, p.y)
            local targetedComponent = cell:get(prism.components.Targeted())

            table.insert(targeting.cells, p)

            if targetedComponent then
               targetedComponent.times = targetedComponent.times + 1
            else
               cell:give(prism.components.Targeted(1))
            end
         end

         return prism.actions.Wait(actor)
      end

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

   -- local attack = prism.actions.Attack(actor, player)
   -- if level:canPerform(attack) then level:perform(attack) end

   return prism.actions.Wait(actor)
end

return BotController
