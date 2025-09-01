prism.registerCell("Floor", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Floor"),
      prism.components.Drawable { index = 10 * 16 + 1 },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
