--- @param rng RNG
--- @param player Actor
--- @param width integer
--- @param height integer
return function(rng, player, width, height)
   local builder = prism.LevelBuilder(prism.cells.Wall)

   -- go back to basics. fill all of width/height with floor.
   builder:rectangle("fill", 1, 1, width - 1, height - 1, prism.cells.Floor)


   local playerPos = prism.Vector2(3, 3)
   builder:addActor(player, playerPos.x, playerPos.y)

   builder:pad(1, prism.cells.Wall)

   -- builder:addActor(prism.actors.Stairs(), randCorner.x, randCorner.y)

   return builder
end
