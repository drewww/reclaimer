prism.registerCell("Pit", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Pit"),
      prism.components.Drawable { index = 1 },
      prism.components.Collider({ allowedMovetypes = { "fly" } }),
   }
end)
