prism.registerCell("Floor", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Floor"),
      prism.components.Drawable { char = "." },
      prism.components.Collider({ allowedMovetypes = { "walk", "fly" } }),
   }
end)
