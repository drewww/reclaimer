local Bresenham = require "prism.engine.math.bresenham"

---@param level Level The game level
---@param startPos Vector2 Starting position
---@param direction Vector2 direction vector (un-normalized ok)
---@param maxCells integer Maximum number of cells to push
---@param moveMask integer Movement mask for collision checking
---@return Vector2 finalPos Final position after knockback
---@return boolean hitWall Whether movement was stopped by a wall
---@return integer cellsMoved Number of cells actually moved
---@return Vector2[] path Array of positions along the path
return function(level, startPos, direction, maxCells, moveMask)
   local dirLength = direction:length()
   if dirLength == 0 then
      -- Zero-length direction, no movement
      return startPos:copy(), false, 0, { startPos:copy() }
   end

   local normalizedDirection = direction / dirLength

   -- For diagonal movement, we need to extend further to ensure we get maxCells steps
   -- Use Manhattan distance scaling to ensure sufficient line length
   local scaleFactor = math.max(math.abs(normalizedDirection.x), math.abs(normalizedDirection.y))
   local extendedDistance = maxCells / scaleFactor

   -- Calculate end position using extended distance
   local endPos = startPos + (normalizedDirection * extendedDistance)
   endPos.x = endPos.x >= 0 and math.floor(endPos.x + 0.5) or math.ceil(endPos.x - 0.5)
   endPos.y = endPos.y >= 0 and math.floor(endPos.y + 0.5) or math.ceil(endPos.y - 0.5)

   -- Get line points using the existing Bresenham library
   local x0, y0 = math.floor(startPos.x), math.floor(startPos.y)
   local x1, y1 = math.floor(endPos.x), math.floor(endPos.y)

   -- Create a passability callback
   local hitWall = false

   local passabilityCallback = function(x, y)
      -- Skip the starting position
      if x == x0 and y == y0 then return true end

      -- Check if this position is passable
      if level:inBounds(x, y) and level:getCellPassable(x, y, moveMask) then
         hitWall = true
         return false -- Stop the line algorithm here
      end
      return true
   end

   -- Get the line path
   local rawPath, lineComplete = Bresenham(x0, y0, x1, y1, passabilityCallback)

   -- Convert to Vector2 objects
   local path = {}
   for i, point in ipairs(rawPath) do
      path[i] = prism.Vector2(point[1], point[2])
   end

   -- Determine final position limited by maxCells
   -- path[1] is the starting position, so actual moves start at path[2]
   local cellsMoved = math.min(maxCells, math.max(0, #path - 1))
   local finalPosIndex = cellsMoved + 1 -- +1 because path includes start position
   local finalPos = (#path >= finalPosIndex) and path[finalPosIndex] or startPos

   -- We hit a wall if the line didn't complete OR we couldn't move the full distance due to obstacles
   hitWall = not lineComplete

   return finalPos, hitWall, cellsMoved, path
end
