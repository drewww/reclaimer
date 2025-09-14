local function registerWallVariation(name, sprite)
   return function()
      return prism.Cell.fromComponents {
         prism.components.Name(name),
         prism.components.Drawable { index = sprite },
         prism.components.Collider(),
         prism.components.Opaque(),
      }
   end
end


-- prism.registerCell("WiggleUL", registerWallVariation("WiggleUL", STAIRS + 1))
-- prism.registerCell("WiggleTop", registerWallVariation("WiggleTop", STAIRS + 2))
-- prism.registerCell("WiggleUR", registerWallVariation("WiggleUR", STAIRS + 3))
-- prism.registerCell("WiggleLeft", registerWallVariation("WiggleLeft", STAIRS + 4))
-- prism.registerCell("WiggleRight", registerWallVariation("WiggleRight", STAIRS + 5))
-- prism.registerCell("WiggleBL", registerWallVariation("WiggleBL", STAIRS + 6))
-- prism.registerCell("WiggleBottom", registerWallVariation("WiggleBottom", STAIRS + 7))
-- prism.registerCell("WiggleBR", registerWallVariation("WiggleBR", STAIRS + 8))


prism.registerCell("CircleWall", registerWallVariation("CircleWall", WALL_BASE + 5))
prism.registerCell("RockWall", registerWallVariation("RockWall", WALL_BASE + 6))
prism.registerCell("SquarePillar", registerWallVariation("SquarePillar", WALL_BASE + 7))
prism.registerCell("RectangularPillar", registerWallVariation("RectangularPillar", WALL_BASE + 8))
prism.registerCell("DoublePillar", registerWallVariation("DoublePillar", WALL_BASE + 9))
prism.registerCell("TriplePillar", registerWallVariation("TriplePillar", WALL_BASE + 10))
prism.registerCell("PinchedWallVertical", registerWallVariation("PinchedWallVertical", WALL_BASE + 11))
prism.registerCell("PinchedWallHorizontal", registerWallVariation("PinchedWallHorizontal", WALL_BASE + 12))
prism.registerCell("Fence", registerWallVariation("Fence", WALL_BASE + 13))
   