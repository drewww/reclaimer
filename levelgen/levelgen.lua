local BLOCK_WIDTH = 7
local BLOCK_HEIGHT = 7

-- Weighted block selection data structure
-- Keys are block filenames, values are weights

local basicWeights = {
   ["7_base"] = 1,
   ["7_big_pillar"] = 2,
   ["7_open_wall"] = 2,
   ["7_pillars_h"] = 3,
   ["7_pillars_v"] = 3,
   ["7_pillars_wide"] = 2,
   ["7_rotary"] = 4,
   ["7_station"] = 2,
   ["7_wide"] = 4,
   ["7_cross"] = 2,
   ["7_half_cross"] = 2,
   ["7_narrow_hallway"] = 1,
   ["7_mini_pillars"] = 3
}

-- Middle weights for additional 7_ block files
local barrelWeights = {
   ["7_alt_stacks"] = 3,
   ["7_barrel_edge"] = 2,
   ["7_boom_hole"] = 1,
   ["7_boom_hole_double"] = 1,
   ["7_boom_room"] = 2,
   ["7_cup_l"] = 3,
   ["7_h"] = 3,
   ["7_lanes_v"] = 3,
   ["7_stacks"] = 3,
   ["7_stacks_gap"] = 2,
   ["7_stacks_v"] = 3,
   ["7_weird"] = 1
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

   local depthInfo = DEPTHS[10 + depth]

   local weights = basicWeights
   if depthInfo.weights == "basic" then
      weights = basicWeights
   elseif depthInfo.weights == "barrels" then
      weights = barrelWeights
   end


   local levelBlocks = {}
   for i = 1, blockWidth do
      levelBlocks[i] = {}
      for j = 1, blockHeight do
         -- Use weighted random selection for block placement
         levelBlocks[i][j] = selectWeightedRandom(rng, weights)
         prism.logger.info("room " .. tostring(i) .. "," .. tostring(j) .. " = " .. levelBlocks[i][j])
      end
   end

   -- Generate 5 distinct positions for special blocks
   local specialPositions = {}
   local occupiedPositions = {}

   -- Generate 5 unique positions
   for i = 1, 5 do
      local x, y
      repeat
         x = rng:random(1, blockWidth)
         y = rng:random(1, blockHeight)
      until not occupiedPositions[x .. "," .. y]

      occupiedPositions[x .. "," .. y] = true
      specialPositions[i] = { x = x, y = y }
   end

   -- Allocate positions: 1=entry, 2=exit, 3-5=chests
   local startX, startY = specialPositions[1].x, specialPositions[1].y
   local exitX, exitY = specialPositions[2].x, specialPositions[2].y

   -- Place entry block
   if depth == START_DEPTH then
      levelBlocks[startX][startY] = "X7_start"
   else
      levelBlocks[startX][startY] = "X7_entry"
   end

   -- Place exit block
   levelBlocks[exitX][exitY] = "X7_exit"

   -- Place exactly 3 chest blocks
   local chestBlocks = { "7_chest_closed", "7_chest_open", "7_chest_wall" }
   for i = 1, 3 do
      local chestPos = specialPositions[i + 2] -- positions 3, 4, 5
      levelBlocks[chestPos.x][chestPos.y] = chestBlocks[i]
      prism.logger.info("Placed chest block " .. chestBlocks[i] .. " at " .. chestPos.x .. "," .. chestPos.y)
   end

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
            if rng:random() < depthInfo.enemyOdds then
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
