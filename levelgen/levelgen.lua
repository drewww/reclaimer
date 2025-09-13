local BLOCK_WIDTH = 5
local BLOCK_HEIGHT = 5

-- Weighted block selection data structure
-- Keys are block filenames, values are weights
local blockWeights = {
   ["5_base"] = 3,
   ["5_checkpoint"] = 1,
   ["5_chest_open"] = 2,
   ["5_chest_room"] = 4,
   ["5_chest_tight"] = 2,
   ["5_depot"] = 1,
   ["5_maze"] = 2,
   ["5_offset"] = 3,
   ["5_open_1"] = 5,
   ["5_open_2"] = 5,
   ["5_open_3"] = 5,
   ["5_open_4"] = 5,
   ["5_open_5"] = 5,
   ["5_open_6"] = 5,
   ["5_plus_hall"] = 3,
   ["5_stacks"] = 2,
   ["5_stacks_deep"] = 1
}

-- Method to select a weighted random block
-- @param rng RNG object
-- @param weights table with keys as items and values as weights
-- @return string selected key
local function selectWeightedRandom(rng, weights)
   -- Calculate total weight
   local totalWeight = 0
   for _, weight in pairs(weights) do
      totalWeight = totalWeight + weight
   end

   -- Generate random number from 0 to 1
   local rand = rng:random()
   local scaledRand = rand * totalWeight

   -- Find the selected item based on cumulative weights
   local cumulative = 0
   for key, weight in pairs(weights) do
      cumulative = cumulative + weight
      if scaledRand <= cumulative then
         return key
      end
   end

   -- Fallback (shouldn't reach here)
   local keys = {}
   for key in pairs(weights) do
      table.insert(keys, key)
   end
   return keys[1]
end

-- Okay, the approach here. We're going to have "blocks" of some size. The map is
-- composed of those blocks randomly composed. There may be rules to what blocks can go
-- next to what blocks. There may be rotations. But what is our implementation order?
--
-- First, make the "block" data structure. Let's build a 50x50 tile world, which
-- is 5x5 blocks. Then in the block data structure we will randomize which block to
-- place. Then we'll have a method for copying blocks out.
--
-- Eventually we can load blocks from prefabs. But for now we will have code that
-- pre-populates two different block types.
--
-- To start, block interconnect will just be that all blocks have walls and then knock out the middles of each wall.


--- @param type type
--- @param rot integer
--- @return LevelBuilder
local function getBlockBuilder(type, rot)
   local builder = prism.LevelBuilder(prism.cells.Floor)
   local x, y = 0, 0
   -- for now support one kind of block.
   prism.logger.info("building block: ", type, x, y)
   if type == "room" then
      builder:rectangle("fill", x, y, x + BLOCK_WIDTH - 1, y + BLOCK_HEIGHT - 1, prism.cells.Floor)
      builder:rectangle("line", x, y, x + BLOCK_WIDTH - 1, y + BLOCK_HEIGHT - 1, prism.cells.Wall)

      -- now knock out doors with two more floor fills.
      builder:rectangle("fill", x, y + BLOCK_HEIGHT / 2 - 1, x + BLOCK_WIDTH - 1, y + BLOCK_HEIGHT / 2 + 1, prism.cells
         .Floor)
      builder:rectangle("fill", x + BLOCK_WIDTH / 2 - 1, y, x + BLOCK_WIDTH / 2 + 1, y + BLOCK_HEIGHT - 1,
         prism.cells.Floor)
   elseif type == "hallway" then
      builder:rectangle("fill", x, y, x + BLOCK_WIDTH - 1, y + BLOCK_HEIGHT - 1, prism.cells.Wall)

      builder:rectangle("fill", x, y + BLOCK_HEIGHT / 2 - 1, x + BLOCK_WIDTH - 1, y + BLOCK_HEIGHT / 2 + 1, prism.cells
         .Floor)
      builder:rectangle("fill", x + BLOCK_WIDTH / 2 - 1, y, x + BLOCK_WIDTH / 2 + 1, y + BLOCK_HEIGHT - 1,
         prism.cells.Floor)
   else
      -- fucking send it
      prism.logger.info("loading " .. type .. ".lz4 ad hoc")
      builder = prism.LevelBuilder.fromLz4("levelgen/blocks/" .. type .. ".lz4", prism.defaultCell)
   end

   return builder
end

--- @param rng RNG
--- @param player Actor
--- @param width integer
--- @param height integer
return function(depth, rng, player, width, height)
   -- loadBlocks()

   local builder = prism.LevelBuilder(prism.cells.Pit)

   local blockWidth = width / BLOCK_WIDTH
   local blockHeight = height / BLOCK_HEIGHT

   if blockWidth ~= math.floor(blockWidth) or
       blockHeight ~= math.floor(blockHeight) then
      prism.logger.error("Map size to build " ..
         tostring(prism.Vector2(width, height)) .. "is not an integer multiple of BLOCK_WIDTH/BLOCK_HEIGHT")
      return nil
   end

   prism.logger.info("blocks: " ..
      tostring(blockWidth) ..
      "x" ..
      tostring(blockHeight) .. " @" .. tostring(BLOCK_WIDTH) .. "x" .. tostring(BLOCK_HEIGHT) .. " tiles per block.")
   -- initialize the blocks. this will eventually have logic, but for now just
   -- places the default "room" type
   local levelBlocks = {}
   for i = 1, blockWidth do
      levelBlocks[i] = {}
      for j = 1, blockHeight do
         -- Use weighted random selection for block placement
         levelBlocks[i][j] = selectWeightedRandom(rng, blockWeights)
         prism.logger.info("room " .. tostring(i) .. "," .. tostring(j) .. " = " .. levelBlocks[i][j])
      end
   end

   -- now, pick a random i/j and make it the start location. can't be on the left edge.
   -- local startX, startY = rng:random(2, blockWidth), rng:random(1, blockHeight)
   local startX, startY = rng:random(2, blockWidth), rng:random(1, blockHeight)
   local exitX, exitY
   repeat
      exitX, exitY = rng:random(1, blockWidth), rng:random(1, blockHeight)
   until not (startX == exitX and startY == exitY)

   -- prism.logger.info("start ", startX, startY, " exit", exitX, exitY)

   -- plus one because we increment on creation
   if depth == START_DEPTH then
      levelBlocks[startX][startY] = "SP5_start_right"
   else
      levelBlocks[startX][startY] = "SP5_stair_exit"
   end

   levelBlocks[exitX][exitY] = "SP5_stair"
   levelBlocks[startX - 1][startY] = "5_base"

   -- now, iterate through the block list and drop them in. (this could be collapsed,
   -- but I expect that we will want multiple passes to do various consistency checks.
   for i = 1, blockWidth do
      for j = 1, blockHeight do
         local x, y = (i - 1) * (BLOCK_WIDTH) + 1, (j - 1) * (BLOCK_HEIGHT) + 1
         prism.logger.info("generating block ", i, j, levelBlocks[i][j], " at ", x, y)
         local blockBuilder = getBlockBuilder(levelBlocks[i][j], 0)

         builder:blit(blockBuilder,
            x,
            y)
      end
   end

   -- wrap the world in a border
   -- builder:rectangle("line", 1, 1, width, height, prism.cells.Wall)

   -- now iterate through all the cells and respond to hints.
   for x, y, cell in builder:eachCell() do
      if cell:has(prism.components.Hint) then
         local hint = cell:get(prism.components.Hint)
         local drawable = cell:get(prism.components.Drawable)

         cell:remove(prism.components.Hint)

         -- TODO need to be smarter about this
         drawable.color = prism.Color4.WHITE

         prism.logger.info("adding actor of type " .. hint.type .. " at ", x, y)
         if hint.type == "enemy" then
            if rng:random() < 0.3 then
               builder:addActor(prism.actors.Bot(), x, y)
            end
         elseif hint.type == "chest" then
            builder:addActor(prism.actors.Chest(), x, y)
         elseif hint.type == "barrel" then
            builder:addActor(prism.actors.Barrel(), x, y)
         elseif hint.type == "player" then
            builder:addActor(player, x, y)
         end
      end
   end

   builder:pad(1, prism.cells.Wall)

   -- builder:addActor(prism.actors.Stairs(), randCorner.x, randCorner.y)

   return builder
end
