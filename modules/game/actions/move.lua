local MoveTarget = prism.Target():isPrototype(prism.Vector2):range(1)
local Game = require "game"

---@class Move : Action
---@field name string
---@field targets Target[]
---@field previousPosition Vector2
local Move = prism.Action:extend("Move")
Move.name = "move"
Move.targets = { MoveTarget }

Move.requiredComponents = {
   prism.components.Controller,
   prism.components.Mover,
}

--- @param level Level
--- @param destination Vector2
function Move:canPerform(level, destination)
   local mover = self.owner:expect(prism.components.Mover)
   local isPassable = level:getCellPassableByActor(destination.x, destination.y, self.owner, mover.mask)

   local hasEnergyIfNeeded = true
   if self.owner:has(prism.components.Dashing) then
      local energy = self.owner:get(prism.components.Energy)

      if energy then
         hasEnergyIfNeeded = energy.energy >= 1
      else
         hasEnergyIfNeeded = false
      end
   end

   return isPassable and hasEnergyIfNeeded
end

--- @param level Level
--- @param destination Vector2
function Move:perform(level, destination)
   level:moveActor(self.owner, destination)

   -- add Dashing to any cell we're passing through.
   if self.owner:has(prism.components.Dashing) then
      -- get the cell being enered
      local cell = level:getCell(destination:decompose())
      if cell then cell:give(prism.components.Dashing()) end

      local energy = self.owner:get(prism.components.Energy)
      if energy then
         energy.energy = energy.energy - DASH_ENERGY_COST_PER_TILE
      end
   end

   if self.owner:has(prism.components.PlayerController) then
      Game:step()
   end

   if self.owner:has(prism.components.PlayerController) then
      prism.logger.info("moving into cell, checking for loot")
      local lootAtDestination = level:query(prism.components.Item):at(destination:decompose()):first()
      prism.logger.info("lootAtDestination", lootAtDestination)
      if lootAtDestination then
         prism.logger.info("attempting pickup", lootAtDestination)
         local pickup = prism.actions.Pickup(self.owner, lootAtDestination)
         level:tryPerform(pickup)
      end
   end

   local targetCell = level:getCell(destination:decompose())
   if targetCell:has(prism.components.OnFire) then
      local damage = prism.actions.Damage(self.owner, 1)
      level:tryPerform(damage)

      local x, y = destination:decompose()
      level:setCell(x, y, prism.cells.Ashes())
   end
end

return Move
