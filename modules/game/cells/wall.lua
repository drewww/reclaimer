prism.registerCell("Wall", function()
   return prism.Cell.fromComponents {
      prism.components.Name("Wall"),
      prism.components.Drawable { index = 10 * 16 + 2 },
      prism.components.Collider(),
      prism.components.Opaque(),
   }
end)
