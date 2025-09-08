local function floorHint(type, color)
   return function()
      return prism.Cell.fromComponents {
         prism.components.Name("Floor"),
         prism.components.Drawable { index = 10 * 16 + 1, color = color },
         prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
         prism.components.Hint(type)
      }
   end
end

prism.registerCell("FloorHintEnemy", floorHint("enemy", prism.Color4.RED))
prism.registerCell("FloorHintChest", floorHint("chest", prism.Color4.YELLOW))
prism.registerCell("FloorHintBarrel", floorHint("barrel", prism.Color4.BLUE))
prism.registerCell("FloorHintStairs", floorHint("stairs", prism.Color4.BROWN))
prism.registerCell("FloorHintPlayer", floorHint("player", prism.Color4.LIME))
