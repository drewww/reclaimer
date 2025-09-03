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
prism.registerCell("FloorHintBarrel", floorHint("chest", prism.Color4.BLUE))
