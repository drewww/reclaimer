local BLOCK_WIDTH = 10
local BLOCK_HEIGHT = 10

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
return function(rng, player, width, height)
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
         local rand = rng:random()

         if rand < 0.7 then
            levelBlocks[i][j] = "room"
            -- elseif rand < 0.8 then
            --    levelBlocks[i][j] = "hallway"
         else
            -- levelBlocks[i][j] = "pit"
            levelBlocks[i][j] = "chest"
         end
      end
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
   builder:rectangle("line", 1, 1, width, height, prism.cells.Wall)

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
            builder:addActor(prism.actors.Bot(), x, y)
         elseif hint.type == "chest" then
            builder:addActor(prism.actors.Chest(), x, y)
         elseif hint.type == "barrel" then
            builder:addActor(prism.actors.Barrel(), x, y)
         end
      end
   end

   local playerPos = prism.Vector2(4, 4)
   builder:addActor(player, playerPos.x, playerPos.y)

   builder:pad(1, prism.cells.Wall)

   -- builder:addActor(prism.actors.Stairs(), randCorner.x, randCorner.y)

   return builder
end
